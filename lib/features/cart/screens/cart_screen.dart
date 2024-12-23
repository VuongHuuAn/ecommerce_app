import 'package:amazon_shop_on/common/widgets/custom_button.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/features/address/screens/address_screen.dart';
import 'package:amazon_shop_on/features/cart/screens/services/cart_services.dart';

import 'package:amazon_shop_on/features/home/widgets/address_box.dart';
import 'package:amazon_shop_on/features/search/screens/search_screen.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = '/cart';
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CartServices cartServices = CartServices(); // Thêm CartServices

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void navigateToSearchScreen(String query) {
    if (query.trim().isNotEmpty) {
      Navigator.pushNamed(context, SearchScreen.routeName, arguments: query);
    }
  }

  void navigateToAddress(double sum) {
    if (sum > 0) {
      Navigator.pushNamed(context, AddressScreen.routeName,
          arguments: sum.toString());
    } else {
      showSnackBar(context, 'Cart is empty or items have invalid prices');
    }
  }

  double calculateTotal(List<dynamic> cart) {
    double sum = 0;
    for (var item in cart) {
      final product = item['product'];
      final quantity = item['quantity'] as int;
      final price = product['finalPrice'] ?? product['price'];
      sum += (price as num) * quantity;
    }
    return sum;
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  margin: const EdgeInsets.only(left: 15),
                  child: Material(
                    borderRadius: BorderRadius.circular(7),
                    elevation: 1,
                    child: TextFormField(
                      controller: _searchController,
                      onFieldSubmitted: navigateToSearchScreen,
                      decoration: InputDecoration(
                        prefixIcon: InkWell(
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.search,
                                color: Colors.black, size: 23),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(top: 10),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          borderSide:
                              BorderSide(color: Colors.black38, width: 1),
                        ),
                        hintText: 'Search Amazon.in',
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.transparent,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: const Icon(Icons.mic, color: Colors.black, size: 25),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final cart = userProvider.user.cart;

          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }

          final total = calculateTotal(cart);

          return SingleChildScrollView(
            child: Column(
              children: [
                const AddressBox(),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Text(
                        'Subtotal ',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButton(
                    text: 'Proceed to Buy (${cart.length} items)',
                    onTap: () => navigateToAddress(total),
                    color: Colors.yellow[600],
                  ),
                ),
                const SizedBox(height: 15),
                ListView.builder(
                  itemCount: cart.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    final product = item['product'];
                    final quantity = item['quantity'] as int;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Image.network(
                            product['images'][0],
                            fit: BoxFit.contain,
                            height: 135,
                            width: 135,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                      ),
                                      Text(
                                        '\$${(product['finalPrice'] ?? product['price']).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text('Eligible for FREE Shipping'),
                                      const Text(
                                        'In Stock',
                                        style: TextStyle(
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black12,
                                            width: 1.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.black12,
                                        ),
                                        child: Row(
                                          children: [
                                            // Nút giảm số lượng với chức năng xóa
                                            InkWell(
                                              onTap: () {
                                                print(
                                                    'Current quantity: $quantity');
                                                if (quantity > 1) {
                                                  userProvider
                                                      .updateCartItemQuantity(
                                                    product['_id'],
                                                    quantity - 1,
                                                  );
                                                } else {
                                                  print(
                                                      'Deleting product: ${product['_id']}');
                                                  cartServices.deleteFromCart(
                                                    context: context,
                                                    productId: product['_id'],
                                                  );
                                                }
                                              },
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
                                            Container(
                                              width: 35,
                                              height: 32,
                                              color: Colors.white,
                                              alignment: Alignment.center,
                                              child: Text(
                                                quantity.toString(),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                userProvider
                                                    .updateCartItemQuantity(
                                                  product['_id'],
                                                  quantity + 1,
                                                );
                                              },
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
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
