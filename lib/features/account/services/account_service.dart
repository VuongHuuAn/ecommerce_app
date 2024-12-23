import 'dart:convert';

import 'package:amazon_shop_on/constants/error_handling.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/constants/utils.dart';

import 'package:amazon_shop_on/features/auth/screens/auth_screen.dart';
import 'package:amazon_shop_on/models/order.dart';

import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountServices {
  Future<List<Order>> fetchOrders(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Order> orderList = [];
    try {
      final res = await http.get(
        Uri.parse('$uri/api/orders/me'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final ordersData = jsonDecode(res.body) as List;
          orderList = ordersData.map((item) => Order.fromMap(item)).toList();
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return orderList;
    }

  void logOut(BuildContext context) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString('x-auth-token', '');
      Navigator.pushNamedAndRemoveUntil(
          context, AuthScreen.routeName, (route) => false);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> requestSeller({
    required BuildContext context,
    required String shopName,
    required String shopDescription,
    required String address,
    required String avatarUrl,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/register-seller'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'shopName': shopName,
          'shopDescription': shopDescription,
          'address': address,
          'avatarUrl': avatarUrl,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Seller request submitted successfully!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<String> checkSellerStatus(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String status = 'none';
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/seller-request-status'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          status = jsonDecode(res.body)['status'];
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return status;
  }
}
