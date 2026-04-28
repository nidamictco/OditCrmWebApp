import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:login_2_it_solution/core/utils/table.dart';
import 'package:login_2_it_solution/core/utils/top_bread_crumb_bar.dart';
import 'package:sizer/sizer.dart';

class LeadStagesScreen extends StatefulWidget {
  const LeadStagesScreen({super.key});

  @override
  State<LeadStagesScreen> createState() => _LeadStagesScreenState();
}

class _LeadStagesScreenState extends State<LeadStagesScreen> {
  String selectedValue = '10';
  List<String> dropdownItems = ['10', '20', '30', '40', '50'];
  bool isHovering = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBreadcrumbBar(subTitle: "Lead Stages", title: "Dashboard"),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: AppColors.lightGrey),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 HEADER
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Lead Stages",
                                style: AppTextStyle.medium(
                                  size: 13.6.sp,
                                  color: AppColors.black.withOpacity(0.77),
                                  weight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 0.2.w),
                              Tooltip(
                                textAlign: TextAlign.center,
                                message:
                                    "Lead Stages lets you track the\nstage of a lead, and you can\nadd new statuses as needed\nto match your sales process.",
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                waitDuration: const Duration(milliseconds: 200),
                                child: Container(
                                  height: 2.h,
                                  width: 2.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.green,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.question_mark_rounded,
                                    size: 10.sp,
                                    color: AppColors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          MouseRegion(
                            onEnter: (_) => setState(() => isHovering = true),
                            onExit: (_) => setState(() => isHovering = false),
                            child: GestureDetector(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                height: 5.h,
                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                decoration: BoxDecoration(
                                  color: isHovering
                                      ? AppColors.green
                                      : AppColors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    "Add New",
                                    style: AppTextStyle.small(
                                      color: isHovering
                                          ? Colors.white
                                          : AppColors.green,
                                      size: 10.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 1.h),
                    Divider(color: AppColors.divider),
                    SizedBox(height: 3.h),

                    /// 🔹 SWITCH
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        children: [
                          Text(
                            "Priority Required for All Stages",
                            style: AppTextStyle.medium(),
                          ),
                          SizedBox(width: 0.4.w),
                          Transform.scale(
                            scale: 0.6,
                            child: Switch(
                              value: false,
                              activeColor: AppColors.primary,
                              onChanged: (value) {},
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    /// 🔹 FILTER
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Show ",
                                style: AppTextStyle.medium(
                                  size: 11.sp,
                                  weight: FontWeight.w400,
                                ),
                              ),
                              _smallDropdown(),
                              Text(
                                " entries",
                                style: AppTextStyle.medium(
                                  size: 11.sp,
                                  weight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Text(
                                "Search:",
                                style: AppTextStyle.medium(
                                  size: 11.sp,
                                  weight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 1.w),
                              Container(
                                width: 12.w,
                                height: 4.h,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.lightGrey,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    /// 🔹 TABLE
                    SizedBox(
                      child: CustomTable(
                        columns: [
                          TableColumn(title: "#", flex: 1),
                          TableColumn(title: "Lead Stage", flex: 4),
                          TableColumn(title: "Created By", flex: 4),
                          TableColumn(title: "Action", flex: 2),
                        ],
                        rows:
                            [
                              ["1", "New", "-", ""],
                              ["2", "Follow Up", "-", ""],
                              ["3", "Rejected", "-", ""],
                              ["4", "Closed", "-", ""],
                              ["5", "Pending", "-", ""],
                            ].map((row) {
                              return [
                                Text(row[0], style: AppTextStyle.medium()),
                                Text(row[1], style: AppTextStyle.medium()),
                                Text(row[2], style: AppTextStyle.medium()),

                                /// ACTION
                                Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 14.sp,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ];
                            }).toList(),
                      ),
                    ),

                    /// 🔹 FOOTER
                    Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Showing 1 to 5 of 5 entries",
                            style: AppTextStyle.medium(weight: FontWeight.w400),
                          ),
                          Row(
                            children: [
                              _paginationButton("Previous", false),
                              SizedBox(width: 0.1.w),
                              _pageNumber("1", true),
                              SizedBox(width: 1.w),
                              _paginationButton("Next", false),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataColumn _column(String title) {
    return DataColumn(
      label: Text(title, style: AppTextStyle.medium(weight: FontWeight.w600)),
    );
  }

  DataRow _row(int index) {
    final item = _data[index];

    return DataRow(
      cells: [
        DataCell(Text("${index + 1}")),
        DataCell(Text(item['stage'] ?? '—')),
        DataCell(Text("-")),
        DataCell(Icon(Icons.edit, color: AppColors.primary, size: 18)),
      ],
    );
  }

  Widget _smallDropdown() {
    return Container(
      width: 4.2.w,
      height: 4.h,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(4),
        color: AppColors.white,
      ),
      alignment: Alignment.center,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 16),
          style: AppTextStyle.small(size: 11.sp),
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue!;
            });
          },
          items: dropdownItems.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: AppTextStyle.small(size: 11.sp)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _paginationButton(String text, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.container,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Text(text),
    );
  }

  Widget _pageNumber(String text, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.container,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: active ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _customTable() {
    return Container(
      // height: ,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          /// 🔹 HEADER
          Container(
            padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
            decoration: BoxDecoration(
              color: AppColors.greyCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: Row(
              children: [
                _headerCell("#", 1),
                _headerCell("Lead Stage", 4),
                _headerCell("Created By", 4),
                _headerCell("Action", 2),
              ],
            ),
          ),

          /// 🔹 ROWS
          ...List.generate(_data.length, (index) {
            final item = _data[index];

            return Container(
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.lightGrey)),
              ),
              child: Row(
                children: [
                  _cell("${index + 1}", 1),
                  _cell(item['stage'] ?? '-', 4),
                  _cell("", 4),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _headerCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTextStyle.medium(weight: FontWeight.w600, size: 11.sp),
      ),
    );
  }

  Widget _cell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: AppTextStyle.small(size: 11.sp)),
      ),
    );
  }
}

/// MOCK DATA
final List<Map<String, String>> _data = [
  {"stage": "New"},
  {"stage": "Follow Up"},
  {"stage": "Rejected"},
  {"stage": "Closed"},
  {"stage": "Pending"},
];
