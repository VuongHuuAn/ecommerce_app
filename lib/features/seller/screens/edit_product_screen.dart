import 'package:amazon_shop_on/common/widgets/custom_button.dart';
import 'package:amazon_shop_on/common/widgets/custom_textfield.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/features/seller/services/seller_services.dart';
import 'package:amazon_shop_on/models/product.dart';
import 'package:amazon_shop_on/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/edit-product';
  final Product product;

  const EditProductScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final SellerServices sellerServices = SellerServices();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    productNameController.text = widget.product.name;
    descriptionController.text = widget.product.description;
    priceController.text = widget.product.price.toString();
    quantityController.text = widget.product.quantity.toString();
  }

  @override
  void dispose() {
    productNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<void> handleUpdateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      // Create updated product
      final updatedProduct = Product(
        id: widget.product.id,
        name: productNameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.parse(priceController.text),
        quantity: int.parse(quantityController.text),
        category: widget.product.category,
        images: widget.product.images,
        sellerId: widget.product.sellerId,
      );

      // Call API first
      await sellerServices.updateProduct(
        context: context,
        product: widget.product,
        name: productNameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.parse(priceController.text),
        quantity: int.parse(quantityController.text),
        category: widget.product.category,
        images: widget.product.images,
        newImages: [],
      );

      // If API call successful, update UI
      productProvider.updateProduct(updatedProduct);

      if (!mounted) return;
      showSnackBar(context, 'Product updated successfully!');
      
      // Pop without WillPopScope
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
          title: const Text(
            'Edit Product',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      widget.product.images[0],
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextfield(
                    controller: productNameController,
                    hintText: 'Product Name',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomTextfield(
                    controller: descriptionController,
                    hintText: 'Description',
                    maxLines: 7,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomTextfield(
                    controller: priceController,
                    hintText: 'Price',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter price';
                      }
                      if (double.tryParse(val) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(val) <= 0) {
                        return 'Price must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomTextfield(
                    controller: quantityController,
                    hintText: 'Quantity',
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter quantity';
                      }
                      if (int.tryParse(val) == null) {
                        return 'Please enter a valid number';
                      }
                      if (int.parse(val) < 0) {
                        return 'Quantity cannot be negative';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Update Product',
                    onTap: handleUpdateProduct,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}