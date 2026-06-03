import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/menu_hover_bottun.dart';
import 'package:sizer/sizer.dart';

class TopBreadcrumbBar extends StatelessWidget {
  final String title;
  final String subTitle;
  final String? subTitle2;
  final VoidCallback? onPressed;
  final bool showMenu;
  final bool show2ndTitle;

  const TopBreadcrumbBar({
    super.key,
    required this.title,
    required this.subTitle,
    this.subTitle2,
    this.onPressed,
    this.showMenu = true,
    this.show2ndTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
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

              if (show2ndTitle == true)
                Row(
                  children: [
                    Icon(
                      Icons.chevron_right,
                      size: 14.sp,
                      color: AppColors.grey,
                    ),

                    SizedBox(width: 0.4.w),

                    TextButton(
                      // onPressed: () {
                      //   Navigator.pop(context);
                      // },
                      onPressed: onPressed ?? () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        subTitle2!,
                        style: AppTextStyle.small(
                          size: 10.5.sp,
                          color: AppColors.grey,
                          weight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),

              Icon(Icons.chevron_right, size: 14.sp, color: AppColors.grey),

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

          SizedBox(width: 2.w),

          /// RIGHT SIDE (Menu Button)
          if (showMenu) const MenuHoverButton(),
        ],
      ),
    );
  }
}
