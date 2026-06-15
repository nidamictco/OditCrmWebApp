import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.cardBg,
    this.growth,
    this.growthLabel,
    this.statusLabel,
    this.statusColor,
    this.valueColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color cardBg;
  final double? growth;
  final String? growthLabel;
  final String? statusLabel;
  final Color? statusColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeColors.borderLight2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 14),
          // Title
          Text(title, style: AppTextStyles.statLabel),
          const SizedBox(height: 4),
          // Value
          Text(
            value,
            style: AppTextStyles.statValue.copyWith(
              color: valueColor ?? AppThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          // Bottom badge
          // if (growth != null)
          //   Row(
          //     children: [
          //       Icon(
          //         Icons.trending_up_rounded,
          //         size: 14,
          //         color: AppThemeColors.growthGreen,
          //       ),
          //       const SizedBox(width: 4),
          //       Text(
          //         '+${growth!.toStringAsFixed(1)}%',
          //         style: const TextStyle(
          //           fontSize: 12,
          //           fontWeight: FontWeight.w600,
          //           color: AppThemeColors.growthGreen,
          //         ),
          //       ),
          //     ],
          //   ),
          // if (statusLabel != null)
          //   Text(
          //     statusLabel!,
          //     style: TextStyle(
          //       fontSize: 12,
          //       fontWeight: FontWeight.w500,
          //       color: statusColor ?? AppThemeColors.growthGreen,
          //     ),
          //   ),
        ],
      ),
    );
  }
}
