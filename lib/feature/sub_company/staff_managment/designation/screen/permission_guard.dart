// lib/core/utils/permission_guard.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class PermissionGuard extends StatelessWidget {
  final bool hasPermission;
  final Widget child;

  const PermissionGuard({
    super.key,
    required this.hasPermission,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (hasPermission) return child;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 30.sp, color: AppColors.grey),
            SizedBox(height: 2.h),
            Text(
              'Access Denied',
              style: AppTextStyle.heading(
                color: AppColors.black,
                weight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "You don't have permission to view this page.",
              style: AppTextStyle.body(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}