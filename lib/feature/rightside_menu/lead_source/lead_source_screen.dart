import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:sizer/sizer.dart';

class LeadSourceScreen extends StatefulWidget {
  const LeadSourceScreen({super.key});

  @override
  State<LeadSourceScreen> createState() => _LeadSourceScreenState();
}

class _LeadSourceScreenState extends State<LeadSourceScreen> {
  bool isHovering = false;

  String selectedValue = "10";
  final List<String> dropdownItems = ["10", "25", "50", "100"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBreadcrumbBar(subTitle: "Dashboard", title: "Lead Source"),

            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),

                /// ✅ INNER COLUMN SAFE NOW
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
                                "Lead Source",
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
                                    "It refers to the source of the\nlead, showing how the\npotential customer discovered\nor engaged with the business,\nsuch as through marketing\ncampaigns, social media,\nreferrals, events, or website\ninquiries.",
                                decoration: BoxDecoration(
                                  color: AppColors.black,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: TextStyle(
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
                          TableColumn(title: "Lead Source", flex: 4),
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
                          Text("Showing 1 to 8 of 8 entries"),

                          Row(
                            children: [
                              _paginationButton("Previous", false),
                              SizedBox(width: 0.1.w),
                              _paginationNumber("1", true),
                              SizedBox(width: 0.1.w),
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

  DataColumn _column(String title) {
    return DataColumn(
      label: Text(title, style: AppTextStyle.small(weight: FontWeight.w600)),
    );
  }

  DataRow _row(int index) {
    final item = _data[index];

    return DataRow(
      cells: [
        DataCell(Text("${index + 1}")),
        DataCell(Text(item['name'] ?? '—')),
        DataCell(Text(item['createdBy'] ?? "-")),
        DataCell(
          item['createdBy'] == null
              ? Text("-")
              : Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue, size: 18),
                    SizedBox(width: 1.w),
                    Icon(Icons.delete, color: Colors.red, size: 18),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _paginationButton(String text, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text),
    );
  }

  Widget _paginationNumber(String text, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: active ? Colors.white : Colors.black),
      ),
    );
  }
}

/// MOCK DATA
final List<Map<String, String?>> _data = [
  {"name": "Direct Entry", "createdBy": null},
  {"name": "Lead From Facebook", "createdBy": null},
  {"name": "Lead From CSV", "createdBy": null},
  {"name": "Lead From IVR", "createdBy": null},
  {"name": "Lead from Website", "createdBy": null},
  {"name": "Lead From Official WhatsApp", "createdBy": null},
  {"name": "Ads", "createdBy": "Boss"},
  {"name": "WhatsApp", "createdBy": "Oxdo technologies pvt ltd"},
];
