import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback? onSubmit;
  final VoidCallback? onClose;
  // final String submitText;

  const AppDialog({
    super.key,
    required this.title,
    required this.body,
    this.onSubmit,
    this.onClose,
    // this.submitText = "Submit",
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 500,
        color: AppColors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🔹 HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFD3E3EC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AppTextStyle.medium(size: 13.sp)),
                  InkWell(
                    onTap: onClose ?? () => Navigator.pop(context),
                    child: Icon(Icons.close, color: AppColors.black),
                  ),
                ],
              ),
            ),

            /// 🔹 BODY (Reusable)
            Padding(padding: EdgeInsets.all(2.w), child: body),

            /// 🔹 FOOTER
            Padding(
              padding: EdgeInsets.only(right: 2.w, bottom: 2.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  /// Close
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      padding: EdgeInsets.symmetric(
                        horizontal: 1.w,
                        vertical: 1.w,
                      ),
                    ),
                    onPressed: onClose ?? () => Navigator.pop(context),
                    child: Text(
                      "Close",
                      style: AppTextStyle.small(
                        size: 10.sp,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  SizedBox(width: 1.w),

                  /// Submit
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C5A8E),
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 1.w,
                      ),
                    ),
                    onPressed: onSubmit,
                    child: Text(
                      'Submit',
                      style: AppTextStyle.small(
                        size: 10.sp,
                        color: AppColors.white,
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
