import 'package:flutter/material.dart';
import 'package:amazon_shop_on/common/widgets/custom_textfield.dart';
import 'package:amazon_shop_on/features/account/services/account_service.dart';

class SellerRequestDialog extends StatefulWidget {
  const SellerRequestDialog({Key? key}) : super(key: key);

  @override
  State<SellerRequestDialog> createState() => _SellerRequestDialogState();
}

class _SellerRequestDialogState extends State<SellerRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final AccountServices accountServices = AccountServices();

  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopDescriptionController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopDescriptionController.dispose();
    _addressController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await accountServices.requestSeller(
        context: context,
        shopName: _shopNameController.text,
        shopDescription: _shopDescriptionController.text,
        address: _addressController.text,
        avatarUrl: _avatarUrlController.text,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Request to Become a Seller',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CustomTextfield(
                  controller: _shopNameController,
                  hintText: 'Shop Name',
                  prefixIcon: const Icon(Icons.store, color: Colors.grey),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter shop name';
                    }
                    if (value.length < 3) {
                      return 'Shop name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextfield(
                  controller: _shopDescriptionController,
                  hintText: 'Shop Description',
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.description, color: Colors.grey),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter shop description';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextfield(
                  controller: _addressController,
                  hintText: 'Shop Address',
                  prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter shop address';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextfield(
                  controller: _avatarUrlController,
                  hintText: 'Shop Avatar URL',
                  prefixIcon: const Icon(Icons.image, color: Colors.grey),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter avatar URL';
                    }
                    if (!Uri.tryParse(value)!.isAbsolute) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
