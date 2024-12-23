import 'package:amazon_shop_on/features/comment/widgets/comment_card.dart';
import 'package:amazon_shop_on/models/comment.dart';
import 'package:flutter/material.dart';

class CommentList extends StatelessWidget {
  final List<Comment> comments;
 final String currentUserId;
 final VoidCallback onRefresh;
  const CommentList({
   Key? key,
   required this.comments,
   required this.currentUserId,
   required this.onRefresh,
 }) : super(key: key);
  @override
 Widget build(BuildContext context) {
   return comments.isEmpty
       ? const Center(child: Text('No reviews yet'))
       : RefreshIndicator(
           onRefresh: () async => onRefresh(),
           child: ListView.builder(
             padding: const EdgeInsets.all(8),
             itemCount: comments.length,
             itemBuilder: (context, index) {
               final comment = comments[index];
               return CommentCard(
                 comment: comment,
                 currentUserId: currentUserId,
                 onRefresh: onRefresh,
               );
             },
           ),
         );
 }
}
