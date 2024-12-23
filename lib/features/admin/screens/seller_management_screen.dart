import 'package:flutter/material.dart';
import 'package:amazon_shop_on/models/user.dart';
import 'package:amazon_shop_on/features/admin/services/admin_service.dart';

class SellerManagementScreen extends StatefulWidget {
  const SellerManagementScreen({Key? key}) : super(key: key);

  @override
  State<SellerManagementScreen> createState() => _SellerManagementScreenState();
}

class _SellerManagementScreenState extends State<SellerManagementScreen> {
  final AdminServices adminServices = AdminServices();
  List<User> sellers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSellers();
  }

  Future<void> fetchSellers() async {
    setState(() {
      isLoading = true;
    });
    sellers = await adminServices.fetchSellers(context);
    setState(() {
      isLoading = false;
    });
  }

  void disableSeller(String sellerId, String shopName) async {
    try {
      await adminServices.disableSeller(
        context: context,
        sellerId: sellerId,
        onSuccess: () {
          fetchSellers();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$shopName has been disabled'),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : sellers.isEmpty
            ? const Center(child: Text('No sellers found'))
            : RefreshIndicator(
                onRefresh: fetchSellers,
                child: ListView.builder(
                  itemCount: sellers.length,
                  itemBuilder: (context, index) {
                    final seller = sellers[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(seller.shopAvatar),
                          onBackgroundImageError: (_, __) => 
                              const Icon(Icons.error),
                        ),
                        title: Text(seller.shopName),
                        subtitle: Text(seller.email),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: const Text('Shop Description'),
                                  subtitle: Text(seller.shopDescription),
                                ),
                                ListTile(
                                  title: const Text('Followers'),
                                  subtitle: Text(seller.followers.length.toString()),
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Disable Seller'),
                                        content: Text(
                                          'Are you sure you want to disable ${seller.shopName}?'
                                          '\nThis will convert their account to a regular user.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              disableSeller(
                                                  seller.id, seller.shopName);
                                            },
                                            child: const Text(
                                              'Disable',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    icon: const Icon(Icons.block),
                                    label: const Text('Disable Seller'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
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
              );
  }
}