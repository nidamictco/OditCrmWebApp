import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class StaffTopBar extends StatelessWidget {
  final String title;
  final String parent;
  final String current;

  const StaffTopBar({
    super.key,
    required this.title,
    required this.parent,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.6.h),
      decoration: BoxDecoration(
        color:  AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.7,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /// LEFT SIDE (TITLE)
          Text(
            title.toUpperCase(),
            style: AppTextStyle.medium(
              size: 12.sp,
              color: AppColors.black,
              weight: FontWeight.w700,
            ),
          ),

          /// RIGHT SIDE (BREADCRUMB)
          Row(
            children: [
               Text(
                parent,
                style: AppTextStyle.medium(
                  size: 11.sp,
                  color: AppColors.black,
                  weight: FontWeight.w600,
                ),
              ),

              SizedBox(width: 0.4.w),

              Icon(
                Icons.chevron_right,
                size: 14.sp,
                color: AppColors.grey,
              ),

              SizedBox(width: 0.4.w),

               Text(
                current,
                style: AppTextStyle.small(
                  size: 10.5.sp,
                  color: AppColors.grey,
                  weight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}