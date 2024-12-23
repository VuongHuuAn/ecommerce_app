// lib/services/seller_services.dart

import 'dart:convert';
import 'dart:io';
import 'package:amazon_shop_on/constants/error_handling.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/models/order.dart';
import 'package:amazon_shop_on/models/product.dart';
import 'package:amazon_shop_on/models/sales.dart';
import 'package:amazon_shop_on/models/shop_stats.dart';
import 'package:amazon_shop_on/models/user.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SellerServices {
  Future<String> registerSeller({
    required BuildContext context,
    required String shopName,
    required String shopDescription,
    required String address,
    required File avatar,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String status = '';
    try {
      // Upload avatar to cloudinary
      final cloudinary = CloudinaryPublic('drylewuid', 'qfpqu7pe');
      CloudinaryResponse avatarRes = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(avatar.path, folder: shopName),
      );

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
          'avatarUrl': avatarRes.secureUrl,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          status = jsonDecode(res.body)['status'];
          showSnackBar(
            context,
            'Seller registration request sent successfully!',
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return status;
  }

  Future<String> checkRequestStatus(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String status = '';
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

  void sellProduct({
    required BuildContext context,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
    required List<File> images,
    required String sellerId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      // ko luu anh tren mongodb vi dung luong kha it(shared clutter),luu anh tren cloudinary
      final cloudinary = CloudinaryPublic('drylewuid', 'qfpqu7pe');
      List<String> imageUrls = [];
      for (int i = 0; i < images.length; i++) {
        CloudinaryResponse res = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(images[i].path, folder: name),
        );
        imageUrls.add(res.secureUrl);
      }
      Product product = Product(
        name: name,
        description: description,
        quantity: quantity,
        images: imageUrls,
        category: category,
        price: price,
        sellerId: sellerId,
      );
      http.Response res = await http.post(
        Uri.parse('$uri/seller/add-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: product.toJson(),
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Product added successfully!');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // get all the products
  Future<List<Product>> fetchAllProducts(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];

    try {
      print('Making API request...'); // Debug log

      http.Response res = await http.get(
        Uri.parse('$uri/seller/get-products'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      print('Response status: ${res.statusCode}'); // Debug log
      print('Response body: ${res.body}'); // Debug log

      if (res.statusCode == 200) {
        final List<dynamic> productsJson = jsonDecode(res.body);
        productList = productsJson
            .map((productData) {
              try {
                // Chuyển đổi dữ liệu discount từ server format sang client format
                Map<String, dynamic> mappedProduct = {
                  'name': productData['name'],
                  'description': productData['description'],
                  'quantity': productData['quantity'],
                  'images': List<String>.from(productData['images']),
                  'category': productData['category'],
                  'price': productData['price']?.toDouble() ?? 0.0,
                  '_id': productData['_id'],
                  'sellerId': productData['sellerId'],
                  'ratings': productData['ratings'] ?? [],
                  'avgRating': productData['avgRating']?.toDouble() ?? 0.0,
                  'finalPrice': productData['finalPrice']?.toDouble() ??
                      productData['price']?.toDouble() ??
                      0.0,
                };

                // Xử lý discount nếu có
                if (productData['discount'] != null &&
                    productData['discount'] > 0) {
                  mappedProduct['discount'] = {
                    'percentage': productData['discount']?.toDouble() ?? 0.0,
                    'startDate': productData['startDate'],
                    'endDate': productData['endDate'],
                  };
                }

                // Xử lý sellerId nếu là populated data
                if (productData['sellerId'] is Map) {
                  mappedProduct['shopName'] =
                      productData['sellerId']['shopName'];
                  mappedProduct['shopAvatar'] =
                      productData['sellerId']['shopAvatar'];
                  mappedProduct['sellerId'] = productData['sellerId']['_id'];
                }

                print('Mapped product: $mappedProduct'); // Debug log
                return Product.fromMap(mappedProduct);
              } catch (e) {
                print('Error parsing product: $e'); // Debug log
                print('Product data: $productData'); // Debug log
                return null;
              }
            })
            .whereType<Product>()
            .toList();

        print('Parsed products length: ${productList.length}'); // Debug log
      }
    } catch (e) {
      print('Fetch error: $e'); // Debug log
      showSnackBar(context, e.toString());
    }

    return productList;
  }

  void deleteProduct({
    required BuildContext context,
    required Product product,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/seller/delete-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': product.id,
        }),
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          onSuccess();
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<List<Order>> fetchAllOrders(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Order> orderList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/seller/get-orders'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            orderList.add(
              Order.fromJson(
                jsonEncode(
                  jsonDecode(res.body)[i],
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return orderList;
  }

  void changeOrderStatus({
    required BuildContext context,
    required int status,
    required Order order,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/seller/change-order-status'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': order.id,
          'status': status,
        }),
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: onSuccess,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<Map<String, dynamic>> getEarnings(BuildContext context) async {
   final userProvider = Provider.of<UserProvider>(context, listen: false);
   List<Sales> sales = [];
   double totalEarnings = 0;
    try {
     http.Response res = await http.get(
       Uri.parse('$uri/seller/analytics'),
       headers: {
         'Content-Type': 'application/json; charset=UTF-8',
         'x-auth-token': userProvider.user.token,
       },
     );
      httpErrorHandle(
       response: res,
       context: context,
       onSuccess: () {
         var data = jsonDecode(res.body);
         totalEarnings = (data['totalEarnings'] ?? 0).toDouble();
         
         if (data['sales'] != null) {
           sales = (data['sales'] as List).map((item) {
             return Sales(
               category: item['category'] ?? '',
               earning: (item['earning'] ?? 0).toDouble(),
               quantity: (item['quantity'] ?? 0),
             );
           }).toList();
         }
       },
     );
   } catch (e) {
     showSnackBar(context, e.toString());
     rethrow;
   }
    return {
     'sales': sales,
     'totalEarnings': totalEarnings,
   };
 }
  // Update Product
  Future<void> updateProduct({
    required BuildContext context,
    required Product product,
    required List<String> images,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
    required List<File> newImages,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      List<String> newImageUrls = [];
      if (newImages.isNotEmpty) {
        // ko luu anh tren mongodb vi dung luong kha it(shared clutter),luu anh tren cloudinary
        final cloudinary = CloudinaryPublic('drylewuid', 'qfpqu7pe');

        for (int i = 0; i < images.length; i++) {
          CloudinaryResponse res = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(newImages[i].path, folder: name),
          );
          newImageUrls.add(res.secureUrl);
        }
      }
      List<String> updateImages =
          (newImageUrls.isNotEmpty) ? newImageUrls : images;
      http.Response res = await http.post(
        Uri.parse('$uri/seller/update-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': product.id,
          'name': name,
          'description': description,
          'price': price,
          'quantity': quantity,
          'category': category,
          'images': updateImages,
        }),
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Product updated successfully!');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<Map<String, dynamic>> getShopData(
      BuildContext context, String sellerId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    User? shopOwner;
    List<Product> products = [];

    try {
      http.Response res = await http.get(
        Uri.parse('$uri/seller/shop-data/$sellerId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          var data = jsonDecode(res.body);
          shopOwner = User.fromMap(data['shopOwner']);
          products = (data['products'] as List)
              .map((product) => Product.fromJson(jsonEncode(product)))
              .toList();
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return {
      'shopOwner': shopOwner,
      'products': products,
    };
  }

// Update getShopStats to accept sellerId
  Future<ShopStats> getShopStats(BuildContext context, String sellerId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    ShopStats stats =
        ShopStats(totalProducts: 0, avgRating: 0, followerCount: 0);

    try {
      http.Response res = await http.get(
        Uri.parse('$uri/seller/shop-stats/$sellerId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          stats = ShopStats.fromJson(jsonDecode(res.body));
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return stats;
  }

// The follow/unfollow methods look good, but let's update the user provider after success
  Future<void> followSeller({
    required BuildContext context,
    required String sellerId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/seller/follow'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'sellerId': sellerId,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          userProvider.followSeller(sellerId);
          showSnackBar(context, 'Successfully followed seller');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> unfollowSeller({
    required BuildContext context,
    required String sellerId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/seller/unfollow'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'sellerId': sellerId,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          userProvider.unfollowSeller(sellerId);
          showSnackBar(context, 'Successfully unfollowed seller');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> setProductDiscount({
  required BuildContext context,
  required Product product,
  required double percentage,
  required DateTime startDate,
  required DateTime endDate,
}) async {
  try {
    print('Setting discount for product: ${product.id}'); // Debug log
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Sửa lại URL endpoint cho đúng
    final url = Uri.parse('$uri/seller/set-discount/${product.id}');
    print('Request URL: $url'); // Debug log
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      },
      body: jsonEncode({
        'percentage': percentage,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      }),
    );

    print('Response status: ${response.statusCode}'); // Debug log
    print('Response body: ${response.body}'); // Debug log

    httpErrorHandle(
      response: response,
      context: context,
      onSuccess: () {
        showSnackBar(context, 'Discount set successfully!');
      },
    );
  } catch (e) {
    print('Error setting discount: $e'); // Debug log
    showSnackBar(context, e.toString());
  }
}
}
