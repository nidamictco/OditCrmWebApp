import 'package:Odit_CRM/core/router/browser_aware_link.dart';
import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/utils/multi_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_style.dart';
import '../../../../../core/utils/dropdown.dart';
import '../../../../../core/utils/export_excel.dart';
import '../../../../../core/utils/input_date.dart';
import '../../../../../core/utils/page_button.dart';
import '../../../../../core/utils/show_entries.dart';
import '../../../../../core/utils/staff_top_bar.dart';
import '../../../../../core/utils/table.dart';
import '../../../lead_managment/leads/cubit/add_lead_cubit.dart';
import '../../../lead_managment/leads/cubit/add_lead_state.dart';
import '../../../lead_managment/leads/model/add_lead_model.dart';
import '../../../rightside_menu/lead_stage/data/lead_tag_repo.dart';
import '../../../rightside_menu/common_model/lead_model.dart';
import 'package:sizer/sizer.dart';

import 'package:go_router/go_router.dart';
import '../../../../../core/router/route_paths.dart';

class RejectedLeads extends StatefulWidget {
  const RejectedLeads({super.key});

  @override
  State<RejectedLeads> createState() => _RejectedLeadsState();
}

class _RejectedLeadsState extends State<RejectedLeads> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  // ── Multi-select filter selections (temporary, pending "View" tap) ────────
  List<String> selectedCategories = [];
  List<String> selectedSources = [];
  List<String> selectedPriorities = [];
  List<String> selectedCallStatuses = [];
  List<String> selectedRejectedReasons = [];
  List<String> selectedStaffs = [];

  String _searchQuery = '';
  String _selectedEntries = '10';

  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;

  // Static variables to preserve filter state across screen navigation
  static bool _hasSavedState = false;
  static String? _staticFromDate;
  static String? _staticToDate;
  static List<String> _staticCategories = [];
  static List<String> _staticSources = [];
  static List<String> _staticPriorities = [];
  static List<String> _staticCallStatuses = [];
  static List<String> _staticRejectedReasons = [];
  static List<String> _staticStaffs = [];
  static String _staticSearchQuery = '';
  static String _staticSelectedEntries = '10';
  static int _staticCurrentPage = 1;

  // Static variables for applied (active) filter state
  static List<String> _staticAppliedCategories = [];
  static List<String> _staticAppliedPriorities = [];
  static List<String> _staticAppliedSources = [];
  static List<String> _staticAppliedStaffs = [];
  static List<String> _staticAppliedRejectedReasons = [];
  static List<String> _staticAppliedCallStatuses = [];
  static DateTime? _staticAppliedFromDate;
  static DateTime? _staticAppliedToDate;

  // ── Snapshot fields (applied only when "View" is tapped) ────────────────────
  List<String> _appliedCategories = [];
  List<String> _appliedPriorities = [];
  List<String> _appliedSources = [];
  List<String> _appliedStaffs = [];
  List<String> _appliedRejectedReasons = [];
  List<String> _appliedCallStatuses = [];
  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;

  @override
  void dispose() {
    // Save current filter state to static variables before widget disposal
    _staticFromDate = _fromDateController.text;
    _staticToDate = _toDateController.text;
    _staticCategories = List<String>.from(selectedCategories);
    _staticSources = List<String>.from(selectedSources);
    _staticPriorities = List<String>.from(selectedPriorities);
    _staticCallStatuses = List<String>.from(selectedCallStatuses);
    _staticRejectedReasons = List<String>.from(selectedRejectedReasons);
    _staticStaffs = List<String>.from(selectedStaffs);

    _staticSearchQuery = _searchQuery;
    _staticSelectedEntries = _selectedEntries;
    _staticCurrentPage = _currentPage;

    _staticAppliedCategories = List<String>.from(_appliedCategories);
    _staticAppliedPriorities = List<String>.from(_appliedPriorities);
    _staticAppliedSources = List<String>.from(_appliedSources);
    _staticAppliedStaffs = List<String>.from(_appliedStaffs);
    _staticAppliedRejectedReasons = List<String>.from(_appliedRejectedReasons);
    _staticAppliedCallStatuses = List<String>.from(_appliedCallStatuses);
    _staticAppliedFromDate = _appliedFromDate;
    _staticAppliedToDate = _appliedToDate;

    _hasSavedState = true;

    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();

    if (_hasSavedState) {
      // Restore filter state from static variables
      _fromDateController.text = _staticFromDate ?? '';
      _toDateController.text = _staticToDate ?? '';
      selectedCategories = List<String>.from(_staticCategories);
      selectedSources = List<String>.from(_staticSources);
      selectedPriorities = List<String>.from(_staticPriorities);
      selectedCallStatuses = List<String>.from(_staticCallStatuses);
      selectedRejectedReasons = List<String>.from(_staticRejectedReasons);
      selectedStaffs = List<String>.from(_staticStaffs);

      _searchQuery = _staticSearchQuery;
      _selectedEntries = _staticSelectedEntries;
      _currentPage = _staticCurrentPage;

      _appliedCategories = List<String>.from(_staticAppliedCategories);
      _appliedPriorities = List<String>.from(_staticAppliedPriorities);
      _appliedSources = List<String>.from(_staticAppliedSources);
      _appliedStaffs = List<String>.from(_staticAppliedStaffs);
      _appliedRejectedReasons = List<String>.from(
        _staticAppliedRejectedReasons,
      );
      _appliedCallStatuses = List<String>.from(_staticAppliedCallStatuses);
      _appliedFromDate = _staticAppliedFromDate;
      _appliedToDate = _staticAppliedToDate;
    } else {
      _fromDateController.text = DateFormat(
        'dd-MM-yyyy',
      ).format(DateTime.now());
      _toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      _appliedFromDate = DateTime.now();
      _appliedToDate = DateTime.now();
    }
  }

  bool _hasActiveFilters() {
    return selectedCategories.isNotEmpty ||
        selectedSources.isNotEmpty ||
        selectedPriorities.isNotEmpty ||
        selectedCallStatuses.isNotEmpty ||
        selectedRejectedReasons.isNotEmpty ||
        selectedStaffs.isNotEmpty ||
        _fromDateController.text.isNotEmpty ||
        _toDateController.text.isNotEmpty;
  }

  void _clearFilters() {
    setState(() {
      selectedCategories = [];
      selectedSources = [];
      selectedPriorities = [];
      selectedCallStatuses = [];
      selectedRejectedReasons = [];
      selectedStaffs = [];
      _fromDateController.clear();
      _toDateController.clear();

      _appliedCategories = [];
      _appliedPriorities = [];
      _appliedSources = [];
      _appliedStaffs = [];
      _appliedRejectedReasons = [];
      _appliedCallStatuses = [];
      _appliedFromDate = null;
      _appliedToDate = null;

      _hasSavedState = false;

      _resetPage();
    });
  }

  Future<void> _loadData() async {
    final cubit = context.read<AddLeadCubit>();
    await cubit.initialize();
    await cubit.fetchStaff();
    await cubit.fetchLeads();
  }

  void _applyFilters() {
    setState(() {
      _appliedCategories = List<String>.from(selectedCategories);
      _appliedPriorities = List<String>.from(selectedPriorities);
      _appliedSources = List<String>.from(selectedSources);
      _appliedStaffs = List<String>.from(selectedStaffs);
      _appliedRejectedReasons = List<String>.from(selectedRejectedReasons);
      _appliedCallStatuses = List<String>.from(selectedCallStatuses);
      _appliedFromDate = _fromDateController.text.trim().isEmpty
          ? null
          : _parseDate(_fromDateController.text);
      _appliedToDate = _toDateController.text.trim().isEmpty
          ? null
          : _parseDate(_toDateController.text);
      _resetPage();
    });
    dev.log(
      '[_applyFilters] Applied filters: FromDate=$_appliedFromDate, '
      'ToDate=$_appliedToDate, Categories=$_appliedCategories, '
      'Priorities=$_appliedPriorities, Staffs=$_appliedStaffs, '
      'RejectedReasons=$_appliedRejectedReasons, '
      'CallStatuses=$_appliedCallStatuses, Sources=$_appliedSources',
    );
  }

  DateTime? _parseDate(String text) {
    try {
      return DateFormat('dd-MM-yyyy').parse(text);
    } catch (_) {
      return null;
    }
  }

  List<AddLeadModel> _filteredLeads(List<AddLeadModel> leads) {
    dev.log('[RejectedLeads] Total leads fetched from state: ${leads.length}');

    // 1. Rejected Stage Filter
    List<AddLeadModel> result = leads
        .where((lead) => lead.leadStage.trim().toUpperCase() == 'REJECTED')
        .toList();
    dev.log(
      '[RejectedLeads] Total leads matching REJECTED stage: ${result.length}',
    );

    // 2. Date Range Filter
    if (_appliedFromDate != null) {
      final from = DateTime(
        _appliedFromDate!.year,
        _appliedFromDate!.month,
        _appliedFromDate!.day,
      );
      result = result.where((l) {
        final date = l.calledDate ?? l.updatedAt ?? l.createdAt;
        return date != null && !date.isBefore(from);
      }).toList();
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
      result = result.where((l) {
        final date = l.calledDate ?? l.updatedAt ?? l.createdAt;
        return date != null && !date.isAfter(to);
      }).toList();
    }

    // 3. Category Filter — match ANY selected
    if (_appliedCategories.isNotEmpty) {
      final cats = _appliedCategories
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((l) => cats.contains(l.leadCategory.toUpperCase()))
          .toList();
    }

    // 4. Lead Source Filter — match ANY selected
    if (_appliedSources.isNotEmpty) {
      final sources = _appliedSources
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((l) => sources.contains(l.leadSource.toUpperCase()))
          .toList();
    }

    // 5. Priority Filter — match ANY selected
    if (_appliedPriorities.isNotEmpty) {
      final priorities = _appliedPriorities
          .map((e) => e.trim().toLowerCase())
          .toSet();
      result = result
          .where((l) => priorities.contains(l.priority.toLowerCase()))
          .toList();
    }

    // 6. Assigned Staff Filter — match ANY selected
    if (_appliedStaffs.isNotEmpty) {
      final staffSet = _appliedStaffs
          .map((e) => e.trim().toLowerCase())
          .toSet();
      result = result
          .where((l) => staffSet.contains(l.assignedStaff.toLowerCase()))
          .toList();
    }

    // 7. Rejected Reason Filter — match ANY selected
    if (_appliedRejectedReasons.isNotEmpty) {
      final reasons = _appliedRejectedReasons
          .map((e) => e.trim().toLowerCase())
          .toSet();
      result = result
          .where(
            (l) =>
                l.leadTag != null &&
                reasons.contains(l.leadTag!.trim().toLowerCase()),
          )
          .toList();
    }

    // 8. Call Status Filter — match ANY selected
    if (_appliedCallStatuses.isNotEmpty) {
      final statuses = _appliedCallStatuses
          .map((e) => e.trim().toLowerCase())
          .toSet();
      result = result
          .where(
            (l) =>
                l.callResult != null &&
                statuses.contains(l.callResult!.trim().toLowerCase()),
          )
          .toList();
    }

    // 9. Search Filter
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

    dev.log('[RejectedLeads] Total leads after filtering: ${result.length}');
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
      backgroundColor: AppThemeColors.scaffoldBg,
      body: BlocListener<AddLeadCubit, AddLeadState>(
        listenWhen: (previous, current) =>
            previous.listStatus != LeadListStatus.loaded &&
            current.listStatus == LeadListStatus.loaded,
        listener: (context, state) {
          _applyFilters();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x14000000),
                        offset: const Offset(0, 1),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: BlocBuilder<AddLeadCubit, AddLeadState>(
                    builder: (context, state) {
                      final categoryItems = state.categories
                          .map((e) => e.name)
                          .toList();
                      final sourceItems = state.sources
                          .map((e) => e.name)
                          .toList();
                      final staffItems = state.staffList
                          .map((e) => e.name)
                          .toList();

                      // Find the REJECTED lead stage from the loaded stages list
                      final rejectedStage = state.stages
                          .where(
                            (s) => s.name.trim().toUpperCase() == 'REJECTED',
                          )
                          .firstOrNull;

                      const priorityItems = [
                        "High",
                        "Low",
                        "Negative",
                        "Normal",
                      ];
                      const callStatusItems = [
                        "Connected",
                        "Busy",
                        "Not Connected",
                        "Wrong Number",
                        "Switched Off",
                        "Rejected",
                        "Out of Coverage",
                      ];
                      return StreamBuilder<List<LeadsModel>>(
                        stream: rejectedStage != null
                            ? LeadTagRepository(
                                tagId: rejectedStage.id,
                              ).watchLeadTags()
                            : const Stream.empty(),
                        builder: (context, tagSnapshot) {
                          final rejectedReasonItems =
                              (tagSnapshot.data ?? [])
                                  .map((tag) => tag.name.trim())
                                  .where((name) => name.isNotEmpty)
                                  .toSet()
                                  .toList()
                                ..sort();
                          // ...existing body, StreamBuilder, etc. — now ends with
                          return _buildFilterCard(
                            categoryItems: categoryItems,
                            sourceItems: sourceItems,
                            staffItems: staffItems,
                            rejectedReasonItems: rejectedReasonItems,
                          );
                        },
                      );
                    },
                  ),
                ),

                
                SizedBox(height: 2.h),
                ShowEntries(
                  initialSearch: _searchQuery,
                  initialEntries: _selectedEntries,
                  onSearchChanged: (v) => setState(() {
                    _searchQuery = v;
                    _resetPage();
                  }),
                  onEntriesChanged: (v) => setState(() {
                    _selectedEntries = v;
                    _resetPage();
                  }),
                  exportWidget: GestureDetector(
                    onTap: () {
                      final leads = context.read<AddLeadCubit>().state.leads;
                      final filtered = _filteredLeads(
                        leads,
                      ); 
                      exportLeadsToExcel(filtered, 'rejected_leads_');
                    },
                    child:  Container(
                        height: 4.h,
                        padding: EdgeInsets.symmetric(horizontal: 0.8.w),
                        decoration: BoxDecoration(
                          color: AppThemeColors.appPrimaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Text(
                              "Export",
                              style: AppTextStyle.medium(
                                color: Colors.white,
                                weight: FontWeight.w500,
                                size: 11.sp,
                              ),
                            ),
                            SizedBox(width: 0.3.w),
                            Icon(
                              Icons.file_download_outlined,
                              color: Colors.white,
                              size: 3.h,
                            ),
                          ],
                        ),
                      ),
                  ),
                ),

                SizedBox(height: 2.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0x14000000,
                        ), // #00000014 (8% opacity)
                        offset: const Offset(0, 1),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: BlocBuilder<AddLeadCubit, AddLeadState>(
                    builder: (context, state) {
                      if (state.listStatus == LeadListStatus.loading) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (state.listStatus == LeadListStatus.failure) {
                        return Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Text(
                            state.listError ?? 'Something went wrong.',
                            style: AppTextStyle.medium(color: Colors.red),
                          ),
                        );
                      }

                      final List<AddLeadModel> rawList =
                          state.listStatus == LeadListStatus.loaded
                          ? state.leads
                          : [];

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

                      final showFrom = totalCount == 0
                          ? 0
                          : (_currentPage - 1) * limit + 1;
                      final showTo = (showFrom + pagedList.length - 1).clamp(
                        0,
                        totalCount,
                      );

                      if (state.listStatus == LeadListStatus.loaded) {
                        // if (allFiltered.isEmpty) {
                        //   return Padding(
                        //     padding: EdgeInsets.symmetric(vertical: 6.h),
                        //     child: Center(
                        //       child: Text(
                        //         "No Rejected Leads Found",
                        //         style: AppTextStyle.medium(
                        //           color: AppColors.black.withOpacity(0.5),
                        //         ),
                        //       ),
                        //     ),
                        //   );
                        // }
                        return Column(
                          children: [
                            SizedBox(
                              child: CustomTable(
                                key: ValueKey(_tableKey),
                                showCheckboxes: true,
                                onCheckChanged: (rowIndex, isChecked) {
                                  setState(() {
                                    if (isChecked) {
                                      if (!_selectedIndices.contains(
                                        rowIndex,
                                      )) {
                                        _selectedIndices.add(rowIndex);
                                      }
                                    } else {
                                      _selectedIndices.remove(rowIndex);
                                    }
                                  });
                                },
                                columns: [
                                  TableColumn(title: "Sl No."),
                                  TableColumn(title: "Name"),
                                  TableColumn(title: "Contact No."),
                                  TableColumn(title: "Lead Category"),
                                  TableColumn(title: "Staff "),
                                  TableColumn(title: "Status"),
                                  TableColumn(title: "Reason"),
                                  TableColumn(title: "Followup Date"),
                                  TableColumn(title: "Called Date"),
                                  TableColumn(title: "Created Date"),
                                  TableColumn(title: "Action"),
                                ],
                                rows: pagedList.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final lead = entry.value;
                                  final serial =
                                      (_currentPage - 1) * limit + index + 1;
                                  return [
                                    Text(
                                      '$serial',
                                      style: AppTextStyle.medium(),
                                    ),
                                    Text(
                                      lead.clientName,
                                      style: AppTextStyle.medium(),
                                    ),
                                    Text(
                                      lead.contactNumber,
                                      style: AppTextStyle.medium(),
                                    ),
                                    Text(
                                      lead.leadSubCategory.isEmpty
                                          ? lead.leadCategory
                                          : '${lead.leadCategory} - ${lead.leadSubCategory}',
                                      style: AppTextStyle.medium(),
                                    ),
                                    Text(
                                      lead.assignedStaff,
                                      style: AppTextStyle.medium(),
                                    ),
                                    Text(
                                      lead.leadStage,
                                      style: AppTextStyle.medium(),
                                    ),
                                    Text(
                                      lead.leadTag ?? '--',
                                      style: AppTextStyle.medium(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      lead.followUpDate != null
                                          ? DateFormat(
                                              'dd-MM-yyyy',
                                            ).format(lead.followUpDate!)
                                          : '--',
                                      style: AppTextStyle.medium(),
                                    ),
                                    Text(
                                      lead.calledDate != null
                                          ? DateFormat(
                                              'dd-MM-yyyy',
                                            ).format(lead.calledDate!)
                                          : '--',
                                      style: AppTextStyle.medium(),
                                    ),
                                    Text(
                                      lead.createdAt != null
                                          ? DateFormat(
                                              'dd-MM-yyyy',
                                            ).format(lead.createdAt!)
                                          : '-',
                                      style: AppTextStyle.medium(),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        BrowserAwareLink(
                                          destination: RoutePaths.followUpPath(
                                            lead.id!,
                                            "NEW",
                                            fromScreen: 'rejectedReport',
                                          ),
                                          usePush: true,
                                          enableInkWell: false,
                                          child: Icon(
                                            Icons.visibility_outlined,
                                            size: 13.sp,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ];
                                }).toList(),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 1.5.h,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "SHOWING ${showFrom.toString().toUpperCase()} TO ${showTo.toString().toUpperCase()} OF ${totalCount.toString().toUpperCase()} ENTRIES",
                                    style: AppTextStyle.medium(
                                      weight: FontWeight.w600,
                                      color: const Color(0xff64748B),
                                      size: 9.8.sp,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _buildPaginationButton(
                                        enabled: _currentPage > 1,
                                        onTap: () => _goToPage(
                                          _currentPage - 1,
                                          totalCount,
                                        ),
                                        child: const Icon(
                                          Icons.chevron_left,
                                          size: 16,
                                          color: Color(0xff94A3B8),
                                        ),
                                      ),
                                      ..._buildCustomPageNumbers(
                                        totalPages,
                                        totalCount,
                                      ),
                                      _buildPaginationButton(
                                        enabled: _currentPage < totalPages,
                                        onTap: () => _goToPage(
                                          _currentPage + 1,
                                          totalCount,
                                        ),
                                        child: const Icon(
                                          Icons.chevron_right,
                                          size: 16,
                                          color: Color(0xff94A3B8),
                                        ),
                                      ),

                                      BlocBuilder<AddLeadCubit, AddLeadState>(
                                        builder: (context, state) {
                                          final List<AddLeadModel> rawList =
                                              state.listStatus ==
                                                  LeadListStatus.loaded
                                              ? state.leads
                                              : [];
                                          final filteredList = _filteredLeads(
                                            rawList,
                                          );

                                          final selectedLeads = _selectedIndices
                                              .where(
                                                (i) => i < filteredList.length,
                                              )
                                              .map((i) => filteredList[i])
                                              .toList();

                                          final hasSelection =
                                              selectedLeads.isNotEmpty;
                                          return GestureDetector(
                                            onTap: hasSelection
                                                ? () => _deleteSelectedLeads(
                                                    selectedLeads,
                                                  )
                                                : null,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 1.2.w,
                                                vertical: 0.8.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xffEF4444),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Selected Item",
                                                    style: AppTextStyle.medium(
                                                      color: Colors.white,
                                                      weight: FontWeight.w500,
                                                      size: 9.sp,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                ),

                SizedBox(height: 1.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteSelectedLeads(List<AddLeadModel> selectedLeads) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Delete Leads"),
        content: Text(
          "Are you sure you want to delete ${selectedLeads.length} lead(s)?",
          style: AppTextStyle.medium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              for (final lead in selectedLeads) {
                await context.read<AddLeadCubit>().deleteLead(lead.id!, lead);
              }
              Navigator.pop(dialogContext);
              setState(() => _selectedIndices = []);
              context.read<AddLeadCubit>().fetchLeads();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.red,
                  content: Text("Leads deleted successfully"),
                ),
              );
            },
            child: Text("Delete", style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  /// ── Filter Card (matches TransferLeadsReport screen UX) ──
  Widget _buildFilterCard({
    required List<String> categoryItems,
    required List<String> sourceItems,
    required List<String> staffItems,
    required List<String> rejectedReasonItems,
  }) {
    const priorityItems = ["High", "Low", "Negative", "Normal"];
    const callStatusItems = [
      "Connected",
      "Busy",
      "Not Connected",
      "Wrong Number",
      "Switched Off",
      "Rejected",
      "Out of Coverage",
    ];

    // Same "rows of 4" grouping pattern used in TransferLeadsReport,
    // applied to this screen's own report-specific fields — none of the
    // fields themselves change, only how they're laid out.
    final List<Widget> filterWidgets = [
      InputDate(
        label: "From Date",
        fromController: _fromDateController,
        toController: _toDateController,
        isFrom: true,
      ),
      InputDate(
        label: "To Date",
        fromController: _fromDateController,
        toController: _toDateController,
        isFrom: false,
      ),
      MultiSelectDropdown(
        hint: 'select category',
        items: categoryItems,
        selectedValues: selectedCategories,
        onChanged: (val) {
          setState(() {
            selectedCategories = val;
            _resetPage();
          });
        },
        label: "Lead Category",
      ),
      MultiSelectDropdown(
        label: "Priority",
        hint: 'select priority',
        items: priorityItems,
        selectedValues: selectedPriorities,
        onChanged: (val) {
          setState(() {
            selectedPriorities = val;
            _resetPage();
          });
        },
      ),
      MultiSelectDropdown(
        label: "Staff",
        hint: 'select staff',
        items: staffItems,
        selectedValues: selectedStaffs,
        onChanged: (val) {
          setState(() {
            selectedStaffs = val;
            _resetPage();
          });
        },
      ),
      MultiSelectDropdown(
        label: "Rejected Reason",
        hint: 'select reason',
        items: rejectedReasonItems,
        selectedValues: selectedRejectedReasons,
        onChanged: (val) {
          setState(() {
            selectedRejectedReasons = val;
            _resetPage();
          });
        },
      ),
      MultiSelectDropdown(
        label: "Lead Source",
        hint: 'select source',
        items: sourceItems,
        selectedValues: selectedSources,
        onChanged: (val) {
          setState(() {
            selectedSources = val;
            _resetPage();
          });
        },
        message: ".",
      ),
      MultiSelectDropdown(
        label: "Call Status",
        hint: 'select status',
        items: callStatusItems,
        selectedValues: selectedCallStatuses,
        onChanged: (val) {
          setState(() {
            selectedCallStatuses = val;
            _resetPage();
          });
        },
      ),
    ];

    // Group into rows of 4, same as TransferLeadsReport.
    List<List<Widget>> rows = [];
    for (int i = 0; i < filterWidgets.length; i += 4) {
      rows.add(
        filterWidgets.sublist(
          i,
          i + 4 > filterWidgets.length ? filterWidgets.length : i + 4,
        ),
      );
    }

    return Column(
      children: [
        ...rows.map((rowItems) {
          return Padding(
            padding: EdgeInsets.only(bottom: 1.5.h),
            child: Row(
              children: [
                ...rowItems.map(
                  (widget) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.5.w),
                      child: widget,
                    ),
                  ),
                ),
                // Fill remaining space if the last row has fewer than 4 items,
                // exactly like TransferLeadsReport does for its own uneven rows.
                ...List.generate(
                  4 - rowItems.length,
                  (_) => Expanded(child: SizedBox()),
                ),
              ],
            ),
          );
        }),

        // ── Action buttons: same style, order, and behavior as TransferLeadsReport ──
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _clearFilters,
                child: Container(
                  height: 4.h,
                  padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Clear All',
                    style: AppTextStyle.small(
                      size: 10.sp,
                      color: const Color(0xFFEF4444),
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 1.w),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _applyFilters,
                child: Container(
                  height: 4.h,
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "View",
                    style: AppTextStyle.small(
                      size: 10.sp,
                      color: Colors.white,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Page number chips ───────────────────────
  Widget _buildPaginationButton({
    required Widget child,
    required bool enabled,
    required VoidCallback onTap,
    bool isActive = false,
    bool hasBorder = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xff002060)
              : (enabled ? Colors.white : const Color(0xffF8FAFC)),
          border: hasBorder
              ? Border.all(
                  color: isActive
                      ? const Color(0xff002060)
                      : const Color(0xffE2E8F0),
                  width: 1,
                )
              : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(child: child),
      ),
    );
  }

  List<Widget> _buildCustomPageNumbers(int totalPages, int totalCount) {
    final List<Widget> chips = [];

    if (totalPages <= 5) {
      for (int i = 1; i <= totalPages; i++) {
        chips.add(
          _buildPaginationButton(
            isActive: _currentPage == i,
            enabled: _currentPage != i,
            onTap: () => _goToPage(i, totalCount),
            child: Text(
              '$i',
              style: AppTextStyle.medium(
                color: _currentPage == i
                    ? Colors.white
                    : const Color(0xff334155),
                weight: _currentPage == i ? FontWeight.w600 : FontWeight.w500,
                size: 9.sp,
              ),
            ),
          ),
        );
      }
    } else {
      chips.add(
        _buildPaginationButton(
          isActive: _currentPage == 1,
          enabled: _currentPage != 1,
          onTap: () => _goToPage(1, totalCount),
          child: Text(
            '1',
            style: AppTextStyle.medium(
              color: _currentPage == 1 ? Colors.white : const Color(0xff334155),
              weight: _currentPage == 1 ? FontWeight.w600 : FontWeight.w500,
              size: 9.sp,
            ),
          ),
        ),
      );

      if (_currentPage > 3) {
        chips.add(
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            child: Text(
              '...',
              style: TextStyle(color: const Color(0xff94A3B8), fontSize: 11.sp),
            ),
          ),
        );
      }

      final start = (_currentPage - 1).clamp(2, totalPages - 1);
      final end = (_currentPage + 1).clamp(2, totalPages - 1);

      final List<int> middlePages = [];
      for (int i = start; i <= end; i++) {
        if (!middlePages.contains(i)) middlePages.add(i);
      }
      if (_currentPage <= 3) {
        if (!middlePages.contains(2)) middlePages.add(2);
        if (!middlePages.contains(3)) middlePages.add(3);
      } else if (_currentPage >= totalPages - 2) {
        if (!middlePages.contains(totalPages - 2))
          middlePages.insert(0, totalPages - 2);
        if (!middlePages.contains(totalPages - 1))
          middlePages.insert(0, totalPages - 1);
      }
      middlePages.sort();

      for (final p in middlePages) {
        if (p == 1 || p == totalPages) continue;
        chips.add(
          _buildPaginationButton(
            isActive: _currentPage == p,
            enabled: _currentPage != p,
            onTap: () => _goToPage(p, totalCount),
            child: Text(
              '$p',
              style: AppTextStyle.medium(
                color: _currentPage == p
                    ? Colors.white
                    : const Color(0xff334155),
                weight: _currentPage == p ? FontWeight.w600 : FontWeight.w500,
                size: 9.sp,
              ),
            ),
          ),
        );
      }

      if (_currentPage < totalPages - 2) {
        chips.add(
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            child: Text(
              '...',
              style: TextStyle(color: const Color(0xff94A3B8), fontSize: 11.sp),
            ),
          ),
        );
      }

      chips.add(
        _buildPaginationButton(
          isActive: _currentPage == totalPages,
          enabled: _currentPage != totalPages,
          onTap: () => _goToPage(totalPages, totalCount),
          child: Text(
            '$totalPages',
            style: AppTextStyle.medium(
              color: _currentPage == totalPages
                  ? Colors.white
                  : const Color(0xff334155),
              weight: _currentPage == totalPages
                  ? FontWeight.w600
                  : FontWeight.w500,
              size: 9.sp,
            ),
          ),
        ),
      );
    }

    return chips;
  }

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
            style: AppTextStyle.small(size: 11.sp, color: AppColors.white),
          ),
        ),
      ),
    ];
  }

  // --------export to excel function (only filtered data)--------
  void exportLeadsToExcel(List<AddLeadModel> leads, String fileName) {
    exportToExcel<AddLeadModel>(
      fileName: fileName,
      wrapColumnIndices: [2],
      rows: leads,
      columns: [
        ExcelColumn(header: 'Sl No.', value: (l) => '${leads.indexOf(l) + 1}'),
        ExcelColumn(header: 'Client Name', value: (l) => l.clientName),
        ExcelColumn(header: 'Phone No', value: (l) => l.contactNumber),
        ExcelColumn(header: 'WhatsApp No', value: (l) => l.whatsappNumber),
        ExcelColumn(header: 'Email', value: (l) => l.email),
        ExcelColumn(header: 'Address', value: (l) => l.address),
        ExcelColumn(header: 'Pin Code', value: (l) => l.pinCode),
        ExcelColumn(header: 'Post Office', value: (l) => l.postOffice),
        ExcelColumn(header: 'State', value: (l) => l.state),
        ExcelColumn(header: 'District', value: (l) => l.district),
        ExcelColumn(header: 'Lead Category', value: (l) => l.leadCategory),
        ExcelColumn(header: 'Lead Source', value: (l) => l.leadSource),
        ExcelColumn(header: 'Lead Stage', value: (l) => l.leadStage),
        ExcelColumn(header: 'Priority', value: (l) => l.priority),
        ExcelColumn(header: 'Assigned Staff', value: (l) => l.assignedStaff),
        ExcelColumn(header: 'Created By', value: (l) => l.createdBy),
        ExcelColumn(header: 'Call Result', value: (l) => l.callResult),
        ExcelColumn(header: 'Rejected Reason', value: (l) => l.leadTag),
        ExcelColumn(header: 'Remarks', value: (l) => l.remarks),
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
