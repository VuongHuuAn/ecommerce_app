import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';

class CartSubtotal extends StatelessWidget {
  const CartSubtotal({Key? key}) : super(key: key);

  double _getCartSubtotal(UserProvider userProvider) {
    double sum = 0;
    for (var item in userProvider.user.cart) {
      // Use finalPrice if available, otherwise use price
      final price = item.product.finalPrice ?? item.product.price;
      sum += price * item.quantity;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final subtotal = _getCartSubtotal(userProvider);

    return Container(
      margin: const EdgeInsets.all(10),
      child: Row(
        children: [
          const Text(
            'Subtotal ',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          Text(
            '\$${subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}