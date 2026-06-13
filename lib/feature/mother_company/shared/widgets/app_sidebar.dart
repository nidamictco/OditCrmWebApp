import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../Dashboard/screens/dashboard_page.dart';
import '../enum/mother_company_enum.dart';


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

  static  final List<_SidebarItem> _items = [
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
    )
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
      width: 230,
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppThemeColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.crop_square_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                 Text(
                  'Odit-crm',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
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
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppThemeColors.scaffoldBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppThemeColors.primary,
                  child: const Text(
                    'IC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ismail CT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppThemeColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Super Admin',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white,
            size: 18,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          visualDensity: VisualDensity.compact,
        ),
      );
    }
    return ListTile(
      dense: true,
      leading: Icon(item.icon, color: AppThemeColors.sidebarInactiveText, size: 20),
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
    );
  }
}
