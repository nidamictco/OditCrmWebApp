import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';

import 'package:google_fonts/google_fonts.dart';

class PricingSummaryCard extends StatelessWidget {
  final double planPrice;
  final double addonPrice;
  final double discount;
  final double total;

  const PricingSummaryCard({
    super.key,
    required this.planPrice,
    required this.addonPrice,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xff0F172A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "Pricing Summary",
            style: AppTextStyle.body(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 24),

          _row("Plan", planPrice),

          const SizedBox(height: 12),

          _row("Add-ons", addonPrice),

          const SizedBox(height: 12),

          _row("Discount", -discount),

          const Divider(
            color: Colors.white24,
            height: 32,
          ),

          _row(
            "Total",
            total,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _row(
      String label,
      double value, {
        bool bold = false,
      }) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyle.body(
            color: Colors.white70,
            fontWeight:
            bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),

        const Spacer(),

        Text(
          "\$${value.toStringAsFixed(0)}",
          style: AppTextStyle.body(
            color: Colors.white,
            fontSize: bold ? 18 : 15,
            fontWeight:
            bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
