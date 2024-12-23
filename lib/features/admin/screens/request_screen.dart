import 'package:flutter/material.dart';
import 'package:amazon_shop_on/models/seller_request.dart';
import 'package:amazon_shop_on/features/admin/services/admin_service.dart';
import 'package:intl/intl.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({Key? key}) : super(key: key);

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final AdminServices adminServices = AdminServices();
  List<SellerRequest> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    setState(() {
      isLoading = true;
    });
    requests = await adminServices.fetchSellerRequests(context);
    setState(() {
      isLoading = false;
    });
  }

  void processRequest(String requestId, String status) async {
    try {
      await adminServices.processSellerRequest(
        context: context,
        requestId: requestId,
        status: status,
        onSuccess: () {
          fetchRequests();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Request $status successfully')),
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
        : requests.isEmpty
            ? const Center(child: Text('No pending requests'))
            : RefreshIndicator(
                onRefresh: fetchRequests,
                child: ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(request.avatarUrl),
                          onBackgroundImageError: (_, __) => 
                              const Icon(Icons.error),
                        ),
                        title: Text(request.shopName),
                        subtitle: Text(
                          'Requested: ${DateFormat.yMMMd().format(request.createdAt)}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: const Text('Shop Description'),
                                  subtitle: Text(request.shopDescription),
                                ),
                                ListTile(
                                  title: const Text('Address'),
                                  subtitle: Text(request.address),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: 
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => processRequest(
                                          request.id, 'approved'),
                                      icon: const Icon(Icons.check),
                                      label: const Text('Approve'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => processRequest(
                                          request.id, 'rejected'),
                                      icon: const Icon(Icons.close),
                                      label: const Text('Reject'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
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