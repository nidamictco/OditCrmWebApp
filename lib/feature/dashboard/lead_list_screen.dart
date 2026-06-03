import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/export_excel.dart';
import 'package:oxdo/core/utils/input_date.dart';
import 'package:oxdo/core/utils/page_button.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/core/utils/transfer_lead_alert.dart';
import 'package:oxdo/feature/dashboard/widget/add_leads_button.dart';
import 'package:oxdo/feature/dashboard/widget/export_leads_to_pdf.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:sizer/sizer.dart';

import '../../core/shared_preference/session_service.dart';
import '../lead_managment/leads/model/add_lead_model.dart';
import '../sidebar/main_screen.dart';
import '../staff_managment/staff/model/staff_model.dart';

Color getLeadStatusColor(String status) {
  switch (status) {
    case 'FOLLOWUP':
      return const Color(0xFFF59E0B);
    case 'NEW':
      return const Color(0xFF10B981);
    case 'TRANSFERRED':
      return const Color(0xFF3B82F6);
    case 'REJECTED':
      return const Color(0xFFEF4444);
    case 'CLOSED':
      return const Color(0xFF0D31E8);
    default:
      return const Color(0xFF10B981);
  }
}

class NewLeadsPage extends StatefulWidget {
  String fromCard;
  final selectedDate;
  final StaffModel? staff;
  NewLeadsPage({
    super.key,
    required this.fromCard,
    this.staff,
    required this.selectedDate,
  });

  @override
  State<NewLeadsPage> createState() => _NewLeadsPageState();
}

class _NewLeadsPageState extends State<NewLeadsPage> {
  bool isHovering = false;
  String selectedValue = '10';
  List<String> dropdownItems = ['10', '50', '100', '500', '1000'];

  bool _selectAll = false;
  String _searchQuery = '';
  String _selectedEntries = '10';

  // ── CHANGED: use Set<String> of lead IDs instead of List<int> indices ──
  Set<String> _selectedIds = {};

  int _tableKey = 0;
  int _currentPage = 1;

  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  static const double _tableWidth =
      52 + 40 + 140 + 160 + 160 + 100 + 110 + 140 + 140 + 150;

  String? selectedCategory;
  String? selectedPriority;
  String? selectedLeadStage;
  String? selectedStaff;

  String? _appliedCategory;
  String? _appliedLeadStage;
  String? _appliedPriority;
  String? _appliedStaff;
  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;

  void _applyFilters() {
    setState(() {
      _appliedCategory = selectedCategory;
      _appliedLeadStage = selectedLeadStage;
      _appliedPriority = selectedPriority;
      _appliedStaff = selectedStaff;
      _appliedFromDate = _parseDate(fromDate.text);
      _appliedToDate = _parseDate(toDate.text);
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

  bool _isPlaceholder(String? val) =>
      val == null ||
      val.trim().isEmpty ||
      val.toLowerCase().startsWith('select');

  List<AddLeadModel> _filteredLeads(List<AddLeadModel> leads) {
    List<AddLeadModel> result = leads;

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

    if (!_isPlaceholder(_appliedCategory)) {
      final cat = _appliedCategory!.trim().toUpperCase();
      result = result
          .where((l) => l.leadCategory.toUpperCase() == cat)
          .toList();
    }

    if (!_isPlaceholder(_appliedLeadStage)) {
      final stage = _appliedLeadStage!.trim().toUpperCase();
      result = result.where((l) => l.leadStage.toUpperCase() == stage).toList();
    }

    if (!_isPlaceholder(_appliedPriority)) {
      result = result
          .where(
            (l) =>
                l.priority.toLowerCase() ==
                _appliedPriority!.trim().toLowerCase(),
          )
          .toList();
    }

    if (!_isPlaceholder(_appliedStaff)) {
      result = result
          .where(
            (l) =>
                l.assignedStaff.toLowerCase() ==
                _appliedStaff!.trim().toLowerCase(),
          )
          .toList();
    }

    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (lead) =>
                lead.clientName.toLowerCase().contains(q) ||
                lead.contactNumber.contains(q) ||
                lead.leadCategory.toLowerCase().contains(q) ||
                lead.assignedStaff.toLowerCase().contains(q),
          )
          .toList();
    }

    return result;
  }

  int _totalPages(int totalCount) {
    final limit = int.tryParse(_selectedEntries) ?? 10;
    if (totalCount == 0) return 1;
    return (totalCount / limit).ceil();
  }

  List<AddLeadModel> _pagedLeads(List<AddLeadModel> allFiltered) {
    final limit = int.tryParse(_selectedEntries) ?? 10;
    final start = (_currentPage - 1) * limit;
    final end = (start + limit).clamp(0, allFiltered.length);
    if (start >= allFiltered.length) return [];
    return allFiltered.sublist(start, end);
  }

  void _goToPage(int page, int total) {
    final tp = _totalPages(total);
    if (page < 1 || page > tp) return;
    setState(() {
      _currentPage = page;
      // ── CHANGED: clear selection on page change ──
      _selectedIds = {};
      _selectAll = false;
      _tableKey++;
    });
  }

  void _resetPage() {
    _currentPage = 1;
    // ── CHANGED: clear selection on reset ──
    _selectedIds = {};
    _selectAll = false;
    _tableKey++;
  }

  // ── CHANGED: toggleSelectAll now takes the current page leads ──
  void _toggleSelectAll(bool? value, List<AddLeadModel> currentPageLeads) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        for (final lead in currentPageLeads) {
          if (lead.id != null) _selectedIds.add(lead.id!);
        }
      } else {
        for (final lead in currentPageLeads) {
          if (lead.id != null) _selectedIds.remove(lead.id!);
        }
      }
    });
  }

  // ── CHANGED: toggleSelect now actually updates _selectedIds ──
  void _toggleSelect(String id, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _onView(AddLeadModel lead) {
    _showSnackBar('Viewing ${lead.clientName}', AppTheme.actionView);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(selectedIndex: 31, lead: lead),
      ),
    ).then((_) {
    // Reload leads from cubit after returning from detail screen
    context.read<AddLeadCubit>().fetchDashboardLeads(
      staffId: widget.staff!.id!,
      role: widget.staff?.staffType ?? 'Admin',
      fromCard: widget.fromCard,
      selectedDate: widget.selectedDate ?? DateTime.now(),
    );
  });
  }

  void _onEdit(AddLeadModel lead) {
    _showSnackBar('Editing ${lead.clientName}', AppTheme.actionEdit);
 Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(selectedIndex: 1, lead: lead),
      ),
    );
  }

  void _onHistory(AddLeadModel lead) {
    _showSnackBar('History for ${lead.clientName}', AppTheme.actionHistory);
  }

  void _onDelete(AddLeadModel lead) {
    showDialog(
      context: context,
      builder: (_) => _DeleteConfirmDialog(
        leadName: lead.clientName,
        onConfirm: () async {
          await context.read<AddLeadCubit>().deleteLead(lead.id!, lead);
        },
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AddLeadCubit>();

    fromDate.text = DateFormat(
      'dd-MM-yyyy',
    ).format(widget.selectedDate ?? DateTime.now());

    toDate.text = DateFormat(
      'dd-MM-yyyy',
    ).format(widget.selectedDate ?? DateTime.now());

    log("Staff ID : ${widget.staff!.id!}");
    log("Staff name : ${widget.staff!.name}");
    log("Role : ${widget.staff?.staffType}");
    log("From Card : ${widget.fromCard}");
    log("Selected Date : ${widget.selectedDate}");

    cubit.fetchDashboardLeads(
      staffId: widget.staff!.id!,
      role: widget.staff?.staffType ?? 'Admin',
      fromCard: widget.fromCard ?? "",
      selectedDate: widget.selectedDate ?? DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBreadcrumbBar(
              title: 'DASHBOARD',
              subTitle: widget.fromCard.toUpperCase(),
            ),

            Padding(
              padding: EdgeInsets.all(1.w),
              child: Container(
                decoration: _cardBox(),
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
                            "${widget.fromCard.toUpperCase()} LEADS",
                            style: AppTextStyle.medium(
                              size: 13.6.sp,
                              color: AppColors.black.withOpacity(0.77),
                              weight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              AddLeadsButton(),
                              SizedBox(width: 1.w),
                              HoverExportButton(onExportExcel: () {
                              final leads = context
                                  .read<AddLeadCubit>()
                                  .state 
                                  .leads;
                              final filtered = _filteredLeads(
                                leads,
                              ); // exports only filtered data
                              exportLeadsToExcel(filtered,'new_leads');
                            }, onExportPDF: () {
                              final leads = context
                                  .read<AddLeadCubit>()
                                  .state 
                                  .leads;
                              final filtered = _filteredLeads(
                                leads,
                              ); // exports only filtered data
                              exportLeadsToPdf(filtered);
                            }),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Divider(color: AppColors.divider),

                    /// 🔹 FILTER SECTION
                    BlocBuilder<AddLeadCubit, AddLeadState>(
                      builder: (context, state) {
                        final categoryItems = state.categories
                            .map((e) => e.name)
                            .toList();
                        final stageItems = state.stages
                            .map((e) => e.name)
                            .toList();
                        final staffItems = state.staffList
                            .map((e) => e.name)
                            .toList();

                        const priorityItems = [
                          "High",
                          "Low",
                          "Negative",
                          "Normal",
                        ];

                        return Padding(
                          padding: EdgeInsets.all(2.w),
                          child: Column(
                            children: [
                              /// FIRST ROW
                              Row(
                                children: [
                                  Expanded(
                                    child: InputDate(
                                      label: "From Date",
                                      fromController: fromDate,
                                      toController: toDate,
                                      isFrom: true,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: InputDate(
                                      label: "To Date",
                                      fromController: fromDate,
                                      toController: toDate,
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
                                      label: "Lead Stage",
                                      hint: 'select stage',
                                      items: stageItems,
                                      selectedValue: selectedLeadStage,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedLeadStage = val;
                                          _resetPage();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 2.h),

                              /// SECOND ROW
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 17.6.w,
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
                                  SizedBox(width: 2.w),
                                  SizedBox(
                                    width: 17.6.w,
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
                                ],
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: _applyFilters,
                                    child: Padding(
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
                                  ),
                                  SizedBox(width: 1.w),
                                  if (selectedCategory != null ||
                                      selectedPriority != null ||
                                      selectedLeadStage != null ||
                                      selectedStaff != null)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedCategory = null;
                                          selectedPriority = null;
                                          selectedLeadStage = null;
                                          selectedStaff = null;
                                          _resetPage();
                                        });
                                      },
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
                    ),

                    Divider(color: AppColors.divider),

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

                    /// 🔹 TABLE
                    _buildTable(),

                    /// 🔹 BOTTOM TRANSFER BUTTON
                    // Padding(
                    //   padding: EdgeInsets.only(bottom: 2.h),
                    //   child: Center(
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Container(
                    //           width: 3.w,
                    //           height: 5.h,
                    //           decoration: BoxDecoration(
                    //             color: AppColors.red.withOpacity(0.2),
                    //             borderRadius: BorderRadius.circular(4),
                    //           ),
                    //           child: Center(
                    //             child: Icon(
                    //               Icons.delete_forever_outlined,
                    //               color: AppColors.red,
                    //               size: 1.5.w,
                    //             ),
                    //           ),
                    //         ),
                    //         SizedBox(width: 0.5.w),
                    //         Center(child: _bottomButton("Transfer")),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    /// 🔹 BOTTOM TRANSFER BUTTON
                    BlocBuilder<AddLeadCubit, AddLeadState>(
                      builder: (context, state) {
                        final List<AddLeadModel> rawList =
                            state.listStatus == LeadListStatus.loaded
                            ? state.leads
                            : [];
                        final filteredList = _filteredLeads(rawList);

                        // ── Map selected IDs → actual lead objects ──
                        final selectedLeads = filteredList
                            .where(
                              (l) =>
                                  l.id != null && _selectedIds.contains(l.id),
                            )
                            .toList();

                        final hasSelection = selectedLeads.isNotEmpty;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Container(
                                //   width: 3.w,
                                //   height: 5.h,
                                //   decoration: BoxDecoration(
                                //     color: AppColors.red.withOpacity(0.2),
                                //     borderRadius: BorderRadius.circular(4),
                                //   ),
                                //   child: Center(
                                //     child: Icon(
                                //       Icons.delete_forever_outlined,
                                //       color: AppColors.red,
                                //       size: 1.5.w,
                                //     ),
                                //   ),
                                // ),
                                GestureDetector(
                                  onTap: hasSelection
                                      ? () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              backgroundColor: AppColors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              title: const Text(
                                                'Delete Selected Leads',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete ${selectedLeads.length} selected lead(s)? This action cannot be undone.',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        AppTheme.textSecondary,
                                                  ),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    for (final lead
                                                        in selectedLeads) {
                                                      await context
                                                          .read<AddLeadCubit>()
                                                          .deleteLead(
                                                            lead.id!,
                                                            lead,
                                                          );
                                                    }
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          '${selectedLeads.length} lead(s) deleted successfully.',
                                                          style:
                                                              AppTextStyle.medium(
                                                                color: AppColors
                                                                    .white,
                                                                weight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                        ),
                                                        backgroundColor:
                                                            AppColors.red,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        duration:
                                                            const Duration(
                                                              seconds: 3,
                                                            ),
                                                      ),
                                                    );
                                                    // ── Clear selections after delete ──
                                                    setState(() {
                                                      _selectedIds = {};
                                                      _selectAll = false;
                                                      _tableKey++;
                                                    });
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.red,
                                                    foregroundColor:
                                                        Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      : () => ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Please select at least one lead to delete.',
                                                  style: AppTextStyle.medium(
                                                    color: AppColors.white,
                                                    weight: FontWeight.w400,
                                                  ),
                                                ),
                                                backgroundColor: AppColors.red,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                              ),
                                            ),
                                  child: Container(
                                    width: 3.w,
                                    height: 5.h,
                                    decoration: BoxDecoration(
                                      color: hasSelection
                                          ? AppColors.red.withOpacity(0.2)
                                          : AppColors.red.withOpacity(
                                              0.08,
                                            ), // dims when nothing selected
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.delete_forever_outlined,
                                        color: hasSelection
                                            ? AppColors.red
                                            : AppColors.red.withOpacity(0.4),
                                        size: 1.5.w,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 0.5.w),
                                GestureDetector(
                                  onTap: hasSelection
                                      ? () => showAssignStaffDialog(
                                          selectedLeads,
                                          context,
                                          onSubmit:
                                              (
                                                String? selectedStaffId,
                                                String? selectedStaffName,
                                              ) async {
                                                if (selectedStaffId == null ||
                                                    selectedStaffName == null)
                                                  return;

                                                // ── Only transfer leads not already assigned to the selected staff ──
                                                final leadsToTransfer =
                                                    selectedLeads
                                                        .where(
                                                          (l) =>
                                                              l.assignedStaff !=
                                                              selectedStaffName,
                                                        )
                                                        .toList();

                                                if (leadsToTransfer.isEmpty) {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'All selected leads are already assigned to $selectedStaffName.',
                                                        style:
                                                            AppTextStyle.medium(
                                                              color: AppColors
                                                                  .white,
                                                              weight: FontWeight
                                                                  .w400,
                                                            ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.orange,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      duration: const Duration(
                                                        seconds: 3,
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                // ── Transfer only the leads that are actually different ──
                                                for (final lead
                                                    in selectedLeads) {
                                                  await context
                                                      .read<AddLeadCubit>()
                                                      .transferLead(
                                                        leadId: lead.id!,
                                                        leadName:
                                                            lead.clientName,
                                                        contactNumber:
                                                            lead.contactNumber,
                                                        leadCategory:
                                                            lead.leadCategory,
                                                        leadStage:
                                                            lead.leadStage,
                                                        fromStaffId: lead
                                                            .assignedStaffId,
                                                        fromStaff:
                                                            lead.assignedStaff,
                                                        toStaffId:
                                                            selectedStaffId,
                                                        toStaff:
                                                            selectedStaffName,
                                                      );
                                                }

                                                Navigator.pop(context);

                                                // ── Show how many were transferred vs skipped ──
                                                final skippedCount =
                                                    selectedLeads.length -
                                                    leadsToTransfer.length;
                                                final message = skippedCount > 0
                                                    ? '${leadsToTransfer.length} lead(s) transferred. $skippedCount already assigned to $selectedStaffName (skipped).'
                                                    : '${leadsToTransfer.length} lead(s) transferred successfully.';

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      message,
                                                      style:
                                                          AppTextStyle.medium(
                                                            color:
                                                                AppColors.white,
                                                            weight:
                                                                FontWeight.w400,
                                                          ),
                                                    ),
                                                    backgroundColor:
                                                        AppColors.primary,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 3,
                                                    ),
                                                  ),
                                                );

                                                // ── Clear selections after transfer ──
                                                setState(() {
                                                  _selectedIds = {};
                                                  _selectAll = false;
                                                  _tableKey++;
                                                });
                                              },
                                        )
                                      : () => ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Please select at least one lead to transfer.',
                                                  style: AppTextStyle.medium(
                                                    color: AppColors.white,
                                                    weight: FontWeight.w400,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    AppColors.primary,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                              ),
                                            ),
                                  child: Container(
                                    width: 5.w,
                                    padding: EdgeInsets.all(0.5.w),
                                    decoration: BoxDecoration(
                                      color: hasSelection
                                          ? AppColors.primary
                                          : AppColors.primary.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Transfer',
                                      style: AppTextStyle.small(
                                        size: 11.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

  /// ================= UI =================

  BoxDecoration _cardBox() => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(4),
    border: Border.all(color: AppColors.divider),
  );

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

  BoxDecoration _box() => BoxDecoration(
    border: Border.all(color: AppColors.lightGrey),
    borderRadius: BorderRadius.circular(4),
    color: AppColors.white,
  );

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Icon(
          Icons.search_off_rounded,
          size: 56,
          color: AppTheme.textMuted.withOpacity(0.5),
        ),
        const SizedBox(height: 10),
        const Text(
          'No leads found',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTable() {
    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      notificationPredicate: (n) => n.depth == 0,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _tableWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Body ──
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: BlocBuilder<AddLeadCubit, AddLeadState>(
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

                    final List<AddLeadModel> rawList =
                        state.listStatus == LeadListStatus.loaded
                        ? state.leads
                        : [];

                    final List<AddLeadModel> leads = rawList;
                    final allFiltered = _filteredLeads(leads);
                    final totalCount = allFiltered.length;
                    final totalPages = _totalPages(totalCount);
                    final limit = int.tryParse(_selectedEntries) ?? 10;

                    if (_currentPage > totalPages) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() => _currentPage = totalPages);
                      });
                    }

                    final pagedList = _pagedLeads(allFiltered);

                    // ── CHANGED: compute selectAll from current page ──
                    final allPageSelected =
                        pagedList.isNotEmpty &&
                        pagedList.every(
                          (l) => l.id != null && _selectedIds.contains(l.id),
                        );
                    if (_selectAll != allPageSelected) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted)
                          setState(() => _selectAll = allPageSelected);
                      });
                    }

                    final showFrom = totalCount == 0
                        ? 0
                        : (_currentPage - 1) * limit + 1;
                    final showTo = (showFrom + pagedList.length - 1).clamp(
                      0,
                      totalCount,
                    );

                    if (pagedList.isEmpty) {
                      return Column(
                        children: [
                          // Still show header even when empty
                          Container(
                            color: AppTheme.surface,
                            child: Column(
                              children: [
                                Container(height: 1, color: AppTheme.border),
                                // ── CHANGED: pass empty list so selectAll does nothing ──
                                _HeaderRow(
                                  selectAll: false,
                                  onSelectAll: (v) => _toggleSelectAll(v, []),
                                ),
                                Container(height: 1, color: AppTheme.border),
                              ],
                            ),
                          ),
                          Center(child: _buildEmptyState()),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        // ── Sticky header ──
                        Container(
                          color: AppTheme.surface,
                          child: Column(
                            children: [
                              Container(height: 1, color: AppTheme.border),
                              // ── CHANGED: pass pagedList so header knows which rows to select ──
                              _HeaderRow(
                                selectAll: allPageSelected,
                                onSelectAll: (v) =>
                                    _toggleSelectAll(v, pagedList),
                              ),
                              Container(height: 1, color: AppTheme.border),
                            ],
                          ),
                        ),

                        ListView.separated(
                          shrinkWrap: true,
                          itemCount: pagedList.length,
                          separatorBuilder: (_, __) =>
                              Container(height: 1, color: AppTheme.border),
                          itemBuilder: (context, index) {
                            final lead = pagedList[index];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainScreen(
                                      selectedIndex: 31,
                                      lead: lead,
                                    ),
                                  )
                                ).then((_) {
    // Reload leads from cubit after returning from detail screen
    context.read<AddLeadCubit>().fetchDashboardLeads(
      staffId: widget.staff!.id!,
      role: widget.staff?.staffType ?? 'Admin',
      fromCard: widget.fromCard,
      selectedDate: widget.selectedDate ?? DateTime.now(),
    );
  });
                              },
                              child: _LeadRow(
                                lead: lead,
                                isEven: index.isEven,
                                // ── CHANGED: pass real isSelected value ──
                                isSelected: _selectedIds.contains(lead.id),
                                onToggleSelect: _toggleSelect,
                                onView: _onView,
                                onEdit: _onEdit,
                                onHistory: _onHistory,
                                onDelete: _onDelete,
                                index: index,
                              ),
                            );
                          },
                        ),

                        Divider(color: AppColors.divider),

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
                                    onTap: () =>
                                        _goToPage(_currentPage - 1, totalCount),
                                  ),
                                  ..._buildPageNumbers(totalPages, totalCount),
                                  PageButton(
                                    label: 'Next',
                                    enabled: _currentPage < totalPages,
                                    isRight: true,
                                    onTap: () =>
                                        _goToPage(_currentPage + 1, totalCount),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers(int totalPages, int totalCount) {
    if (totalPages <= 1) return [];

    final List<Widget> widgets = [];

    int start = (_currentPage - 2).clamp(1, totalPages);
    int end = (start + 4).clamp(1, totalPages);
    if (end - start < 4) start = (end - 4).clamp(1, totalPages);

    for (int page = start; page <= end; page++) {
      final isActive = page == _currentPage;
      widgets.add(
        GestureDetector(
          onTap: () => _goToPage(page, totalCount),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 0.2.w),
            padding: EdgeInsets.symmetric(horizontal: 1.2.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.white,
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Text(
              '$page',
              style: AppTextStyle.small(
                size: 11.sp,
                color: isActive ? AppColors.white : AppColors.grey,
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  // -------export to excel-------
  void exportLeadsToExcel(List<AddLeadModel> leads, String fileName) {
  exportToExcel<AddLeadModel>(
    fileName: fileName,
    rows: leads,
    columns: [
      ExcelColumn(header: '#',              value: (l) => '${leads.indexOf(l) + 1}'),
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

class HoverExportButton extends StatefulWidget {
  final VoidCallback? onExportExcel;
  final VoidCallback? onExportPDF;
  const HoverExportButton({super.key,this.onExportExcel, this.onExportPDF});

  @override
  State<HoverExportButton> createState() => _HoverExportButtonState();
}

class _HoverExportButtonState extends State<HoverExportButton> {
  OverlayEntry? _overlayEntry;
  bool _isHovering = false;

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 10.w,
        top: position.dy + renderBox.size.height + 5,
        child: MouseRegion(
          onEnter: (_) => _isHovering = true,
          onExit: (_) => _hideOverlay(),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 180,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _item(Icons.table_chart, "Export Excel",onTap: widget.onExportExcel),
                  _item(Icons.picture_as_pdf, "Export PDF", onTap: widget.onExportPDF),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!_isHovering) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  // Widget _item(IconData icon, String text, {VoidCallback? onTap}) {
  //   return InkWell(
  //     onTap: () {
  //       _overlayEntry?.remove();
  //       _overlayEntry = null;
  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  //       child: GestureDetector(
  //         onTap: onTap,
  //         child: Row(
  //           children: [
  //             Icon(icon, size: 18),
  //             const SizedBox(width: 10),
  //             Text(text),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _item(IconData icon, String text, {VoidCallback? onTap}) {
  return InkWell(
    onTap: () {
      // Close overlay first
      _isHovering = false;
      _overlayEntry?.remove();
      _overlayEntry = null;
      // Then run the action
      onTap?.call();
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _isHovering = true;
        _showOverlay();
      },
      onExit: (_) {
        _isHovering = false;
        _hideOverlay();
      },
      child: Container(
        height: 4.5.h,
        width: 4.5.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.indigo.shade100,
        ),
        child: Icon(Icons.print, size: 18, color: Colors.indigo.shade900),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HEADER ROW
// ─────────────────────────────────────────────

class _HeaderRow extends StatelessWidget {
  final bool selectAll;
  final ValueChanged<bool?> onSelectAll;

  const _HeaderRow({required this.selectAll, required this.onSelectAll});

  static const _style = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppTheme.textSecondary,
    letterSpacing: 0.6,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15),
      color: const Color(0xFFF1F5F9),
      height: 44,
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Center(
              child: Checkbox(
                value: selectAll,
                onChanged: onSelectAll,
                activeColor: AppTheme.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          _cell('#', 40),
          _cell('NAME', 140),
          _cell('CONTACT NUMBER', 140),
          _cell('LEAD CATEGORY', 160),
          _cell('STAFF', 100),
          _cell('STATUS', 110),
          _cell('FOLLOWUP DATE', 140),
          _cell('CALLED DATE', 140),
          _cell('ACTION', 130),
        ],
      ),
    );
  }

  Widget _cell(String label, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(label, style: _style),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA ROW
// ─────────────────────────────────────────────

class _LeadRow extends StatefulWidget {
  final AddLeadModel lead;
  final bool isEven;
  final bool isSelected; // ── CHANGED: added isSelected ──
  final int index;
  final void Function(String, bool?) onToggleSelect;
  final void Function(AddLeadModel) onView;
  final void Function(AddLeadModel) onEdit;
  final void Function(AddLeadModel) onHistory;
  final void Function(AddLeadModel) onDelete;

  const _LeadRow({
    required this.lead,
    required this.isEven,
    required this.isSelected, // ── CHANGED ──
    required this.onToggleSelect,
    required this.onView,
    required this.onEdit,
    required this.onHistory,
    required this.onDelete,
    required this.index,
  });

  @override
  State<_LeadRow> createState() => _LeadRowState();
}

class _LeadRowState extends State<_LeadRow> {
  bool _hovered = false;

  static final DateFormat _fmt = DateFormat('dd-MM-yyyy hh:mm a');

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        // ── CHANGED: highlight selected rows ──
        color: widget.isSelected
            ? AppTheme.primary.withOpacity(0.07)
            : _hovered
            ? const Color(0xFFF8FAFC)
            : widget.isEven
            ? AppTheme.surface
            : const Color(0xFFFAFAFA),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              // Checkbox
              SizedBox(
                width: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: const BoxDecoration(
                        color: AppTheme.onlineGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    // ── CHANGED: use widget.isSelected and wire onChanged ──
                    Checkbox(
                      value: widget.isSelected,
                      onChanged: (v) => widget.onToggleSelect(lead.id!, v),
                      activeColor: AppTheme.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              // #
              _textCell(
                '${widget.index + 1}',
                40,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Name
              _textCell(
                lead.clientName,
                140,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Contact
              SizedBox(
                width: 140,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: lead.contactNumber),
                      );
                    },
                    child: Text(
                      lead.contactNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              // Category
              _textCell(
                lead.leadCategory,
                160,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              // Staff
              SizedBox(
                width: 100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppTheme.border,
                        child: const Icon(
                          Icons.person_rounded,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          lead.assignedStaff,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Status
              SizedBox(
                width: 110,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _StatusBadge(status: lead.leadStage),
                ),
              ),
              // FollowUp Date
              lead.followUpDate == null
                  ? _textCell(
                      _fmt.format(DateTime.now()),
                      140,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    )
                  : _textCell(
                      _fmt.format(lead.followUpDate!),
                      140,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
              // Called Date
              lead.calledDate == null
                  ? _textCell(
                      _fmt.format(DateTime.now()),
                      140,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    )
                  : _textCell(
                      _fmt.format(lead.calledDate!),
                      140,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
              // Actions
              SizedBox(
                width: 130,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      _ActionButton(
                        icon: Icons.visibility_rounded,
                        color: AppTheme.actionView,
                        tooltip: 'View',
                        onTap: () => widget.onView(lead),
                      ),
                      _ActionButton(
                        icon: Icons.edit_rounded,
                        color: AppTheme.actionEdit,
                        tooltip: 'Edit',
                        onTap: () => widget.onEdit(lead),
                      ),
                      _ActionButton(
                        icon: Icons.delete_rounded,
                        color: AppTheme.actionDelete,
                        tooltip: 'Delete',
                        onTap: () => widget.onDelete(lead),
                      ),
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

  Widget _textCell(String text, double width, {required TextStyle style}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(text, style: style),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: getLeadStatusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: getLeadStatusColor(status).withOpacity(0.3)),
      ), 
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: getLeadStatusColor(status),
          letterSpacing: 0.2,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _hovered
                  ? widget.color.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(widget.icon, size: 16, color: widget.color),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DELETE CONFIRM DIALOG
// ─────────────────────────────────────────────

class _DeleteConfirmDialog extends StatelessWidget {
  final String leadName;
  final VoidCallback onConfirm;

  const _DeleteConfirmDialog({required this.leadName, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Delete Lead',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "$leadName"? This action cannot be undone.',
        style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.actionDelete,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
