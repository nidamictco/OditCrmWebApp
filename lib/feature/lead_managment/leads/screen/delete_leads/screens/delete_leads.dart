import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/footer.dart';
import 'package:oxdo/core/utils/input_date.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';
import 'package:sizer/sizer.dart';

class DeleteLeads extends StatefulWidget {
  const DeleteLeads({super.key});

  @override
  State<DeleteLeads> createState() => _DeleteLeadsState();
}

class _DeleteLeadsState extends State<DeleteLeads> {
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

  final List<String> assingedStaff = ["John", "Doe", "Smith", "Alice", "Bob"];
  final List<String> leadSource = ["Direct Entry", "ADS", "Whatsapp"];
  final List<String> deletedBy = ["John", "Doe", "Smith", "Alice", "Bob"];

  String? selectedCategory;
  String? selectedSource;
  String? selectedDeletedBy;
  String? selectedAssignedStaff;

  String _searchQuery = '';
  String _selectedEntries = '10';

  @override
  void initState() {
    super.initState();
    context.read<AddLeadCubit>().fetchDeletedLeads();
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  List<AddLeadModel> _filteredLeads(List<AddLeadModel> leads) {
    List<AddLeadModel> result = leads;

    // Search filter
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (lead) =>
                (lead.clientName).toLowerCase().contains(q) ||
                (lead.contactNumber).toLowerCase().contains(q),
          )
          .toList();
    }

    // Entries limit
    final limit = int.tryParse(_selectedEntries) ?? 10;
    return result.take(limit).toList();

    // // Date filter
    // final fromDate = _fromDateController.text.trim();
    // final toDate = _toDateController.text.trim();

    // if (fromDate.isNotEmpty || toDate.isNotEmpty) {
    //   result = result.where((lead) {
    //     final leadDateStr = lead.date;
    //     if (leadDateStr == null || leadDateStr.isEmpty) return false;

    //     final leadDate = DateTime.tryParse(leadDateStr.split('T')[0]);
    //     if (leadDate == null) return false;

    //     if (fromDate.isNotEmpty) {
    //       final fDate = DateTime.tryParse(fromDate);
    //       if (fDate != null && leadDate.isBefore(fDate)) return false;
    //     }
    //     if (toDate.isNotEmpty) {
    //       final tDate = DateTime.tryParse(toDate);
    //       if (tDate != null && leadDate.isAfter(tDate)) return false;
    //     }

    //     return true;
    //   }).toList();
    // }

    // // Category filter
    // if (selectedCategory != null &&
    //     selectedCategory != "Select lead Type " &&
    //     selectedCategory != "All") {
    //   result = result
    //       .where(
    //         (lead) =>
    //             (lead.category ?? '').toLowerCase() ==
    //             selectedCategory!.toLowerCase(),
    //       )
    //       .toList();
    // }

    // // Source filter
    // if (selectedSource != null &&
    //     selectedSource != "Select Source" &&
    //     selectedSource != "All") {
    //   result = result
    //       .where(
    //         (lead) =>
    //             (lead.leadSource ?? '').toLowerCase() ==
    //             selectedSource!.toLowerCase(),
    //       )
    //       .toList();
    // }

    // // Assigned staff filter
    // if (selectedAssignedStaff != null &&
    //     selectedAssignedStaff != "Select Staff" &&
    //     selectedAssignedStaff != "All") {
    //   result = result
    //       .where(
    //         (lead) =>
    //             (lead.assigned ?? '').toLowerCase() ==
    //             selectedAssignedStaff!.toLowerCase(),
    //       )
    //       .toList();
    // }

    // // Deleted by filter
    // if (selectedDeletedBy != null &&
    //     selectedDeletedBy != "Select Deleted By" &&
    //     selectedDeletedBy != "All") {
    //   result = result
    //       .where(
    //         (lead) =>
    //             (lead.deletedBy ?? '').toLowerCase() ==
    //             selectedDeletedBy!.toLowerCase(),
    //       )
    //       .toList();
    // }

    // return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AddLeadCubit, AddLeadState>(
        listener: (context, state) {
          if (state.listStatus == LeadListStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.listError ?? "Something went wrong"),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                TopBreadcrumbBar(
                  subTitle: 'Deleted Leads',
                  title: 'Leads Management',
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
                        /// TITLE BAR
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 2.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Deleted Leads",
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

                        /// FILTERS
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
    isFrom: true,  // shows fromDate value
  ),
),
SizedBox(width: 2.w),
Expanded(
  child: InputDate(
    label: "To Date",
    fromController: _fromDateController,
    toController: _toDateController,
    isFrom: false, // shows toDate value
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
                                      hint: 'Select Lead Category',
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Dropdown(
                                      label: "Lead Source",
                                      hint: 'Select Lead Source',
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
                                ],
                              ),

                              SizedBox(height: 1.h),

                              Row(
                                children: [
                                  SizedBox(
                                    width: 17.45.w,
                                    child: Dropdown(
                                      label: "Assigned Staff",
                                      hint: 'Select Assigned Staff',
                                      items: assingedStaff,
                                      selectedValue: selectedAssignedStaff,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedAssignedStaff = val;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  SizedBox(
                                    width: 17.45.w,
                                    child: Dropdown(
                                      label: "Deleted By",
                                      hint: 'Select Deleted By',
                                      showHelp: true,
                                      items: deletedBy,
                                      selectedValue: selectedDeletedBy,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedDeletedBy = val;
                                        });
                                      },
                                      message: '.',
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Padding(
                                    padding: EdgeInsets.only(top: 2.h),
                                    child: SizedBox(
                                      width: 7.w,
                                      height: 4.5.h,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: const Color(0xff1BAA90),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                        ShowEntries(
                          initialSearch: _searchQuery,
                          initialEntries: _selectedEntries,
                          onSearchChanged: (v) =>
                              setState(() => _searchQuery = v),
                          onEntriesChanged: (v) =>
                              setState(() => _selectedEntries = v),
                        ),

                        _buildTavbleSection(state),

                        ///FOOTER
                        Footer(),

                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // _______________Table Section________________
  Widget _buildTavbleSection(AddLeadState leadState) {
    if (leadState.listStatus == LeadListStatus.loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.orange,
            strokeWidth: 2,
          ),
        ),
      );
    }
    if (leadState.listStatus == LeadListStatus.failure) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 2.w),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 18.sp),
              SizedBox(height: 1.h),
              Text(
                'Failed to load deleted staff.',
                style: AppTextStyle.medium(color: Colors.red),
              ),
              SizedBox(height: 1.5.h),
              GestureDetector(
                onTap: () => context.read<AddLeadCubit>().fetchDeletedLeads(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    border: Border.all(color: AppColors.orange),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Retry',
                    style: AppTextStyle.small(color: AppColors.orange),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<AddLeadModel> rawList =
        leadState.listStatus == LeadListStatus.loaded ? leadState.leads : [];
    final List<AddLeadModel> filteredList = _filteredLeads(rawList);
    // // Empty state
    // if (filteredList.isEmpty) {
    //   return Padding(
    //     padding: EdgeInsets.symmetric(vertical: 6.h),
    //     child: Center(
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Icon(
    //             Icons.delete_outline,
    //             color: Colors.grey.shade400,
    //             size: 20.sp,
    //           ),
    //           SizedBox(height: 1.h),
    //           Text(
    //             'No deleted leads found.',
    //             style: AppTextStyle.medium(color: Colors.grey.shade500),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }
    return SizedBox(
      child: CustomTable(
        columns: [
          TableColumn(title: "#", flex: 1),
          TableColumn(title: "Name", flex: 4),
          TableColumn(title: "Contact Number", flex: 4),
          TableColumn(title: "Lead Category", flex: 4),
          TableColumn(title: "Assigned Staff", flex: 4),
          TableColumn(title: "Lead Status", flex: 4),
          // TableColumn(title: "Last Called", flex: 4),
          TableColumn(title: "Delete Date", flex: 4),
          TableColumn(title: "Deleted By", flex: 4),
          TableColumn(title: "Action", flex: 2),
        ],
        rows: filteredList.asMap().entries.map((entry) {
          final index = entry.key;
          final lead = entry.value;
          final deletedAt = lead.createdAt != null
              ? '${lead.createdAt!.day.toString().padLeft(2, '0')}/'
                    '${lead.createdAt!.month.toString().padLeft(2, '0')}/'
                    '${lead.createdAt!.year}'
              : '—';
          return [
            Text('${index + 1}', style: AppTextStyle.medium()),
            Text(lead.clientName, style: AppTextStyle.medium()),
            Text(lead.contactNumber, style: AppTextStyle.medium()),
            Text(lead.leadCategory, style: AppTextStyle.medium()),
            Text(lead.assignedStaff, style: AppTextStyle.medium()),
            Text(lead.leadStage, style: AppTextStyle.medium()),
            // Text(lead.lastCalled, style: AppTextStyle.medium()),
            Text(deletedAt, style: AppTextStyle.medium()),
            Text(lead.assignedStaff ?? "—", style: AppTextStyle.medium()),

            /// ACTION
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _confirmRestore(context, lead),
                      child: Tooltip(
                        message: 'Restore',
                        child: Icon(
                          Icons.restore,
                          size: 14.sp,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(width: 0.1.w),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _confirmDelete(context, lead),
                      child: Tooltip(
                        message: 'Delete',
                        child: Icon(
                          Icons.delete_outline,
                          size: 14.sp,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
        }).toList(),
      ),
    );
  }

  // ─── Restore confirmation dialog ───────────────────────────────────────────
  void _confirmRestore(BuildContext ctx, AddLeadModel lead) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Restore Lead', style: AppTextStyle.medium(size: 14.sp)),
        content: Text(
          'Restore "${lead.clientName}" back to leads reports?',
          style: AppTextStyle.medium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyle.medium(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<AddLeadCubit>().restoreLead(lead);
            },
            child: Text(
              'Restore',
              style: AppTextStyle.medium(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, AddLeadModel lead) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Delete Lead', style: AppTextStyle.medium(size: 14.sp)),
        content: Text(
          'Delete "${lead.clientName}" permanently?',
          style: AppTextStyle.medium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyle.medium(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<AddLeadCubit>().permanentlyDeleteLead(
                lead.id ?? '',
              ); // see cubit addition below
            },
            child: Text(
              'Delete',
              style: AppTextStyle.medium(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
