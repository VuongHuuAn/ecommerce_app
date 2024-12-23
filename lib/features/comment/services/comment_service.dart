import 'dart:convert';
import 'package:amazon_shop_on/constants/error_handling.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/models/comment.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CommentService {
   // Lấy danh sách comments cho một sản phẩm
 Future<Map<String, dynamic>> getComments({
   required BuildContext context,
   required String productId,
 }) async {
   final userProvider = Provider.of<UserProvider>(context, listen: false);
   List<Comment> commentList = [];
   int totalComments = 0;
    try {
     http.Response res = await http.get(
       Uri.parse('$uri/api/product/comments/$productId'),
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
         if (data['comments'] != null) {
           commentList = (data['comments'] as List)
               .map((comment) => Comment.fromMap(comment))
               .toList();
         }
         totalComments = data['totalComments'] ?? 0;
       },
     );
   } catch (e) {
     debugPrint('Error getting comments: $e');
     showSnackBar(context, e.toString());
   }
   return {
     'comments': commentList,
     'totalComments': totalComments,
   };
 }
  // Thêm comment mới
 Future<void> addComment({
   required BuildContext context,
   required String productId,
   required String content,
   required double rating,
   required List<String> images,
   bool purchaseVerified = false,
 }) async {
   final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
     http.Response res = await http.post(
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
      httpErrorHandle(
       response: res,
       context: context,
       onSuccess: () {
         showSnackBar(context, 'Comment added successfully!');
       },
     );
   } catch (e) {
     debugPrint('Error adding comment: $e');
     showSnackBar(context, e.toString());
   }
 }
  // Thêm reply cho comment
Future<void> addReply({
   required BuildContext context,
   required String commentId,
   required String content,
 }) async {
   final userProvider = Provider.of<UserProvider>(context, listen: false);
   
   debugPrint('addReply - Starting process');
   debugPrint('addReply - Comment ID: $commentId');
   debugPrint('addReply - Content: $content');
    try {
     final res = await http.post(
       Uri.parse('$uri/api/add-reply'),
       headers: {
         'Content-Type': 'application/json; charset=UTF-8',
         'x-auth-token': userProvider.user.token,
       },
       body: jsonEncode({
         'commentId': commentId,
         'content': content,
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