import 'dart:convert';

class Reply {
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;
  final bool isSellerReply;

  Reply({
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    required this.isSellerReply,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isSellerReply': isSellerReply,
    };
  }

  factory Reply.fromMap(Map<String, dynamic> map) {
    return Reply(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      isSellerReply: map['isSellerReply'] ?? false,
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final List<String> images;
  final int rating;
  final List<String> likes;
  final bool purchaseVerified;
  final DateTime createdAt;
  final List<Reply> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.images,
    required this.rating,
    required this.likes,
    required this.purchaseVerified,
    required this.createdAt,
    required this.replies,
  });

  Map<String, dynamic> toMap() {
    return {
       '_id': id,
      'userId': userId,
      'userName': userName,
      'content': content,
      'images': images,
      'rating': rating,
      'likes': likes,
      'purchaseVerified': purchaseVerified,
      'createdAt': createdAt.toIso8601String(),
      'replies': replies.map((x) => x.toMap()).toList(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(id: map['_id'] ?? '', 
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      content: map['content'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      rating: map['rating']?.toInt() ?? 0,
      likes: List<String>.from(map['likes'] ?? []),
      purchaseVerified: map['purchaseVerified'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      replies: List<Reply>.from(
        (map['replies'] ?? []).map(
          (x) => Reply.fromMap(x),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) => Comment.fromMap(json.decode(source));
}