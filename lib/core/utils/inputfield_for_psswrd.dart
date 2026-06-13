import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class InputFieldForPsswrd extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool showStar;
  const InputFieldForPsswrd({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.showStar = false,
  });

  @override
  State<InputFieldForPsswrd> createState() => _InputFieldForPsswrdState();
}

class _InputFieldForPsswrdState extends State<InputFieldForPsswrd> {
  bool _isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.label, style: AppTextStyle.medium()),
              if (widget.showStar)
                Text("*", style: AppTextStyle.medium(color: Colors.red)),
            ],
          ),
          SizedBox(height: 0.5.h),
          Container(
            height: 5.3.h,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(4),
              color: AppColors.greyCard,
            ),
            child: TextField(
              controller: widget.controller,
              style: AppTextStyle.body(size: 11.sp),
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColors.grey,
                    size: 12.6.sp,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                hintText: widget.hint,
                hintStyle: AppTextStyle.small(
                  size: 11.sp,
                  color: AppColors.grey,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(1.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
