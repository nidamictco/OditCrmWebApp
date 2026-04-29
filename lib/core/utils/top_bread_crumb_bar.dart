

import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/menu_hover_bottun.dart';
import 'package:sizer/sizer.dart';

class TopBreadcrumbBar extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool showMenu;

  const TopBreadcrumbBar({
    super.key,
    required this.title,
    required this.subTitle,
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /// LEFT SIDE (Breadcrumb)
          Row(
            children: [
              Text(
                title,
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
                subTitle,
                style: AppTextStyle.small(
                  size: 10.5.sp,
                  color: AppColors.grey,
                  weight: FontWeight.w400,
                ),
              ),
            ],
          ),

          /// RIGHT SIDE (Menu Button)
          if (showMenu) const MenuHoverButton(),
        ],
      ),
    );
  }
}