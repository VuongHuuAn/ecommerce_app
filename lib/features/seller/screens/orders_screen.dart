import 'package:amazon_shop_on/common/widgets/loader.dart';
import 'package:amazon_shop_on/features/seller/services/seller_services.dart';
import 'package:amazon_shop_on/features/order_details/screens/order_details.dart';
import 'package:amazon_shop_on/models/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order>? orders;
  final SellerServices sellerServices = SellerServices();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      setState(() => isLoading = true);
      orders = await sellerServices.fetchAllOrders(context);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching orders: $e')),
        );
      }
    }
  }

  void _changeOrderStatus(Order order, int newStatus) async {
    try {
      sellerServices.changeOrderStatus(
        context: context,
        status: newStatus,
        order: order,
        onSuccess: () {
          fetchOrders(); // Refresh orders after status change
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order status updated successfully')),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status: $e')),
      );
    }
  }

  Widget _buildStatusButton(Order order) {
    return PopupMenuButton<int>(
      initialValue: order.status,
      onSelected: (int status) => _changeOrderStatus(order, status),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        const PopupMenuItem<int>(
          value: 0,
          child: Text('Pending'),
        ),
        const PopupMenuItem<int>(
          value: 1,
          child: Text('Processing'),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: Text('Shipped'),
        ),
        const PopupMenuItem<int>(
          value: 3,
          child: Text('Delivered'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: _getStatusColor(order.status),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getStatusText(order.status),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: Loader());
    }

    if (orders == null || orders!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No orders yet',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchOrders,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchOrders,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: orders!.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final orderData = orders![index];
            // Get first CartItem and its product
            final firstCartItem = orderData.products.first;
            final firstProduct = firstCartItem.product;

            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  OrderDetails.routeName,
                  arguments: orderData,
                ).then((_) => fetchOrders());
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Image
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        child: firstProduct.images.isNotEmpty
                            ? Image.network(
                                firstProduct.images[0],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.error_outline),
                                  );
                                },
                              )
                            : const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                      ),
                    ),

                    // Order Details
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order ID
                          Text(
                            'Order #${orderData.id.substring(0, 8)}...',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Order Date
                          Text(
                            DateFormat('MMM dd, yyyy').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                orderData.orderedAt,
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Order Status
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(orderData.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(orderData.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
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

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Processing';
      case 2:
        return 'Shipped';
      case 3:
        return 'Delivered';
      default:
        return 'Unknown';
    }
  }
}
