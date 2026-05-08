import 'package:flutter/material.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/footer.dart';
import 'package:oxdo/core/utils/input_date.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:sizer/sizer.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';

class TransferLeads extends StatefulWidget {
  const TransferLeads({super.key});

  @override
  State<TransferLeads> createState() => _TransferLeadsState();
}

class _TransferLeadsState extends State<TransferLeads> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  final List<String> leadCategory = [
    "Select lead Type ",
    "Need Further Followup",
    "Not Contacted",
    "Fake",
    "Visited",
    "May vist",
    "Not Interested",
    "Converted",
    "Lost",
  ];

  final List<String> status = [
    "Select Status",
    "In Progress",
    "Not Contacted",
    "Fake",
    "Visited",
    "May Vist",
    "Not Interested",
    "Converted",
    "Lost",
  ];

  final List<String> staff = [
    "Select Staff",
    "John Doe",
    "Jane Smith",
    "Bob Johnson",
    "Alice Williams",
  ];

  final List<String> leadSource = ["Direct Entry", "ADS", "Whatsapp"];
  final List<String> priority = ["High", "Low", "Negative", "Normal"];
  final List<String> leadStage = ["New", "Follow Up", "Closed", 'Rejected'];

  String? selectedCategory;
  String? selectedSource;
  String? selectedPriority;
  String? selectedLeadStage;
  String? selectedStatus;
  String? selectedStaff;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBreadcrumbBar(
              subTitle: 'Transfer Leads',
              title: 'Lead Management',
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    /// 🔹 HEADER
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 2.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Transfer Leads",
                            style: AppTextStyle.medium(
                              size: 13.6.sp,
                              color: AppColors.black.withOpacity(0.77),
                              weight: FontWeight.w600,
                            ),
                          ),
                          _topButton("Transfer"),
                        ],
                      ),
                    ),

                    Divider(color: AppColors.divider),

                    /// 🔹 FILTERS
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
                              Expanded(
                                child: InputDate(
                                  label: "From Date",
                                  fromController: _fromDateController,
                                  toController: _toDateController,
                                  isFrom: true, // shows fromDate value
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: InputDate(
                                  label: "To Date",
                                  fromController: _fromDateController,
                                  toController: _toDateController,
                                  isFrom: false, // shows fromDate value
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Dropdown(
                                  label: "Lead Category",
                                  hint: 'select category',
                                  showHelp: true,
                                  items: leadCategory,
                                  selectedValue: selectedCategory,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedCategory = val;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Dropdown(
                                  label: "Lead Status",
                                  hint: 'select status',
                                  showHelp: true,
                                  items: status,
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

                          SizedBox(height: 2.h),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 17.65.w,
                                child: Dropdown(
                                  label: "Lead Source",
                                  hint: 'select source',
                                  showHelp: true,
                                  items: leadSource,
                                  selectedValue: selectedSource,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedSource = val;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 2.w),
                              SizedBox(
                                width: 17.65.w,
                                child: Dropdown(
                                  label: "Priority",
                                  hint: 'select priority',
                                  showHelp: true,
                                  items: priority,
                                  selectedValue: selectedPriority,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedPriority = val;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 2.w),
                              SizedBox(
                                width: 17.65.w,
                                child: Dropdown(
                                  label: "Staff",
                                  hint: 'select staff',
                                  showHelp: true,
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
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Divider(color: AppColors.divider),

                    /// 🔹 TABLE CONTROLS
                    ShowEntries(),

                    /// 🔹 TABLE HEADER
                    SizedBox(
                      child: CustomTable(
                        columns: [
                          // TableColumn(title: "", flex: 1),
                          TableColumn(title: "#", flex: 1),
                          TableColumn(title: "Name", flex: 4),
                          TableColumn(title: "Contact Number", flex: 4),
                          TableColumn(title: "Lead Category", flex: 4),
                          TableColumn(title: "Staff", flex: 4),
                          TableColumn(title: "Lead Status", flex: 4),
                          TableColumn(title: "Created Date", flex: 4),
                          TableColumn(title: "Action", flex: 2),
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
                                "Created Date",
                                "Cost",
                                "Lead Source",
                                "",
                              ],
                              [
                                "2",
                                "name",
                                "1234567890",
                                "category",
                                "Last Updated",
                                "Staff",
                                "Status",
                                "Created Date",
                                "Cost",
                                "Lead Source",
                                "",
                              ],
                              [
                                "3",
                                "name",
                                "1234567890",
                                "category",
                                "Last Updated",
                                "Staff",
                                "Status",
                                "Created Date",
                                "Cost",
                                "Lead Source",
                                "",
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
                                // Text(row[7], style: AppTextStyle.medium()),

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
                        showCheckboxes: true,
                        // initialCheckedStates: [false, false, false], // optional
                        onCheckChanged: (index, isChecked) {
                          print("Row $index is now $isChecked");
                        },
                      ),
                    ),

                    /// 🔹 FOOTER
                    Footer(),

                    /// 🔹 BOTTOM TRANSFER BUTTON
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Center(child: _bottomButton("Transfer")),
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

  /// ================= UI COMPONENTS =================

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

  Widget _topButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.1.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyle.small(
          size: 11.sp,
          weight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _bottomButton(String text) {
    return Container(
      width: 5.w,
      padding: EdgeInsets.all(0.5.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyle.small(size: 11.sp, color: Colors.white),
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

  BoxDecoration _box() {
    return BoxDecoration(
      border: Border.all(color: AppColors.lightGrey),
      borderRadius: BorderRadius.circular(4),
      color: AppColors.white,
    );
  }
}
