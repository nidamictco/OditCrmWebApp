import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:Odit_CRM/feature/auth/cubit/auth/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/cubit/permition_cubit/permission_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/core/router/browser_aware_link.dart';
import 'package:go_router/go_router.dart';

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
      // width: 150,
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
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => _UserProfileAlertDialog(
                      user: user,
                      parentContext: context,
                    ),
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
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
                              user.imageUrl == null ||
                                  user.imageUrl!.trim().isEmpty
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
                  ),
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
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
            margin: const EdgeInsets.only(left: 25, top: 4, bottom: 4),
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

class _UserProfileAlertDialog extends StatefulWidget {
  final StaffModel user;
  final BuildContext parentContext;

  const _UserProfileAlertDialog({
    required this.user,
    required this.parentContext,
  });

  @override
  State<_UserProfileAlertDialog> createState() =>
      _UserProfileAlertDialogState();
}

class _UserProfileAlertDialogState extends State<_UserProfileAlertDialog> {
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    Navigator.of(context).pop();
    final confirmed = await showDialog<bool>(
      context: widget.parentContext,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(
              'Confirm Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && widget.parentContext.mounted) {
      widget.parentContext.read<AuthCubit>().logout(
        permissionCubit: widget.parentContext.read<PermissionCubit>(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final hasImage = user.imageUrl != null && user.imageUrl!.trim().isNotEmpty;
    final width = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: width * 0.5,
        constraints: const BoxConstraints(maxWidth: 580),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Row: Avatar & Actions (Settings, Logout)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile Avatar with rounded corners
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade200,
                    child: hasImage
                        ? Image.network(
                            user.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.person,
                                  size: 36,
                                  color: Colors.grey,
                                ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 36,
                            color: Colors.grey,
                          ),
                  ),
                ),
                // Top-right Action Icons (Gear, Red Logout)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.parentContext.go(RoutePaths.generalSettings);
                      },
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Color(0xFF1E3A8A),
                        size: 22,
                      ),
                      tooltip: 'Settings',
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: _handleLogout,
                      icon: const Icon(
                        Icons.logout,
                        color: Color(0xFFE11D48),
                        size: 22,
                      ),
                      tooltip: 'Logout',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),

            // User Name
            Text(
              user.name,
              style: AppTextStyle.heading(
                fontSize: 14,

                color: Color(0xFF0F172A),
              ),
            ),
            // const SizedBox(height: 4),

            // User Designation/Role
            Text(
              user.staffType ?? user.designation ?? '',
              style: AppTextStyle.small(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E3A8A),
              ),
            ),

            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
            ),

            // Email & Mobile fields
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 450;
                final emailField = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Address',
                      style: AppTextStyle.medium(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _emailController,
                      style: AppTextStyle.medium(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),
                    ),
                  ],
                );

                final phoneField = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mobile Number',
                      style: AppTextStyle.medium(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _phoneController,
                      style: AppTextStyle.medium(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),
                    ),
                  ],
                );

                if (isCompact) {
                  return Column(
                    children: [
                      emailField,
                      const SizedBox(height: 16),
                      phoneField,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: emailField),
                    const SizedBox(width: 16),
                    Expanded(child: phoneField),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Bottom Action Bar: Change Password (left), Cancel & Update (right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.parentContext.go(
                      RoutePaths.changePasswordPath(widget.user.id ?? ''),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: Color(0xFF007AFF),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Change Password?',
                          style: AppTextStyle.medium(
                            color: Color(0xFF007AFF),
                            // fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // const SizedBox(width: 12),
                    // ElevatedButton.icon(
                    //   onPressed: () {
                    //     Navigator.of(context).pop();
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: const Color(0xFF00C875),
                    //     elevation: 0,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 22,
                    //       vertical: 14,
                    //     ),
                    //   ),
                    //   icon: const Icon(
                    //     Icons.content_paste_outlined,
                    //     size: 18,
                    //     color: Colors.white,
                    //   ),
                    //   label: const Text(
                    //     'Update',
                    //     style: TextStyle(
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.w600,
                    //       fontSize: 14,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// BlocBuilder<AuthCubit, AuthState>(
//             builder: (context, state) {
//               if (state is! Authenticated) return const SizedBox.shrink();
//               final user = state.user;
//               return GestureDetector(
//                 onTapDown: (details) async {
//                   final position = RelativeRect.fromLTRB(
//                     details.globalPosition.dx,
//                     details.globalPosition.dy + 10,
//                     details.globalPosition.dx,
//                     0,
//                   );

//                   final selected = await showMenu<String>(
//                     color: AppColors.white,
//                     context: context,
//                     position: position,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     items: [
//                       _buildMenuItem(Icons.person_outline, "Profile"),
//                       _buildMenuItem(Icons.lock_outline, "Change Password"),
//                       _buildMenuItem(Icons.settings_outlined, "Settings"),
//                       const PopupMenuDivider(),
//                       _buildMenuItem(Icons.logout, "Logout", isLogout: true),
//                     ],
//                   );

//                   if (selected == "Logout" && context.mounted) {
//                     final confirmed = await showDialog<bool>(
//                       context: context,
//                       builder: (ctx) => AlertDialog(
//                         backgroundColor: AppColors.background,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         title: const Row(
//                           children: [
//                             Icon(Icons.logout, color: Colors.red, size: 20),
//                             SizedBox(width: 8),
//                             Text(
//                               'Confirm Logout',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                         content: const Text('Are you sure you want to logout?'),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.of(ctx).pop(false),
//                             child: const Text(
//                               'Cancel',
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                           ),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             onPressed: () => Navigator.of(ctx).pop(true),
//                             child: const Text(
//                               'Logout',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                     if (confirmed == true && context.mounted) {
//                       context.read<AuthCubit>().logout(
//                         permissionCubit: context.read<PermissionCubit>(),
//                       );
//                     }
//                   }
//                   if (selected == "Settings" && context.mounted) {
//                     context.go(RoutePaths.generalSettings);
//                   }
//                   if (selected == "Profile" && context.mounted) {
//                     context.go(RoutePaths.personalProfile);
//                   }
//                   if (selected == "Change Password" && context.mounted) {
//                     context.go(RoutePaths.changePasswordPath(user.id ?? ''));
//                   }
//                 },
//                 child: MouseRegion(
//                   cursor: SystemMouseCursors.click,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                     decoration: BoxDecoration(
//                       border: Border(
//                         top: BorderSide(
//                           color: AppThemeColors.borderLight,
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 18,
//                           backgroundColor: Colors.grey.shade200,
//                           backgroundImage:
//                               user.imageUrl != null &&
//                                       user.imageUrl!.trim().isNotEmpty
//                                   ? NetworkImage(user.imageUrl!)
//                                   : null,
//                           child:
//                               user.imageUrl == null ||
//                                       user.imageUrl!.trim().isEmpty
//                                   ? const Icon(
//                                       Icons.person,
//                                       color: Colors.grey,
//                                       size: 18,
//                                     )
//                                   : null,
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 user.name,
//                                 style: AppTextStyle.medium(
//                                   size: 13,
//                                   weight: FontWeight.w600,
//                                   color: AppThemeColors.sidebarLogoTxtClr,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Text(
//                                 user.staffType ?? '',
//                                 style: AppTextStyle.small(
//                                   size: 11,
//                                   color: AppColors.grey,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           )
