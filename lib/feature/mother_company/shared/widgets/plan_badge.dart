import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class PlanBadge extends StatelessWidget {
  const PlanBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppThemeColors.planBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyle.body(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppThemeColors.planText,
          letterSpacing: .6,
        ),
      ),
    );
  }
}
