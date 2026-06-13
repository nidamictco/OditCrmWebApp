import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/export_excel.dart';
import 'package:oxdo/core/utils/input_date.dart';
import 'package:oxdo/core/utils/page_button.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import 'package:sizer/sizer.dart';

class DeleteLeads extends StatefulWidget {
  const DeleteLeads({super.key});

  @override
  State<DeleteLeads> createState() => _DeleteLeadsState();
}

class _DeleteLeadsState extends State<DeleteLeads> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  String? selectedCategory;
  String? selectedSource;
  String? selectedDeletedBy;
  String? selectedAssignedStaff;

  String _searchQuery = '';
  String _selectedEntries = '10';

  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    context.read<AddLeadCubit>().fetchDeletedLeads();
    context.read<AddLeadCubit>().fetchStaff();
    // context.read<AddLeadCubit>().fetchLeads();
    context.read<AddLeadCubit>().initialize();

    _fromDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilters());
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  String? _appliedCategory;
  String? _appliedSource;
  String? _appliedStaff;
  String? _appliedDeletedBy;
  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;

  // ── Called ONLY when "View" is tapped ───────────────────────────────────────
  void _applyFilters() {
    setState(() {
      _appliedCategory = selectedCategory;
      _appliedSource = selectedSource;
      _appliedStaff = selectedAssignedStaff;
      _appliedDeletedBy = selectedDeletedBy;
      _appliedFromDate = _parseDate(_fromDateController.text);
      _appliedToDate = _parseDate(_toDateController.text);
      _resetPage();
    });
  }

  DateTime? _parseDate(String text) {
    try {
      return DateFormat('dd-MM-yyyy').parse(text);
    } catch (_) {
      return null;
    }
  }

  // ── Skip placeholder "Select …" values ──────────────────────────────────────
  bool _isPlaceholder(String? val) =>
      val == null ||
      val.trim().isEmpty ||
      val.toLowerCase().startsWith('select');

  List<AddLeadModel> _filteredLeads(List<AddLeadModel> leads) {
    List<AddLeadModel> result = leads;

    // ── Date range ─────────────────────────────────────────────────────────────
    if (_appliedFromDate != null) {
      final from = DateTime(
        _appliedFromDate!.year,
        _appliedFromDate!.month,
        _appliedFromDate!.day,
      );
      result = result
          .where((l) => l.createdAt != null && !l.createdAt!.isBefore(from))
          .toList();
    }
    if (_appliedToDate != null) {
      final to = DateTime(
        _appliedToDate!.year,
        _appliedToDate!.month,
        _appliedToDate!.day,
        23,
        59,
        59,
      );
      result = result
          .where((l) => l.createdAt != null && !l.createdAt!.isAfter(to))
          .toList();
    }

    // ── Lead Category — stored UPPERCASE in Firestore ─────────────────────────
    if (!_isPlaceholder(_appliedCategory)) {
      final cat = _appliedCategory!.trim().toUpperCase();
      result = result
          .where((l) => l.leadCategory.toUpperCase() == cat)
          .toList();
    }

    // ── Lead Source — stored UPPERCASE in Firestore ───────────────────────────
    if (!_isPlaceholder(_appliedSource)) {
      final source = _appliedSource!.trim().toUpperCase();
      result = result
          .where((l) => l.leadSource.toUpperCase() == source)
          .toList();
    }

    // ── Assigned Staff — stored as-is ────────────────────────────────────────
    if (!_isPlaceholder(_appliedStaff)) {
      result = result
          .where(
            (l) =>
                l.assignedStaff.toLowerCase() ==
                _appliedStaff!.trim().toLowerCase(),
          )
          .toList();
    }

    // ── Deleted By — stored as-is ─────────────────────────────────────────────
    if (!_isPlaceholder(_appliedDeletedBy)) {
      result = result
          .where(
            (l) =>
                l.assignedStaff.toLowerCase() ==
                _appliedDeletedBy!.trim().toLowerCase(),
          )
          .toList();
    }

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

    return result;
  }

  List<AddLeadModel> _pagedLeads(List<AddLeadModel> allFiltered) {
    final limit = int.tryParse(_selectedEntries) ?? 10;
    final start = (_currentPage - 1) * limit;
    final end = (start + limit).clamp(0, allFiltered.length);
    if (start >= allFiltered.length) return [];
    return allFiltered.sublist(start, end);
  }

  int _totalPages(int totalCount) {
    final limit = int.tryParse(_selectedEntries) ?? 10;
    if (totalCount == 0) return 1;
    return (totalCount / limit).ceil();
  }

  void _goToPage(int page, int total) {
    final tp = _totalPages(total);
    if (page < 1 || page > tp) return;
    setState(() {
      _currentPage = page;
      _selectedIndices = [];
      _tableKey++;
    });
  }

  void _resetPage() {
    _currentPage = 1;
    _selectedIndices = [];
    _tableKey++;
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
                              GestureDetector(
                                 onTap: () {
                              final leads = context
                                  .read<AddLeadCubit>()
                                  .state
                                  .leads;
                              final filtered = _filteredLeads(
                                leads,
                              ); // exports only filtered data
                              exportLeadsToExcel(filtered,'deleted_leads_');
                            },
                                child: Container(
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
                              ),
                            ],
                          ),
                        ),
                        Divider(color: AppColors.divider),

                        /// FILTERS
                        BlocBuilder<AddLeadCubit, AddLeadState>(
                          builder: (context, state) {
                            final categoryItems = state.categories
                                .map((e) => e.name)
                                .toList();
                            final sourceItems = state.sources
                                .map((e) => e.name)
                                .toList();
                            // final stageItems = state.stages
                            //     .map((e) => e.name)
                            //     .toList();
                            final staffItems = state.staffList
                                .map((e) => e.name)
                                .toList();
                            final deletedByItems = state.staffList
                                .map((e) => e.name)
                                .toList();
                            return Padding(
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
                                          isFrom: false, // shows toDate value
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Expanded(
                                        child: Dropdown(
                                          showHelp: true,
                                          message:
                                              'Lead Category is the type\n of product, service, or solution \na potential customer is \ninterested in, helping businesses\n identify and classify inquiries \nfor better follow-up.',
                                          items: categoryItems,
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
                                          message: 'It refers to the source of the \nlead, showing how the potential \ncustomer discovered or engaged with \nthe business, such as through marketing \ncampaigns, social media, referrals, events,\n or website inquiries.',
                                          items: sourceItems,
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
                                          items: staffItems,
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
                                          items: deletedByItems,
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
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () => _applyFilters(),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 2.h),
                                          child: SizedBox(
                                            width: 7.w,
                                            height: 4.5.h,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: const Color(0xff1BAA90),
                                                borderRadius:
                                                    BorderRadius.circular(6),
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
                                      SizedBox(width: 1.w),
                                      if (selectedCategory != null ||
                                          selectedSource != null ||
                                          selectedAssignedStaff != null ||
                                          selectedDeletedBy != null)
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedCategory = null;
                                              selectedSource = null;
                                              selectedAssignedStaff = null;
                                              selectedDeletedBy = null;
                                              _resetPage();
                                            });
                                          },
                                          child: Container(
                                            width: 7.w,
                                            height: 4.5.h,
                                            padding: EdgeInsets.all(1.h),
                                            margin: EdgeInsets.only(top: 2.h),
                                            decoration: BoxDecoration(
                                              color: AppColors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Reset Filters',
                                              style: AppTextStyle.small(
                                                size: 10.sp,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
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
    // final List<AddLeadModel> filteredList = _filteredLeads(rawList);
    final allFiltered = _filteredLeads(rawList);
    final totalCount = allFiltered.length;
    final totalPages = _totalPages(totalCount);
    final limit = int.tryParse(_selectedEntries) ?? 10;
    if (_currentPage > totalPages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _currentPage = totalPages);
      });
    }
    final pagedList = _pagedLeads(allFiltered);

    // "Showing X to Y of Z entries"
    final showFrom = totalCount == 0 ? 0 : (_currentPage - 1) * limit + 1;
    final showTo = (showFrom + pagedList.length - 1).clamp(0, totalCount);
    return Column(
      children: [
        SizedBox(
          child: CustomTable(
            columns: [
              TableColumn(title: "Sl No.", flex: 1),
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
            rows: pagedList.asMap().entries.map((entry) {
              final index = entry.key;
              final lead = entry.value;
              final deletedAt = lead.deletedAt != null
                  ? '${lead.deletedAt!.day.toString().padLeft(2, '0')}/'
                        '${lead.deletedAt!.month.toString().padLeft(2, '0')}/'
                        '${lead.deletedAt!.year}'
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
                Text(lead.assignedStaff, style: AppTextStyle.medium()),

                /// ACTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    SizedBox(width: 0.5.w),
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
              ];
            }).toList(),
          ),
        ),

        /// 🔹 FOOTER
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Showing $showFrom to $showTo of $totalCount entries",
                style: AppTextStyle.medium(weight: FontWeight.w400),
              ),
              Row(
                children: [
                  PageButton(
                    label: 'Previous',
                    enabled: _currentPage > 1,
                    isLeft: true,
                    onTap: () => _goToPage(_currentPage - 1, totalCount),
                  ),
                  ..._buildPageNumbers(totalPages, totalCount),
                  PageButton(
                    label: 'Next',
                    enabled: _currentPage < totalPages,
                    isRight: true,
                    onTap: () => _goToPage(_currentPage + 1, totalCount),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Page number chips ───────────────────────
 List<Widget> _buildPageNumbers(int totalPages, int totalCount) {
  if (totalPages <= 1) return [];

  return [
    GestureDetector(
      onTap: () {}, // already on this page
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 0.2.w),
        padding: EdgeInsets.symmetric(horizontal: 1.2.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Text(
          '$_currentPage',
          style: AppTextStyle.small(
            size: 11.sp,
            color: AppColors.white,
          ),
        ),
      ),
    ),
  ];
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

  // -------------export to excel function (filtered)-------------
  void exportLeadsToExcel(List<AddLeadModel> leads, String fileName) {
  exportToExcel<AddLeadModel>(
    fileName: fileName,
    wrapColumnIndices: [2],
    rows: leads,
    columns: [
      ExcelColumn(header: 'SL No.',              value: (l) => '${leads.indexOf(l) + 1}'),
      ExcelColumn(header: 'Client Name',    value: (l) => l.clientName),
      ExcelColumn(header: 'Phone No',       value: (l) => l.contactNumber),
      ExcelColumn(header: 'WhatsApp No',    value: (l) => l.whatsappNumber),
      ExcelColumn(header: 'Email',          value: (l) => l.email),
      ExcelColumn(header: 'Address',        value: (l) => l.address),
      ExcelColumn(header: 'Pin Code',       value: (l) => l.pinCode),
      ExcelColumn(header: 'Post Office',    value: (l) => l.postOffice),
      ExcelColumn(header: 'State',          value: (l) => l.state),
      ExcelColumn(header: 'District',       value: (l) => l.district),
      ExcelColumn(header: 'Lead Category',  value: (l) => l.leadCategory),
      ExcelColumn(header: 'Lead Source',    value: (l) => l.leadSource),
      ExcelColumn(header: 'Lead Stage',     value: (l) => l.leadStage),
      ExcelColumn(header: 'Priority',       value: (l) => l.priority),
      ExcelColumn(header: 'Assigned Staff', value: (l) => l.assignedStaff),
      ExcelColumn(header: 'Created By',     value: (l) => l.createdBy),
      ExcelColumn(header: 'Call Result',    value: (l) => l.callResult),
      ExcelColumn(header: 'Remarks',        value: (l) => l.remarks),
      ExcelColumn(
        header: 'Created Date',
        value: (l) => l.createdAt != null
            ? DateFormat('dd-MM-yyyy').format(l.createdAt!)
            : '-',
      ),
    ],
  );
}
}
