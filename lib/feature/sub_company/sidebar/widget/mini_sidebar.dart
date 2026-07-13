import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:Odit_CRM/feature/sub_company/sidebar/widget/hover/sidebar_hover.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/cubit/permition_cubit/permission_cubit.dart';
import 'package:Odit_CRM/feature/auth/cubit/auth/auth_cubit.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sizer/sizer.dart';

class MiniSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onBackArrowTap;

  const MiniSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onBackArrowTap,
  });

  bool _isGroupSelected(List<int> indices) => indices.contains(selectedIndex);

  @override
  Widget build(BuildContext context) {
    final perm = context.watch<PermissionCubit>();
    return Container(
      width: 70,
      color: AppThemeColors.sidebarBg,
      child: Column(
        children: [
          SizedBox(height: 3.h),

          /// LOGO
          InkWell(
            onTap: onBackArrowTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.5.sp),
              child: Center(
                child: SizedBox(
                  height: 5.h,
                  width: 5.h,
                  child: Image.asset(AssetResources.iconLogo),
                ),
              ),
            ),
          ),

          SizedBox(height: 5.h),

          /// DASHBOARD
          HoverSidebarItem(
            icon: Icons.dashboard_outlined,
            title: "Dashboard",
            isExpandable: false,
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
            destination: RoutePaths.dashboard,
          ),

          /// LEAD MANAGEMENT
          HoverSidebarItem(
            icon: Symbols.query_stats,
            title: "Lead Management",
            isExpandable: true,
            children: [
              if (perm.canAddLead) "Add Lead",
              if (perm.canViewLeadsReport) "Leads Report",
              if (perm.canImportLeads) 'Import Leads',
              if (perm.canViewDeletedLeads) 'Deleted Leads',
              if (perm.canTransferLeads || perm.canViewTransferLeads)
                "Transfer Leads",
            ],
            destinations: [
              if (perm.canAddLead) RoutePaths.addLead,
              if (perm.canViewLeadsReport) RoutePaths.leadsReport,
              if (perm.canImportLeads) RoutePaths.importLeads,
              if (perm.canViewDeletedLeads) RoutePaths.deletedLeads,
              if (perm.canTransferLeads || perm.canViewTransferLeads)
                RoutePaths.transferLeads,
            ],
            isSelected: _isGroupSelected([1, 2, 14, 4, 13, 5]),
            onItemTap: (index) {
              final list = [
                if (perm.canAddLead) 1,
                if (perm.canViewLeadsReport) 2,
                if (perm.canImportLeads) 14,
                if (perm.canViewDeletedLeads) 4,
                if (perm.canTransferLeads || perm.canViewTransferLeads) 5,
              ];
              onItemSelected(list[index]);
            },
          ),

          /// STAFF MANAGEMENT
          if (perm.canAddStaff ||
              perm.canViewStaff ||
              perm.canViewDesignation ||
              perm.canViewDeletedStaff)
            HoverSidebarItem(
              icon: Symbols.badge,
              title: "Staff Management",
              isExpandable: true,
              children: [
                if (perm.canAddStaff) "Add Staff",
                if (perm.canViewStaff) "View Staff",
                if (perm.canViewDesignation) "Designations",
                if (perm.canViewDeletedStaff) "Deleted Staff",
              ],
              destinations: [
                if (perm.canAddStaff) RoutePaths.addStaff,
                if (perm.canViewStaff) RoutePaths.viewStaff,
                if (perm.canViewDesignation) RoutePaths.designation,
                if (perm.canViewDeletedStaff) RoutePaths.deletedStaff,
              ],
              isSelected: _isGroupSelected([15, 16, 17, 18]),
              onItemTap: (index) {
                final list = [
                  if (perm.canAddStaff) 15,
                  if (perm.canViewStaff) 16,
                  if (perm.canViewDesignation) 17,
                  if (perm.canViewDeletedStaff) 18,
                ];
                onItemSelected(list[index]);
              },
            ),

          /// REPORTS
          if (perm.canViewStaffReport ||
              perm.canViewTransferReport ||
              perm.canViewTotalReport ||
              perm.canViewRejectedReport)
            HoverSidebarItem(
              icon: Symbols.news,
              title: "Reports",
              isExpandable: true,
              children: [
                if (perm.canViewStaffReport) "Staff Report",
                if (perm.canViewTransferReport) "Transfer Leads Reports",
                if (perm.canViewTotalReport) "Total Leads Reports",
                if (perm.canViewRejectedReport) "Rejected leads Reports",
              ],
              destinations: [
                if (perm.canViewStaffReport) RoutePaths.staffReports,
                if (perm.canViewTransferReport) RoutePaths.transferReport,
                if (perm.canViewTotalReport) RoutePaths.leadsReport,
                if (perm.canViewRejectedReport) RoutePaths.rejectedReport,
              ],
              isSelected: _isGroupSelected([22, 23, 2, 24, 25]),
              onItemTap: (index) {
                final list = [
                  if (perm.canViewStaffReport) 22,
                  if (perm.canViewTransferReport) 23,
                  if (perm.canViewTotalReport) 2,
                  if (perm.canViewRejectedReport) 25,
                ];
                onItemSelected(list[index]);
              },
            ),

          const Spacer(),

          /// USER AVATAR AT BOTTOM
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is! Authenticated) return const SizedBox.shrink();
              final user = state.user;
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      user.imageUrl != null && user.imageUrl!.trim().isNotEmpty
                      ? NetworkImage(user.imageUrl!)
                      : null,
                  child: user.imageUrl == null || user.imageUrl!.trim().isEmpty
                      ? const Icon(Icons.person, color: Colors.grey, size: 18)
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
