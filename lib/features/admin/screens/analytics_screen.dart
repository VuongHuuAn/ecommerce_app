import 'package:flutter/material.dart';
import 'package:amazon_shop_on/features/admin/services/admin_service.dart';
import 'package:amazon_shop_on/features/admin/models/seller_stats.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AdminServices adminServices = AdminServices();
  bool isLoading = true;
  late SellerStats stats;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    setState(() {
      isLoading = true;
    });
    stats = await adminServices.getSellerStats(context);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: fetchStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatCard(
                      'Active Sellers',
                      stats.totalSellers,
                      Icons.store,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Pending Requests',
                      stats.pendingRequests,
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                    if (stats.totalSellers > 0 || stats.pendingRequests > 0) ...[
                      const SizedBox(height: 32),
                      const Text(
                        'Account Distribution',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: Colors.blue,
                                value: stats.totalSellers.toDouble(),
                                title: 'Sellers\n${stats.totalSellers}',
                                radius: 100,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PieChartSectionData(
                                color: Colors.orange,
                                value: stats.pendingRequests.toDouble(),
                                title: 'Pending\n${stats.pendingRequests}',
                                radius: 100,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}