import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.5.h,
      color: Colors.white,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Text(
        "Design & Develop by Mictco Creations",
        style: AppTextStyle.medium(
          size: 11.sp,
          weight: FontWeight.w400,
          color: AppColors.grey,
        ),
      ),
    );
  }
}
