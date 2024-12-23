import 'package:amazon_shop_on/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromMap(map['product'] as Map<String, dynamic>),
      quantity: (map['quantity'] as num).toInt(),
    );
  }
}