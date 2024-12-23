import 'dart:io';
import 'package:amazon_shop_on/common/widgets/custom_button.dart';
import 'package:amazon_shop_on/common/widgets/custom_textfield.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/features/seller/services/seller_services.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddProductScreen extends StatefulWidget {
  static const String routeName = '/add-product';
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final SellerServices sellerServices = SellerServices();

  final _addProductFormKey = GlobalKey<FormState>();
  bool isLoading = false;
  List<File> images = [];

  final List<String> productCategories = [
    'Fashion',
    'Mobiles',
    'Essentials',
    'Appliances',
    'Books',
    'Electronics'
  ];
  String category = 'Fashion';

  @override
  void dispose() {
    super.dispose();
    productNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
  }

  void sellProduct() {
    if (_addProductFormKey.currentState!.validate() && images.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      sellerServices.sellProduct(
        context: context,
        name: productNameController.text,
        description: descriptionController.text,
        price: double.parse(priceController.text),
        quantity: int.parse(quantityController.text),
        category: category,
        images: images,
        sellerId: userProvider.user.id,
      );
    } else if (images.isEmpty) {
      showSnackBar(context, 'Please select at least one image');
    }
  }

  void selectImages() async {
    var res = await pickImages();
    setState(() {
      images = res;
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
          title: const Text(
            'Add Product',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _addProductFormKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                images.isNotEmpty
                    ? CarouselSlider(
                        items: images.map(
                          (i) {
                            return Builder(
                              builder: (BuildContext context) => Image.file(
                                i,
                                fit: BoxFit.cover,
                                height: 200,
                              ),
                            );
                          },
                        ).toList(),
                        options: CarouselOptions(
                          viewportFraction: 1,
                          height: 200,
                        ),
                      )
                    : GestureDetector(
                        onTap: selectImages,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black38),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.folder_open, size: 40),
                              const SizedBox(height: 15),
                              Text(
                                'Select Product Images',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 30),
                CustomTextfield(
                  controller: productNameController,
                  hintText: 'Product Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextfield(
                  controller: priceController,
                  hintText: 'Price',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    try {
                      double price = double.parse(value);
                      if (price <= 0) {
                        return 'Price must be greater than 0';
                      }
                    } catch (e) {
                      return 'Please enter valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextfield(
                  controller: quantityController,
                  hintText: 'Quantity',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    try {
                      int quantity = int.parse(value);
                      if (quantity <= 0) {
                        return 'Quantity must be greater than 0';
                      }
                    } catch (e) {
                      return 'Please enter valid quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black38,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButton(
                    value: category,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    iconSize: 32,
                    elevation: 4,
                    underline: Container(height: 0),
                    isExpanded: true,
                    items: productCategories.map((String item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (String? newVal) {
                      setState(() {
                        category = newVal!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Sell',
                  onTap: sellProduct,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}