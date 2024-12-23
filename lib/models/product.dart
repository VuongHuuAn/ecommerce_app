import 'dart:convert';

import 'package:amazon_shop_on/models/comment.dart';
import 'package:amazon_shop_on/models/rating.dart';

class Discount {
  final double percentage;
  final DateTime? startDate;
  final DateTime? endDate;

  Discount({
    required this.percentage,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'percentage': percentage,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory Discount.fromMap(Map<String, dynamic> map) {
    return Discount(
      percentage: map['percentage']?.toDouble() ?? 0.0,
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
    );
  }
}


class Product {
  final String name;
  final String description;
  final int quantity;
  final List<String> images;
  final String category;
  final double price;
  final String? id;
  final String sellerId;
  final List<Rating>? ratings;
  final double? avgRating;
  final String? shopName;
  final String? shopAvatar;
  final Discount? discount;
  final double finalPrice;
  final List<Comment>? comments; // Thêm trường comments
  final int commentCount; 
  Product({
    required this.name,
    required this.description,
    required this.quantity,
    required this.images,
    required this.category,
    required this.price,
    this.id,
    required this.sellerId,
    this.ratings,
    this.avgRating,
    this.shopName,
    this.shopAvatar,
    this.discount,
    this.comments, // Thêm vào constructor
    this.commentCount = 0, 
    double? finalPrice,
  }) : finalPrice = finalPrice ?? price ;
  // Chuyển đổi từ đối tượng thành Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
      'images': images,
      'category': category,
      'price': price,
      '_id': id,
      'sellerId': sellerId, 
      'ratings': ratings,
      'avgRating': avgRating,
      'shopName': shopName,
      'shopAvatar': shopAvatar,
       'discount': discount?.toMap(),
      'finalPrice': finalPrice,
       'comments': comments?.map((x) => x.toMap()).toList(),
      'commentCount': commentCount,
    };
  }

// Chuyển đổi từ Map thành đối tượng Product
  factory Product.fromMap(Map<String, dynamic> map) {
    try {
      var ratingsList = map['ratings'];
      List<Rating>? ratings;
      
      if (ratingsList != null) {
        if (ratingsList is List) {
          ratings = ratingsList.map((x) {
            if (x is Map<String, dynamic>) {
              return Rating.fromMap(x);
            } else {
              print('Invalid rating format: $x');
              return null;
            }
          }).whereType<Rating>().toList();
        } else {
          print('Ratings is not a List: $ratingsList');
        }
      }

      return Product(
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        quantity: map['quantity']?.toInt() ?? 0,
        images: List<String>.from(map['images'] ?? []),
        category: map['category'] ?? '',
        price: (map['price'] is int)
            ? (map['price'] as int).toDouble()
            : map['price']?.toDouble() ?? 0.0,
        id: map['_id']?.toString(),
        sellerId: map['sellerId'] is Map 
            ? map['sellerId']['_id'].toString() 
            : (map['sellerId']?.toString() ?? ''),
        ratings: ratings,
        avgRating: map['avgRating']?.toDouble() ?? 0.0,
        shopName: map['sellerId'] is Map 
            ? map['sellerId']['shopName']?.toString() 
            : map['shopName'],
        shopAvatar: map['sellerId'] is Map 
            ? map['sellerId']['shopAvatar']?.toString() 
            : map['shopAvatar'],
        discount: map['discount'] != null 
            ? Discount.fromMap(
                map['discount'] is Map<String, dynamic>
                    ? map['discount']
                    : {'percentage': map['discount']}
              )
            : null,
        finalPrice: (map['finalPrice'] is int)
            ? (map['finalPrice'] as int).toDouble()
            : map['finalPrice']?.toDouble() ?? map['price']?.toDouble() ?? 0.0,
         comments: map['comments'] != null
            ? List<Comment>.from(
                (map['comments'] as List).map(
                  (x) => Comment.fromMap(x),
                ),
              )
            : null,
        commentCount: map['commentCount']?.toInt() ?? 0,    
      );
    } catch (e) {
      print('Error in Product.fromMap: $e');
      print('Problematic map: $map');
      rethrow;
    }
  }


// Chuyển đổi đối tượng thành JSON
  String toJson() => json.encode(toMap());

// Chuyển đổi JSON thành đối tượng Product
  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));
}