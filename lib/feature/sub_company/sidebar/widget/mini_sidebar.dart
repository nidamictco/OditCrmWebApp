import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/theme/asset_resources.dart';
import 'package:oxdo/feature/sub_company/sidebar/widget/hover/sidebar_hover.dart';
import 'package:sizer/sizer.dart';

class MiniSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const MiniSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  bool _isGroupSelected(List<int> indices) => indices.contains(selectedIndex);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: 3.h),

          /// LOGO
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.5.sp),
            child: Center(
              child: SizedBox(
                height: 5.h,
                width: 5.h,
                child: Image.asset(AssetResources.iconLogo),
              ),
            ),
          ),

          SizedBox(height: 5.h),

          /// DASHBOARD
          HoverSidebarItem(
            icon: Icons.dashboard,
            title: "Dashboard",
            isExpandable: true,
            children: ["Dashboard"],
            isSelected: selectedIndex == 0,
            onItemTap: (Index) => onItemSelected(0),
          ),

          /// LEAD MANAGEMENT
          HoverSidebarItem(
            icon: Icons.phone,
            title: "Lead Management",
            isExpandable: true,
            children: [
              "Add Lead",
              "Leads Report",
              'Import Leads',
              'Deleted Leads',
              // "Call History",
              'Unassigned Leads',
              "Transfer Leads",
              // "Phone Call Log",
            ],
            isSelected: _isGroupSelected([1, 2, 14, 4 /*,3*/, 13, 5 /*6*/]),
            onItemTap: (index) {
              const map = [1, 2, 14, 4 /*,3*/, 13, 5 /*6*/];
              onItemSelected(map[index]);
            },
          ),

          /// SETTINGS
          HoverSidebarItem(
            icon: Icons.settings,
            title: "Settings",
            isExpandable: true,
            children: ["General Settings" /*"Facebook Settings"*/],
            isSelected: _isGroupSelected([20 /*21*/]),
            onItemTap: (index) {
              const map = [20 /*21*/];
              onItemSelected(map[index]);
            },
          ),

          /// STAFF MANAGEMENT
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
            isSelected: _isGroupSelected([15, 16, 17, 18]),
            onItemTap: (index) {
              const map = [15, 16, 17, 18];
              onItemSelected(map[index]);
            },
          ),

          // /// FILES  MANAGEMENT
          // HoverSidebarItem(
          //   icon: Icons.folder,
          //   title: "Files Manager",
          //   isExpandable: true,
          //   children: ["View"],
          //   isSelected: _isGroupSelected([19]),
          //   onItemTap: (index) {
          //     const map = [19];
          //     onItemSelected(map[index]);
          //   },
          // ),

          /// reports
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
            isSelected: _isGroupSelected([22, 23, 2, 24, 25]),
            onItemTap: (index) {
              const map = [22, 23, 2, 24, 25];
              onItemSelected(map[index]);
            },
          ),
        ],
      ),
    );
  }
}
