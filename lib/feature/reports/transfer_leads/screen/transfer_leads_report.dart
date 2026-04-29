import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/footer.dart';
import 'package:oxdo/core/utils/input_date.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/staff_top_bar.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:sizer/sizer.dart';

class TransferLeadsReport extends StatefulWidget {
  const TransferLeadsReport({super.key});

  @override
  State<TransferLeadsReport> createState() => _TransferLeadsReportState();
}

class _TransferLeadsReportState extends State<TransferLeadsReport> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  String? selectedStatus;
  String? selectedCategory;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StaffTopBar(
              title: 'Transfer Leads Report',
              parent: 'Reports',
              current: 'Transfer Leads',
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: InputDate(
                              label: 'From Date',
                              controller: _fromDateController,
                              top: 32.h,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: InputDate(
                              label: 'To Date',
                              controller: _toDateController,
                              top: 32.h,
                              left: 43.w,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Dropdown(
                              hint: 'select category',
                              showHelp: true,
                              items: [],
                              selectedValue: selectedCategory,
                              onChanged: (val) {
                                setState(() {
                                  selectedCategory = val;
                                });
                              },
                              label: "Lead Category",
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Dropdown(
                              label: "Status",
                              hint: ' select status',
                              showHelp: false,
                              items: [],
                              selectedValue: selectedStatus,
                              onChanged: (val) {
                                setState(() {
                                  selectedStatus = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 17.45.w,
                            child: Dropdown(
                              label: "From Staff",
                              hint: "select staff",
                            ),
                          ),
                          SizedBox(width: 2.w),
                          SizedBox(
                            width: 17.45.w,
                            child: Dropdown(
                              label: "To Staff",
                              hint: "select staff",
                            ),
                          ),
                          SizedBox(width: 2.w),

                          /// 🔥 VIEW BUTTON (perfect aligned)
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
                    ),
                    SizedBox(height: 1.w),
                    Divider(color: AppColors.divider),
                    ShowEntries(),
                    SizedBox(
                      child: CustomTable(
                        columns: [
                          TableColumn(title: "#", flex: 1),
                          TableColumn(title: "Name", flex: 4),
                          TableColumn(title: "Contact Number", flex: 4),
                          TableColumn(title: "From Staff", flex: 4),
                          TableColumn(title: "To Staff", flex: 4),
                          TableColumn(title: "Lead Category", flex: 4),
                          TableColumn(title: "Transfer Date", flex: 4),
                        ],
                        rows:
                            [
                              [
                                "1",
                                "name",
                                "1234567890",
                                "category",
                                "Last Updated",
                                "Staff",
                                "Status",
                              ],
                              [
                                "2",
                                "name",
                                "1234567890",
                                "category",
                                "Last Updated",
                                "Staff",
                                "Status",
                              ],
                              [
                                "3",
                                "name",
                                "1234567890",
                                "category",
                                "Last Updated",
                                "Staff",
                                "Status",
                              ],
                              [
                                "4",
                                "name",
                                "1234567890",
                                "category",
                                "Last Updated",
                                "Staff",
                                "Status",
                              ],
                              [
                                "5",
                                "name",
                                "1234567890",
                                "category",
                                "Last Updated",
                                "Staff",
                                "Status",
                              ],
                              [
                                "6",
                                "name",
                                "1234567890",
                                "category",
                                "Last Updated",
                                "Staff",
                                "Status",
                              ],
                              [
                                "7",
                                "name",
                                "1234567890",
                                "category",
                                "Last Updated",
                                "Staff",
                                "Status",
                              ],
                              [
                                "8",
                                "name",
                                "1234567890",
                                "category",
                                "Last Updated",
                                "Staff",
                                "Status",
                              ],
                            ].map((row) {
                              return [
                                Text(row[0], style: AppTextStyle.medium()),
                                Text(row[1], style: AppTextStyle.medium()),
                                Text(row[2], style: AppTextStyle.medium()),
                                Text(row[3], style: AppTextStyle.medium()),
                                Text(row[4], style: AppTextStyle.medium()),
                                Text(row[5], style: AppTextStyle.medium()),

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
