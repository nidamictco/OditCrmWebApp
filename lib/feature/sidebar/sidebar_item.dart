import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:material_symbols_icons/symbols.dart';
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
        widget.selectedIndex >= 22 && widget.selectedIndex <= 25 ||
        widget.selectedIndex == 2;

    return Container(
      width: 250,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(6, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Oxdo",
                style: AppTextStyle.heading(size: 20, weight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 30),

            /// DASHBOARD
            sidebarItem(Icons.dashboard, "Dashboard", 0),

            /// LEAD MANAGEMENT
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                initiallyExpanded: isLeadSelected,
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                childrenPadding: EdgeInsets.zero,

                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Icon(
                  Icons.phone,
                  color: isLeadSelected ? AppColors.primary : AppColors.grey,
                ),

                title: Text(
                  "Lead Management",
                  style: AppTextStyle.medium(
                    size: 14,
                    color: isLeadSelected ? AppColors.primary : AppColors.grey,
                    weight: FontWeight.w500,
                  ),
                ),

                children: [
                  subMenuItem("Add Lead", 1),
                  subMenuItem("Leads Report", 2),
                  subMenuItem("Import Leads", 14),
                  subMenuItem("Call History ", 3),
                  subMenuItem("Delete Leads", 4),
                  subMenuItem("Transfer Leads", 5),
                  subMenuItem("Unassigned Leads", 13),
                  subMenuItem("Phone Call Log ", 6),
                ],
              ),
            ),

           
            ///settings
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                initiallyExpanded: isSettingsSelected,
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                childrenPadding: EdgeInsets.zero,

                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Icon(
                  Symbols.settings,
                  color: isSettingsSelected
                      ? AppColors.primary
                      : AppColors.grey,
                ),

                title: Text(
                  "Settings",
                  style: AppTextStyle.medium(
                    size: 14,
                    color: isSettingsSelected
                        ? AppColors.primary
                        : AppColors.grey,
                    weight: FontWeight.w500,
                  ),
                ),

                children: [
                  subMenuItem("Facebook Settings", 21),
                  subMenuItem("General Settings", 20),
                ],
              ),
            ),


             ///staff managment
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                initiallyExpanded: isStaffSelected,
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                childrenPadding: EdgeInsets.zero,

                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Icon(
                  Symbols.article_person_sharp,
                  color: isStaffSelected ? AppColors.primary : AppColors.grey,
                ),

                title: Text(
                  "Staff Management",
                  style: AppTextStyle.medium(
                    size: 14,
                    color: isStaffSelected ? AppColors.primary : AppColors.grey,
                    weight: FontWeight.w500,
                  ),
                ),

                children: [
                  subMenuItem("Add Staff", 15),
                  subMenuItem("View Staff", 16),
                  subMenuItem("Designation", 17),
                  subMenuItem("Delete Staff", 18),
                ],
              ),
            ),





            ///file manager
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                initiallyExpanded: isFileSelected,
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                childrenPadding: EdgeInsets.zero,

                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Icon(
                  Symbols.folder,
                  color: isFileSelected ? AppColors.primary : AppColors.grey,
                ),

                title: Text(
                  "File Manager",
                  style: AppTextStyle.medium(
                    size: 14,
                    color: isFileSelected ? AppColors.primary : AppColors.grey,
                    weight: FontWeight.w500,
                  ),
                ),

                children: [subMenuItem("View", 19)],
              ),
            ),

            /// Reports
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                initiallyExpanded: isReportsSelected,
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                childrenPadding: EdgeInsets.zero,

                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Icon(
                  Symbols.news,
                  color: isReportsSelected ? AppColors.primary : AppColors.grey,
                ),

                title: Text(
                  "Reports",
                  style: AppTextStyle.medium(
                    size: 14,
                    color: isReportsSelected
                        ? AppColors.primary
                        : AppColors.grey,
                    weight: FontWeight.w500,
                  ),
                ),

                children: [
                  subMenuItem("Staff Reports", 22),
                  subMenuItem("Transfer Leads Reports", 23),
                  subMenuItem("Total Leads Reports", 2),
                  subMenuItem('Scheduled Lead report', 24),
                  subMenuItem("Rejected Leads Reports", 25),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sidebarItem(IconData icon, String title, int index) {
    final isSelected = widget.selectedIndex == index;

    return InkWell(
      onTap: () => widget.onItemSelected(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.grey),
            const SizedBox(width: 10),
            Text(
              title,
              style: AppTextStyle.medium(
                size: 14,
                color: isSelected ? AppColors.primary : AppColors.grey,
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
            Text(
              '- $title',
              style: AppTextStyle.small(
                size: 11.sp,
                weight: FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.grey,
              ),
              textAlign: TextAlign.start,
            ),
            if (index == 5 || index == 3) ...[
              Icon(
                Symbols.crown_sharp,
                color: AppColors.orange,
                size: 16,
                fill: 1,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
