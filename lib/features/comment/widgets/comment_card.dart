import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/features/comment/services/comment_service.dart';
import 'package:amazon_shop_on/models/comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final String currentUserId;
 
  final VoidCallback onRefresh;

  const CommentCard({
    Key? key,
    required this.comment,
    required this.currentUserId,
     required this.onRefresh,
  }) : super(key: key);

  void showReplyDialog(BuildContext context) {
    final TextEditingController replyController = TextEditingController();
    final CommentService commentService = CommentService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reply'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(
            hintText: 'Write your reply...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (replyController.text.isEmpty) {
                showSnackBar(context, 'Please enter a reply');
                return;
              }

              try {
                await commentService.addReply(
                  context: context,
                   // Assuming this is the product ID
                  commentId: comment.id,
                  content: replyController.text,
                );
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                  onRefresh();
                }
              } catch (e) {
                debugPrint('Error adding reply: $e');
                if (Navigator.canPop(context)) {
                  showSnackBar(context, 'Error adding reply');
                }
              }
            },
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCommentHeader(),
            const SizedBox(height: 8),
            _buildRating(),
            const SizedBox(height: 8),
            Text(comment.content),
            if (comment.images.isNotEmpty) _buildImageGallery(),
            if (comment.replies.isNotEmpty) _buildReplies(),
            TextButton(
              onPressed: () => showReplyDialog(context),
              child: const Text('Reply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentHeader() {
    return Row(
      children: [
        CircleAvatar(
          child: Text(comment.userName[0].toUpperCase()),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (comment.purchaseVerified)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Verified Purchase',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                DateFormat('MMM d, yyyy').format(comment.createdAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        RatingBarIndicator(
          rating: comment.rating.toDouble(),
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          itemSize: 20,
        ),
        const SizedBox(width: 8),
        Text(
          comment.rating.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: comment.images.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Image.network(
              comment.images[index],
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
          );
        },
      ),
    );
  }

  Widget _buildReplies() {
    return Column(
      children: [
        const Divider(),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comment.replies.length,
          itemBuilder: (context, index) {
            final reply = comment.replies[index];
            return Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        child: Text(reply.userName[0].toUpperCase()),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  reply.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (reply.isSellerReply)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Seller',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              DateFormat('MMM d, yyyy')
                                  .format(reply.createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 32, top: 4),
                    child: Text(reply.content),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
