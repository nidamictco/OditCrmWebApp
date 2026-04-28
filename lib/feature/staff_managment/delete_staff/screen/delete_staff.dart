import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:login_2_it_solution/core/utils/footer.dart';
import 'package:login_2_it_solution/core/utils/show_entries.dart';
import 'package:login_2_it_solution/core/utils/staff_top_bar.dart';
import 'package:login_2_it_solution/core/utils/table.dart';
import 'package:login_2_it_solution/core/utils/top_bread_crumb_bar.dart';
import 'package:sizer/sizer.dart';

class DeleteStaff extends StatefulWidget {
  const DeleteStaff({super.key});

  @override
  State<DeleteStaff> createState() => _DeleteStaffState();
}

class _DeleteStaffState extends State<DeleteStaff> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StaffTopBar(
              title: 'Staff List',
              current: 'Delete Staff',
              parent: 'Staff Management',
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                        right: 15.w,
                        top: 2.h,
                        bottom: 1.h,
                      ),
                      child: Text(
                        "Delete Staff",
                        style: AppTextStyle.medium(
                          size: 13.6.sp,
                          color: AppColors.black.withOpacity(0.77),
                          weight: FontWeight.w600,
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
                          TableColumn(title: "Phone No", flex: 4),
                          TableColumn(title: "Designation", flex: 4),
                          TableColumn(title: "Deleted Date", flex: 4),
                          TableColumn(title: "Action", flex: 2),
                        ],
                        rows:
                            [
                              ["1", "name", "1234567890", "10 min", "Incoming"],
                              ["1", "name", "1234567890", "10 min", "Incoming"],
                              ["1", "name", "1234567890", "10 min", "Incoming"],
                              ["1", "name", "1234567890", "10 min", "Incoming"],
                            ].map((row) {
                              return [
                                Text(row[0], style: AppTextStyle.medium()),
                                Text(row[1], style: AppTextStyle.medium()),
                                Text(row[2], style: AppTextStyle.medium()),
                                Text(row[3], style: AppTextStyle.medium()),
                                Center(
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: 14.sp,
                                    color: Colors.blue,
                                  ),
                                ),

                                /// ACTION
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        size: 14.sp,
                                        color: Colors.blue,
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
