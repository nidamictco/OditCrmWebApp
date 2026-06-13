
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/theme/asset_resources.dart';
import 'package:oxdo/feature/sub_company/sidebar/widget/hover/sidebar_hover.dart';
import 'package:oxdo/feature/sub_company/staff_managment/designation/cubit/cubit/permission_cubit.dart';
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
    final perm = context.watch<PermissionCubit>();
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

          /// DASHBOARD — non-expandable, direct tap
          HoverSidebarItem(
            icon: Icons.dashboard,
            title: "Dashboard",
            isExpandable: false,
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),

          /// LEAD MANAGEMENT
          HoverSidebarItem(
            icon: Icons.phone,
            title: "Lead Management",
            isExpandable: true,
            children: [
              if(perm.canAddLead)"Add Lead",
             if(perm.canViewLeadsReport) "Leads Report",
              if (perm.canImportLeads) 'Import Leads',
             if (perm.canViewDeletedLeads) 'Deleted Leads',
              // "Call History",
              // 'Unassigned Leads',
             if (perm.canTransferLeads || perm.canViewTransferLeads) "Transfer Leads",
              // "Phone Call Log",
            ],
            isSelected: _isGroupSelected([1, 2, 14, 4 /*,3*/, 13, 5 /*6*/]),
            onItemTap: (index) {
              const map = [1, 2, 14, 4 /*,3*/, 13, 5 /*6*/];
              onItemSelected(map[index]);
            },
          ),

          /// SETTINGS — non-expandable, direct tap
          if (perm.canViewGeneralSettings) HoverSidebarItem(
            icon: Icons.settings,
            title: "Settings",
            isExpandable: false,
            isSelected: _isGroupSelected([20 /*21*/]),
            onTap: () => onItemSelected(20),
          ),

          /// STAFF MANAGEMENT
          if(perm.canAddStaff || perm.canViewStaff || perm.canViewDesignation || perm.canViewDeletedStaff)
          HoverSidebarItem(
            icon: Icons.person,
            title: "Staff Management",
            isExpandable: true,
            children: [
              if (perm.canAddStaff)  "Add Staff",
              if (perm.canViewStaff) "View Staff",
             if (perm.canViewDesignation) "Designations",
             if (perm.canViewDeletedStaff) "Deleted Staff",
            ],
            isSelected: _isGroupSelected([15, 16, 17, 18]),
            onItemTap: (index) {
              const map = [15, 16, 17, 18];
              onItemSelected(map[index]);
            },
          ),

          // /// FILES MANAGEMENT
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

          /// REPORTS
          if(perm.canViewStaffReport || perm.canViewTransferReport || perm.canViewTotalReport || perm.canViewRejectedReport)
          HoverSidebarItem(
            icon: Icons.file_copy,
            title: "Reports",
            isExpandable: true,
            children: [
              if (perm.canViewStaffReport) "Staff Report",
              if (perm.canViewTransferReport) "Transfer Leads Reports",
              if (perm.canViewTotalReport)"Total Leads Reports",
              // "Scheduled Leads Reports",
             if (perm.canViewRejectedReport)"Rejected leads Reports",
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