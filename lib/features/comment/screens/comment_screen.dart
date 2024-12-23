import 'package:amazon_shop_on/common/widgets/loader.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/features/comment/services/comment_service.dart';
import 'package:amazon_shop_on/features/comment/widgets/comment_input.dart';
import 'package:amazon_shop_on/features/comment/widgets/comment_list.dart';
import 'package:amazon_shop_on/models/comment.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentScreen extends StatefulWidget {
  static const String routeName = '/comment-screen';
  final String productId;

  const CommentScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final CommentService commentService = CommentService();
  List<Comment> comments = [];
  int totalComments = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    debugPrint('CommentScreen initialized');
    fetchComments();
  }

  Future<void> fetchComments() async {
    debugPrint('Fetching comments...');
    try {
      final response = await commentService.getComments(
        context: context,
        productId: widget.productId,
      );
      debugPrint('Comments fetched: ${response['comments'].length}');
      if (mounted) {
        setState(() {
          comments = response['comments'];
          totalComments = response['totalComments'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      if (mounted) {
        showSnackBar(context, 'Error loading comments');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews ($totalComments)'),
      ),
      body: isLoading
          ? const Loader()
          : Column(
              children: [
                Expanded(
                  child: CommentList(
                    comments: comments,
                    currentUserId: user.id,
                     
                    onRefresh: fetchComments,
                  ),
                ),
                CommentInput(
                  productId: widget.productId,
                  onCommentAdded: fetchComments,
                   
                ),
              ],
            ),
    );
  }
}
