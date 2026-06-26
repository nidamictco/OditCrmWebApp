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
import 'package:sizer/sizer.dart';

class RejectedLeads extends StatefulWidget {
  const RejectedLeads({super.key});

  @override
  State<RejectedLeads> createState() => _RejectedLeadsState();
}

class _RejectedLeadsState extends State<RejectedLeads> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  String? selectedCategory;
  String? selectedLeadSource;
  String? selectedPriority;
  String? selectedSource;
  String? selectedCallStatus;
  String? selectedRejectedReason;
  String? selectedStaff;

  String _searchQuery = '';
  String _selectedEntries = '10';

  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
    _fromDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _appliedFromDate = DateTime.now();
    _appliedToDate = DateTime.now();
  }

  Future<void> _loadData() async {
    final cubit = context.read<AddLeadCubit>();
    await cubit.initialize();
    await cubit.fetchStaff();
    await cubit.fetchLeads();
  }

  String? _appliedCategory;
  String? _appliedPriority;
  String? _appliedSource;
  String? _appliedStaff;
  String? _rejectedReason;
  String? _callStatus;
  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;

  void _applyFilters() {
    setState(() {
      _appliedCategory = selectedCategory;
      _appliedPriority = selectedPriority;
      _appliedSource = selectedLeadSource;
      _appliedStaff = selectedStaff;
      _rejectedReason = selectedRejectedReason;
      _callStatus = selectedCallStatus;
      _appliedFromDate = _fromDateController.text.trim().isEmpty
          ? null
          : _parseDate(_fromDateController.text);
      _appliedToDate = _toDateController.text.trim().isEmpty
          ? null
          : _parseDate(_toDateController.text);
      _resetPage();
    });
    dev.log(
      '[_applyFilters] Applied filters: FromDate=$_appliedFromDate, ToDate=$_appliedToDate, Category=$_appliedCategory, Priority=$_appliedPriority, Staff=$_appliedStaff, RejectedReason=$_rejectedReason, CallStatus=$_callStatus, Source=$_appliedSource',
    );
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
    dev.log('[RejectedLeads] Total leads fetched from state: ${leads.length}');
    
    // Log each lead's stage for troubleshooting
    for (final lead in leads) {
      dev.log('[RejectedLeads] Lead ID: ${lead.id}, Stage: "${lead.leadStage}"');
    }

    // 1. Rejected Stage Filter
    List<AddLeadModel> result = leads.where((lead) => lead.leadStage.trim().toUpperCase() == 'REJECTED').toList();
    dev.log('[RejectedLeads] Total leads matching REJECTED stage: ${result.length}');

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

    // 3. Category Filter
    if (!_isPlaceholder(_appliedCategory)) {
      final cat = _appliedCategory!.trim().toUpperCase();
      result = result
          .where((l) => l.leadCategory.toUpperCase() == cat)
          .toList();
    }

    // 4. Lead Source Filter
    if (!_isPlaceholder(_appliedSource)) {
      final source = _appliedSource!.trim().toUpperCase();
      result = result
          .where((l) => l.leadSource.toUpperCase() == source)
          .toList();
    }

    // 5. Priority Filter
    if (!_isPlaceholder(_appliedPriority)) {
      result = result
          .where(
            (l) =>
                l.priority.toLowerCase() ==
                _appliedPriority!.trim().toLowerCase(),
          )
          .toList();
    }

    // 6. Assigned Staff Filter
    if (!_isPlaceholder(_appliedStaff)) {
      result = result
          .where(
            (l) =>
                l.assignedStaff.toLowerCase() ==
                _appliedStaff!.trim().toLowerCase(),
          )
          .toList();
    }

    // 7. Rejected Reason Filter
    if (!_isPlaceholder(_rejectedReason)) {
      result = result
          .where(
            (l) =>
                l.leadTag != null &&
                l.leadTag!.toLowerCase() ==
                _rejectedReason!.trim().toLowerCase(),
          )
          .toList();
    }

    // 8. Call Status Filter
    if (!_isPlaceholder(_callStatus)) {
      result = result
          .where(
            (l) =>
                l.callResult != null &&
                l.callResult!.toLowerCase() ==
                _callStatus!.trim().toLowerCase(),
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
                              exportLeadsToExcel(filtered,'rejected_leads_');
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
                        final stageItems = state.stages
                            .map((e) => e.name)
                            .toList();
                        final staffItems = state.staffList
                            .map((e) => e.name)
                            .toList();
                        final createdByItems = state.staffList
                            .map((e) => e.name)
                            .toList();
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
                        const rejectedReasonItems = [
                          "Costly",
                          "Not Interested",
                          "Not Responding",
                          "Wrong Lead",
                          "Other",
                        ];
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 2.w,
                            right: 2.w,
                            top: 2.w,
                            bottom: 1.h,
                          ),
                          child: Column(
                            children: [
                              // Row(
                              //   children: [
                              //     _radio("Created Date", true),
                              //     SizedBox(width: 3.w),
                              //     _radio("Updated Date", false),
                              //   ],
                              // ),
                              // SizedBox(height: 1.h),

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
                                    child: Dropdown(
                                      hint: 'select category',
                                      items: categoryItems,
                                      selectedValue: selectedCategory,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedCategory = val;
                                          _resetPage();
                                        });
                                      },
                                      label: "Lead Category",
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Dropdown(
                                      label: "Priority",
                                      hint: 'select priority',
                                      items: priorityItems,
                                      selectedValue: selectedPriority,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedPriority = val;
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
                                    child: Dropdown(
                                      label: "Staff",
                                      hint: 'select staff',
                                      items: staffItems,
                                      selectedValue: selectedStaff,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedStaff = val;
                                          _resetPage();
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Dropdown(
                                      label: "Rejected Reason",
                                      hint: 'select reason',
                                      items: rejectedReasonItems,
                                      selectedValue: selectedRejectedReason,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedRejectedReason = val;
                                          _resetPage();
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Dropdown(
                                      label: "Lead Source",
                                      hint: 'select source',
                                      items: sourceItems,
                                      selectedValue: selectedLeadSource,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedLeadSource = val;
                                          _resetPage();
                                        });
                                      },
                                      message: ".",
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Dropdown(
                                      label: "Call Status",
                                      hint: 'select status',
                                      items: callStatusItems,
                                      selectedValue: selectedCallStatus,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedCallStatus = val;
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
                                  ),
                                  SizedBox(width: 2.w),
                                  if (selectedCategory != null ||
                                      selectedSource != null ||
                                      selectedPriority != null ||
                                      selectedStaff != null ||
                                      selectedCallStatus != null ||
                                      selectedRejectedReason != null)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedCategory = null;
                                          selectedSource = null;
                                          selectedPriority = null;
                                          selectedStaff = null;
                                          selectedRejectedReason = null;
                                          selectedCallStatus = null;
                                          _resetPage();
                                        });
                                      },
                                      child: Container(
                                        // width: 7.w,
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
                        // Loading
                        if (state.listStatus == LeadListStatus.loading) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
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

                        // "Showing X to Y of Z entries"
                        final showFrom = totalCount == 0
                            ? 0
                            : (_currentPage - 1) * limit + 1;
                        final showTo = (showFrom + pagedList.length - 1).clamp(
                          0,
                          totalCount,
                        );
                        // Loaded with data
                        if (state.listStatus == LeadListStatus.loaded) {
                          if (allFiltered.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              child: Center(
                                child: Text(
                                  "No Rejected Leads Found",
                                  style: AppTextStyle.medium(
                                    color: AppColors.black.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              SizedBox(
                                child: CustomTable(
                                  key: ValueKey(_tableKey),
                                  showCheckboxes: true,
                                  // key: ValueKey(filteredList.length),
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
                                    TableColumn(title: "Sl No.", flex: 1),
                                    TableColumn(title: "Name", flex: 4),
                                    TableColumn(title: "Contact No.", flex: 4),
                                    TableColumn(
                                      title: "Lead Category",
                                      flex: 4,
                                    ),
                                    TableColumn(title: "Staff ", flex: 4),
                                    TableColumn(title: "Status", flex: 4),
                                    TableColumn(title: "Reason", flex: 4),
                                    TableColumn(
                                      title: "Followup Date",
                                      flex: 4,
                                    ),
                                    TableColumn(title: "Called Date", flex: 4),
                                    TableColumn(title: "Created Date", flex: 4),
                                    TableColumn(title: "Action", flex: 2),
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
                                        lead.leadCategory,
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
                                          Icon(
                                            Icons.edit_outlined,
                                            size: 14.sp,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 0.2.w),
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

                        // 🔹 Map selected indices → actual lead objects
                        final selectedLeads = _selectedIndices
                            .where((i) => i < filteredList.length)
                            .map((i) => filteredList[i])
                            .toList();

                        final hasSelection = selectedLeads.isNotEmpty;
                        // final staff=state.assignedStaffName.map((e) => e.name).toList();
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
          style: AppTextStyle.small(
            size: 11.sp,
            color: AppColors.white,
          ),
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
      ExcelColumn(header: 'Sl No.',              value: (l) => '${leads.indexOf(l) + 1}'),
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
      ExcelColumn(header: 'Rejected Reason', value: (l) => l.leadTag),
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
