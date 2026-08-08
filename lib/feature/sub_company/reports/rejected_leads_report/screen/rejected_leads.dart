import 'package:Odit_CRM/core/router/browser_aware_link.dart';
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
      backgroundColor: AppColors.background,
      body: BlocListener<AddLeadCubit, AddLeadState>(
        listenWhen: (previous, current) =>
            previous.listStatus != LeadListStatus.loaded &&
            current.listStatus == LeadListStatus.loaded,
        listener: (context, state) {
          _applyFilters();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              StaffTopBar(
                title: '',
                parent: 'Reports',
                current: 'Rejected Leads',
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 2.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Rejected Leads Report",
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
                                exportLeadsToExcel(filtered, 'rejected_leads_');
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
                      BlocBuilder<AddLeadCubit, AddLeadState>(
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
                                (s) =>
                                    s.name.trim().toUpperCase() == 'REJECTED',
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
                                        label: 'From Date',
                                        fromController: _fromDateController,
                                        toController: _toDateController,
                                        isFrom: true,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: InputDate(
                                        label: 'To Date',
                                        fromController: _fromDateController,
                                        toController: _toDateController,
                                        isFrom: false,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: MultiSelectDropdown(
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
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: MultiSelectDropdown(
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
                                    ),
                                  ],
                                ),

                                SizedBox(height: 1.h),

                                Row(
                                  children: [
                                    Expanded(
                                      child: MultiSelectDropdown(
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
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: MultiSelectDropdown(
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
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: MultiSelectDropdown(
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
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: MultiSelectDropdown(
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
                                    ),
                                  ],
                                ),

                                SizedBox(height: 1.h),

                                /// 🔥 VIEW BUTTON (perfect aligned)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                    SizedBox(width: 2.w),
                                    if (_hasActiveFilters())
                                      InkWell(
                                        onTap: _clearFilters,
                                        child: Container(
                                          height: 4.5.h,
                                          padding: EdgeInsets.all(1.h),
                                          margin: EdgeInsets.only(top: 2.h),
                                          decoration: BoxDecoration(
                                            color: AppColors.orange,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
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
                          );
                        },
                      ),
                      Divider(color: AppColors.divider),
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
                      ),

                      SizedBox(height: 2.h),
                      BlocBuilder<AddLeadCubit, AddLeadState>(
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
                          final showTo = (showFrom + pagedList.length - 1)
                              .clamp(0, totalCount);

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
                                    rows: pagedList.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final lead = entry.value;
                                      final serial =
                                          (_currentPage - 1) * limit +
                                          index +
                                          1;
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
                                              destination:
                                                  RoutePaths.followUpPath(
                                                    lead.id!,
                                                    "NEW",
                                                    fromScreen: 'rejectedReport'
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
                                        "Showing $showFrom to $showTo of $totalCount entries",
                                        style: AppTextStyle.medium(
                                          weight: FontWeight.w400,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          PageButton(
                                            label: 'Previous',
                                            enabled: _currentPage > 1,
                                            isLeft: true,
                                            onTap: () => _goToPage(
                                              _currentPage - 1,
                                              totalCount,
                                            ),
                                          ),
                                          ..._buildPageNumbers(
                                            totalPages,
                                            totalCount,
                                          ),
                                          PageButton(
                                            label: 'Next',
                                            enabled: _currentPage < totalPages,
                                            isRight: true,
                                            onTap: () => _goToPage(
                                              _currentPage + 1,
                                              totalCount,
                                            ),
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

                      BlocBuilder<AddLeadCubit, AddLeadState>(
                        builder: (context, state) {
                          final List<AddLeadModel> rawList =
                              state.listStatus == LeadListStatus.loaded
                              ? state.leads
                              : [];
                          final filteredList = _filteredLeads(rawList);

                          final selectedLeads = _selectedIndices
                              .where((i) => i < filteredList.length)
                              .map((i) => filteredList[i])
                              .toList();

                          final hasSelection = selectedLeads.isNotEmpty;
                          return Center(
                            child: GestureDetector(
                              onTap: hasSelection
                                  ? () => _deleteSelectedLeads(selectedLeads)
                                  : null,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 1.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.red.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.delete_forever,
                                  size: 14.sp,
                                  color: AppColors.red,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 1.h),
                    ],
                  ),
                ),
              ),
            ],
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
