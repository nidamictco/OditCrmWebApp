import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/input_date.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:sizer/sizer.dart';

class FollowUpTab extends StatefulWidget {
  const FollowUpTab({super.key});

  @override
  State<FollowUpTab> createState() => _FollowUpTabState();
}

class _FollowUpTabState extends State<FollowUpTab> {

final TextEditingController fromDateController = TextEditingController();
final TextEditingController toDateController = TextEditingController();

  String selectedValue = "10";

  final List<String> dropdownItems = ["10", "100", "1200", "3000"];
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
    return Column(
      children: [
        /// FILTERS
        Padding(
          padding: EdgeInsets.all(2.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
             Expanded(
  child: InputDate(
    label: "From Date",
    fromController: fromDateController,
    toController: toDateController,
    isFrom: true,  // shows fromDate value
  ),
),
SizedBox(width: 2.w),
Expanded(
  child: InputDate(
    label: "To Date",
    fromController: fromDateController,
    toController: toDateController,
    isFrom: false, // shows toDate value
  ),
),
SizedBox(width: 2.w),
              Expanded(child:  _dropdown(
                              "Staff",
                              items: staff,
                              selectedValue: selectedStaff,
                              onChanged: (val) {
                                setState(() {
                                  selectedStaff = val;
                                });
                              },
                            ),),
              SizedBox(width: 2.w),
              _viewButton(),
            ],
          ),
        ),

        Divider(color: AppColors.divider),

        _tableControls(),


         SizedBox(
                      child: CustomTable(
                        columns: [
                          TableColumn(title: "#", flex: 1),
                          TableColumn(title: "Client Name", flex: 4),
                          TableColumn(title: "Contact No", flex: 4),
                          TableColumn(title: "Lead Category", flex: 4),
                          TableColumn(title: "Staff", flex: 4),
                          TableColumn(title: "Status", flex: 4),
                          TableColumn(title: "Called Date", flex: 4),
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
                            ].map((row) {
                              return [
                                Text(row[0], style: AppTextStyle.medium()),
                                Text(row[1], style: AppTextStyle.medium()),
                                Text(row[2], style: AppTextStyle.medium()),
                                Text(row[3], style: AppTextStyle.medium()),
                                Text(row[4], style: AppTextStyle.medium()),
                                Text(row[5], style: AppTextStyle.medium()),
                                Text(row[6], style: AppTextStyle.medium()),
                                

                              ];
                            }).toList(),
                      ),
                    ),

        _footer(),
      ],
    );
  }

  /// ---------- UI ----------

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
    List<String> items=const [],
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
    return Container(
      height: 4.5.h,
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        "View",
        style: AppTextStyle.small(size: 10.sp, color: Colors.white),
      ),
    );
  }

  Widget _tableControls() {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Show ",
                style: AppTextStyle.medium(weight: FontWeight.w400),
              ),
              _smallDropdown(),
              Text(
                " entries",
                style: AppTextStyle.medium(weight: FontWeight.w400),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "Search:",
                style: AppTextStyle.medium(weight: FontWeight.w400),
              ),
              SizedBox(width: 1.w),
              Container(width: 12.w, height: 4.h, decoration: _box()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(List<String> headers) {
    return Container(
      padding: EdgeInsets.all(1.w),
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      color: AppColors.greyCard,
      child: Row(children: headers.map((e) => _th(e)).toList()),
    );
  }

  Widget _empty() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Text(
        "No data available in table",
        style: AppTextStyle.medium(size: 10.sp),
      ),
    );
  }

  Widget _footer() {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Showing 0 to 0 of 0 entries",
            style: AppTextStyle.medium(weight: FontWeight.w400),
          ),
          Row(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.lightGrey),
                        bottom: BorderSide(color: AppColors.lightGrey),
                        left: BorderSide(color: AppColors.lightGrey),
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: AppTextStyle.small(
                        size: 11.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: AppTextStyle.small(
                        size: 11.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------- COMMON ----------

  Widget _th(String text) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyle.medium(weight: FontWeight.w600),
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

  Widget _paginationButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyle.small(size: 10.sp, color: AppColors.grey),
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      border: Border.all(color: AppColors.divider),
      borderRadius: BorderRadius.circular(4),
      color: AppColors.greyCard,
    );
  }
}
