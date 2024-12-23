import 'package:amazon_shop_on/common/widgets/loader.dart';
import 'package:amazon_shop_on/features/seller/services/seller_services.dart';
import 'package:amazon_shop_on/models/sales.dart';
import 'package:amazon_shop_on/features/seller/widgets/category_products_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final SellerServices sellerServices = SellerServices();
  double? totalEarnings;
  List<Sales>? sales;
  bool isLoading = true;
  String? error;
  bool showEarnings = true;

  @override
  void initState() {
    super.initState();
    getAnalytics();
  }

  Future<void> getAnalytics() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      var analyticsData = await sellerServices.getEarnings(context);
      setState(() {
        totalEarnings = analyticsData['totalEarnings'];
        sales = analyticsData['sales'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: Loader());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: getAnalytics,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: getAnalytics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Earnings Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Earnings',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${totalEarnings?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (sales != null && sales!.isNotEmpty) ...[
                // Chart Toggle Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      showEarnings ? 'Revenue by Category' : 'Quantity by Category',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(showEarnings ? 'Revenue' : 'Quantity'),
                        Switch(
                          value: showEarnings,
                          onChanged: (value) {
                            setState(() {
                              showEarnings = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Chart Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: PieChartAnalytics(
                      salesData: sales!,
                      showEarnings: showEarnings,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Category Details List
                const Text(
                  'Category Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sales!.length,
                  itemBuilder: (context, index) {
                    final sale = sales![index];
                    return Card(
                      child: ListTile(
                        title: Text(sale.category),
                        subtitle: Text('Quantity: ${sale.quantity}'),
                        trailing: Text(
                          '\$${sale.earning.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ] else
                const Center(
                  child: Text(
                    'No sales data available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
