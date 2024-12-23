import 'package:amazon_shop_on/common/widgets/custom_button.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/features/comment/services/comment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CommentInput extends StatefulWidget {
  final String productId;
  final VoidCallback onCommentAdded;

  const CommentInput({
    Key? key,
    required this.productId,
    required this.onCommentAdded,
  }) : super(key: key);

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final CommentService commentService = CommentService();
  final TextEditingController commentController = TextEditingController();
  double userRating = 5;
  List<dynamic> images = [];

  Future<void> addComment() async {
    if (commentController.text.isEmpty) {
      showSnackBar(context, 'Please enter a comment');
      return;
    }

    try {
      List<String> imageUrls = [];
      

      await commentService.addComment(
        context: context,
        productId: widget.productId,
        content: commentController.text,
        rating: userRating,
        images: imageUrls,
      );

      // Clear input and refresh
      setState(() {
        commentController.clear();
        images = [];
        userRating = 5;
      });

      widget.onCommentAdded();
    } catch (e) {
      debugPrint('Error adding comment: $e');
      if (mounted) {
        showSnackBar(context, 'Error adding comment');
      }
    }
  }

  void selectImages() async {
    var res = await pickImages();
    setState(() {
      images = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            initialRating: userRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 30,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                userRating = rating;
              });
            },
          ),
          const SizedBox(height: 8),
          if (images.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 100,
                    child: Stack(
                      children: [
                        Image.file(
                          images[index],
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                images.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: 'Write a review...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: selectImages,
              ),
              SizedBox(
                width: 80,
                child: CustomButton(
                  text: 'Post',
                  onTap: addComment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
