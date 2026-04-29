import 'package:flutter/material.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/core/utils/popup_msg.dart';
import 'package:sizer/sizer.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';

class LeadCategory extends StatefulWidget {
  const LeadCategory({super.key});

  @override
  State<LeadCategory> createState() => _LeadCategoryState();
}

class _LeadCategoryState extends State<LeadCategory> {
  int? hoveringIndex;

  final TextEditingController categoryController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  int selectedEntries = 10;
  String selectedValue = '10';
  List<String> dropdownItems = ['10', '20', '30', '40', '50'];

  final List<Map<String, String>> data = [
    {"id": "1", "name": "Need Further Followup", "created": "Boss"},
    {
      "id": "2",
      "name": "Not Contacted",
      "created": "Oxdo technologies pvt ltd",
    },
    {"id": "3", "name": "Fake", "created": "Boss"},
    {"id": "4", "name": "Visited", "created": "Boss"},
    {"id": "5", "name": "May Visit", "created": "Boss"},
    {"id": "6", "name": "Converted", "created": "Boss"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBreadcrumbBar(subTitle: 'Lead Category', title: 'Dashboard'),

            /// 🔹 MAIN CONTENT
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(3),
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
                                "Lead Category",
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
                                    "Lead Category is the type of\nproduct, service, or solution a\npotential customer is\ninterested in, helping\nbusinesses identify and\nclassify inquiries for better\nfollow-up.",
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                waitDuration: Duration(milliseconds: 200),
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

                          Row(
                            children: [
                              _actionBtn(
                                0,
                                "Add New",
                                AppColors.greenLight,
                                AppColors.green,
                                () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AppDialog(
                                        title: 'Add Lead Category',
                                        body: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            /// Lead Category
                                            const Text("Lead Category"),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller: categoryController,
                                              decoration: InputDecoration(
                                                hintText: "Enter Category",
                                                hintStyle: AppTextStyle.medium(
                                                  size: 11.sp,
                                                  color: AppColors.grey,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 16),

                                            /// Cost
                                            const Text("Cost"),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller: costController,
                                              decoration: InputDecoration(
                                                hintText: "Enter Category",
                                                hintStyle: AppTextStyle.medium(
                                                  size: 11.sp,
                                                  color: AppColors.grey,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // submitText: 'Submit',
                                        onSubmit: () {
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              SizedBox(width: 1.w),
                              _actionBtn(
                                1,
                                "Import",
                                AppColors.blueLight,
                                AppColors.primary,
                                () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AppDialog(
                                        title: 'Bulk Upload',
                                        body: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            /// Lead Category
                                            Text(
                                              "Import CSV File",
                                              style: AppTextStyle.medium(
                                                size: 11.sp,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Container(
                                              height: 5.h,
                                              width: 50.w,
                                              decoration: BoxDecoration(
                                                color: AppColors.white,
                                                border: Border.all(
                                                  color: AppColors.divider,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.file_upload),
                                                  SizedBox(width: 1.h),
                                                  Text(
                                                    "Upload CSV File",
                                                    style:
                                                        AppTextStyle.medium(),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(height: 16),
                                            Text(
                                              'Simple File',
                                              style: AppTextStyle.small(
                                                color: Colors.indigo,
                                                size: 11.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // submitText: 'Submit',
                                        onSubmit: () {
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              SizedBox(width: 1.w),
                              _actionBtn(
                                2,
                                "Bulk Add",
                                AppColors.orangeLight,
                                AppColors.orange,
                                () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AppDialog(
                                        title: 'Bulk Add Category',
                                        body: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            /// Lead Category
                                            const Text("Lead Category"),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller: categoryController,
                                              decoration: InputDecoration(
                                                hintText: "Enter Category",
                                                hintStyle: AppTextStyle.medium(
                                                  size: 11.sp,
                                                  color: AppColors.grey,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 16),
                                          ],
                                        ),
                                        // submitText: 'Submit',
                                        onSubmit: () {
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 1.h),
                    Divider(color: AppColors.divider),
                    SizedBox(height: 3.h),

                    /// 🔹 FILTER ROW
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

                    /// 🔹 TABLE (FIXED)
                    SizedBox(
                      child: CustomTable(
                        columns: [
                          TableColumn(title: "#", flex: 1),
                          TableColumn(title: "Category Name", flex: 4),
                          TableColumn(title: "Created By", flex: 4),
                          TableColumn(title: "Action", flex: 2),
                        ],
                        rows:
                            [
                              ["1", "Need further followup", "Boss", ""],
                              ["2", "Need further followup", "Boss", ""],
                              ["3", "Need further followup", "Boss", ""],
                              ["4", "Need further followup", "Boss", ""],
                              ["5", "Need further followup", "Boss", ""],
                              ["6", "Need further followup", "Boss", ""],
                            ].map((row) {
                              return [
                                Text(row[0], style: AppTextStyle.medium()),
                                Text(row[1], style: AppTextStyle.medium()),
                                Text(row[2], style: AppTextStyle.medium()),

                                /// ACTION
                                Row(
                                  children: [
                                    Icon(
                                      Icons.menu,
                                      size: 14.sp,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 0.5.w),
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 14.sp,
                                      color: Colors.blue,
                                    ),
                                    Icon(
                                      Icons.delete_outline,
                                      size: 14.sp,
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ];
                            }).toList(),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    /// 🔹 FOOTER
                    Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Showing 1 to 6 of 6 entries",
                            style: AppTextStyle.medium(weight: FontWeight.w400),
                          ),

                          Row(
                            children: [
                              _paginationBtn("Previous", false),
                              SizedBox(width: 0.2.w),
                              _paginationBtn("1", true),
                              SizedBox(width: 0.2.w),
                              _paginationBtn("Next", false),
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

  /// 🔹 ACTION BUTTON
  Widget _actionBtn(
    int index,
    String text,
    Color bg,
    Color color,
    VoidCallback onTap,
  ) {
    final isHovering = hoveringIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveringIndex = index),
      onExit: (_) => setState(() => hoveringIndex = null),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 5.h,
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: isHovering ? color : bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              text,
              style: AppTextStyle.small(
                color: isHovering ? Colors.white : color,
                size: 10.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 TABLE ROW
  Widget _tableRow(Map<String, String> e) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.8.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: _cell(e["id"]!)),
          Expanded(flex: 4, child: _cell(e["name"]!)),
          Expanded(flex: 3, child: _cell(e["created"]!)),

          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.list, color: AppColors.green, size: 18),
                SizedBox(width: 1.w),
                Icon(Icons.edit, color: AppColors.primary, size: 18),
                SizedBox(width: 1.w),
                Icon(Icons.delete, color: AppColors.red, size: 18),
              ],
            ),
          ),
        ],
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

  /// 🔹 CELL
  Widget _cell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: Text(text, style: AppTextStyle.body()),
    );
  }

  /// 🔹 PAGINATION BUTTON
  Widget _paginationBtn(String text, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.container,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyle.body(
          color: active ? AppColors.white : AppColors.grey,
        ),
      ),
    );
  }

  /// 🔹 BORDER BOX
  BoxDecoration _borderBox() {
    return BoxDecoration(
      border: Border.all(color: AppColors.lightGrey),
      borderRadius: BorderRadius.circular(4),
    );
  }
}

/// 🔹 HEADER TEXT
class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: Text(text, style: AppTextStyle.medium(weight: FontWeight.w600)),
    );
  }
}
