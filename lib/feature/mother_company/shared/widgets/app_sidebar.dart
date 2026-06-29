import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../Dashboard/screens/dashboard_page.dart';
import '../enum/mother_company_enum.dart';
import '../../../auth/cubit/auth/auth_cubit.dart';
import '../../../sub_company/staff_managment/designation/cubit/permition_cubit/permission_cubit.dart';

class _SidebarItem {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.page,
  });

  final IconData icon;
  final String label;
  final MotherCompanyPage page;
}

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.selectedPage,
    required this.onPageChanged,
  });

  final MotherCompanyPage selectedPage;
  final ValueChanged<MotherCompanyPage> onPageChanged;

  static final List<_SidebarItem> _items = [
    const _SidebarItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      page: MotherCompanyPage.dashboard,
    ),
    const _SidebarItem(
      icon: Icons.business_rounded,
      label: 'Company Manage',
      page: MotherCompanyPage.companyManage,
    ),
    const _SidebarItem(
      label: "Add Company",
      icon: Icons.add_business,
      page: MotherCompanyPage.addCompany,
    ),
    // const _SidebarItem(
    //   icon: Icons.settings_rounded,
    //   label: 'System Setting',
    //   page: MotherCompanyPage.systemSetting,
    // ),
    // const _SidebarItem(
    //   icon: Icons.history_rounded,
    //   label: 'Active Logs',
    //   page: MotherCompanyPage.activeLogs,
    // ),
    // const _SidebarItem(
    //   icon: Icons.confirmation_number_rounded,
    //   label: 'Support Tickets',
    //   page: MotherCompanyPage.supportTickets,
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppThemeColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AppThemeColors.borderLight, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
            child: Row(
              children: [
                Container(
                  width: 150,
                  height: 60,
                  decoration: BoxDecoration(
                    // color: AppThemeColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(AssetResources.sidebar_logo),
                ),
                // const SizedBox(width: 10),
                // Text(
                //   'Odit CRM',
                //   style: AppTextStyle.body(
                //     fontSize: 18,
                //     fontWeight: FontWeight.w700,
                //     color: AppThemeColors.textPrimary,
                //     letterSpacing: -0.3,
                //   ),
                // ),
              ],
            ),
          ),
          // Nav items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final item = _items[index];
                return _SidebarNavItem(
                  item: item,
                  isActive: selectedPage == item.page,
                  onTap: () => onPageChanged(item.page),
                );
              },
            ),
          ),
          // Bottom user hint
          GestureDetector(
            onTap: () => _showLogoutDialog(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: AppThemeColors.scaffoldBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppThemeColors.borderLight, width: 1),
              ),
              child: Center(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppThemeColors.primary,
                      child: Image.asset("assets/icon/logout.png", scale: 2),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppThemeColors.textPrimary,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(25),
          buttonPadding: EdgeInsets.all(15),

          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirm Logout',
            style: AppTextStyle.body(
              fontWeight: FontWeight.bold,
              color: AppThemeColors.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to log out of your account?',
            style: AppTextStyle.body(color: AppThemeColors.textSecondary),
          ),
          actionsPadding: const EdgeInsets.only(right: 25, bottom: 25),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyle.body(
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                 context.read<AuthCubit>().logout(
                  permissionCubit: context.read<PermissionCubit>(),
                );
                Navigator.pop(context); // Close the dialog
               
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeColors.statusSuspended,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Log Out',
                style: AppTextStyle.body(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _SidebarItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppThemeColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(item.icon, color: Colors.white, size: 20),
          title: Text(
            item.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white,
            size: 18,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 2,
          ),
          visualDensity: VisualDensity.compact,
        ),
      );
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppThemeColors.borderLight3, width: 1),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          item.icon,
          color: AppThemeColors.sidebarInactiveText,
          size: 20,
        ),

        title: Text(
          item.label,
          style: const TextStyle(
            color: AppThemeColors.sidebarInactiveText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        hoverColor: AppThemeColors.scaffoldBg,
        onTap: onTap,
      ),
    );
  }
}
