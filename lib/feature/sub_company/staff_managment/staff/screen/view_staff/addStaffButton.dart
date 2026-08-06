import 'package:Odit_CRM/core/router/browser_aware_link.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AddNewStaffButton extends StatefulWidget {
  const AddNewStaffButton({super.key});

  @override
  State<AddNewStaffButton> createState() => _AddNewStaffButtonState();
}

class _AddNewStaffButtonState extends State<AddNewStaffButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 7.5.w,
      height: 4.5.h,
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovering = true),
        onExit: (_) => setState(() => isHovering = false),
        child: BrowserAwareLink(
          destination: RoutePaths.addStaff,
          usePush: false,
          enableInkWell: false,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: 5.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppThemeColors.basicGreen,
                width: 0.02.w,
              ),
              color: isHovering
                  ? AppThemeColors.basicGreen
                  : AppThemeColors.basicGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                "Add Staff",
                style: AppTextStyle.small(
                  color: Colors.white,
                  // color: isHovering ? Colors.white : AppThemeColors.basicGreen,
                  size: 10.sp,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
