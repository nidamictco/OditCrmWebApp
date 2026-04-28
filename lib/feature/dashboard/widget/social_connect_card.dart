import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';

class SocialConnectCard extends StatelessWidget {
  final String title;
  final String buttonText;
  final Color buttonColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? ontap;

  const SocialConnectCard({
    super.key,
    required this.title,
    required this.buttonText,
    required this.buttonColor,
    required this.icon,
    required this.iconColor,
    this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP LABEL
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
            decoration: BoxDecoration(color: const Color(0xFFF4E7D6)),
            child: Text(
              title,
              style: AppTextStyle.small(color: Colors.brown, size: 11.sp),
            ),
          ),

          SizedBox(height: 2.h),

          /// CONTENT ROW
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFFF3DAD3),
                  child: Icon(icon, color: iconColor, size: 16.sp),
                ),

                SizedBox(width: 2.w),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Auto-assign leads to staff and stay ahead of the game ",
                          style: AppTextStyle.medium(size: 11.5.sp),
                        ),
                        Icon(Icons.arrow_forward, size: 12.6.sp),
                      ],
                    ),
                    SizedBox(height: 1.h),

                    /// BUTTON
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 1.2.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: ontap ?? () {},
                      child: Text(
                        buttonText,
                        style: AppTextStyle.small(
                          color: Colors.white,
                          size: 11.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
