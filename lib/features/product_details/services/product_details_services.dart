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

class ProductDetailsServices {
  // Add to cart
  Future<void> addToCart({
    required BuildContext context,
    required Product product,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Validate inputs

      // Prepare cart item data
      final cartItem = {
        'product': product.id,
        'quantity': 1,
      };

      debugPrint('Adding to cart: ${product.id}');

      final res = await http.post(
        Uri.parse('$uri/api/add-to-cart'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode(cartItem),
      );

      debugPrint('Add to cart response: ${res.statusCode}');
      debugPrint('Response body: ${res.body}');

      if (context.mounted) {
        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            try {
              // Parse and validate cart data
              final responseData = jsonDecode(res.body);
              if (!responseData.containsKey('cart')) {
                throw Exception('Invalid response format');
              }

              final cartData = responseData['cart'] as List<dynamic>;

              // Update user model with new cart
              User user = userProvider.user.copyWith(
                cart: cartData.map((item) {
                  if (item == null) return {};
                  return {
                    'product': item['product'],
                    'quantity': item['quantity'] ?? 1,
                  };
                }).toList(),
              );

              userProvider.setUserFromModel(user);
              showSnackBar(context, 'Added to Cart');
            } catch (e) {
              debugPrint('Error parsing cart data: $e');
              showSnackBar(context, 'Error updating cart');
            }
          },
        );
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  // Rate product
  Future<void> rateProduct({
    required BuildContext context,
    required Product product,
    required double rating,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Validate inputs

      if (rating < 0 || rating > 5) {
        throw Exception('Rating must be between 0 and 5');
      }

      debugPrint('Rating product: ${product.id} with $rating stars');

      final res = await http.post(
        Uri.parse('$uri/api/rate-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': product.id,
          'rating': rating,
        }),
      );

      debugPrint('Rate product response: ${res.statusCode}');
      debugPrint('Response body: ${res.body}');

      if (context.mounted) {
        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Thank you for rating!');
          },
        );
      }
    } catch (e) {
      debugPrint('Error rating product: $e');
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }
//
Future<void> addComment({
   required BuildContext context,
   required String productId,
   required String content,
   required double rating,
   required List<String> images,
   bool purchaseVerified = false,
 }) async {
   final userProvider = Provider.of<UserProvider>(context, listen: false);
   debugPrint('addComment - Starting process');
   debugPrint('addComment - Product ID: $productId');
   debugPrint('addComment - Content: $content');
   debugPrint('addComment - Rating: $rating');
   debugPrint('addComment - Images: $images');
   debugPrint('addComment - Purchase Verified: $purchaseVerified');
    try {
     final res = await http.post(
       Uri.parse('$uri/api/add-comment'),
       headers: {
         'Content-Type': 'application/json; charset=UTF-8',
         'x-auth-token': userProvider.user.token,
       },
       body: jsonEncode({
         'productId': productId,
         'content': content,
         'rating': rating,
         'images': images,
         'purchaseVerified': purchaseVerified,
       }),
     );
      debugPrint('Add comment response status: ${res.statusCode}');
     debugPrint('Response body: ${res.body}');
      if (context.mounted) {
       httpErrorHandle(
         response: res,
         context: context,
         onSuccess: () {
           showSnackBar(context, 'Comment added successfully!');
         },
       );
     }
   } catch (e) {
     debugPrint('Error adding comment: $e');
     if (context.mounted) {
       showSnackBar(context, e.toString());
     }
   }
 }
  // Add reply to comment
 Future<void> addReply({
   required BuildContext context,
   required String productId,
   required String commentId,
   required String content,
   bool isSellerReply = false,
 }) async {
   final userProvider = Provider.of<UserProvider>(context, listen: false);
   debugPrint('addReply - Starting process');
   debugPrint('addReply - Product ID: $productId');
   debugPrint('addReply - Comment ID: $commentId');
   debugPrint('addReply - Content: $content');
   debugPrint('addReply - Is Seller Reply: $isSellerReply');
    try {
     final res = await http.post(
       Uri.parse('$uri/api/add-reply'),
       headers: {
         'Content-Type': 'application/json; charset=UTF-8',
         'x-auth-token': userProvider.user.token,
       },
       body: jsonEncode({
         'productId': productId,
         'commentId': commentId,
         'content': content,
         'isSellerReply': isSellerReply,
       }),
     );
      debugPrint('Add reply response status: ${res.statusCode}');
     debugPrint('Response body: ${res.body}');
      if (context.mounted) {
       httpErrorHandle(
         response: res,
         context: context,
         onSuccess: () {
           showSnackBar(context, 'Reply added successfully!');
         },
       );
     }
   } catch (e) {
     debugPrint('Error adding reply: $e');
     if (context.mounted) {
       showSnackBar(context, e.toString());
     }
   }
 }
}