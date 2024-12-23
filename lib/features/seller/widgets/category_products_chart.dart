import 'package:amazon_shop_on/models/sales.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartAnalytics extends StatelessWidget {
  final List<Sales> salesData;
  final bool showEarnings;

  const PieChartAnalytics({
    Key? key,
    required this.salesData,
    required this.showEarnings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.5,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: showEarnings
                  ? _generateEarningsSections()
                  : _generateQuantitySections(),
              pieTouchData: PieTouchData(enabled: true),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: salesData.asMap().entries.map((entry) {
        final color = _getColor(entry.key);
        final value = showEarnings
            ? '\$${entry.value.earning.toStringAsFixed(2)}'
            : '${entry.value.quantity} items';

        return Container(
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${entry.value.category}: $value',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<PieChartSectionData> _generateEarningsSections() {
    final total = salesData.fold<double>(0, (sum, item) => sum + item.earning);
    return _generateSections(
      total: total,
      getValue: (item) => item.earning,
      getLabel: (value) => '\$${value.toStringAsFixed(0)}',
    );
  }

  List<PieChartSectionData> _generateQuantitySections() {
    final total = salesData.fold<int>(0, (sum, item) => sum + item.quantity);
    return _generateSections(
      total: total.toDouble(),
      getValue: (item) => item.quantity.toDouble(),
      getLabel: (value) => '${value.toInt()}',
    );
  }

  List<PieChartSectionData> _generateSections({
    required double total,
    required double Function(Sales) getValue,
    required String Function(double) getLabel,
  }) {
    return salesData.asMap().entries.map((entry) {
      final value = getValue(entry.value);
      final percentage = (value / total * 100);

      return PieChartSectionData(
        color: _getColor(entry.key),
        value: value,
        title: '${percentage.toStringAsFixed(1)}%\n${getLabel(value)}',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  Color _getColor(int index) {
    final colors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFFF44336), // Red
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF009688), // Teal
      const Color(0xFFE91E63), // Pink
      const Color(0xFFFFC107), // Amber
    ];
    return colors[index % colors.length];
  }
}
