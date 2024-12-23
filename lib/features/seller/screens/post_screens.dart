import 'dart:async';
import 'package:amazon_shop_on/common/widgets/bottom_bar.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/features/account/services/account_service.dart';
import 'package:amazon_shop_on/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:amazon_shop_on/features/seller/services/seller_services.dart';
import 'package:amazon_shop_on/models/product.dart';
import 'package:amazon_shop_on/features/seller/screens/add_product_screen.dart';
import 'package:amazon_shop_on/features/seller/screens/edit_product_screen.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PostsScreen extends StatefulWidget {
  static const String routeName = '/posts-screen';
  const PostsScreen({Key? key}) : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final SellerServices sellerServices = SellerServices();
  final AccountServices accountServices = AccountServices();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchAllProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.setLoading(true);
    
    try {
      final products = await sellerServices.fetchAllProducts(context);
      if (mounted) {
        productProvider.setProducts(products);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, e.toString());
      }
    }
    
    if (mounted) {
      productProvider.setLoading(false);
    }
  }

  void navigateToAddProduct() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final result = await Navigator.pushNamed(
      context,
      AddProductScreen.routeName,
      arguments: {
        'sellerId': userProvider.user.id,
      },
    );

    if (result == true) {
      fetchAllProducts();
    }
  }

  void navigateToEditProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    );

    if (result == true) {
      fetchAllProducts();
    }
  }

  void deleteProduct(Product product, int index) {
  final productProvider = Provider.of<ProductProvider>(context, listen: false);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Product'),
      content: const Text('Are you sure you want to delete this product?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            sellerServices.deleteProduct(
              context: context,
              product: product,
              onSuccess: () {
                // Sửa lại dòng này
                productProvider.removeProduct(product.id!); // Thêm dấu ! để xác nhận id không null
                showSnackBar(context, 'Product deleted successfully!');
              },
            );
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

  Widget _buildProductCard(Product product, int index) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showProductOptions(product, index),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.images[0],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error_outline),
                      );
                    },
                  ),
                  if (product.discount != null) ...[
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '-${product.discount!.percentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          productProvider.getDiscountTimeRemaining(product),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${product.finalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.discount != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'Stock: ${product.quantity}',
                    style: TextStyle(
                      color: product.quantity < 10
                          ? Colors.red
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiscountDialog(Product product) {
    final TextEditingController percentageController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    if (product.discount != null) {
      percentageController.text = product.discount!.percentage.toString();
      startDate = product.discount!.startDate;
      endDate = product.discount!.endDate;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Discount'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: percentageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Discount Percentage',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    startDate == null
                        ? 'Select Start Date'
                        : 'Start: ${DateFormat('yyyy-MM-dd').format(startDate!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => startDate = date);
                    }
                  },
                ),
                ListTile(
                  title: Text(
                    endDate == null
                        ? 'Select End Date'
                        : 'End: ${DateFormat('yyyy-MM-dd').format(endDate!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    if (startDate == null) {
                      showSnackBar(context, 'Please select start date first');
                      return;
                    }
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate!.add(const Duration(days: 1)),
                      firstDate: startDate!.add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => endDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (percentageController.text.isEmpty) {
                  showSnackBar(context, 'Please enter discount percentage');
                  return;
                }
                if (startDate == null) {
                  showSnackBar(context, 'Please select start date');
                  return;
                }
                if (endDate == null) {
                  showSnackBar(context, 'Please select end date');
                  return;
                }

                final percentage = double.tryParse(percentageController.text);
                if (percentage == null || percentage <= 0 || percentage > 100) {
                  showSnackBar(context, 'Please enter valid discount percentage (1-100)');
                  return;
                }

                Navigator.pop(context);
                
                try {
                  await sellerServices.setProductDiscount(
                    context: context,
                    product: product,
                    percentage: percentage,
                    startDate: startDate!,
                    endDate: endDate!,
                  );
                  
                  // Refresh products after setting discount
                  fetchAllProducts();
                } catch (e) {
                  showSnackBar(context, e.toString());
                }
              },
              child: const Text('Set Discount'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductOptions(Product product, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Product'),
            onTap: () {
              Navigator.pop(context);
              navigateToEditProduct(product);
            },
          ),
          ListTile(
            leading: const Icon(Icons.discount),
            title: const Text('Set Discount'),
            onTap: () {
              Navigator.pop(context);
              _showDiscountDialog(product);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Product', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              deleteProduct(product, index);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: GlobalVariables.appBarGradient,
                ),
              ),
              title: const Text(
                'My Products',
                style: TextStyle(color: Colors.black),
              ),
              actions: [
              PopupMenuButton(
                icon: const Icon(Icons.menu),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Add Product'),
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        Navigator.pop(context);
                        navigateToAddProduct();
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text('Go to Home'),
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          BottomBar.routeName,
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        Navigator.pop(context);
                        accountServices.logOut(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
            ),
          ),
          body: productProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productProvider.products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No products yet',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: navigateToAddProduct,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchAllProducts,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: productProvider.products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          return _buildProductCard(
                            productProvider.products[index],
                            index,
                          );
                        },
                      ),
                    ),
        );
      },
    );
  }
}