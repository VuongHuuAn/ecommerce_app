import 'package:amazon_shop_on/common/widgets/custom_button.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/features/search/screens/search_screen.dart';
import 'package:amazon_shop_on/features/seller/services/seller_services.dart';

import 'package:amazon_shop_on/models/order.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderDetails extends StatefulWidget {
  static const String routeName = '/order-details';
  final Order order;

  const OrderDetails({super.key, required this.order});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  int currentStep = 0;
  final SellerServices sellerServices = SellerServices();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo currentStep dựa trên trạng thái ban đầu của order
    currentStep = widget.order.status.clamp(0, 3);
  }

  void navigateToSearchScreen(String query) {
    Navigator.pushNamed(context, SearchScreen.routeName, arguments: query);
  }

  Future<void> changeOrderStatus(int status) async {
    if (status >= 3) return;

    setState(() {
      isLoading = true;
      // Cập nhật trực tiếp trạng thái hiện tại trên UI
      currentStep = (status + 1).clamp(0, 3);
    });

    try {
       sellerServices.changeOrderStatus(
        context: context,
        status: status + 1,
        order: widget.order,
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order status updated successfully')),
          );
        },
      );
    } catch (e) {
      // Rollback trạng thái nếu gặp lỗi
      setState(() {
        currentStep = status; // Khôi phục trạng thái trước đó
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshOrder() async {
    try {
      final orders = await sellerServices.fetchAllOrders(context);
      final updatedOrder = orders.firstWhere((o) => o.id == widget.order.id);
      setState(() {
        currentStep = updatedOrder.status.clamp(0, 3);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  margin: const EdgeInsets.only(left: 15),
                  child: Material(
                    borderRadius: BorderRadius.circular(7),
                    elevation: 1,
                    child: TextFormField(
                      onFieldSubmitted: navigateToSearchScreen,
                      decoration: InputDecoration(
                        prefixIcon: InkWell(
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 23,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(top: 10),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          borderSide: BorderSide(color: Colors.black38, width: 1),
                        ),
                        hintText: 'Search Amazon.in',
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.transparent,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: const Icon(Icons.mic, color: Colors.black, size: 25),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrder,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildOrderInfoSection(),
                const SizedBox(height: 20),
                _buildPurchaseDetailsSection(),
                const SizedBox(height: 20),
                _buildTrackingSection(user),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Date: ${DateFormat.yMMMd().format(
              DateTime.fromMillisecondsSinceEpoch(widget.order.orderedAt),
            )}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            'Order ID: ${widget.order.id}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            'Order Total: \$${widget.order.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseDetailsSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Purchase Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.order.products.length,
            itemBuilder: (context, index) {
              final cartItem = widget.order.products[index];
              final product = cartItem.product;
              final quantity = cartItem.quantity;
              final totalProductPrice = product.finalPrice * quantity;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.images.isNotEmpty
                            ? product.images[0]
                            : 'placeholder_image_url',
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text('Quantity: $quantity'),
                          Text(
                            'Total: \$${totalProductPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingSection(user) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Tracking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Stepper(
            currentStep: currentStep,
            controlsBuilder: (context, details) {
              if (user.type == 'seller' && currentStep < 3 && !isLoading) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Update to ${_getNextStatusText(currentStep)}',
                          onTap: () => changeOrderStatus(currentStep),
                          color: _getStatusColor(currentStep),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            steps: [
              Step(
                title: const Text('Pending'),
                content: Text(_getStepContent(0)),
                isActive: currentStep >= 0,
                state: currentStep > 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Processing'),
                content: Text(_getStepContent(1)),
                isActive: currentStep >= 1,
                state: currentStep > 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Shipped'),
                content: Text(_getStepContent(2)),
                isActive: currentStep >= 2,
                state: currentStep > 2 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Delivered'),
                content: Text(_getStepContent(3)),
                isActive: currentStep >= 3,
                state: currentStep >= 3 ? StepState.complete : StepState.indexed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getNextStatusText(int currentStatus) {
    switch (currentStatus) {
      case 0:
        return 'Processing';
      case 1:
        return 'Shipped';
      case 2:
        return 'Delivered';
      default:
        return 'Completed';
    }
  }

  String _getStepContent(int step) {
    switch (step) {
      case 0:
        return 'Order received and pending processing';
      case 1:
        return 'Order is being processed and prepared for shipping';
      case 2:
        return 'Order has been shipped and is on its way';
      case 3:
        return 'Order has been successfully delivered';
      default:
        return '';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
