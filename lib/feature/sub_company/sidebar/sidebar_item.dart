import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/cubit/permition_cubit/permission_cubit.dart';
import 'package:sizer/sizer.dart';

class SidebarItem extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SidebarItem({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  @override
  Widget build(BuildContext context) {
    // ✅ Read permission cubit once
    final perm = context.watch<PermissionCubit>();

    final isLeadSelected =
        (widget.selectedIndex >= 1 && widget.selectedIndex <= 6) ||
        widget.selectedIndex == 13 ||
        widget.selectedIndex == 14;
    final isStaffSelected =
        widget.selectedIndex >= 15 && widget.selectedIndex <= 18;
    final isSettingsSelected =
        widget.selectedIndex >= 20 && widget.selectedIndex <= 21;
    final isFileSelected = widget.selectedIndex == 19;
    final isReportsSelected =
        (widget.selectedIndex >= 22 && widget.selectedIndex <= 25) ||
        widget.selectedIndex == 2;

    // ─── Which lead sub-items are visible ─────────────────────────────────
    final leadChildren = [
      if (perm.canAddLead) subMenuItem("Add Lead", 1),
      if (perm.canViewLeadsReport) subMenuItem("Leads Report", 2),
      if (perm.canImportLeads) subMenuItem("Import Leads", 14),
      // if(perm.canViewCallHistory)
      //   subMenuItem("Call History", 3),
      if (perm.canViewDeletedLeads) subMenuItem("Deleted Leads", 4),
      // if (perm.canViewUnassignedLeads) subMenuItem("Unassigned Leads", 13),
      if (perm.canTransferLeads || perm.canViewTransferLeads)
        subMenuItem("Transfer Leads", 5),
      // if(perm.canViewPhoneCallLog)
      // subMenuItem("Phone Call Logs", 6),
    ];

    // ─── Which staff sub-items are visible ────────────────────────────────
    final staffChildren = [
      if (perm.canAddStaff) subMenuItem("Add Staff", 15),
      if (perm.canViewStaff) subMenuItem("View Staff", 16),
      if (perm.canViewDesignation) subMenuItem("Designation", 17),
      if (perm.canViewDeletedStaff) subMenuItem("Deleted Staff", 18),
    ];

    // ─── Which report sub-items are visible ───────────────────────────────
    final reportChildren = [
      if (perm.canViewStaffReport) subMenuItem("Staff Reports", 22),
      if (perm.canViewTransferReport)
        subMenuItem("Transferred Leads Reports", 23),
      if (perm.canViewTotalReport) subMenuItem("Total Leads Reports", 2),
      // if (perm.canViewLeadSource) subMenuItem("Scheduled Leads Reports", 24),
      if (perm.canViewRejectedReport) subMenuItem("Rejected Leads Reports", 25),
    ];

    return Container(
      width: 240,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: BoxBorder.fromLTRB(right: BorderSide(color: Colors.black12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(20, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.w),
                // padding: EdgeInsets.zero,
                // child: Text(
                //   "Oxdo Leads",
                //   style: AppTextStyle.heading(size: 20, weight: FontWeight.w700),
                // ),
                child: Image.asset(
                  AssetResources.sidebar_logo,
                  // width: 8.w,
                  scale: 10,
                ),
              ),
            ),
            //  SizedBox(height: 2.h),

            /// DASHBOARD — always visible
            sidebarItem(Icons.dashboard, "Dashboard", 0),

            /// LEAD MANAGEMENT — only show if any child is visible
            if (leadChildren.isNotEmpty)
              _expansionSection(
                icon: Icons.phone,
                title: "Lead Management",
                isSelected: isLeadSelected,
                children: leadChildren,
              ),

            /// STAFF MANAGEMENT — only show if any child is visible
            if (staffChildren.isNotEmpty)
              _expansionSection(
                icon: Symbols.article_person_sharp,
                title: "Staff Management",
                isSelected: isStaffSelected,
                children: staffChildren,
              ),

            /// SETTINGS
            if (perm.canViewGeneralSettings || perm.canViewFacebookSettings)
              _expansionSection(
                // icon: Symbols.settings,
                icon: Icons.settings_outlined,
                title: "Settings",
                isSelected: isSettingsSelected,
                children: [
                  // if (perm.canViewFacebookSettings)
                  //   subMenuItem("Facebook Settings", 21),
                  if (perm.canViewGeneralSettings)
                    subMenuItem("General Settings", 20),
                ],
              ),

            // /// FILE MANAGER
            // if (perm.canViewFileManager)
            //   _expansionSection(
            //     icon: Symbols.folder,
            //     title: "File Manager",
            //     isSelected: isFileSelected,
            //     children: [subMenuItem("View", 19)],
            //   ),

            /// REPORTS — only show if any child is visible
            if (reportChildren.isNotEmpty)
              _expansionSection(
                icon: Symbols.news,
                title: "Reports",
                isSelected: isReportsSelected,
                children: reportChildren,
              ),
          ],
        ),
      ),
    );
  }

  // ─── Reusable expansion section ───────────────────────────────────────────
  Widget _expansionSection({
    required IconData icon,
    required String title,
    required bool isSelected,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        initiallyExpanded: isSelected,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: EdgeInsets.only(left: 20),
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.grey,
        ),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: AppTextStyle.medium(
            size: 14,
            color: isSelected ? AppColors.primary : AppColors.grey,
            weight: FontWeight.w500,
          ),
        ),
        children: children,
      ),
    );
  }

  Widget sidebarItem(IconData icon, String title, int index) {
    final isSelected = widget.selectedIndex == index;
    return InkWell(
      onTap: () {
        // if (index == 0) {
        //   final today = DateTime.now();
        //   context.read<AddLeadCubit>().fetchDashboardCounts(today);
        // }
        widget.onItemSelected(index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.grey),
            SizedBox(width: 0.6.w),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTextStyle.medium(
                  size: 14,
                  color: isSelected ? AppColors.primary : AppColors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget subMenuItem(String title, int index) {
    final isSelected = widget.selectedIndex == index;
    return InkWell(
      onTap: () => widget.onItemSelected(index),
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 14, left: 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '-   $title',
                style: AppTextStyle.small(
                  size: 11.sp,
                  weight: FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.grey,
                ),
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
