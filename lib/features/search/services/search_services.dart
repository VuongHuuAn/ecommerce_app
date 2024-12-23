import 'dart:convert';
import 'package:amazon_shop_on/constants/error_handling.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/models/product.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SearchServices {
  Future<List<Product>> fetchSearchedProduct({
    required BuildContext context,
    required String searchQuery,
  }) async {
    print('SearchServices - fetchSearchedProduct started');
    print('Search query: $searchQuery');

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];
    
    try {
      print('Calling API: $uri/api/products/search/$searchQuery');
      http.Response res = await http.get(
        Uri.parse('$uri/api/products/search/$searchQuery'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      print('API Response status: ${res.statusCode}');
      print('API Response body: ${res.body}');

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          List<dynamic> productsJson = jsonDecode(res.body);
          print('Parsed JSON products count: ${productsJson.length}');

          productList = productsJson.map((json) {
            try {
              if (json is Map<String, dynamic>) {
                // Parse discount data
                Map<String, dynamic>? discountData;
                if (json['discount'] != null) {
                  if (json['discount'] is num) {
                    discountData = {
                      'percentage': json['discount'],
                      'startDate': json['startDate'],
                      'endDate': json['endDate'],
                    };
                  } else if (json['discount'] is Map) {
                    discountData = json['discount'] as Map<String, dynamic>;
                  }
                }

                // Update json with parsed discount
                if (discountData != null) {
                  json['discount'] = discountData;
                }

                // Calculate finalPrice if not provided
                if (json['finalPrice'] == null && json['price'] != null) {
                  double price = (json['price'] as num).toDouble();
                  double discountPercentage = discountData?['percentage']?.toDouble() ?? 0.0;
                  json['finalPrice'] = price * (1 - discountPercentage / 100);
                }

                // Parse sellerId if it's an object (from populate)
                if (json['sellerId'] is Map) {
                  String sellerId = json['sellerId']['_id'].toString();
                  String? shopName = json['sellerId']['shopName']?.toString();
                  String? shopAvatar = json['sellerId']['shopAvatar']?.toString();
                  
                  json['sellerId'] = sellerId;
                  json['shopName'] = shopName;
                  json['shopAvatar'] = shopAvatar;
                }

                print('Processing product: ${json['name']}');
                print('Discount data: $discountData');
                print('Final price: ${json['finalPrice']}');
                print('Shop info: ${json['shopName']} (${json['shopAvatar']})');

                return Product.fromMap(json);
              }
              throw Exception('Invalid product data format');
            } catch (e) {
              print('Error parsing product: $e');
              rethrow;
            }
          }).toList();

          print('Successfully mapped ${productList.length} products');
        },
      );
    } catch (e) {
      print('SearchServices - Error in fetchSearchedProduct: $e');
      showSnackBar(context, e.toString());
    }
    
    return productList;
  }
}