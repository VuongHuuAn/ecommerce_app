import 'package:amazon_shop_on/common/widgets/stars.dart';
import 'package:amazon_shop_on/models/product.dart';
import 'package:flutter/material.dart';

class SearchedProduct extends StatelessWidget {
  final Product product;
  const SearchedProduct({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double discountPercentage = product.discount?.percentage ?? 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.images[0],
              fit: BoxFit.contain,
              height: 135,
              width: 135,
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Rating Stars
                  Row(
                    children: [
                      Stars(rating: product.avgRating ?? 0),
                      const SizedBox(width: 8),
                      if ((product.ratings?.length ?? 0) > 0)
                        Text(
                          '(${product.ratings?.length})',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Price Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (discountPercentage > 0) ...[
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${product.finalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${discountPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ] else
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Shop Name if available
                  if (product.shopName != null) ...[
                    Text(
                      'Sold by ${product.shopName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Shipping Info
                  const Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 16,
                        color: Colors.teal,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Eligible for FREE Shipping',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Stock Status
                  Row(
                    children: [
                      Icon(
                        product.quantity > 0 
                            ? Icons.check_circle_outline 
                            : Icons.error_outline,
                        size: 16,
                        color: product.quantity > 0 ? Colors.teal : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.quantity > 0 
                            ? 'In Stock (${product.quantity} available)' 
                            : 'Out of Stock',
                        style: TextStyle(
                          color: product.quantity > 0 ? Colors.teal : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}