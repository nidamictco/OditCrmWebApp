
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DonutChart extends StatelessWidget {
  final Map<String, int> leadsByCategory;

  const DonutChart({required this.leadsByCategory});

  static const _colors = [
    Color(0xFF4F6BED), // New
    Color(0xFF7BC96F), // Follow Up
    Color(0xFFF87171), // Rejected
    Color(0xFF38B2AC), // Closed
    Color(0xFFECC94B), // Pending
    Color(0xFF9F7AEA), // fallback
  ];

  @override
  Widget build(BuildContext context) {
    final entries = leadsByCategory.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    // Build sections dynamically from leadsByCategory
    final sections = entries.asMap().entries.map((mapEntry) {
      final index = mapEntry.key;
      final entry = mapEntry.value;
      final isNoData = entry.key == 'No Data';

      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: isNoData
            ? Colors.grey.shade300
            : _colors[index % _colors.length],
        radius: 22,
        showTitle: false,
      );
    }).toList();

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            startDegreeOffset: -90,
            sectionsSpace: 2,
            centerSpaceRadius: 45,
            sections: sections, // ← now dynamic
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$total',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Total\nLeads',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.2,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ],
    );
  }
}