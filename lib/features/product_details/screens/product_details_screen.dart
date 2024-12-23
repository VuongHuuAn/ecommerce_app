import 'package:amazon_shop_on/common/widgets/custom_button.dart';
import 'package:amazon_shop_on/common/widgets/stars.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/features/cart/screens/cart_screen.dart';
import 'package:amazon_shop_on/features/comment/screens/comment_screen.dart';
import 'package:amazon_shop_on/features/product_details/services/product_details_services.dart';

import 'package:amazon_shop_on/models/product.dart';
import 'package:amazon_shop_on/models/rating.dart';
import 'package:amazon_shop_on/providers/product_provider.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  static const String routeName = '/product-details';
  final Product product;
  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductDetailsServices productDetailsServices =
      ProductDetailsServices();
  final TextEditingController commentController = TextEditingController();
  double avgRating = 0;
  double myRating = 0;
  List<dynamic> commentImages = [];
  @override
  void initState() {
    super.initState();
    calculateAverageRating();
  }

  void calculateAverageRating() {
    avgRating = widget.product.avgRating ?? 0;
    if (widget.product.ratings != null && widget.product.ratings!.isNotEmpty) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var myRatingObj = widget.product.ratings!.firstWhere(
        (rating) => rating.userId == userProvider.user.id,
        orElse: () => Rating(userId: '', rating: 0),
      );
      myRating = myRatingObj.rating;
    }
  }

  void selectImages() async {
    var res = await pickImages();
    setState(() {
      commentImages = res;
    });
  }

  void updateRating(double rating) async {
    setState(() {
      myRating = rating;
    });
    await productDetailsServices.rateProduct(
      context: context,
      product: widget.product,
      rating: rating,
    );
  }

  void addComment() async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final productProvider = Provider.of<ProductProvider>(context, listen: false);
  
  // Check if user is logged in
  if (userProvider.user.token.isEmpty) {
    showSnackBar(context, 'Please login to add review');
    return;
  }

  // Check if rating is provided
  if (myRating == 0) {
    showSnackBar(context, 'Please provide a rating before submitting');
    return;
  }

  // Check if comment is not empty
  if (commentController.text.isEmpty) {
    showSnackBar(context, 'Please enter a comment');
    return;
  }

  try {
    List<String> imageUrls = [];

    await productDetailsServices.addComment(
      context: context,
      productId: widget.product.id!,
      content: commentController.text,
      rating: myRating,
      images: imageUrls,
    );
    // Update product in provider after successful comment
    final product = productProvider.getProductById(widget.product.id!);
    if (product != null) {
      productProvider.updateProduct(product);
    }
    setState(() {
      commentController.clear();
      commentImages = [];
    });
  } catch (e) {
    showSnackBar(context, e.toString());
  }
}

  void addToCartAndNavigate() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user.token.isEmpty) {
      showSnackBar(context, 'Please login to add to cart');
      return;
    }
    try {
      await productDetailsServices.addToCart(
        context: context,
        product: widget.product,
      );
      if (context.mounted) {
        Navigator.pushNamed(context, CartScreen.routeName);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: const Text('Product Details'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images Carousel
            CarouselSlider(
              items: widget.product.images.map(
                (i) {
                  return Builder(
                    builder: (BuildContext context) => Image.network(
                      i,
                      fit: BoxFit.contain,
                      height: 200,
                    ),
                  );
                },
              ).toList(),
              options: CarouselOptions(
                viewportFraction: 1,
                height: 300,
                autoPlay: true,
              ),
            ),
            // Product Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${widget.product.price}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Stars(rating: avgRating),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Shop Info
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Shop Avatar
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: widget.product.shopAvatar !=
                                        null &&
                                    widget.product.shopAvatar!.isNotEmpty
                                ? NetworkImage(widget.product.shopAvatar!)
                                : const AssetImage(
                                        'assets/images/shop_placeholder.png')
                                    as ImageProvider,
                          ),
                          const SizedBox(width: 12),
                          // Shop Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.shopName ?? 'Shop',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.store,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Official Store',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Rating and Review Section
                  const Text(
                    'Rate & Review This Product',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Rating Stars
                  Center(
                    child: RatingBar.builder(
                      initialRating: myRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: GlobalVariables.secondaryColor,
                      ),
                      onRatingUpdate: updateRating,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Comment Input
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write your review...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  // Selected Images Preview
                  if (commentImages.isNotEmpty)
                    Container(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: commentImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 100,
                            child: Stack(
                              children: [
                                Image.file(
                                  commentImages[index],
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
                                        commentImages.removeAt(index);
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
                  // Comment Actions
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: selectImages,
                      ),
                      Expanded(
                        child: CustomButton(
                          text: 'Submit Review',
                          onTap: addComment,
                          color: GlobalVariables.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // View All Reviews Button
                  CustomButton(
                    text: 'View All Reviews & Comments',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        CommentScreen.routeName,
                        arguments: widget.product.id,
                      );
                    },
                    color: Colors.white,
                    textColor: GlobalVariables.selectedNavBarColor,
                  ),
                  const SizedBox(height: 16),
                  // Add to Cart Button
                  if (widget.product.quantity > 0)
                    CustomButton(
                      text: 'Add to Cart',
                      onTap: addToCartAndNavigate,
                      color: Colors.yellow[600],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
