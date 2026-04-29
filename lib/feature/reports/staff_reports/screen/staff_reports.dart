import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/footer.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/staff_top_bar.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:sizer/sizer.dart';

class StaffReports extends StatefulWidget {
  const StaffReports({super.key});

  @override
  State<StaffReports> createState() => _StaffReportsState();
}

class _StaffReportsState extends State<StaffReports> {
  bool isHovering = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StaffTopBar(
              title: 'Staff Reports',
              parent: 'Staff Management',
              current: 'Staff Reports',
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
                  children: [
                    ///TITLE BAR
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MainScreen(selectedIndex: 15),
                                  ),
                                );
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
                                  borderRadius: BorderRadius.circular(6),
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
                    SizedBox(height: 2.h),
                    ShowEntries(),
                    SizedBox(
                      child: CustomTable(
                        columns: [
                          // TableColumn(title: "", flex: 1),
                          TableColumn(title: "#", flex: 1),
                          TableColumn(title: "Name", flex: 4),
                          TableColumn(title: "Phone Number", flex: 4),
                          TableColumn(title: "Designation", flex: 4),
                          TableColumn(title: "Action", flex: 2),
                        ],
                        rows:
                            [
                              ["1", "name", "1234567890", "Telecalling"],
                              ["2", "name", "1234567890", "Telecalling"],
                              ["3", "name", "1234567890", "Telecalling"],
                              ["4", "name", "1234567890", "Telecalling"],
                            ].map((row) {
                              return [
                                Text(row[0], style: AppTextStyle.medium()),
                                Text(row[1], style: AppTextStyle.medium()),
                                Text(row[2], style: AppTextStyle.medium()),
                                Text(row[3], style: AppTextStyle.medium()),
                                Center(
                                  child: IconButton(
                                    icon: Icon(
                                    Icons.preview,
                                    size: 14.sp,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {},
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
