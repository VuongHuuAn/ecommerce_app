import 'dart:convert';

import 'package:amazon_shop_on/constants/error_handling.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/models/product.dart';
import 'package:amazon_shop_on/models/user.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CartServices {
  Future<void> deleteFromCart({
  required BuildContext context,
  required String productId,
}) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  try {
    print('Deleting product with ID: $productId');
    
    http.Response res = await http.delete(
      Uri.parse('$uri/api/delete-from-cart/$productId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      },
    );

    print('Response status: ${res.statusCode}');
    print('Response body: ${res.body}');

    httpErrorHandle(
      response: res,
      context: context,
      onSuccess: () {
        var responseData = jsonDecode(res.body);
        User user = userProvider.user.copyWith(
          cart: List.from(responseData['user']['cart']),
        );
        userProvider.setUserFromModel(user);
        showSnackBar(context, responseData['message']);
      },
    );
  } catch (e) {
    print('Error in deleteFromCart: $e');
    showSnackBar(context, e.toString());
  }
}
}
