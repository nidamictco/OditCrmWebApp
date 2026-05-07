import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/feature/sidebar/widget/hover/sidebar_hover.dart';
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
            child: Center(
              child: Text(
                "Oxdo Leads",
                style: AppTextStyle.heading(
                  size: 11.sp,
                  weight: FontWeight.w700,
                ),
              ),
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
              "Add Lead",
              "Leads Report",
              "Call History",
              "Transfer Leads",
              "Phone Call Log",
            ],
            onItemTap: (index) => onItemSelected(index + 1),
          ),

          /// LEAD MANAGEMENT
          HoverSidebarItem(
            icon: Icons.settings,
            title: "Settings",
            isExpandable: true,
            children: ["General Settings", "Facebook Settings"],
            onItemTap: (index) => onItemSelected(index + 1),
          ),

          /// LEAD MANAGEMENT
          HoverSidebarItem(
            icon: Icons.person,
            title: "Staff Management",
            isExpandable: true,
            children: [
              "Add Staff",
              "View Staff",
              "Designations",
              "Deleted Staff",
            ],
            onItemTap: (index) => onItemSelected(index + 1),
          ),

          /// LEAD MANAGEMENT
          HoverSidebarItem(
            icon: Icons.folder,
            title: "Files Manager",
            isExpandable: true,
            children: ["View"],
            onItemTap: (index) => onItemSelected(index + 1),
          ),

          /// LEAD MANAGEMENT
          HoverSidebarItem(
            icon: Icons.file_copy,
            title: "Reports",
            isExpandable: true,
            children: [
              "Staff Report",
              "Transfer Leads Reports",
              "Total Leads Reports",
              "Scheduled Leads Reports",
              "Rejected leads Reports",
            ],
            onItemTap: (index) => onItemSelected(index + 1),
          ),
        ],
      ),
    );
  }
}
