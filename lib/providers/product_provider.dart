import 'package:flutter/material.dart';
import 'package:amazon_shop_on/models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  void setProducts(List<Product> products) {
    _products = products;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void removeProduct(String id) {
    _products.removeWhere((product) => product.id == id);
    notifyListeners();
  }

  void updateProduct(Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }
   Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  String getDiscountTimeRemaining(Product product) {
    if (product.discount == null || product.discount!.endDate == null) {
      return '';
    }

    final now = DateTime.now();
    final end = product.discount!.endDate!;
    
    if (now.isAfter(end)) {
      return 'Expired';
    }

    final difference = end.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return '${difference.inSeconds}s left';
    }
  }
}