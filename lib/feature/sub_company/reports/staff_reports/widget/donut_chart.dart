import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DonutChart extends StatelessWidget {
  final Map<String, int> leadsByCategory;

  const DonutChart({super.key, required this.leadsByCategory});

  static const _categoryColors = <String, Color>{
    'New': Color(0xFF0085FF),
    'Follow-Up': Color(0xFF00B16E),
    'Follow Up': Color(0xFF00B16E),
    'Rejected': Color(0xFFEF4444),
    'Closed': Color(0xFF00B4D8),
    'Transferred': Color(0xFFF97316),
    'Pending': Color(0xFFF97316),
  };

  static const _defaultColors = [
    Color(0xFF0085FF),
    Color(0xFF00B16E),
    Color(0xFFEF4444),
    Color(0xFF00B4D8),
    Color(0xFFF97316),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = leadsByCategory.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    final allZero = total == 0;

    final List<PieChartSectionData> sections;

    if (allZero) {
      // Render single clean grey ring section when total is 0
      sections = [
        PieChartSectionData(
          value: 1,
          color: const Color(0xFFE2E8F0),
          radius: 20,
          showTitle: false,
        ),
      ];
    } else {
      sections = entries.asMap().entries.map((mapEntry) {
        final index = mapEntry.key;
        final entry = mapEntry.value;
        final color = _categoryColors[entry.key] ??
            _defaultColors[index % _defaultColors.length];

        return PieChartSectionData(
          value: entry.value == 0 ? 0.001 : entry.value.toDouble(),
          color: color,
          radius: 20,
          showTitle: false,
        );
      }).toList();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            startDegreeOffset: -90,
            sectionsSpace: 2,
            centerSpaceRadius: 42,
            sections: sections,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$total',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const Text(
              'Leads',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}