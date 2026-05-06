import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/input_date.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/feature/lead_managment/add_lead/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/add_lead/cubit/add_lead_state.dart';
import 'package:oxdo/feature/lead_managment/add_lead/model/add_lead_model.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';

class LeadsReport extends StatefulWidget {
  const LeadsReport({super.key});

  @override
  State<LeadsReport> createState() => _LeadsReportState();
}

class _LeadsReportState extends State<LeadsReport> {
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();
  String selectedValue = "10";

  final List<String> dropdownItems = ["10", "100", "1200", "3000"];

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

  final List<String> createdBy = [
    "Select Created By",
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
  String? selectedCreatedBy;

  @override
void initState() {
  super.initState();
  context.read<AddLeadCubit>().fetchLeads();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBreadcrumbBar(
              subTitle: 'Leads Report',
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
                    /// 🔹 TITLE BAR
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 2.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Leads Report",
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
                                  label: "From Date",
                                  controller: fromDate,
                                  top: 48.h,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: InputDate(
                                  label: "To Date",
                                  controller: toDate,
                                  top: 48.h,
                                  left: 38.w,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Dropdown(
                                  hint: 'select category',
                                  showHelp: true,
                                  items: leadCategory,
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
                                  label: "Lead Stage",
                                  hint: 'select stage',
                                  showHelp: true,
                                  items: leadStage,
                                  selectedValue: selectedLeadStage,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedLeadStage = val;
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
                                  label: "Priority",
                                  hint: 'select priority',
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
                              Expanded(
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
                                  message: '.',
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Dropdown(
                                  label: "Staff",
                                  hint: 'select staff',
                                  items: staff,
                                  selectedValue: selectedStaff,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedStaff = val;
                                    });
                                  },
                                  message: ".",
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Dropdown(
                                  label: "Create By",
                                  hint: 'select creator',
                                  items: createdBy,
                                  selectedValue: selectedCreatedBy,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedCreatedBy = val;
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
                                  label: "State",
                                  hint: "select state",
                                ),
                              ),
                              SizedBox(width: 2.w),
                              SizedBox(
                                width: 17.45.w,
                                child: Dropdown(
                                  label: "District",
                                  hint: "select district",
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
                        ],
                      ),
                    ),

                    Divider(color: AppColors.divider),

                    /// 🔹 TABLE CONTROLS
                    
                    ShowEntries(),

                    // SizedBox(
                    //   child: CustomTable(
                    //     columns: [
                    //       TableColumn(title: "#", flex: 1),
                    //       TableColumn(title: "Name", flex: 4),
                    //       TableColumn(title: "Phone No", flex: 4),
                    //       TableColumn(title: "Category", flex: 4),
                    //       TableColumn(title: "Last Updated", flex: 4),
                    //       TableColumn(title: "Staff", flex: 4),
                    //       TableColumn(title: "Status", flex: 4),
                    //       TableColumn(title: "Created Date", flex: 4),
                    //       TableColumn(title: "Cost", flex: 4),
                    //       TableColumn(title: "Lead Source", flex: 4),
                    //       TableColumn(title: "Action", flex: 2),
                    //     ],
                    //     rows:
                    //         [
                    //           [
                    //             "1",
                    //             "name",
                    //             "1234567890",
                    //             "category",
                    //             "Last Updated",
                    //             "Staff",
                    //             "Status",
                    //             "Created Date",
                    //             "Cost",
                    //             "Lead Source",
                    //             "",
                    //           ],
                    //           [
                    //             "2",
                    //             "name",
                    //             "1234567890",
                    //             "category",
                    //             "Last Updated",
                    //             "Staff",
                    //             "Status",
                    //             "Created Date",
                    //             "Cost",
                    //             "Lead Source",
                    //             "",
                    //           ],
                    //           [
                    //             "3",
                    //             "name",
                    //             "1234567890",
                    //             "category",
                    //             "Last Updated",
                    //             "Staff",
                    //             "Status",
                    //             "Created Date",
                    //             "Cost",
                    //             "Lead Source",
                    //             "",
                    //           ],
                    //           [
                    //             "4",
                    //             "name",
                    //             "1234567890",
                    //             "category",
                    //             "Last Updated",
                    //             "Staff",
                    //             "Status",
                    //             "Created Date",
                    //             "Cost",
                    //             "Lead Source",
                    //             "",
                    //           ],
                    //           [
                    //             "5",
                    //             "name",
                    //             "1234567890",
                    //             "category",
                    //             "Last Updated",
                    //             "Staff",
                    //             "Status",
                    //             "Created Date",
                    //             "Cost",
                    //             "Lead Source",
                    //             "",
                    //           ],
                    //           [
                    //             "6",
                    //             "name",
                    //             "1234567890",
                    //             "category",
                    //             "Last Updated",
                    //             "Staff",
                    //             "Status",
                    //             "Created Date",
                    //             "Cost",
                    //             "Lead Source",
                    //             "",
                    //           ],
                    //           [
                    //             "7",
                    //             "name",
                    //             "1234567890",
                    //             "category",
                    //             "Last Updated",
                    //             "Staff",
                    //             "Status",
                    //             "Created Date",
                    //             "Cost",
                    //             "Lead Source",
                    //             "",
                    //           ],
                    //           [
                    //             "8",
                    //             "name",
                    //             "1234567890",
                    //             "category",
                    //             "Last Updated",
                    //             "Staff",
                    //             "Status",
                    //             "Created Date",
                    //             "Cost",
                    //             "Lead Source",
                    //             "",
                    //           ],
                    //           [
                    //             "9",
                    //             "name",
                    //             "1234567890",
                    //             "category",
                    //             "Last Updated",
                    //             "Staff",
                    //             "Status",
                    //             "Created Date",
                    //             "Cost",
                    //             "Lead Source",
                    //             "",
                    //           ],
                    //           [
                    //             "10",
                    //             "name",
                    //             "1234567890",
                    //             "category",
                    //             "Last Updated",
                    //             "Staff",
                    //             "Status",
                    //             "Created Date",
                    //             "Cost",
                    //             "Lead Source",
                    //             "",
                    //           ],
                    //           [
                    //             "11",
                    //             "name",
                    //             "1234567890",
                    //             "category",
                    //             "Last Updated",
                    //             "Staff",
                    //             "Status",
                    //             "Created Date",
                    //             "Cost",
                    //             "Lead Source",
                    //             "",
                    //           ],
                    //         ].map((row) {
                    //           return [
                    //             Text(row[0], style: AppTextStyle.medium()),
                    //             Text(row[1], style: AppTextStyle.medium()),
                    //             Text(row[2], style: AppTextStyle.medium()),
                    //             Text(row[3], style: AppTextStyle.medium()),
                    //             Text(row[4], style: AppTextStyle.medium()),
                    //             Text(row[5], style: AppTextStyle.medium()),
                    //             Text(row[6], style: AppTextStyle.medium()),
                    //             Text(row[7], style: AppTextStyle.medium()),
                    //             Text(row[8], style: AppTextStyle.medium()),
                    //             Text(row[9], style: AppTextStyle.medium()),

                    //             /// ACTION
                    //             Center(
                    //               child: Row(
                    //                 mainAxisAlignment: MainAxisAlignment.center,
                    //                 children: [
                    //                   Icon(
                    //                     Icons.edit_outlined,
                    //                     size: 14.sp,
                    //                     color: Colors.blue,
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ];
                    //         }).toList(),
                    //   ),
                    // ),

                   BlocBuilder<AddLeadCubit, AddLeadState>(
  builder: (context, state) {
    // Loading
    if (state.listStatus == LeadListStatus.loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Error
    if (state.listStatus == LeadListStatus.failure) {
      return Padding(
        padding: EdgeInsets.all(4.w),
        child: Text(
          state.listError ?? 'Something went wrong.',
          style: AppTextStyle.medium(color: Colors.red),
        ),
      );
    }

    // Loaded but empty
    if (state.listStatus == LeadListStatus.loaded && state.leads.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Center(
          child: Text("No records found.", style: AppTextStyle.medium()),
        ),
      );
    }

    // Loaded with data
    if (state.listStatus == LeadListStatus.loaded) {
      return CustomTable(
        columns: [
          TableColumn(title: "#", flex: 1),
          TableColumn(title: "Name", flex: 4),
          TableColumn(title: "Phone No", flex: 4),
          TableColumn(title: "Category", flex: 4),
          TableColumn(title: "Staff", flex: 4),
          TableColumn(title: "Status", flex: 4),
          TableColumn(title: "Created Date", flex: 4),
          TableColumn(title: "Lead Source", flex: 4),
          TableColumn(title: "Action", flex: 2),
        ],
        rows: List.generate(state.leads.length, (i) {
          final lead = state.leads[i];
          return [
            Text('${i + 1}', style: AppTextStyle.medium()),
            Text(lead.clientName, style: AppTextStyle.medium()),
            Text(lead.contactNumber, style: AppTextStyle.medium()),
            Text(lead.leadCategory, style: AppTextStyle.medium()),
            Text(lead.assignedStaff, style: AppTextStyle.medium()),
            Text(lead.leadStage, style: AppTextStyle.medium()),
            Text(
              lead.createdAt != null
                  ? DateFormat('dd MMM yyyy').format(lead.createdAt!)
                  : '-',
              style: AppTextStyle.medium(),
            ),
            Text(lead.leadSource, style: AppTextStyle.medium()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MainScreen(selectedIndex: 1,lead:lead),
                      ),
                    ), 
                  child: Icon(Icons.edit,
                      size: 14.sp, color: Colors.blue),
                ),
                GestureDetector(
                  onTap: () =>{
                  _confirmDelete(context, lead),
                  },
                  child: Icon(Icons.delete_outline,
                      size: 14.sp, color: Colors.red),
                ),
              ],
            ),
          ];
        }),
      );
    }

    return const SizedBox();
  },
),

                    /// 🔹 FOOTER
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 1.5.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Showing 0 to 0 of 0 entries",
                            style: AppTextStyle.medium(weight: FontWeight.w400),
                          ),
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
                                    bottom: BorderSide(
                                      color: AppColors.lightGrey,
                                    ),
                                    left: BorderSide(
                                      color: AppColors.lightGrey,
                                    ),
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
                                  border: Border.all(
                                    color: AppColors.lightGrey,
                                  ),
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
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- WIDGETS ----------------

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

  // Widget _dropdown(
  //   String label, {
  //   bool showHelp = false,
  //   List<String> items = const [],
  //   String? selectedValue,
  //   Function(String?)? onChanged,
  //   bool enabled = true,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       /// 🔹 LABEL + OPTIONAL HELP
  //       Row(
  //         children: [
  //           Text(
  //             label,
  //             style: AppTextStyle.small(
  //               size: 11.sp,
  //               color: AppColors.black,
  //               weight: FontWeight.w500,
  //             ),
  //           ),

  //           if (showHelp) ...[
  //             SizedBox(width: 0.5.w),
  //             Container(
  //               height: 1.8.h,
  //               width: 1.8.h,
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: AppColors.green),
  //                 shape: BoxShape.circle,
  //               ),
  //               child: Center(
  //                 child: Text(
  //                   "?",
  //                   style: TextStyle(fontSize: 9.sp, color: AppColors.green),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ],
  //       ),

  //       SizedBox(height: 0.5.h),

  //       /// 🔹 DROPDOWN
  //       Container(
  //         height: 5.h,
  //         padding: EdgeInsets.symmetric(horizontal: 1.w),
  //         decoration: _box(),

  //         child: DropdownSearch<String>(
  //           items: items,
  //           selectedItem: selectedValue,
  //           enabled: enabled && items.isNotEmpty,

  //           /// 🔥 POPUP STYLE
  //           popupProps: PopupProps.menu(
  //             showSearchBox: true,
  //             fit: FlexFit.loose,
  //             constraints: const BoxConstraints(maxHeight: 300),
  //           ),

  //           /// 🔥 INPUT STYLE
  //           dropdownDecoratorProps: DropDownDecoratorProps(
  //             dropdownSearchDecoration: InputDecoration(
  //               hintText: "Select $label",
  //               hintStyle: AppTextStyle.small(
  //                 size: 11.sp,
  //                 color: AppColors.grey,
  //               ),
  //               border: InputBorder.none,
  //               contentPadding: EdgeInsets.zero,
  //             ),
  //           ),

  //           /// 🔥 DISPLAY SELECTED VALUE (IMPORTANT FIX)
  //           dropdownBuilder: (context, selectedItem) {
  //             final isHint = selectedItem == null;

  //             return Text(
  //               isHint ? "Select $label" : selectedItem,
  //               maxLines: 1,
  //               overflow: TextOverflow.ellipsis,
  //               style: isHint
  //                   ? AppTextStyle.small(size: 11.sp, color: AppColors.grey)
  //                   : AppTextStyle.medium(size: 11.sp),
  //             );
  //           },

  //           onChanged: onChanged,
  //         ),
  //       ),
  //     ],
  //   );
  // }

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

  Widget _th(String text) {
    return Expanded(
      child: Text(
        text,
        style: AppTextStyle.medium(weight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      border: Border.all(color: AppColors.divider),
      borderRadius: BorderRadius.circular(3),
      color: AppColors.greyCard,
    );
  }

  // ─── Delete confirmation dialog ────────────────────────────────────────────

  void _confirmDelete(BuildContext ctx, AddLeadModel lead) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Delete Staff', style: AppTextStyle.medium(size: 14.sp)),
        content: Text(
          'Are you sure you want to delete "${lead.clientName}"? This action cannot be undone.',
          style: AppTextStyle.medium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyle.medium(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<AddLeadCubit>().deleteLead(lead.id!);
            },
            child: Text('Delete',
                style: AppTextStyle.medium(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
