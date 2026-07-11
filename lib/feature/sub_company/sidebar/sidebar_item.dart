import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:Odit_CRM/feature/auth/cubit/auth/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/cubit/permition_cubit/permission_cubit.dart';
import 'package:sizer/sizer.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/core/router/browser_aware_link.dart';

class SidebarItem extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onBackArrowTap;

  const SidebarItem({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onBackArrowTap,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  @override
  Widget build(BuildContext context) {
    // Read permission cubit once
    final perm = context.watch<PermissionCubit>();

    final isLeadSelected =
        (widget.selectedIndex >= 1 && widget.selectedIndex <= 6) ||
        widget.selectedIndex == 13 ||
        widget.selectedIndex == 14;
    final isStaffSelected =
        widget.selectedIndex >= 15 && widget.selectedIndex <= 18;
    final isReportsSelected =
        (widget.selectedIndex >= 22 && widget.selectedIndex <= 25) ||
        widget.selectedIndex == 2;

    // Lead sub-items visible
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

    // Staff sub-items visible
    final staffChildren = [
      if (perm.canAddStaff) subMenuItem("Add Staff", 15),
      if (perm.canViewStaff) subMenuItem("View Staff", 16),
      if (perm.canViewDesignation) subMenuItem("Designation", 17),
      if (perm.canViewDeletedStaff) subMenuItem("Deleted Staff", 18),
    ];

    // Report sub-items visible
    final reportChildren = [
      if (perm.canViewStaffReport) subMenuItem("Staff Reports", 22),
      if (perm.canViewTransferReport)
        subMenuItem("Transferred Leads Reports", 23),
      if (perm.canViewTotalReport) subMenuItem("Total Leads Reports", 2),
      // if (perm.canViewLeadSource) subMenuItem("Scheduled Leads Reports", 24),
      if (perm.canViewRejectedReport) subMenuItem("Rejected Leads Reports", 25),
    ];

    return Container(
      width: 200,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: AppThemeColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AppThemeColors.borderLight, width: 1),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo Row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: widget.onBackArrowTap,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              AssetResources.iconLogo,
                              scale: 40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Odit CRM',
                          style: AppTextStyle.body(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppThemeColors.sidebarLogoTxtClr,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: widget.onBackArrowTap,
                          child: Icon(
                            Icons.keyboard_double_arrow_left_sharp,
                            color: AppThemeColors.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // DASHBOARD
                  sidebarItem(
                    Icons.dashboard_outlined,
                    "Dashboard",
                    0,
                    Image.asset(AssetResources.dashboard_icon, scale: 2),
                  ),

                  // LEAD MANAGEMENT
                  if (leadChildren.isNotEmpty)
                    CustomExpandedTile(
                      icon: Symbols.query_stats,
                      title: "Lead Management",
                      isSelected: isLeadSelected,
                      children: leadChildren,
                    ),

                  // STAFF MANAGEMENT
                  if (staffChildren.isNotEmpty)
                    CustomExpandedTile(
                      icon: Symbols.badge,
                      title: "Staff Management",
                      isSelected: isStaffSelected,
                      children: staffChildren,
                    ),

                  // REPORTS
                  if (reportChildren.isNotEmpty)
                    CustomExpandedTile(
                      icon: Symbols.news,
                      title: "Reports",
                      isSelected: isReportsSelected,
                      children: reportChildren,
                    ),
                ],
              ),
            ),
          ),
          // User Section at Bottom
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is! Authenticated) return const SizedBox.shrink();
              final user = state.user;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppThemeColors.borderLight,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          user.imageUrl != null &&
                              user.imageUrl!.trim().isNotEmpty
                          ? NetworkImage(user.imageUrl!)
                          : null,
                      child:
                          user.imageUrl == null || user.imageUrl!.trim().isEmpty
                          ? const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 18,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.name,
                            style: AppTextStyle.medium(
                              size: 13,
                              weight: FontWeight.w600,
                              color: AppThemeColors.sidebarLogoTxtClr,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.staffType ?? '',
                            style: AppTextStyle.small(
                              size: 11,
                              color: AppColors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget sidebarItem(
    IconData icon,
    String title,
    int index,
    Widget? iconWidget,
  ) {
    final isSelected = widget.selectedIndex == index;
    final path = RoutePaths.sidebarPaths[index] ?? '/';
    return BrowserAwareLink(
      destination: path,
      onTap: () => widget.onItemSelected(index),
      enableInkWell: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff002b66) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (iconWidget != null)
              isSelected
                  ? ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      child: iconWidget,
                    )
                  : iconWidget
            else
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.grey,
                size: 20,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTextStyle.medium(
                  size: 12,
                  color: isSelected ? Colors.white : AppColors.grey,
                  weight: FontWeight.w500,
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
    final path = RoutePaths.sidebarPaths[index] ?? '/';
    return BrowserAwareLink(
      destination: path,
      onTap: () => widget.onItemSelected(index),
      enableInkWell: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeColors.appPrimaryColor.withAlpha(15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.medium(
                  size: 12,
                  weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xff002b66) : AppColors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomExpandedTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final List<Widget> children;

  const CustomExpandedTile({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.children,
  });

  @override
  State<CustomExpandedTile> createState() => _CustomExpandedTileState();
}

class _CustomExpandedTileState extends State<CustomExpandedTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant CustomExpandedTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected && widget.isSelected) {
      _isExpanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTileSelected = widget.isSelected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isTileSelected
                  ? const Color(0xff002b66)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: isTileSelected ? Colors.white : AppColors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTextStyle.medium(
                      size: 12,
                      color: isTileSelected ? Colors.white : AppColors.grey,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: isTileSelected ? Colors.white : AppColors.grey,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded && widget.children.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 32, top: 4, bottom: 4),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xffe2e8f0), width: 1.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
      ],
    );
  }
}
