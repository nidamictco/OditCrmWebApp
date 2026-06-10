import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _iconButton(Icons.chevron_left),
            SizedBox(width: 1.w),
            _iconButton(Icons.chevron_right),
            SizedBox(width: 2.w),
            _todayButton(),
          ],
        ),

        Text(
          "APRIL 2026",
          style: AppTextStyle.heading(weight: FontWeight.w600),
        ),

        Row(
          children: [
            _viewButton("Month", true),
            _viewButton("Week", false),
            _viewButton("Day", false),
          ],
        )
      ],
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 14.sp),
    );
  }

  Widget _todayButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text("Today", style: AppTextStyle.small()),
    );
  }

  Widget _viewButton(String text, bool active) {
    return Container(
      margin: EdgeInsets.only(left: 1.w),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyle.small(
          color: active ? Colors.white : AppColors.black,
        ),
      ),
    );
  }
}