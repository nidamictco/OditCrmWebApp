import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class PageButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isLeft;
  final bool isRight;
  final VoidCallback onTap;

  const PageButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.isLeft = false,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: enabled ? AppColors.white : AppColors.background,
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.only(
            topLeft: isLeft ? const Radius.circular(4) : Radius.zero,
            bottomLeft: isLeft ? const Radius.circular(4) : Radius.zero,
            topRight: isRight ? const Radius.circular(4) : Radius.zero,
            bottomRight: isRight ? const Radius.circular(4) : Radius.zero,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.small(
            size: 11.sp,
            color: enabled ? AppColors.grey : AppColors.lightGrey,
          ),
        ),
      ),
    );
  }
}
