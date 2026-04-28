import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:login_2_it_solution/feature/sidebar/widget/hover/sidebar_hover.dart';
import 'package:sizer/sizer.dart';

class MiniSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const MiniSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: 02.h),

          /// LOGO
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.5.sp),
            child: Text(
              "Oxdo",
              style: AppTextStyle.heading(size: 11.sp, weight: FontWeight.w700),
            ),
          ),

          SizedBox(height: 5.h),

          /// DASHBOARD
          HoverSidebarItem(
            icon: Icons.dashboard,
            title: "Dashboard",
            onTap: () => onItemSelected(0),
          ),

          /// LEAD MANAGEMENT
          HoverSidebarItem(
            icon: Icons.phone,
            title: "Lead Management",
            isExpandable: true,
            children: [
              "Dashboard",
              "Add Lead",
              "Leads Report",
              "Call History",
              "Transfer Leads",
              "Phone Call Log",
            ],
            onItemTap: (index) => onItemSelected(index + 1),
          ),
        ],
      ),
    );
  }
}
