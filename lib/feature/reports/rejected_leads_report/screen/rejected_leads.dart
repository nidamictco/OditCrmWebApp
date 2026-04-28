import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:login_2_it_solution/core/utils/dropdown.dart';
import 'package:login_2_it_solution/core/utils/footer.dart';
import 'package:login_2_it_solution/core/utils/input_date.dart';
import 'package:login_2_it_solution/core/utils/show_entries.dart';
import 'package:login_2_it_solution/core/utils/staff_top_bar.dart';
import 'package:login_2_it_solution/core/utils/table.dart';
import 'package:sizer/sizer.dart';

class RejectedLeads extends StatefulWidget {
  const RejectedLeads({super.key});

  @override
  State<RejectedLeads> createState() => _RejectedLeadsState();
}

class _RejectedLeadsState extends State<RejectedLeads> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  String? selectedCategory;
  String? selectedLeadSource;
  String? selectedPriority;
  String? selectedSource;
  String? selectedCallStatus;
  String? selectedRejectedReason;
  String? selectedStaff;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StaffTopBar(
              title: 'Rejected Leads Report',
              parent: 'Reports',
              current: 'Rejected Leads',
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 2.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Rejected Leads Report",
                            style: AppTextStyle.medium(
                              size: 13.6.sp,
                              color: AppColors.black.withOpacity(0.77),
                              weight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 1.4.w,
                              vertical: 1.2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffE5E7EB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "Export",
                              style: AppTextStyle.medium(
                                color: Colors.indigo[900],
                                weight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(color: AppColors.divider),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 2.w,
                        right: 2.w,
                        top: 2.w,
                        bottom: 1.h,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _radio("Created Date", true),
                              SizedBox(width: 3.w),
                              _radio("Updated Date", false),
                            ],
                          ),
                          SizedBox(height: 1.h),

                          Row(
                            children: [
                              Expanded(
                                child: InputDate(
                                  label: 'From Date',
                                  controller: _fromDateController,
                                  top: 46.h,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: InputDate(
                                  label: 'To Date',
                                  controller: _toDateController,
                                  top: 46.h,
                                  left: 44.w,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Dropdown(
                                  hint: 'select category',
                                  showHelp: true,
                                  items: ['All'],
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
                                  label: "Priority",
                                  hint: 'select priority',
                                  items: ['All'],
                                  selectedValue: selectedPriority,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedPriority = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 1.h),

                          Row(
                            children: [
                              Expanded(
                                child: Dropdown(
                                  label: "Staff",
                                  hint: 'select staff',
                                  items: ['All'],
                                  selectedValue: selectedStaff,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedStaff = val;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Dropdown(
                                  label: "Rejected Reason",
                                  hint: 'select reason',
                                  showHelp: true,
                                  items: [],
                                  selectedValue: selectedRejectedReason,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedRejectedReason = val;
                                    });
                                  },
                                  message: '.',
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Dropdown(
                                  label: "Lead Source",
                                  hint: 'select source',
                                  items: [],
                                  selectedValue: selectedLeadSource,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedLeadSource = val;
                                    });
                                  },
                                  message: ".",
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Dropdown(
                                  label: "Call Status",
                                  hint: 'select status',
                                  items: [],
                                  selectedValue: selectedCallStatus,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedCallStatus = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 1.h),

                          /// 🔥 VIEW BUTTON (perfect aligned)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
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
                          ),
                        ],
                      ),
                    ),
                    Divider(color: AppColors.divider),
                    SizedBox(height: 2.h),
                    ShowEntries(),

                    SizedBox(height: 2.h),
                    SizedBox(
                      child: CustomTable(
                        columns: [
                          // TableColumn(title: "", flex: 1),
                          TableColumn(title: "#", flex: 1),
                          TableColumn(title: "Name", flex: 4),
                          TableColumn(title: "Contact No.", flex: 4),
                          TableColumn(title: "Lead Category", flex: 4),
                          TableColumn(title: "Staff ", flex: 4),
                          TableColumn(title: "Status", flex: 4),
                          TableColumn(title: "Reason", flex: 4),
                          TableColumn(title: "Followup Date", flex: 4),
                          TableColumn(title: "Called Date", flex: 4),
                          TableColumn(title: "Created Date", flex: 4),
                          TableColumn(title: "Action", flex: 2),
                        ],
                        rows:
                            [
                              [
                                "1",
                                "name",
                                "1234567890",
                                "test",
                                "test",
                                "test",
                                "test",
                                "test",
                                "test",
                                "test",
                              ],
                              [
                                "1",
                                "name",
                                "1234567890",
                                "test",
                                "test",
                                "test",
                                "test",
                                "test",
                                "test",
                                "test",
                              ],
                              [
                                "1",
                                "name",
                                "1234567890",
                                "test",
                                "test",
                                "test",
                                "test",
                                "test",
                                "test",
                                "test",
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
                                Text(row[8], style: AppTextStyle.medium()),
                                Text(row[9], style: AppTextStyle.medium()),

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

  Widget _radio(String text, bool selected) {
    return Row(
      children: [
        Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          size: 13.sp,
          color: AppColors.green,
        ),
        SizedBox(width: 0.5.w),
        Text(
          text,
          style: AppTextStyle.small(
            size: 11.sp,
            color: AppColors.black,
            weight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 0.5.w),
        Container(
          height: 1.8.h,
          width: 1.8.h,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.green),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              "?",
              style: TextStyle(fontSize: 9.sp, color: AppColors.green),
            ),
          ),
        ),
      ],
    );
  }
}
