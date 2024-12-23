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

class HomeServices {
  Future<List<Product>> fetchDealOfDay({
    required BuildContext context,
  }) async {
    print('HomeServices - fetchDealOfDay started');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];

    try {
      print('Calling API: $uri/api/deal-of-day');
      http.Response res = await http.get(
        Uri.parse('$uri/api/deal-of-day'),
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
                    // If discount is a number, create discount object
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
                  double discountPercentage =
                      discountData?['percentage']?.toDouble() ?? 0.0;
                  json['finalPrice'] = price * (1 - discountPercentage / 100);
                }

                print('Processing product: ${json['name']}');
                print('Discount data: $discountData');
                print('Final price: ${json['finalPrice']}');

                return Product.fromMap(json);
              }
              throw Exception('Invalid product data format');
            } catch (e) {
              print('Error parsing product: $e');
              rethrow;
            }
          }).toList();

          print('Successfully mapped products: ${productList.length}');
        },
      );
    } catch (e) {
      print('HomeServices - Error in fetchDealOfDay: $e');
      showSnackBar(context, e.toString());
    }

    return productList;
  }

  // Fetch products by category
  Future<List<Product>> fetchProductsByCategory({
    required BuildContext context,
    required String category,
  }) async {
    print('HomeServices - fetchProductsByCategory started');
    print('Category: $category');

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];

    try {
      print('Calling API: $uri/api/products?category=$category');
      http.Response res = await http.get(
        Uri.parse('$uri/api/products?category=$category'),
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
                    // If discount is a number, create discount object
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
                  double discountPercentage =
                      discountData?['percentage']?.toDouble() ?? 0.0;
                  json['finalPrice'] = price * (1 - discountPercentage / 100);
                }

                // Parse sellerId if it's an object
                if (json['sellerId'] is Map) {
                  String sellerId = json['sellerId']['_id'].toString();
                  String? shopName = json['sellerId']['shopName']?.toString();
                  String? shopAvatar =
                      json['sellerId']['shopAvatar']?.toString();

                  json['sellerId'] = sellerId;
                  json['shopName'] = shopName;
                  json['shopAvatar'] = shopAvatar;
                }

                print('Processing product: ${json['name']}');
                print('Discount data: $discountData');
                print('Final price: ${json['finalPrice']}');

                return Product.fromMap(json);
              }
              throw Exception('Invalid product data format');
            } catch (e) {
              print('Error parsing product: $e');
              rethrow;
            }
          }).toList();

          print('Successfully mapped products: ${productList.length}');
        },
      );
    } catch (e) {
      print('HomeServices - Error in fetchProductsByCategory: $e');
      showSnackBar(context, e.toString());
    }

    return productList;
  }

  // Search products
  Future<List<Product>> searchProducts({
    required BuildContext context,
    required String searchQuery,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> products = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/products/search/$searchQuery'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          List<dynamic> productsJson = jsonDecode(res.body);
          products = productsJson.map((json) {
            if (json is Map<String, dynamic>) {
              return Product.fromMap(json);
            }
            throw Exception('Invalid product data format');
          }).toList();
        },
      );
    } catch (e) {
      print('Error searching products: $e');
      showSnackBar(context, e.toString());
    }
    return products;
  }

  // Add to Cart
  Future<void> addToCart({
    required BuildContext context,
    required Product product,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Validate product ID
      if (product.id == null || product.id!.isEmpty) {
        throw 'Product ID is required';
      }

      // Log request details
      debugPrint('=== Add to Cart Request ===');
      debugPrint('Product ID: ${product.id}');

      final requestBody = {
        'product': product.id,
        'quantity': 1,
      };
      debugPrint('Request body: ${jsonEncode(requestBody)}');

      final res = await http.post(
        Uri.parse('$uri/api/add-to-cart'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode(requestBody),
      );

      // Log response details
      debugPrint('=== Add to Cart Response ===');
      debugPrint('Status code: ${res.statusCode}');
      debugPrint('Response body: ${res.body}');

      if (context.mounted) {
        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            try {
              // Log success details
              debugPrint('=== Processing Response ===');
              final userData = jsonDecode(res.body);
              debugPrint('Updated user data: ${jsonEncode(userData)}');

              final updatedUser = User.fromMap(userData);
              userProvider.setUserFromModel(updatedUser);

              // Log cart update
              debugPrint('Cart updated successfully');
              debugPrint('New cart items: ${updatedUser.cart.length}');

              showSnackBar(context, 'Added to Cart Successfully!');
            } catch (e) {
              debugPrint('=== Error Processing Response ===');
              debugPrint('Error: $e');
              showSnackBar(context, 'Error updating cart');
            }
          },
        );
      }
    } catch (e) {
      debugPrint('=== Exception Caught ===');
      debugPrint('Error in addToCart: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  void removeFromCart(
      {required BuildContext context, required String productId}) {}
}

Future<void> deleteFromCart({
  required BuildContext context,
  required String productId,
}) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  try {
    print('Deleting product with ID: $productId');
    print('Request URL: $uri/api/delete-from-cart/$productId');
    print('Token: ${userProvider.user.token}');

    http.Response res = await http.delete(
      Uri.parse('$uri/api/delete-from-cart/$productId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      },
    );

    print('Response status code: ${res.statusCode}');
    print('Response body: ${res.body}');

    httpErrorHandle(
      response: res,
      context: context,
      onSuccess: () {
        var responseData = jsonDecode(res.body);
        print('Parsed response data: $responseData');

        User user = userProvider.user.copyWith(
          cart: List.from(responseData['user']['cart']),
        );
        print('Updated cart: ${user.cart}');

        userProvider.setUserFromModel(user);
        showSnackBar(context, responseData['message']);
      },
    );
  } catch (e, stackTrace) {
    print('Error in deleteFromCart: $e');
    print('Stack trace: $stackTrace');
    showSnackBar(context, 'Error: ${e.toString()}');
  }
}
