import 'package:amazon_shop_on/common/widgets/loader.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/features/home/services/home_services.dart';
import 'package:amazon_shop_on/features/product_details/screens/product_details_screen.dart';
import 'package:amazon_shop_on/models/product.dart';
import 'package:flutter/material.dart';

class CategoryDealsScreen extends StatefulWidget {
  static const String routeName = '/category-deals';
  final String category;
  const CategoryDealsScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<CategoryDealsScreen> createState() => _CategoryDealsScreenState();
}

class _CategoryDealsScreenState extends State<CategoryDealsScreen> {
  List<Product> productList = [];
  final HomeServices homeServices = HomeServices();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategoryProducts();
  }

  fetchCategoryProducts() async {
    productList = await homeServices.fetchProductsByCategory(
      context: context,
      category: widget.category,
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: Text(
            widget.category,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: Loader())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    left: 15,
                    top: 10,
                    bottom: 10,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Keep shopping for ${widget.category}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (productList.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No products found in this category',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      itemCount: productList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final product = productList[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              ProductDetailScreen.routeName,
                              arguments: product,
                            );
                          },
                          child: ProductCard(
                            product: product,
                            onAddToCart: () async {
                              await homeServices.addToCart(
                                context: context,
                                product: product,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Image.network(
                product.images[0],
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Price Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (product.finalPrice != null &&
                          product.finalPrice! < product.price)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${product.finalPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              '\$${product.price}',
                              style: const TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          '\$${product.price}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Add to Cart Button
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
