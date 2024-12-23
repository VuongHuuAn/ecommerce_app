import 'package:amazon_shop_on/features/home/services/home_services.dart';
import 'package:amazon_shop_on/features/product_details/services/product_details_services.dart';
import 'package:amazon_shop_on/models/product.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartProduct extends StatefulWidget {
  final int index;
  const CartProduct({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  State<CartProduct> createState() => _CartProductState();
}

class _CartProductState extends State<CartProduct> {
  final HomeServices homeServices = HomeServices();
  final ProductDetailsServices productDetailsServices =
      ProductDetailsServices();

  // Remove from cart
  Future<void> removeFromCart(String productId) async {
    homeServices.removeFromCart(
      context: context,
      productId: productId,
    );
  }

  // Add to cart
  Future<void> addToCart(Product product) async {
    await productDetailsServices.addToCart(
      context: context,
      product: product,
    );
  }

  @override
  Widget build(BuildContext context) {
    final productCart = context.watch<UserProvider>().user.cart[widget.index];
    final product = productCart.product;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              // Product image
              Image.network(
                product.images[0],
                fit: BoxFit.contain,
                height: 135,
                width: 135,
              ),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    // Price
                    Container(
                      padding: const EdgeInsets.only(left: 10, top: 5),
                      child: Text(
                        '\$${product.price}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // In stock
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text('In Stock'),
                    ),
                    // Quantity controls
                    Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black12,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.black12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Decrease quantity
                          InkWell(
                            onTap: () => removeFromCart(product.id),
                            child: Container(
                              width: 35,
                              height: 32,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.remove,
                                size: 18,
                              ),
                            ),
                          ),
                          // Quantity display
                          Container(
                            width: 35,
                            height: 32,
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: Text(
                              productCart.quantity.toString(),
                            ),
                          ),
                          // Increase quantity
                          InkWell(
                            onTap: () => addToCart(product),
                            child: Container(
                              width: 35,
                              height: 32,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.add,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Divider between products
        const Divider(
          height: 1,
          thickness: 1,
          color: Colors.black12,
        ),
      ],
    );
  }
}
