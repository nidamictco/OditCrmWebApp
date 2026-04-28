import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/utils/footer.dart';
import 'package:login_2_it_solution/core/utils/input_date.dart';
import 'package:login_2_it_solution/core/utils/table.dart';
import 'package:login_2_it_solution/core/utils/top_bread_crumb_bar.dart';
import 'package:sizer/sizer.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';

class PhoneCallLog extends StatefulWidget {
  const PhoneCallLog({super.key});

  @override
  State<PhoneCallLog> createState() => _PhoneCallLogState();
}

class _PhoneCallLogState extends State<PhoneCallLog> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  String selectedValue = '10';
  List<String> dropdownItems = ['10', '20', '30', '40', '50'];

  final List<String> staff = [
    "Select Staff",
    "John Doe",
    "Jane Smith",
    "Bob Johnson",
    "Alice Williams",
  ];
  String? selectedStaff;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBreadcrumbBar(
              subTitle: 'Phone Call Log',
              title: 'Lead Management',
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                decoration: _cardBox(),
                child: Column(
                  children: [
                    /// 🔹 HEADER
                    Padding(
                      padding: EdgeInsets.only(
                        left: 2.w,
                        right: 15.w,
                        top: 2.h,
                        bottom: 1.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Phone Call Log",
                            style: AppTextStyle.medium(
                              size: 13.6.sp,
                              color: AppColors.black.withOpacity(0.77),
                              weight: FontWeight.w600,
                            ),
                          ),

                          /// Manual Call Checkbox
                          Row(
                            children: [
                              Container(
                                height: 2.5.h,
                                width: 2.5.h,
                                decoration: BoxDecoration(
                                  color: AppColors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              SizedBox(width: 0.5.w),
                              Text(
                                "Manual Call",
                                style: AppTextStyle.small(size: 11.sp),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Divider(color: AppColors.divider),

                    /// 🔹 FILTERS
                    Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 17.5.w,
                            child: InputDate(
                              label: "From Date",
                              controller: _fromDateController,
                              left: 25.w,
                              top: 43.h,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          SizedBox(
                            width: 17.5.w,
                            child: InputDate(
                              label: "To Date",
                              controller: _toDateController,
                              left: 40.w,
                              top: 43.h,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          SizedBox(
                            width: 17.5.w,
                            child: _dropdown(
                              "Staff",
                              items: staff,
                              selectedValue: selectedStaff,
                              onChanged: (val) {
                                setState(() {
                                  selectedStaff = val;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 2.w),
                          _viewButton(),
                        ],
                      ),
                    ),

                    Divider(color: AppColors.divider),

                    /// 🔹 TABLE CONTROLS
                    Padding(
                      padding: EdgeInsets.only(
                        top: 1.h,
                        left: 2.w,
                        right: 2.w,
                        bottom: 1.h,
                      ),
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
                                decoration: _box(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// 🔹 TABLE
                    SizedBox(
                      child: CustomTable(
                        columns: [
                          // TableColumn(title: "", flex: 1),
                          TableColumn(title: "#", flex: 1),
                          TableColumn(title: "Name", flex: 4),
                          TableColumn(title: "Phone No", flex: 4),
                          TableColumn(title: "Duration", flex: 4),
                          TableColumn(title: "Call Type", flex: 4),
                          TableColumn(title: "Sim", flex: 4),
                          TableColumn(title: "Time", flex: 4),
                          TableColumn(title: "User", flex: 4),
                          TableColumn(title: "Action", flex: 2),
                        ],
                        rows:
                            [
                              [
                                "1",
                                "name",
                                "1234567890",
                                "10 min",
                                "Incoming",
                                "SIM 1",
                                "10:30 AM",
                                "Admin",
                              ],
                              [
                                "1",
                                "name",
                                "1234567890",
                                "10 min",
                                "Incoming",
                                "SIM 1",
                                "10:30 AM",
                                "Admin",
                              ],
                              [
                                "1",
                                "name",
                                "1234567890",
                                "10 min",
                                "Incoming",
                                "SIM 1",
                                "10:30 AM",
                                "Admin",
                              ],
                              [
                                "1",
                                "name",
                                "1234567890",
                                "10 min",
                                "Incoming",
                                "SIM 1",
                                "10:30 AM",
                                "Admin",
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

                    /// 🔹 FOOTER
                    // Padding(
                    //   padding: EdgeInsets.symmetric(
                    //     horizontal: 2.w,
                    //     vertical: 1.5.h,
                    //   ),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text(
                    //         "Showing 0 to 0 of 0 entries",
                    //         style: AppTextStyle.medium(
                    //           size: 11.sp,
                    //           weight: FontWeight.w400,
                    //         ),
                    //       ),
                    //       Row(
                    //         children: [
                    //           Container(
                    //             padding: EdgeInsets.symmetric(
                    //               horizontal: 2.w,
                    //               vertical: 1.h,
                    //             ),
                    //             decoration: BoxDecoration(
                    //               border: Border(
                    //                 top: BorderSide(color: AppColors.lightGrey),
                    //                 bottom: BorderSide(
                    //                   color: AppColors.lightGrey,
                    //                 ),
                    //                 left: BorderSide(
                    //                   color: AppColors.lightGrey,
                    //                 ),
                    //               ),
                    //               borderRadius: BorderRadius.only(
                    //                 topLeft: Radius.circular(4),
                    //                 bottomLeft: Radius.circular(4),
                    //               ),
                    //             ),
                    //             child: Text(
                    //               'Previous',
                    //               style: AppTextStyle.small(
                    //                 size: 11.sp,
                    //                 color: AppColors.grey,
                    //               ),
                    //             ),
                    //           ),

                    //           Container(
                    //             padding: EdgeInsets.symmetric(
                    //               horizontal: 2.w,
                    //               vertical: 1.h,
                    //             ),
                    //             decoration: BoxDecoration(
                    //               border: Border.all(
                    //                 color: AppColors.lightGrey,
                    //               ),
                    //               borderRadius: BorderRadius.only(
                    //                 topRight: Radius.circular(4),
                    //                 bottomRight: Radius.circular(4),
                    //               ),
                    //             ),
                    //             child: Text(
                    //               'Next',
                    //               style: AppTextStyle.small(
                    //                 size: 11.sp,
                    //                 color: AppColors.grey,
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Footer(),

                    /// 🔹 TOTAL DURATION
                    Padding(
                      padding: EdgeInsets.only(right: 2.w, bottom: 2.h),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Total Duration : 00:00:00",
                          style: AppTextStyle.medium(
                            size: 12.sp,
                            weight: FontWeight.w600,
                            color: AppColors.red,
                          ),
                        ),
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

  /// ================= COMMON UI =================

  BoxDecoration _cardBox() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: AppColors.divider),
    );
  }

  Widget _input(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.small(
            size: 11.sp,
            color: AppColors.black,
            weight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.3.h),
        Container(
          height: 4.5.h,
          decoration: _box(),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Text(
            value,
            style: AppTextStyle.small(
              size: 11.sp,
              color: AppColors.black,
              weight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(
    String label, {
    List<String> items = const [],
    String? selectedValue,
    Function(String?)? onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.small(
            size: 11.sp,
            color: AppColors.black,
            weight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 0.5.h),

        Container(
          height: 5.h,
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          decoration: _box(),

          child: DropdownSearch<String>(
            items: items,
            selectedItem: selectedValue,

            /// ✅ FIX (NO CRASH)
            enabled: enabled && items.isNotEmpty,

            popupProps: PopupProps.menu(
              showSearchBox: true,
              fit: FlexFit.loose,
              constraints: const BoxConstraints(maxHeight: 300),
            ),

            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: "Select $label",
                hintStyle: AppTextStyle.small(
                  size: 11.sp,
                  color: AppColors.grey,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            dropdownBuilder: (context, selectedItem) {
              final isHint = selectedItem == null;

              return Text(
                isHint ? "Select $label" : selectedItem,
                overflow: TextOverflow.ellipsis,
                style: isHint
                    ? AppTextStyle.small(size: 11.sp, color: AppColors.grey)
                    : AppTextStyle.medium(size: 11.sp),
              );
            },

            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _viewButton() {
    return SizedBox(
      width: 8.w,
      height: 4.5.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            "View",
            style: AppTextStyle.small(size: 10.sp, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _checkbox() {
    return SizedBox(
      width: 4.w,
      child: Checkbox(
        value: false,
        onChanged: (v) {},
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _smallDropdown() {
    return Container(
      width: 4.2.w,
      height: 4.h,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: _box(),
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

  BoxDecoration _box() {
    return BoxDecoration(
      border: Border.all(color: AppColors.lightGrey),
      borderRadius: BorderRadius.circular(4),
      color: AppColors.white,
    );
  }
}
