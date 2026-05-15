import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/inputfield_for_psswrd.dart';
import 'package:oxdo/core/utils/staff_top_bar.dart';
import 'package:sizer/sizer.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePasswordnew = true;
  bool _obscurePasswordConfirm = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaffTopBar(
            title: 'Change Password',
            parent: 'Staff Management',
            current: 'Change Password',
            parent2True: true,
            parent2: 'View Staff',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Container(
            width: 50.w,
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2.w, left: 2.w, right: 2.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Password',
                        style: AppTextStyle.medium(size: 12.sp),
                      ),
                      Container(
                        width: 12.w,
                        height: 0.1.h,
                        color: AppColors.black,
                      ),
                    ],
                  ),
                ),
                Container(height: 0.15.h, color: AppColors.divider),
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Row(
                    children: [
                        Expanded(
                          child: InputFieldForPsswrd(
                              label: "New Password",
                              hint: "Enter your new password",
                              controller: _passwordController,
                              showStar: true,
                            ),
                        ),
                      SizedBox(width: 1.w),
                        Expanded(
                          child: InputFieldForPsswrd(
                              label: "Confirm Password",
                              hint: "Confirm your new password",
                              controller: _confirmPasswordController,
                              showStar: true,
                            ),
                        ),
                    ],
                  ),
                ),
                // SizedBox(height: 1.h),
                Padding(
                  padding: EdgeInsets.only(right: 2.w, bottom: 2.w),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 1.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Change Password',
                        style: AppTextStyle.medium(
                          color: AppColors.white,
                          size: 11.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
