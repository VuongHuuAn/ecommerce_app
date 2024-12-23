import 'dart:convert';
import 'package:amazon_shop_on/models/product.dart';

class Order {
  final String id;
  final List<OrderProduct> products;
  final double totalPrice;
  final String address;
  final String userId;
  final int orderedAt;
   int status;

  Order({
    required this.id,
    required this.products,
    required this.totalPrice,
    required this.address,
    required this.userId,
    required this.orderedAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'products': products.map((x) => x.toMap()).toList(),
      'totalPrice': totalPrice,
      'address': address,
      'userId': userId,
      'orderedAt': orderedAt,
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    try {
      return Order(
        id: map['_id']?.toString() ?? '',
        products: List<OrderProduct>.from(
          (map['products'] as List).map(
            (x) => OrderProduct.fromMap(x as Map<String, dynamic>),
          ),
        ),
        totalPrice: (map['totalPrice'] is int) 
            ? (map['totalPrice'] as int).toDouble() 
            : map['totalPrice']?.toDouble() ?? 0.0,
        address: map['address']?.toString() ?? '',
        userId: map['userId']?.toString() ?? '',
        orderedAt: map['orderedAt'] is String 
            ? int.parse(map['orderedAt']) 
            : map['orderedAt']?.toInt() ?? 0,
        status: map['status'] is String 
            ? int.parse(map['status']) 
            : map['status']?.toInt() ?? 0,
      );
    } catch (e) {
      print('Error in Order.fromMap: $e');
      print('Problematic map: $map');
      rethrow;
    }
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));
}

class OrderProduct {
  final Product product;
  final int quantity;

  OrderProduct({
    required this.product,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

 factory OrderProduct.fromMap(Map<String, dynamic> map) {
    try {
      return OrderProduct(
        product: Product.fromMap(map['product'] as Map<String, dynamic>),
        quantity: map['quantity'] is String 
            ? int.parse(map['quantity']) 
            : map['quantity']?.toInt() ?? 0,
      );
    } catch (e) {
      print('Error in OrderProduct.fromMap: $e');
      print('Problematic map: $map');
      rethrow;
    }
  }
  String toJson() => json.encode(toMap());

  factory OrderProduct.fromJson(String source) => 
      OrderProduct.fromMap(json.decode(source));
}