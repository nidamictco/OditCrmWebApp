import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/staff_top_bar.dart';
import 'package:oxdo/core/utils/tool_tips.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:sizer/sizer.dart';

class FacebookSettings extends StatefulWidget {
  const FacebookSettings({super.key});

  @override
  State<FacebookSettings> createState() => _FacebookSettingsState();
}

class _FacebookSettingsState extends State<FacebookSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          StaffTopBar(
            title: 'Facebook Settings',
            parent: 'Settings',
            current: 'Facebook Settings',
          ),
          Padding(
            padding: EdgeInsets.all(2.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    /// TITLE
                    Center(
                      child: Text(
                        "Manage FB Settings",
                        style: AppTextStyle.medium(
                          size: 12.sp,
                          weight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    /// DESCRIPTION
                    Text(
                      "You have the option to connect your Facebook lead with our system to synchronize leads. Once connected, our system will automatically assign leads to the staff members and notification will send to staffs WhatsApp number. Along with you have the option to set up a welcome message or acknowledgment to be sent to customers.",
                      textAlign: TextAlign.start,
                      style: AppTextStyle.medium(weight: FontWeight.w400),
                    ),

                    SizedBox(height: 2.h),

                    /// LINK ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Lead test tool",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        // Icon(
                        //   Icons.help_outline,
                        //   size: 14.sp,
                        //   color: Colors.teal,
                        // ),
                        ToolTipWidget(
                          message:
                              'The lead test tool verify \nif your Facebook Lead settings \nare working correctly',
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    /// FACEBOOK LOGO
                    Center(
                      child: Icon(
                        Icons.facebook,
                        color: Colors.blue,
                        size: 32.sp,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    /// BUTTON
                    Center(
                      child: SizedBox(
                        height: 5.h,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D88FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                          ),
                          child: Text(
                            "Connect with Facebook",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// PROFESSIONAL FACEBOOK LOGO
  Widget _facebookLogo() {
    return Container(
      height: 12.h,
      width: 12.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF1877F2), Color(0xFF0A58CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          "f",
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}
