import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:login_2_it_solution/core/utils/dropdown.dart';
import 'package:login_2_it_solution/core/utils/input_date.dart';
import 'package:login_2_it_solution/core/utils/show_entries.dart';
import 'package:login_2_it_solution/core/utils/table.dart';
import 'package:login_2_it_solution/core/utils/top_bread_crumb_bar.dart';
import 'package:login_2_it_solution/feature/sidebar/main_screen.dart';
import 'package:sizer/sizer.dart';

class UnassingnedLead extends StatefulWidget {
  const UnassingnedLead({super.key});

  @override
  State<UnassingnedLead> createState() => _UnassingnedLeadState();
}

class _UnassingnedLeadState extends State<UnassingnedLead> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  List<String> tableRow = [
    "1",
    "name",
    "1234567890",
    "category",
    "Status",
    "Created Date",
    "",
  ];

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

  final List<String> leadSource = ["Direct Entry", "ADS", "Whatsapp"];

  String? selectedCategory;
  String? selectedStatus;
  String? selectedSource;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBreadcrumbBar(
              title: 'Leads Management',
              subTitle: 'Unassigned Leads',
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
                    ///TITLE BAR
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 2.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Unassigned Leads",
                            style: AppTextStyle.medium(
                              size: 13.6.sp,
                              color: AppColors.black.withOpacity(0.77),
                              weight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>MainScreen(selectedIndex: 14,)));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.4.w,
                                vertical: 1.2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Import",
                                style: AppTextStyle.medium(
                                  color: Colors.white,
                                  weight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: AppColors.divider),

                    ///FILTERS
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
                                  label: 'From Date',
                                  controller: _fromDateController,
                                  top: 35.h,
                                  left: 28.w,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: InputDate(
                                  label: "To Date",
                                  controller: _toDateController,
                                  top: 35.h,
                                  left: 42.w,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Dropdown(
                                  showHelp: true,
                                  items: leadCategory,
                                  selectedValue: selectedCategory,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedCategory = val;
                                    });
                                  },
                                  label: "Lead Category",
                                  hint: 'select category',
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

                          SizedBox(height: 1.h),

                          Row(
                            children: [
                              SizedBox(
                                width: 17.45.w,
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

                              SizedBox(width: 2.w),
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
                        ],
                      ),
                    ),

                    Divider(color: AppColors.divider),

                    ///TABLE CONTROLS
                    ShowEntries(),

                    ///TABLE
                    SizedBox(
                      child: CustomTable(
                        columns: [
                          TableColumn(title: "#", flex: 1),
                          TableColumn(title: "Name", flex: 4),
                          TableColumn(title: "Contact Number", flex: 4),
                          TableColumn(title: "Lead Category", flex: 4),
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

                                "Status",
                                "Created Date",
                                "",
                              ],
                              [
                                "2",
                                "name",
                                "1234567890",
                                "category",

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

                                "Status",
                                "Created Date",
                                "Cost",
                                "Lead Source",
                                "",
                              ],
                              [
                                "4",
                                "name",
                                "1234567890",
                                "category",

                                "Status",
                                "Created Date",
                                "Cost",
                                "Lead Source",
                                "",
                              ],
                              [
                                "5",
                                "name",
                                "1234567890",
                                "category",

                                "Status",
                                "Created Date",
                                "Cost",
                                "Lead Source",
                                "",
                              ],
                              [
                                "6",
                                "name",
                                "1234567890",
                                "category",

                                "Status",
                                "Created Date",
                                "Cost",
                                "Lead Source",
                                "",
                              ],
                              [
                                "7",
                                "name",
                                "1234567890",
                                "category",

                                "Status",
                                "Created Date",
                                "Cost",
                                "Lead Source",
                                "",
                              ],
                              [
                                "8",
                                "name",
                                "1234567890",
                                "category",

                                "Status",
                                "Created Date",
                                "Cost",
                                "Lead Source",
                                "",
                              ],
                              [
                                "9",
                                "name",
                                "1234567890",
                                "category",

                                "Status",
                                "Created Date",
                                "Cost",
                                "Lead Source",
                                "",
                              ],
                              [
                                "10",
                                "name",
                                "1234567890",
                                "category",

                                "Status",
                                "Created Date",
                                "Cost",
                                "Lead Source",
                                "",
                              ],
                              [
                                "11",
                                "name",
                                "1234567890",
                                "category",

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
