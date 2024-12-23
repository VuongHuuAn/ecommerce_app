
import 'package:amazon_shop_on/common/widgets/custom_textfield.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/features/seller/services/seller_services.dart';
import 'package:amazon_shop_on/models/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiscountSettingsScreen extends StatefulWidget {
  static const String routeName = '/discount-settings';
  final Product product;

  const DiscountSettingsScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<DiscountSettingsScreen> createState() => _DiscountSettingsScreenState();
}

class _DiscountSettingsScreenState extends State<DiscountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final SellerServices sellerServices = SellerServices();
  final TextEditingController discountController = TextEditingController();
  
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;
  double previewPrice = 0;

  @override
  void initState() {
    super.initState();
    previewPrice = widget.product.price;
    if (widget.product.discount != null) {
      discountController.text = widget.product.discount!.percentage.toString();
      startDate = widget.product.discount!.startDate;
      endDate = widget.product.discount!.endDate;
      _calculatePreviewPrice();
    }
  }

  @override
  void dispose() {
    discountController.dispose();
    super.dispose();
  }

  void _calculatePreviewPrice() {
    if (discountController.text.isEmpty) {
      setState(() => previewPrice = widget.product.price);
      return;
    }

    try {
      double discount = double.parse(discountController.text);
      if (discount < 0 || discount > 100) {
        setState(() => previewPrice = widget.product.price);
        return;
      }

      double discountAmount = (widget.product.price * discount) / 100;
      setState(() => previewPrice = widget.product.price - discountAmount);
    } catch (e) {
      setState(() => previewPrice = widget.product.price);
    }
  }

  Future<void> handleSetDiscount() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (startDate == null || endDate == null) {
      showSnackBar(context, 'Please select both start and end dates');
      return;
    }

    setState(() => isLoading = true);

    try {
      await sellerServices.setProductDiscount(
        context: context,
        product: widget.product,
        percentage: double.parse(discountController.text),
        startDate: startDate!,
        endDate: endDate!,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: GlobalVariables.appBarGradient,
          ),
        ),
        title: const Text(
          'Discount Settings',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price Preview Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price Preview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '\$${widget.product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              decoration: previewPrice < widget.product.price
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: previewPrice < widget.product.price
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          if (previewPrice < widget.product.price) ...[
                            const SizedBox(width: 8),
                            Text(
                              '\$${previewPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Discount Input
                CustomTextfield(
                  controller: discountController,
                  hintText: 'Discount Percentage (0-100)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter discount percentage';
                    }
                    final number = double.tryParse(val);
                    if (number == null) {
                      return 'Please enter a valid number';
                    }
                    if (number < 0 || number > 100) {
                      return 'Percentage must be between 0 and 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Date Selection
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          startDate == null
                              ? 'Select Start Date'
                              : 'Start: ${DateFormat('MMM dd, yyyy').format(startDate!)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: isLoading
                            ? null
                            : () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null) {
                                  setState(() {
                                    startDate = date;
                                    if (endDate != null &&
                                        endDate!.isBefore(date)) {
                                      endDate = null;
                                    }
                                  });
                                }
                              },
                      ),
                      const Divider(height: 0),
                      ListTile(
                        title: Text(
                          endDate == null
                              ? 'Select End Date'
                              : 'End: ${DateFormat('MMM dd, yyyy').format(endDate!)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: isLoading || startDate == null
                            ? null
                            : () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      startDate!.add(const Duration(days: 1)),
                                  firstDate:
                                      startDate!.add(const Duration(days: 1)),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null) {
                                  setState(() => endDate = date);
                                }
                              },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Set Discount Button
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}