import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class WeekDaysRow extends StatelessWidget {
  const WeekDaysRow({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

    return Container(
      color: AppColors.grey.withOpacity(0.1),
      child: Row(
        children: days.map((day) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Center(
                child: Text(
                  day,
                  style: AppTextStyle.medium(weight: FontWeight.w600),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}