import 'dart:convert';
import 'package:amazon_shop_on/constants/error_handling.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/models/order.dart';

import 'package:amazon_shop_on/models/user.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OrderServices {
  // Save user address
  Future<void> saveUserAddress({
    required BuildContext context,
    required String address,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/save-user-address'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'address': address,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          User user = userProvider.user.copyWith(address: address);
          userProvider.setUserFromModel(user);
        },
      );
    } catch (e) {
      print('Error saving address: $e');
      showSnackBar(context, e.toString());
    }
  }

  // Place order
  Future<void> placeOrder({
    required BuildContext context,
    required String address,
    required double totalSum,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      print('Starting place order...');
      print('Cart items: ${userProvider.user.cart}');

      // Format cart items for API request
      final List<Map<String, dynamic>> formattedCart =
          userProvider.user.cart.map((item) {
        return {
          'product': item['product'],
          'quantity': item['quantity'],
        };
      }).toList();

      // Create request body
      final Map<String, dynamic> orderRequest = {
        'cart': formattedCart,
        'address': address,
        'totalPrice': totalSum,
      };

      print('Order request: ${jsonEncode(orderRequest)}');

      http.Response res = await http.post(
        Uri.parse('$uri/api/order'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode(orderRequest),
      );

      print('Order response status: ${res.statusCode}');
      print('Order response body: ${res.body}');

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // Clear cart after successful order
          User updatedUser = userProvider.user.copyWith(cart: []);
          userProvider.setUserFromModel(updatedUser);

          showSnackBar(context, 'Order placed successfully!');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      print('Error placing order: $e');
      showSnackBar(context, e.toString());
    }
  }

  // Fetch user orders
Future<List<Order>> fetchMyOrders(BuildContext context) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  List<Order> orderList = [];

  try {
    http.Response res = await http.get(
      Uri.parse('$uri/api/orders/me'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      },
    );

    print('Response status: ${res.statusCode}');
    print('Response body: ${res.body}'); // Thêm log để debug

    httpErrorHandle(
      response: res,
      context: context,
      onSuccess: () {
        var decodedData = jsonDecode(res.body) as List;
        orderList = decodedData.map((item) {
          try {
            return Order.fromMap(item as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing individual order: $e');
            print('Problematic data: $item');
            return null;
          }
        }).whereType<Order>().toList();
      },
    );
  } catch (e) {
    print('Error fetching orders: $e');
    showSnackBar(context, e.toString());
  }

  return orderList;
}
}
