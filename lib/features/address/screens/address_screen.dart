import 'package:amazon_shop_on/common/widgets/custom_textfield.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/features/address/services/order_services.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';

class AddressScreen extends StatefulWidget {
  static const String routeName = '/address';
  final String totalAmount;
  const AddressScreen({super.key, required this.totalAmount});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController flatBuildingController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final _addressFormKey = GlobalKey<FormState>();
  final OrderServices orderServices = OrderServices();
  List<PaymentItem> paymentItems = [];

  final String defaultGooglePayConfigString = '''{
    "provider": "google_pay",
    "data": {
      "environment": "TEST",
      "apiVersion": 2,
      "apiVersionMinor": 0,
      "allowedPaymentMethods": [
        {
          "type": "CARD",
          "parameters": {
            "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
            "allowedCardNetworks": ["VISA", "MASTERCARD"]
          },
          "tokenizationSpecification": {
            "type": "PAYMENT_GATEWAY",
            "parameters": {
              "gateway": "example",
              "gatewayMerchantId": "exampleGatewayMerchantId"
            }
          }
        }
      ],
      "merchantInfo": {
        "merchantName": "Example Merchant"
      },
      "transactionInfo": {
        "totalPriceStatus": "FINAL",
        "totalPrice": "0.00",
        "currencyCode": "USD"
      }
    }
  }''';

  @override
  void initState() {
    super.initState();
    double amount = 0.0;
    try {
      amount = double.parse(widget.totalAmount);
    } catch (e) {
      print('Error parsing amount: $e');
    }

    paymentItems.add(
      PaymentItem(
        label: 'Total Amount',
        amount: amount.toStringAsFixed(2),
        status: PaymentItemStatus.final_price,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    flatBuildingController.dispose();
    areaController.dispose();
    pincodeController.dispose();
    cityController.dispose();
  }

  String _getAddress() {
    String address = Provider.of<UserProvider>(context, listen: false).user.address;
    if (address.isEmpty) {
      address = '${flatBuildingController.text}, ${areaController.text}, ${cityController.text} - ${pincodeController.text}';
    }
    return address;
  }

  void onGooglePayResult(dynamic paymentResult) {
    try {
      String address = _getAddress();
      double totalSum = double.parse(widget.totalAmount);

      orderServices.placeOrder(
        context: context,
        address: address,
        totalSum: totalSum,
      );

      showSnackBar(context, 'Order placed successfully!');
      Navigator.pop(context);
    } catch (e) {
      print('Error in payment: $e');
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var address = context.watch<UserProvider>().user.address;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (address.isNotEmpty)
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black12,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          address,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              Form(
                key: _addressFormKey,
                child: Column(
                  children: [
                    CustomTextfield(
                      controller: flatBuildingController,
                      hintText: 'Flat, House no. etc.',
                    ),
                    const SizedBox(height: 10),
                    CustomTextfield(
                      controller: areaController,
                      hintText: 'Area, Colony, Street etc.',
                    ),
                    const SizedBox(height: 10),
                    CustomTextfield(
                      controller: pincodeController,
                      hintText: 'Pin Code',
                    ),
                    const SizedBox(height: 10),
                    CustomTextfield(
                      controller: cityController,
                      hintText: 'City',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:'),
                        Text(
                          '\$${widget.totalAmount}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GooglePayButton(
                paymentConfiguration: PaymentConfiguration.fromJsonString(
                  defaultGooglePayConfigString,
                ),
                paymentItems: paymentItems,
                type: GooglePayButtonType.pay,
                margin: const EdgeInsets.only(top: 15.0),
                onPaymentResult: onGooglePayResult,
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
                width: double.infinity,
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}