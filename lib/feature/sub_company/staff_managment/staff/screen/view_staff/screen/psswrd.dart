import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/inputfield_for_psswrd.dart';
import 'package:oxdo/core/utils/staff_top_bar.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/cubit/add_staff_state.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/model/staff_model.dart';
import 'package:sizer/sizer.dart';

class ChangePasswordScreen extends StatefulWidget {
  final StaffModel staff; 
  const ChangePasswordScreen({super.key, required this.staff});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // ─── Validation ───────────────────────────
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnack('Please fill in both fields.', Colors.red);
      return;
    }

    if (newPassword.length < 6) {
      _showSnack('Password must be at least 6 characters.', Colors.red);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnack('Passwords do not match.', Colors.red);
      return;
    }

    if (widget.staff.id == null) {
      _showSnack('Staff ID not found.', Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    // update only the password field in Firestore
    context.read<StaffCubit>().updateStaffField(
      widget.staff.id!,
      {'password': newPassword},
    );
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffCubit, StaffState>(
      listener: (context, state) {
        if (state is StaffLoaded) {
          setState(() => _isSaving = false);
          _passwordController.clear();
          _confirmPasswordController.clear();
          _showSnack('Password changed successfully.', Colors.green);
        }
        if (state is StaffError) {
          setState(() => _isSaving = false);
          _showSnack(state.message, Colors.red);
        }
      },
      child: Scaffold(
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
              onPressed: () => Navigator.pop(context),
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
                    padding: EdgeInsets.only(
                      top: 2.w,
                      left: 2.w,
                      right: 2.w,
                    ),
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
                            label: 'New Password',
                            hint: 'Enter your new password',
                            controller: _passwordController,
                            showStar: true,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: InputFieldForPsswrd(
                            label: 'Confirm Password',
                            hint: 'Confirm your new password',
                            controller: _confirmPasswordController,
                            showStar: true,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                        onPressed: _isSaving ? null : _changePassword,
                        child: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
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
      ),
    );
  }
}