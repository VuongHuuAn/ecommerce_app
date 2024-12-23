import 'dart:math';
import 'package:amazon_shop_on/common/widgets/loader.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/features/address/services/order_services.dart';
import 'package:amazon_shop_on/features/order_details/screens/order_details.dart';
import 'package:amazon_shop_on/models/order.dart';
import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  List<Order>? orders;
  final OrderServices orderServices = OrderServices();
  bool isLoading = true;
  String? error;
  void navigateToOrderDetails(Order order) {
    Navigator.pushNamed(
      context,
      OrderDetails.routeName,
      arguments: order,
    ).then((_) => fetchOrders()); // Refresh sau khi quay lại
  }

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  void fetchOrders() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      orders = await orderServices.fetchMyOrders(context);
      print('Fetched orders: ${orders?.length}');

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error in fetchOrders: $e');
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Loader();
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading orders:\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'See all',
                style: TextStyle(
                  color: GlobalVariables.selectedNavBarColor,
                ),
              ),
            ],
          ),
        ),
        if (orders == null || orders!.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: orders!.length,
              itemBuilder: (context, index) {
                final order = orders![index];
                try {
                  return GestureDetector(
                    onTap: () => navigateToOrderDetails(order),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #${order.id.substring(0, min(8, order.id.length))}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '\$${order.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: order.products.length,
                              itemBuilder: (context, productIndex) {
                                try {
                                  final orderProduct =
                                      order.products[productIndex];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        if (orderProduct
                                            .product.images.isNotEmpty)
                                          Container(
                                            height: 64,
                                            width: 64,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black12,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Image.network(
                                              orderProduct.product.images[0],
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons.error),
                                            ),
                                          ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                orderProduct.product.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Qty: ${orderProduct.quantity}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '\$${(orderProduct.product.finalPrice * orderProduct.quantity).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } catch (e) {
                                  print('Error rendering product: $e');
                                  return const SizedBox();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } catch (e) {
                  print('Error rendering order: $e');
                  return const SizedBox();
                }
              },
            ),
          ),
      ],
    );
  }
}
