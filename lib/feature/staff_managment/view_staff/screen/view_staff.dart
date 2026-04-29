import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/footer.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/staff_top_bar.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:sizer/sizer.dart';

class ViewStaff extends StatefulWidget {
  const ViewStaff({super.key});

  @override
  State<ViewStaff> createState() => _ViewStaffState();
}

class _ViewStaffState extends State<ViewStaff> {
  bool isHovering = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StaffTopBar(
              title: 'Staff List',
              current: 'View Staff',
              parent: 'Staff Management',
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 2.w,
                        right: 2.w,
                        top: 2.h,
                        bottom: 1.h,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 7.5.w,
                          height: 4.5.h,
                          child: MouseRegion(
                            onEnter: (_) => setState(() => isHovering = true),
                            onExit: (_) => setState(() => isHovering = false),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 15,)));
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                height: 5.h,
                                // padding: EdgeInsets.symmetric(horizontal: 3.w),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.orange,
                                    width: 0.02.w,
                                  ),
                                  color: isHovering
                                      ? AppColors.orange
                                      : AppColors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    "Add New",
                                    style: AppTextStyle.small(
                                      color: isHovering
                                          ? Colors.white
                                          : AppColors.orange,
                                      size: 10.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(color: AppColors.divider),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 1.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Text('Permissions', style: AppTextStyle.medium()),
                          Row(
                            children: [
                              SizedBox(
                                width: 17.w,
                                child: Dropdown(
                                  label: 'Permissions',
                                  hint: 'All',
                                ),
                              ),
                              SizedBox(width: 1.w),
                              Padding(
                                padding: EdgeInsets.only(top: 2.h),
                                child: SizedBox(
                                  width: 7.w,
                                  height: 4.5.h,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: const Color(0xff1BAA90),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "View",
                                        style: AppTextStyle.small(
                                          size: 10.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 1.h,
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 5.h,
                            width: 6.w,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              border: Border.all(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                "Active",
                                style: AppTextStyle.small(
                                  color: Colors.white,
                                  size: 10.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 0.6.w),
                          Container(
                            height: 5.h,
                            width: 6.w,
                            decoration: BoxDecoration(
                              color: AppColors.red.withOpacity(0.8),
                              border: Border.all(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                "Inactive",
                                style: AppTextStyle.small(
                                  color: Colors.white,
                                  size: 10.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: AppColors.divider),

                    SizedBox(height: 2.h),
                    ShowEntries(),
                    SizedBox(
                      child: CustomTable(
                        columns: [
                          // TableColumn(title: "", flex: 1),
                          TableColumn(title: "#", flex: 1),
                          TableColumn(title: "Name", flex: 4),
                          TableColumn(title: "Staff Type", flex: 4),
                          TableColumn(title: "Status ", flex: 4),
                          TableColumn(title: "Phone Number ", flex: 4),
                          TableColumn(title: "Designation ", flex: 4),
                          TableColumn(title: "Expiry Date", flex: 4),
                          TableColumn(title: "Crated at", flex: 4),
                          TableColumn(title: "Action", flex: 2),
                        ],
                        rows:
                            [
                              [
                                "1",
                                "name",
                                "1234567890",
                                "10 min",
                                "1234567890",
                                "10 min",
                                "1234567890",
                                "10 min",
                              ],
                              [
                                "1",
                                "name",
                                "1234567890",
                                "10 min",
                                "1234567890",
                                "10 min",
                                "1234567890",
                                "10 min",
                              ],
                              [
                                "1",
                                "name",
                                "1234567890",
                                "10 min",
                                "1234567890",
                                "10 min",
                                "1234567890",
                                "10 min",
                              ],
                            ].map((row) {
                              return [
                                Text(row[0], style: AppTextStyle.medium()),
                                Text(row[1], style: AppTextStyle.medium()),
                                Text(row[2], style: AppTextStyle.medium()),
                                Text(row[3], style: AppTextStyle.medium()),
                                Text(row[4], style: AppTextStyle.medium()),
                                Text(row[5], style: AppTextStyle.medium()),
                                Text(row[6], style: AppTextStyle.medium()),
                                Text(row[7], style: AppTextStyle.medium()),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        size: 14.sp,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 0.2.w),
                                      Icon(
                                        Icons.delete_outline,
                                        size: 14.sp,
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                              ];
                            }).toList(),
                      ),
                    ),
                    Footer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
