import 'dart:developer';

import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/utils/multi_select_dropdown.dart';
import 'package:Odit_CRM/core/utils/resolved_lead_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/utils/dropdown.dart';
import 'package:Odit_CRM/core/utils/export_excel.dart';
import 'package:Odit_CRM/core/utils/input_date.dart';
import 'package:Odit_CRM/core/utils/page_button.dart';
import 'package:Odit_CRM/core/utils/show_entries.dart';
import 'package:Odit_CRM/core/utils/table.dart';
import 'package:Odit_CRM/core/utils/top_bread_crumb_bar.dart';
import 'package:Odit_CRM/core/utils/transfer_lead_alert.dart';
import 'package:Odit_CRM/feature/sub_company/dashboard/widget/add_leads_button.dart';
import 'package:Odit_CRM/feature/sub_company/dashboard/widget/export_leads_to_pdf.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:sizer/sizer.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/router/browser_aware_link.dart';
import '../../../core/shared_preference/session_service.dart';
import '../lead_managment/leads/model/add_lead_model.dart';
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
  final DateTime? selectedDate;
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

  String? _currentUserRole;

  bool _selectAll = false;
  String _searchQuery = '';
  String _selectedEntries = '10';

  Set<String> _selectedIds = {};

  int _tableKey = 0;
  int _currentPage = 1;

  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  static const double _tableWidth =
      52 + 40 + 140 + 160 + 160 + 100 + 110 + 140 + 140 + 150;

  // ── Draft (UI-bound) multi-select values ──
  List<String> selectedCategories = [];
  List<String> selectedSources = [];
  List<String> selectedPriorities = [];
  List<String> selectedLeadStages = [];
  List<String> selectedStaffs = [];
  List<String> selectedSubCategories = [];
  List<String> selectedTags = [];

  // ── Currently APPLIED filter values (used by _filteredLeads) ──
  List<String> _appliedCategories = [];
  List<String> _appliedLeadStages = [];
  List<String> _appliedPriorities = [];
  List<String> _appliedStaff = [];
  List<String> _appliedSubCategories = [];
  List<String> _appliedTags = [];

  // ── Static: preserve DRAFT selections across navigation ──
  static List<String> _staticCategories = [];
  static List<String> _staticSources = [];
  static List<String> _staticPriorities = [];
  static List<String> _staticLeadStages = [];
  static List<String> _staticStaffs = [];
  static List<String> _staticSubCategories = [];
  static List<String> _staticTags = [];

  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;

  // Static variables to preserve filter state across screen navigation
  static bool _hasSavedState = false;
  static String? _staticFromCard;
  static String? _staticFromDate;
  static String? _staticToDate;

  // ── Static: preserve APPLIED selections across navigation ──
  static List<String> _staticAppliedCategories = [];
  static List<String> _staticAppliedLeadStages = [];
  static List<String> _staticAppliedPriorities = [];
  static List<String> _staticAppliedSources = [];
  static List<String> _staticAppliedStaff = [];
  static List<String> _staticAppliedSubCategories = [];
  static List<String> _staticAppliedTags = [];

  static DateTime? _staticAppliedFromDate;
  static DateTime? _staticAppliedToDate;
  static String _staticSearchQuery = '';
  static String _staticSelectedEntries = '10';
  static int _staticCurrentPage = 1;

  void _applyFilters() {
    final from = _parseDate(fromDate.text);
    final to = _parseDate(toDate.text);

    // Re-fetch from Firestore with the new date range
    // so records outside the original dashboard date are included
    context.read<AddLeadCubit>().fetchDashboardLeads(
      staffId: widget.staff?.id ?? '',
      role: widget.staff?.staffType ?? 'Admin',
      fromCard: widget.fromCard,
      selectedDate: from,
      toDate: to ?? DateTime.now(),
    );
    setState(() {
      _appliedCategories = List.from(selectedCategories);
      _appliedLeadStages = List.from(selectedLeadStages);
      _appliedPriorities = List.from(selectedPriorities);
      _appliedStaff = List.from(selectedStaffs);
      _appliedSubCategories = List.from(selectedSubCategories);
      _appliedTags = List.from(selectedTags);
      _appliedFromDate = from;
      _appliedToDate = to ?? DateTime.now();
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

  int _priorityOrder(String priority) {
    switch (priority.trim().toLowerCase()) {
      case 'high':
        return 1;
      case 'normal':
        return 2;
      case 'low':
        return 3;
      case 'negative':
        return 4;
      default:
        return 5;
    }
  }

  List<AddLeadModel> _filteredLeads(List<AddLeadModel> leads) {
    List<AddLeadModel> result = leads;

    final from = _appliedFromDate;
    final to = _appliedToDate;

    if (from != null || to != null) {
      final fromDay = from != null
          ? DateTime(from.year, from.month, from.day)
          : null;
      final toDay = to != null
          ? DateTime(to.year, to.month, to.day, 23, 59, 59)
          : null;

      result = result.where((lead) {
        // Pick the right date field based on which card opened this screen
        DateTime? dateToCheck;

        switch (widget.fromCard.toUpperCase()) {
          case 'NEW':
            dateToCheck = lead.createdAt;
            break;
          case 'FOLLOWUP':
            dateToCheck = lead.followUpDate;
            break;
          case 'TOTAL':
            dateToCheck = lead.calledDate;
            break;
          case 'CLOSED':
          case 'MISSED':
            // These are stage-based, not date-based.
            // Allow all through — don't filter by date.
            return true;
          case 'TRANSFERRED':
            // Check if any transfer falls in range
            if (lead.transferLeads == null || lead.transferLeads!.isEmpty) {
              return false;
            }
            return lead.transferLeads!.any((t) {
              if (t.transferTime == null) return false;
              if (fromDay != null && t.transferTime!.isBefore(fromDay))
                return false;
              if (toDay != null && t.transferTime!.isAfter(toDay)) return false;
              return true;
            });
          default:
            dateToCheck = lead.createdAt;
        }

        if (dateToCheck == null) return false;
        if (fromDay != null && dateToCheck.isBefore(fromDay)) return false;
        if (toDay != null && dateToCheck.isAfter(toDay)) return false;
        return true;
      }).toList();
    }

    if (_appliedCategories.isNotEmpty) {
      final cats = _appliedCategories
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((l) => cats.contains(l.leadCategory.toUpperCase()))
          .toList();
    }

    if (_appliedLeadStages.isNotEmpty) {
      final stages = _appliedLeadStages
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((l) => stages.contains(l.leadStage.toUpperCase()))
          .toList();
    }

    if (_appliedPriorities.isNotEmpty) {
      final priorities = _appliedPriorities
          .map((e) => e.trim().toLowerCase())
          .toSet();
      result = result
          .where((l) => priorities.contains(l.priority.toLowerCase()))
          .toList();
    }

    if (_appliedStaff.isNotEmpty) {
      final staffSet = _appliedStaff.map((e) => e.trim().toLowerCase()).toSet();
      result = result
          .where((l) => staffSet.contains(l.assignedStaff.toLowerCase()))
          .toList();
    }

    // ── Sub Category ─────────────────────────────────────────────────────────
    if (_appliedSubCategories.isNotEmpty) {
      final subCats = _appliedSubCategories
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((l) => subCats.contains(l.leadSubCategory.toUpperCase()))
          .toList();
    }

    // ── Lead Tag ─────────────────────────────────────────────────────────────
    if (_appliedTags.isNotEmpty) {
      final tags = _appliedTags.map((e) => e.trim().toUpperCase()).toSet();
      result = result
          .where((l) => tags.contains(l.leadTag.toUpperCase()))
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

    result.sort((a, b) {
      // First sort by priority
      final priorityCompare = _priorityOrder(
        a.priority,
      ).compareTo(_priorityOrder(b.priority));

      if (priorityCompare != 0) {
        return priorityCompare;
      }

      // If priority is same, latest createdAt first
      final aCreated = a.createdAt ?? DateTime(1970);
      final bCreated = b.createdAt ?? DateTime(1970);

      return bCreated.compareTo(aCreated);
    });

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
    context.push(RoutePaths.followUpPath(lead.id!, widget.fromCard)).then((_) {
      // Reload leads from cubit after returning from detail screen
      context.read<AddLeadCubit>().fetchDashboardLeads(
        staffId: widget.staff!.id!,
        role: widget.staff?.staffType ?? 'Admin',
        fromCard: widget.fromCard,
        selectedDate: widget.selectedDate,
      );
    });
  }

  void _onEdit(AddLeadModel lead) async {
    final didUpdate = await context.push<bool>(
      RoutePaths.leadEditPath(lead.id!),
    );
    if (didUpdate == true && mounted) {
      context.read<AddLeadCubit>().fetchDashboardLeads(
        staffId: widget.staff?.id ?? '',
        role: widget.staff?.staffType ?? 'Admin',
        fromCard: widget.fromCard,
        selectedDate: widget.selectedDate,
      );
    }
  }

  void _onHistory(AddLeadModel lead) {
    _showSnackBar('History for ${lead.clientName}', AppTheme.actionHistory);
  }

  void _onDelete(AddLeadModel lead) {
    showDialog(
      context: context,
      builder: (dialogContext) => _DeleteConfirmDialog(
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
    // Save current filter state to static variables before widget disposal
    _staticFromCard = widget.fromCard;
    _staticFromDate = fromDate.text;
    _staticToDate = toDate.text;

    // Save draft (UI-bound) selections
    _staticCategories = List.from(selectedCategories);
    _staticLeadStages = List.from(selectedLeadStages);
    _staticPriorities = List.from(selectedPriorities);
    _staticStaffs = List.from(selectedStaffs);
    _staticSources = List.from(selectedSources);
    _staticSubCategories = List.from(selectedSubCategories);
    _staticTags = List.from(selectedTags);

    // Save applied (active) filters
    _staticAppliedCategories = List.from(_appliedCategories);
    _staticAppliedLeadStages = List.from(_appliedLeadStages);
    _staticAppliedPriorities = List.from(_appliedPriorities);
    _staticAppliedStaff = List.from(_appliedStaff);
    _staticAppliedSubCategories = List.from(_appliedSubCategories);
    _staticAppliedTags = List.from(_appliedTags);

    _staticAppliedFromDate = _appliedFromDate;
    _staticAppliedToDate = _appliedToDate;

    _staticSearchQuery = _searchQuery;
    _staticSelectedEntries = _selectedEntries;
    _staticCurrentPage = _currentPage;

    _hasSavedState = true;

    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    fromDate.dispose();
    toDate.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _loadCurrentUserRole();

    final bool cardChanged =
        _hasSavedState && (_staticFromCard != widget.fromCard);
    final bool dateChanged =
        _hasSavedState && (_staticAppliedFromDate != widget.selectedDate);

    log("jhdsgadgjagdjsagd ${widget.selectedDate}");

    if (_hasSavedState && !cardChanged && !dateChanged) {
      // Restore filter state from static variables
      fromDate.text = _staticFromDate ?? '';
      toDate.text = _staticToDate ?? '';

      selectedCategories = List.from(_staticCategories);
      selectedLeadStages = List.from(_staticLeadStages);
      selectedPriorities = List.from(_staticPriorities);
      selectedStaffs = List.from(_staticStaffs);
      selectedSources = List.from(_staticSources);
      selectedSubCategories = List.from(_staticSubCategories);
      selectedTags = List.from(_staticTags);

      _appliedCategories = List.from(_staticAppliedCategories);
      _appliedLeadStages = List.from(_staticAppliedLeadStages);
      _appliedPriorities = List.from(_staticAppliedPriorities);
      _appliedStaff = List.from(_staticAppliedStaff);
      _appliedSubCategories = List.from(_staticAppliedSubCategories);
      _appliedTags = List.from(_staticAppliedTags);
      _appliedFromDate = _staticAppliedFromDate;
      _appliedToDate = _staticAppliedToDate;

      _searchQuery = _staticSearchQuery;
      _selectedEntries = _staticSelectedEntries;
      _currentPage = _staticCurrentPage;
    } else {
      final initialDate = widget.selectedDate;

      fromDate.text = initialDate != null
          ? DateFormat('dd-MM-yyyy').format(initialDate)
          : '';
      toDate.text = initialDate != null
          ? DateFormat('dd-MM-yyyy').format(initialDate)
          : '';

      // Initialize applied dates so filter works immediately
      _appliedFromDate = initialDate;
      _appliedToDate = initialDate;
    }

    context.read<AddLeadCubit>().fetchDashboardLeads(
      staffId: widget.staff?.id ?? '',
      role: widget.staff?.staffType ?? 'Admin',
      fromCard: widget.fromCard,
      selectedDate: _appliedFromDate,
      toDate: _appliedToDate,
    );
  }

  Future<void> _loadCurrentUserRole() async {
    final user = await SessionService().getSavedUser();
    if (!mounted) return;
    setState(() {
      _currentUserRole = user?.staffType;
    });
  }

  bool _hasActiveFilters() {
    return selectedCategories.isNotEmpty ||
        selectedPriorities.isNotEmpty ||
        selectedLeadStages.isNotEmpty ||
        selectedStaffs.isNotEmpty ||
        selectedSubCategories.isNotEmpty ||
        selectedTags.isNotEmpty ||
        fromDate.text.isNotEmpty ||
        toDate.text.isNotEmpty;
  }

  void _clearFilters() {
    setState(() {
      selectedCategories = [];
      selectedLeadStages = [];
      selectedPriorities = [];
      selectedStaffs = [];
      selectedSources = [];
      selectedSubCategories = [];
      selectedTags = [];
      fromDate.clear();
      toDate.clear();

      _appliedCategories = [];
      _appliedLeadStages = [];
      _appliedPriorities = [];
      _appliedStaff = [];
      _appliedSubCategories = [];
      _appliedTags = [];

      // Clear applied dates and reset back to dashboard default date
      final initialDate = widget.selectedDate;
      _appliedFromDate = initialDate;
      _appliedToDate = initialDate;

      _hasSavedState = false;

      _resetPage();
    });

    // Re-fetch using default/reset dates
    context.read<AddLeadCubit>().fetchDashboardLeads(
      staffId: widget.staff?.id ?? '',
      role: widget.staff?.staffType ?? 'Admin',
      fromCard: widget.fromCard,
      selectedDate: _appliedFromDate,
      toDate: _appliedToDate,
    );
    // Reset cubit selections so subcategory/tag lists clear
    final cubit = context.read<AddLeadCubit>();
    cubit.selectCategory(null);
    cubit.selectLeadStage(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TopBreadcrumbBar(
            //   title: 'DASHBOARD',
            //   subTitle: widget.fromCard.toUpperCase(),
            // ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  /// 🔹 HEADER
                  // Padding(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: 2.w,
                  //     vertical: 2.h,
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Text(
                  //         widget.fromCard.toUpperCase() == "TOTAL"
                  //             ? "CALLED LEADS"
                  //             : "${widget.fromCard.toUpperCase()} LEADS",
                  //         style: AppTextStyle.medium(
                  //           size: 13.6.sp,
                  //           color: AppColors.black.withOpacity(0.77),
                  //           weight: FontWeight.w600,
                  //         ),
                  //       ),
                  //       Row(children: [AddLeadsButton()]),
                  //     ],
                  //   ),
                  // ),

                  /// 🔹 FILTER SECTION
                  BlocBuilder<AddLeadCubit, AddLeadState>(
                    builder: (context, state) {
                      return _buildFilterCard(state);
                      // final categoryItems = state.categories
                      //     .map((e) => e.name)
                      //     .toList();
                      // final stageItems = state.stages
                      //     .map((e) => e.name)
                      //     .toList();
                      // final staffItems = state.staffList
                      //     .map((e) => e.name)
                      //     .toList();

                      // const priorityItems = [
                      //   "High",
                      //   "Low",
                      //   "Negative",
                      //   "Normal",
                      // ];

                      // return Padding(
                      //   padding: EdgeInsets.all(2.w),
                      //   child: Column(
                      //     children: [
                      //       /// FIRST ROW
                      //       Row(
                      //         children: [
                      //           Expanded(
                      //             child: InputDate(
                      //               label: "From Date",
                      //               fromController: fromDate,
                      //               toController: toDate,
                      //               isFrom: true,
                      //             ),
                      //           ),
                      //           SizedBox(width: 2.w),
                      //           Expanded(
                      //             child: InputDate(
                      //               label: "To Date",
                      //               fromController: fromDate,
                      //               toController: toDate,
                      //               isFrom: false,
                      //             ),
                      //           ),
                      //           SizedBox(width: 2.w),
                      //           Expanded(
                      //             child: MultiSelectDropdown(
                      //               hint: 'select category',
                      //               items: categoryItems,
                      //               selectedValues: selectedCategories,
                      //               onChanged: (val) {
                      //                 setState(() {
                      //                   selectedCategories = val;
                      //                   selectedSubCategories = [];
                      //                   _resetPage();
                      //                 });
                      //                 if (val.isNotEmpty) {
                      //                   context
                      //                       .read<AddLeadCubit>()
                      //                       .selectCategory(val.last);
                      //                 } else {
                      //                   context
                      //                       .read<AddLeadCubit>()
                      //                       .selectCategory(null);
                      //                 }
                      //               },
                      //               label: "Lead Category",
                      //             ),
                      //           ),
                      //           SizedBox(width: 2.w),
                      //           Expanded(
                      //             child: MultiSelectDropdown(
                      //               label: "Lead Stage",
                      //               hint: 'select stage',
                      //               items: stageItems,
                      //               selectedValues: selectedLeadStages,
                      //               onChanged: (val) {
                      //                 setState(() {
                      //                   selectedLeadStages = val;
                      //                   selectedTags = [];
                      //                   _resetPage();
                      //                 });
                      //                 if (val.isNotEmpty) {
                      //                   context
                      //                       .read<AddLeadCubit>()
                      //                       .selectLeadStage(val.last);
                      //                 } else {
                      //                   context
                      //                       .read<AddLeadCubit>()
                      //                       .selectLeadStage(null);
                      //                 }
                      //               },
                      //             ),
                      //           ),
                      //         ],
                      //       ),

                      //       // ── Conditional Sub Category & Tag row ──
                      //       (() {
                      //         final showSubCategory =
                      //             selectedCategories.isNotEmpty &&
                      //             state.subCategories.isNotEmpty;
                      //         final showTags =
                      //             selectedLeadStages.isNotEmpty &&
                      //             state.leadTag.isNotEmpty;

                      //         if (!showSubCategory && !showTags) {
                      //           return const SizedBox.shrink();
                      //         }

                      //         final List<Widget> extraCols = [];

                      //         if (showSubCategory) {
                      //           final subCategoryItems = state.subCategories
                      //               .map((e) => e.name)
                      //               .toList();
                      //           extraCols.add(
                      //             Expanded(
                      //               child: MultiSelectDropdown(
                      //                 label: "Lead Sub Category",
                      //                 hint: "select sub category",
                      //                 items: subCategoryItems,
                      //                 selectedValues: selectedSubCategories,
                      //                 onChanged: (vals) {
                      //                   setState(() {
                      //                     selectedSubCategories = vals;
                      //                     _resetPage();
                      //                   });
                      //                 },
                      //               ),
                      //             ),
                      //           );
                      //         }

                      //         if (showTags) {
                      //           final tagItems = state.leadTag
                      //               .map((e) => e.name)
                      //               .toList();
                      //           extraCols.add(
                      //             Expanded(
                      //               child: MultiSelectDropdown(
                      //                 label: "Tag",
                      //                 hint: "select tag",
                      //                 items: tagItems,
                      //                 selectedValues: selectedTags,
                      //                 onChanged: (vals) {
                      //                   setState(() {
                      //                     selectedTags = vals;
                      //                     _resetPage();
                      //                   });
                      //                 },
                      //               ),
                      //             ),
                      //           );
                      //         }

                      //         return Column(
                      //           children: [
                      //             SizedBox(height: 2.h),
                      //             Row(
                      //               children: [
                      //                 for (
                      //                   int i = 0;
                      //                   i < extraCols.length;
                      //                   i++
                      //                 ) ...[
                      //                   if (i > 0) SizedBox(width: 2.w),
                      //                   extraCols[i],
                      //                 ],
                      //               ],
                      //             ),
                      //           ],
                      //         );
                      //       })(),

                      //       SizedBox(height: 2.h),

                      //       /// SECOND ROW
                      //       Row(
                      //         crossAxisAlignment: CrossAxisAlignment.end,
                      //         children: [
                      //           SizedBox(
                      //             width: 17.6.w,
                      //             child: MultiSelectDropdown(
                      //               label: "Priority",
                      //               hint: 'select priority',
                      //               items: priorityItems,
                      //               selectedValues: selectedPriorities,
                      //               onChanged: (val) {
                      //                 setState(() {
                      //                   selectedPriorities = val;
                      //                   _resetPage();
                      //                 });
                      //               },
                      //             ),
                      //           ),
                      //           SizedBox(width: 2.w),
                      //           SizedBox(
                      //             width: 17.6.w,
                      //             child: MultiSelectDropdown(
                      //               label: "Staff",
                      //               hint: 'select staff',
                      //               items: staffItems,
                      //               selectedValues: selectedStaffs,
                      //               onChanged: (val) {
                      //                 setState(() {
                      //                   selectedStaffs = val;
                      //                   _resetPage();
                      //                 });
                      //               },
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       Row(
                      //         children: [
                      //           InkWell(
                      //             onTap: _applyFilters,
                      //             child: Padding(
                      //               padding: EdgeInsets.only(top: 2.h),
                      //               child: SizedBox(
                      //                 width: 7.w,
                      //                 height: 4.5.h,
                      //                 child: DecoratedBox(
                      //                   decoration: BoxDecoration(
                      //                     color: const Color(0xff1BAA90),
                      //                     borderRadius: BorderRadius.circular(
                      //                       6,
                      //                     ),
                      //                   ),
                      //                   child: Center(
                      //                     child: Text(
                      //                       "View",
                      //                       style: AppTextStyle.small(
                      //                         size: 10.sp,
                      //                         color: Colors.white,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //           SizedBox(width: 1.w),
                      //           if (_hasActiveFilters())
                      //             InkWell(
                      //               onTap: _clearFilters,
                      //               child: Container(
                      //                 height: 4.5.h,
                      //                 padding: EdgeInsets.all(1.h),
                      //                 margin: EdgeInsets.only(top: 2.h),
                      //                 decoration: BoxDecoration(
                      //                   color: AppColors.orange,
                      //                   borderRadius: BorderRadius.circular(
                      //                     6,
                      //                   ),
                      //                 ),
                      //                 child: Text(
                      //                   'Reset Filters',
                      //                   style: AppTextStyle.small(
                      //                     size: 10.sp,
                      //                     color: Colors.white,
                      //                   ),
                      //                   textAlign: TextAlign.center,
                      //                 ),
                      //               ),
                      //             ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // );
                    },
                  ),
                  SizedBox(height: 13),
                  // Divider(color: AppColors.divider),
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
                    middleWidget: _buildPriorityLegend(),
                    exportWidget: HoverExportButton(
                      onExportExcel: () {
                        final leads = context.read<AddLeadCubit>().state.leads;
                        final filtered = _filteredLeads(
                          leads,
                        ); // exports only filtered data
                        exportLeadsToExcel(filtered, 'new_leads');
                      },
                      onExportPDF: () {
                        final leads = context.read<AddLeadCubit>().state.leads;
                        final filtered = _filteredLeads(
                          leads,
                        ); // exports only filtered data
                        exportLeadsToPdf(filtered);
                      },
                    ),
                  ),

                  SizedBox(height: 13),

                  /// 🔹 TABLE
                  _buildTable(),

                  /// 🔹 BOTTOM TRANSFER BUTTON
                  // BlocBuilder<AddLeadCubit, AddLeadState>(
                  //   builder: (context, state) {
                  //     final List<AddLeadModel> rawList =
                  //         state.listStatus == LeadListStatus.loaded
                  //         ? state.leads
                  //         : [];
                  //     final filteredList = _filteredLeads(rawList);
                  //     if (filteredList.isEmpty) return const SizedBox.shrink();
                  //     // ── Map selected IDs → actual lead objects ──
                  //     final selectedLeads = filteredList
                  //         .where(
                  //           (l) => l.id != null && _selectedIds.contains(l.id),
                  //         )
                  //         .toList();

                  //     final hasSelection = selectedLeads.isNotEmpty;

                  //     return Padding(
                  //       padding: EdgeInsets.only(bottom: 2.h),
                  //       child: Center(
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             GestureDetector(
                  //               onTap: hasSelection
                  //                   ? () {
                  //                       showDialog(
                  //                         context: context,
                  //                         builder: (dialogContext) => AlertDialog(
                  //                           backgroundColor: AppColors.white,
                  //                           shape: RoundedRectangleBorder(
                  //                             borderRadius:
                  //                                 BorderRadius.circular(16),
                  //                           ),
                  //                           title: const Text(
                  //                             'Delete Selected Leads',
                  //                             style: TextStyle(
                  //                               fontSize: 17,
                  //                               fontWeight: FontWeight.w700,
                  //                               color: AppTheme.textPrimary,
                  //                             ),
                  //                           ),
                  //                           content: Text(
                  //                             'Are you sure you want to delete ${selectedLeads.length} selected lead(s)? This action cannot be undone.',
                  //                             style: const TextStyle(
                  //                               fontSize: 14,
                  //                               color: AppTheme.textSecondary,
                  //                             ),
                  //                           ),
                  //                           actions: [
                  //                             TextButton(
                  //                               onPressed: () => Navigator.pop(
                  //                                 dialogContext,
                  //                               ),
                  //                               style: TextButton.styleFrom(
                  //                                 foregroundColor:
                  //                                     AppTheme.textSecondary,
                  //                               ),
                  //                               child: const Text('Cancel'),
                  //                             ),
                  //                             ElevatedButton(
                  //                               onPressed: () async {
                  //                                 Navigator.pop(dialogContext);
                  //                                 for (final lead
                  //                                     in selectedLeads) {
                  //                                   await context
                  //                                       .read<AddLeadCubit>()
                  //                                       .deleteLead(
                  //                                         lead.id!,
                  //                                         lead,
                  //                                       );
                  //                                 }
                  //                                 ScaffoldMessenger.of(
                  //                                   context,
                  //                                 ).showSnackBar(
                  //                                   SnackBar(
                  //                                     content: Text(
                  //                                       '${selectedLeads.length} lead(s) deleted successfully.',
                  //                                       style:
                  //                                           AppTextStyle.medium(
                  //                                             color: AppColors
                  //                                                 .white,
                  //                                             weight: FontWeight
                  //                                                 .w400,
                  //                                           ),
                  //                                     ),
                  //                                     backgroundColor:
                  //                                         AppColors.red,
                  //                                     behavior: SnackBarBehavior
                  //                                         .floating,
                  //                                     shape: RoundedRectangleBorder(
                  //                                       borderRadius:
                  //                                           BorderRadius.circular(
                  //                                             8,
                  //                                           ),
                  //                                     ),
                  //                                     duration: const Duration(
                  //                                       seconds: 3,
                  //                                     ),
                  //                                   ),
                  //                                 );
                  //                                 // ── Clear selections after delete ──
                  //                                 setState(() {
                  //                                   _selectedIds = {};
                  //                                   _selectAll = false;
                  //                                   _tableKey++;
                  //                                 });
                  //                               },
                  //                               style: ElevatedButton.styleFrom(
                  //                                 backgroundColor:
                  //                                     AppColors.red,
                  //                                 foregroundColor: Colors.white,
                  //                                 elevation: 0,
                  //                                 shape: RoundedRectangleBorder(
                  //                                   borderRadius:
                  //                                       BorderRadius.circular(
                  //                                         8,
                  //                                       ),
                  //                                 ),
                  //                               ),
                  //                               child: const Text('Delete'),
                  //                             ),
                  //                           ],
                  //                         ),
                  //                       );
                  //                     }
                  //                   : () => ScaffoldMessenger.of(context)
                  //                         .showSnackBar(
                  //                           SnackBar(
                  //                             content: Text(
                  //                               'Please select at least one lead to delete.',
                  //                               style: AppTextStyle.medium(
                  //                                 color: AppColors.white,
                  //                                 weight: FontWeight.w400,
                  //                               ),
                  //                             ),
                  //                             backgroundColor: AppColors.red,
                  //                             behavior:
                  //                                 SnackBarBehavior.floating,
                  //                             shape: RoundedRectangleBorder(
                  //                               borderRadius:
                  //                                   BorderRadius.circular(8),
                  //                             ),
                  //                             duration: const Duration(
                  //                               seconds: 2,
                  //                             ),
                  //                           ),
                  //                         ),
                  //               child: Container(
                  //                 width: 3.w,
                  //                 height: 5.h,
                  //                 decoration: BoxDecoration(
                  //                   color: hasSelection
                  //                       ? AppColors.red.withOpacity(0.2)
                  //                       : AppColors.red.withOpacity(
                  //                           0.08,
                  //                         ), // dims when nothing selected
                  //                   borderRadius: BorderRadius.circular(4),
                  //                 ),
                  //                 child: Center(
                  //                   child: Icon(
                  //                     Icons.delete_forever_outlined,
                  //                     color: hasSelection
                  //                         ? AppColors.red
                  //                         : AppColors.red.withOpacity(0.4),
                  //                     size: 1.5.w,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //             SizedBox(width: 0.5.w),
                  //             GestureDetector(
                  //               onTap: hasSelection
                  //                   ? () => showAssignStaffDialog(
                  //                       "",
                  //                       selectedLeads,
                  //                       context,
                  //                       onSubmit:
                  //                           (
                  //                             String? selectedStaffId,
                  //                             String? selectedStaffName,
                  //                           ) async {
                  //                             if (selectedStaffId == null ||
                  //                                 selectedStaffName == null)
                  //                               return;

                  //                             // ── Only transfer leads not already assigned to the selected staff ──
                  //                             final leadsToTransfer =
                  //                                 selectedLeads
                  //                                     .where(
                  //                                       (l) =>
                  //                                           l.assignedStaff !=
                  //                                           selectedStaffName,
                  //                                     )
                  //                                     .toList();

                  //                             if (leadsToTransfer.isEmpty) {
                  //                               Navigator.pop(context);
                  //                               ScaffoldMessenger.of(
                  //                                 context,
                  //                               ).showSnackBar(
                  //                                 SnackBar(
                  //                                   content: Text(
                  //                                     'All selected leads are already assigned to $selectedStaffName.',
                  //                                     style:
                  //                                         AppTextStyle.medium(
                  //                                           color:
                  //                                               AppColors.white,
                  //                                           weight:
                  //                                               FontWeight.w400,
                  //                                         ),
                  //                                   ),
                  //                                   backgroundColor:
                  //                                       Colors.orange,
                  //                                   behavior: SnackBarBehavior
                  //                                       .floating,
                  //                                   shape: RoundedRectangleBorder(
                  //                                     borderRadius:
                  //                                         BorderRadius.circular(
                  //                                           8,
                  //                                         ),
                  //                                   ),
                  //                                   duration: const Duration(
                  //                                     seconds: 3,
                  //                                   ),
                  //                                 ),
                  //                               );
                  //                               return;
                  //                             }

                  //                             String _resolveTransferredStageId(
                  //                               BuildContext context,
                  //                             ) {
                  //                               final stages = context
                  //                                   .read<AddLeadCubit>()
                  //                                   .state
                  //                                   .stages;
                  //                               final match = stages.where(
                  //                                 (s) =>
                  //                                     s.name
                  //                                         .trim()
                  //                                         .toUpperCase() ==
                  //                                     'TRANSFERRED',
                  //                               );
                  //                               if (match.isEmpty) {
                  //                                 log(
                  //                                   '[Transfer] Could not resolve "TRANSFERRED" stage id — '
                  //                                   'stages loaded=${stages.map((s) => s.name).toList()}',
                  //                                 );
                  //                                 return '';
                  //                               }
                  //                               return match.first.id;
                  //                             }

                  //                             // ── Transfer only the leads that are actually different ──
                  //                             for (final lead
                  //                                 in selectedLeads) {
                  //                               await context
                  //                                   .read<AddLeadCubit>()
                  //                                   .transferLead(
                  //                                     leadId: lead.id!,
                  //                                     leadName: lead.clientName,
                  //                                     contactNumber:
                  //                                         lead.contactNumber,
                  //                                     leadCategory:
                  //                                         // lead.leadCategory,
                  //                                         resolveLeadName(
                  //                                           list: state
                  //                                               .categories,
                  //                                           id: lead
                  //                                               .leadCategoryId,
                  //                                           fallback: lead
                  //                                               .leadCategory,
                  //                                           idOf: (s) => s.id,
                  //                                           nameOf: (s) =>
                  //                                               s.name,
                  //                                         ),
                  //                                     leadCategoryId:
                  //                                         lead.leadCategoryId,
                  //                                     leadSubCategory:
                  //                                         // lead.leadSubCategory,
                  //                                         resolveLeadName(
                  //                                           list: state
                  //                                               .subCategories,
                  //                                           id: lead
                  //                                               .leadSubCategoryId,
                  //                                           fallback: lead
                  //                                               .leadSubCategory,
                  //                                           idOf: (s) => s.id,
                  //                                           nameOf: (s) =>
                  //                                               s.name,
                  //                                         ),
                  //                                     leadSubCategoryId: lead
                  //                                         .leadSubCategoryId,
                  //                                     leadStage: 'TRANSFERRED',
                  //                                     leadStageId:
                  //                                         _resolveTransferredStageId(
                  //                                           context,
                  //                                         ),
                  //                                     fromStaffId:
                  //                                         lead.assignedStaffId,
                  //                                     fromStaff:
                  //                                         lead.assignedStaff,
                  //                                     toStaffId:
                  //                                         selectedStaffId,
                  //                                     toStaff:
                  //                                         selectedStaffName,
                  //                                   );
                  //                             }

                  //                             // context.read<AddLeadCubit>().fetchLeads();
                  //                             context.pop();

                  //                             // ── Show how many were transferred vs skipped ──
                  //                             final skippedCount =
                  //                                 selectedLeads.length -
                  //                                 leadsToTransfer.length;
                  //                             final message = skippedCount > 0
                  //                                 ? '${leadsToTransfer.length} lead(s) transferred. $skippedCount already assigned to $selectedStaffName (skipped).'
                  //                                 : '${leadsToTransfer.length} lead(s) transferred successfully.';

                  //                             ScaffoldMessenger.of(
                  //                               context,
                  //                             ).showSnackBar(
                  //                               SnackBar(
                  //                                 content: Text(
                  //                                   message,
                  //                                   style: AppTextStyle.medium(
                  //                                     color: AppColors.white,
                  //                                     weight: FontWeight.w400,
                  //                                   ),
                  //                                 ),
                  //                                 backgroundColor:
                  //                                     AppColors.primary,
                  //                                 behavior:
                  //                                     SnackBarBehavior.floating,
                  //                                 shape: RoundedRectangleBorder(
                  //                                   borderRadius:
                  //                                       BorderRadius.circular(
                  //                                         8,
                  //                                       ),
                  //                                 ),
                  //                                 duration: const Duration(
                  //                                   seconds: 3,
                  //                                 ),
                  //                               ),
                  //                             );

                  //                             // ── Clear selections after transfer ──
                  //                             setState(() {
                  //                               _selectedIds = {};
                  //                               _selectAll = false;
                  //                               _tableKey++;
                  //                             });
                  //                             if (mounted) {
                  //                               context
                  //                                   .read<AddLeadCubit>()
                  //                                   .fetchDashboardLeads(
                  //                                     staffId:
                  //                                         widget.staff?.id ??
                  //                                         '',
                  //                                     role:
                  //                                         widget
                  //                                             .staff
                  //                                             ?.staffType ??
                  //                                         'Admin',
                  //                                     fromCard: widget.fromCard,
                  //                                     selectedDate:
                  //                                         widget.selectedDate,
                  //                                   );
                  //                             }
                  //                           },
                  //                     )
                  //                   : () => ScaffoldMessenger.of(context)
                  //                         .showSnackBar(
                  //                           SnackBar(
                  //                             content: Text(
                  //                               'Please select at least one lead to transfer.',
                  //                               style: AppTextStyle.medium(
                  //                                 color: AppColors.white,
                  //                                 weight: FontWeight.w400,
                  //                               ),
                  //                             ),
                  //                             backgroundColor:
                  //                                 AppColors.primary,
                  //                             behavior:
                  //                                 SnackBarBehavior.floating,
                  //                             shape: RoundedRectangleBorder(
                  //                               borderRadius:
                  //                                   BorderRadius.circular(8),
                  //                             ),
                  //                             duration: const Duration(
                  //                               seconds: 2,
                  //                             ),
                  //                           ),
                  //                         ),
                  //               child: Container(
                  //                 width: 5.w,
                  //                 padding: EdgeInsets.all(0.5.w),
                  //                 decoration: BoxDecoration(
                  //                   color: hasSelection
                  //                       ? AppColors.primary
                  //                       : AppColors.primary.withOpacity(0.4),
                  //                   borderRadius: BorderRadius.circular(4),
                  //                 ),
                  //                 child: Text(
                  //                   'Transfer',
                  //                   style: AppTextStyle.small(
                  //                     size: 11.sp,
                  //                     color: Colors.white,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
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

  /// ── Priority Legend Dots ──
  Widget _buildPriorityLegend() {
    return Container(
      height: 4.h,
      padding: EdgeInsets.symmetric(
        horizontal: 1.w,
        // vertical: 0.5.h,
      ),
      decoration: BoxDecoration(
        color: AppThemeColors.appPrimaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendDot(const Color(0xffEF4444)),
          SizedBox(width: 0.3.w),
          Text(
            'High',
            style: AppTextStyle.small(size: 10.sp, color: Colors.white),
          ),
          SizedBox(width: 0.8.w),
          _legendDot(AppThemeColors.basicGreen),
          SizedBox(width: 0.3.w),
          Text(
            'Normal',
            style: AppTextStyle.small(size: 10.sp, color: Colors.white),
          ),
          SizedBox(width: 0.8.w),
          _legendDot(const Color(0xffE2F916)),
          SizedBox(width: 0.3.w),
          Text(
            'Low',
            style: AppTextStyle.small(size: 10.sp, color: Colors.white),
          ),
          SizedBox(width: 0.8.w),
          _legendDot(const Color(0xff9CA3AF)),
          SizedBox(width: 0.3.w),
          Text(
            'Negative',
            style: AppTextStyle.small(size: 10.sp, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ── Legend Dot ──────────────────────────────
  Widget _legendDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  /// ── Filter Card ──
  Widget _buildFilterCard(AddLeadState state) {
    final categoryItems = state.categories.map((e) => e.name).toList();
    final subCategoryItems = state.subCategories.map((e) => e.name).toList();
    final stageItems = state.stages.map((e) => e.name).toList();
    final tagItems = state.leadTag.map((e) => e.name).toList();
    final sourceItems = state.sources.map((e) => e.name).toList();
    final staffItems = state.staffList.map((e) => e.name).toList();
    final isAdmin = (_currentUserRole ?? '').toLowerCase() == 'admin';
    final deletedByItems = state.staffList.map((e) => e.name).toList();
    const priorityItems = ["High", "Low", "Negative", "Normal"];

    final showSubCategory =
        selectedCategories.length == 1 && state.subCategories.isNotEmpty;
    final showTags = selectedLeadStages.length == 1 && state.leadTag.isNotEmpty;

    // Collect all filter widgets in display order
    final List<Widget> filterWidgets = [
      InputDate(
        label: "From Date",
        fromController: fromDate,
        toController: toDate,
        isFrom: true,
      ),
      InputDate(
        label: "To Date",
        fromController: fromDate,
        toController: toDate,
        isFrom: false,
      ),
      MultiSelectDropdown(
        showHelp: true,
        message: 'Lead Category is the type of product/service inquiries.',
        items: categoryItems,
        selectedValues: selectedCategories,
        onChanged: (val) {
          setState(() {
            selectedCategories = val;
            selectedSubCategories = [];
            _resetPage();
          });
          if (val.length == 1) {
            context.read<AddLeadCubit>().selectCategory(val.first);
          } else {
            context.read<AddLeadCubit>().selectCategory(null);
          }
        },
        label: "Lead Category",
        hint: 'Select Lead Category',
      ),
    ];

    // Sub-Category directly next to Category if visible
    if (showSubCategory) {
      filterWidgets.add(
        MultiSelectDropdown(
          showChips: true,
          label: "Lead Sub-Category",
          hint: 'Select Sub-Category',
          items: subCategoryItems,
          selectedValues: selectedSubCategories,
          onChanged: (vals) {
            setState(() {
              selectedSubCategories = vals;
              _resetPage();
            });
          },
        ),
      );
    }
    if (widget.fromCard == "FOLLOWUP" ||
        widget.fromCard == "MISSED" ||
        widget.fromCard == "TOTAL") {
      // Lead Stage
      filterWidgets.add(
        MultiSelectDropdown(
          label: "Lead Stage",
          hint: 'Select Lead Stage',
          items: stageItems,
          selectedValues: selectedLeadStages,
          onChanged: (vals) {
            setState(() {
              selectedLeadStages = vals;
              selectedTags = [];
              _resetPage();
            });
            if (vals.length == 1) {
              context.read<AddLeadCubit>().selectLeadStage(vals.first);
            } else {
              context.read<AddLeadCubit>().selectLeadStage(null);
            }
          },
        ),
      );
    }

    // // Tag directly next to Stage if visible
    if (showTags) {
      filterWidgets.add(
        MultiSelectDropdown(
          showChips: true,
          label: "Tag",
          hint: 'Select Tag',
          items: tagItems,
          selectedValues: selectedTags,
          onChanged: (vals) {
            setState(() {
              selectedTags = vals;
              _resetPage();
            });
          },
        ),
      );
    }

    filterWidgets.add(
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
    );

    if (isAdmin) {
      filterWidgets.add(
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
      );
    }

    // Group filter widgets into rows of 3 columns
    List<List<Widget>> rows = [];
    for (int i = 0; i < filterWidgets.length; i += 3) {
      rows.add(
        filterWidgets.sublist(
          i,
          i + 3 > filterWidgets.length ? filterWidgets.length : i + 3,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(1.8.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000), // #00000014 (8% opacity)
            offset: const Offset(0, 1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
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
                  // Fill remaining space if row has fewer than 3 items
                  ...List.generate(
                    3 - rowItems.length,
                    (_) => Expanded(child: SizedBox()),
                  ),
                ],
              ),
            );
          }),

          /// Action Buttons (Clear All & View)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              /// Clear All Button
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

              /// View Button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _applyFilters,
                  child: Container(
                    height: 4.h,
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981), // Emerald Green
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
      ),
    );
  }

  Widget _buildTable() {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, state) {
        if (state.listStatus == LeadListStatus.loading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: const Center(child: CircularProgressIndicator()),
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
            state.listStatus == LeadListStatus.loaded ? state.leads : [];

        final allFiltered = _filteredLeads(rawList);
        final totalCount = allFiltered.length;
        final totalPages = _totalPages(totalCount);
        final limit = int.tryParse(_selectedEntries) ?? 10;
        final isNew = widget.fromCard.toUpperCase() == 'NEW';

        if (_currentPage > totalPages) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _currentPage = totalPages);
          });
        }

        final pagedList = _pagedLeads(allFiltered);

        final allPageSelected =
            pagedList.isNotEmpty &&
            pagedList.every((l) => l.id != null && _selectedIds.contains(l.id));
        if (_selectAll != allPageSelected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectAll = allPageSelected);
          });
        }

        final showFrom = totalCount == 0 ? 0 : (_currentPage - 1) * limit + 1;
        final showTo = (showFrom + pagedList.length - 1).clamp(0, totalCount);

        const _dateStyle = TextStyle(
          fontSize: 11,
          color: AppTheme.textSecondary,
        );

        final columns = [
          TableColumn(title: 'No.', flex: 1),
          TableColumn(title: 'NAME', flex: 4),
          TableColumn(title: 'CONTACT NO.', flex: 3),
          TableColumn(title: 'LEAD CATEGORY', flex: 4),
          TableColumn(title: 'STAFF', flex: 4),
          TableColumn(title: 'STATUS', flex: 4),
          if (!isNew) TableColumn(title: 'FOLLOWUP DATE', flex: 3),
          if (!isNew) TableColumn(title: 'CALLED DATE', flex: 3),
          TableColumn(title: 'SELECT ALL', flex: 2),
        ];

        final _fmt = DateFormat('dd-MM-yyyy hh:mm a');

        // ── Build rows ─────────────────────────────────────────
        final rows = pagedList.asMap().entries.map((entry) {
          final index = entry.key;
          final lead = entry.value;
          final serial = (_currentPage - 1) * limit + index + 1;

          return [
            // #
            Text(
              '$serial',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            // Name
            Text(
              lead.clientName,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
              // overflow: TextOverflow.ellipsis,
            ),
            // Contact
            GestureDetector(
              onTap: () =>
                  Clipboard.setData(ClipboardData(text: lead.contactNumber)),
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
            // Category
            Text(
              // lead.leadCategory,
              lead.leadSubCategoryId.isNotEmpty
                  ? "${resolveLeadName(list: state.categories, id: lead.leadCategoryId, fallback: lead.leadCategory, idOf: (s) => s.id, nameOf: (s) => s.name)} - ${resolveLeadName(list: state.subCategories, id: lead.leadSubCategoryId, fallback: lead.leadSubCategory, idOf: (s) => s.id, nameOf: (s) => s.name)}"
                  : resolveLeadName(
                      list: state.categories,
                      id: lead.leadCategoryId,
                      fallback: lead.leadCategory,
                      idOf: (s) => s.id,
                      nameOf: (s) => s.name,
                    ),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            // Staff
            Row(
              mainAxisSize: MainAxisSize.min,
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
            // Status
            SizedBox(child: _StatusBadge(status: lead.leadStage)),

            if (!isNew)
              Text(
                lead.followUpDate != null
                    ? _fmt.format(lead.followUpDate!)
                    : '',
                style: _dateStyle,
              ),
            // Called Date (conditional — already correct, no change needed)
            if (!isNew)
              Text(
                lead.calledDate != null ? _fmt.format(lead.calledDate!) : '',
                style: _dateStyle,
              ),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // BrowserAwareLink(
                //   destination: RoutePaths.followUpPath(
                //     lead.id!,
                //     widget.fromCard,
                //   ),
                //   onTap: () => _onView(lead),
                //   usePush: true,
                //   enableInkWell: false,
                //   child: _ActionButton(
                //     icon: Icons.visibility_rounded,
                //     color: AppTheme.actionView,
                //     tooltip: 'View',
                //     onTap: () {
                //       // _onView(lead);
                //     },
                //   ),
                // ),
                // BrowserAwareLink(
                //   destination: RoutePaths.leadEditPath(lead.id!),
                //   onTap: () => _onEdit(lead),
                //   usePush: true,
                //   enableInkWell: false,
                //   child: _ActionButton(
                //     icon: Icons.edit_rounded,
                //     color: AppTheme.actionEdit,
                //     tooltip: 'Edit',
                //     onTap: () {
                //       _onEdit(lead);
                //     },
                //   ),
                // ),
                BrowserAwareLink(
                  destination: RoutePaths.followUpPath(lead.id!, "NEW"),
                  usePush: true,
                  enableInkWell: false,
                  child: Icon(
                    Icons.visibility_outlined,
                    size: 13.sp,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(width: 0.1.h),
                BrowserAwareLink(
                  destination: RoutePaths.leadEditPath(lead.id!),
                  onTap: () async {
                    final didUpdate = await context.push<bool>(
                      RoutePaths.leadEditPath(lead.id!),
                    );
                    if (didUpdate == true && context.mounted) {
                      context.read<AddLeadCubit>().fetchLeads();
                    }
                  },
                  usePush: true,
                  enableInkWell: false,
                  child: Icon(Icons.edit, size: 14.sp, color: Colors.blue),
                ),
                SizedBox(width: 0.1.w),
                _ActionButton(
                  icon: Icons.delete_rounded,
                  color: AppColors.red,
                  tooltip: 'Delete',
                  onTap: () => _onDelete(lead),
                ),
              ],
            ),
          ];
        }).toList();

        // ── Priority colors for the left dot ──────────────────
        final priorityColors = pagedList.map((lead) {
          switch (lead.priority.trim().toLowerCase()) {
            case 'high':
              return const Color(0xFFEF4444);
            case 'normal':
              return AppThemeColors.basicGreen;
            case 'low':
              return const Color.fromARGB(255, 226, 249, 22);
            case 'negative':
              return const Color(0xFF9CA3AF);
            default:
              return const Color(0xFF9CA3AF);
          }
        }).toList();

        return Column(
          children: [
            // SizedBox(height: 2.w),
            // Padding(
            //   padding: EdgeInsets.only(left: 2.w, bottom: 0.5.h),
            //   child: Row(
            //     children: [
            //       Padding(
            //         padding: EdgeInsets.only(left: 0.6.w, right: 0.3.w),
            //         child: Container(
            //           width: 8.5,
            //           height: 8.5,
            //           decoration: BoxDecoration(
            //             color: const Color(0xffEF4444),
            //             shape: BoxShape.circle,
            //           ),
            //         ),
            //       ),
            //       Text('High', style: AppTextStyle.small()),
            //       SizedBox(width: 0.5.w),
            //       Padding(
            //         padding: EdgeInsets.only(left: 0.6.w, right: 0.3.w),
            //         child: Container(
            //           width: 8.5,
            //           height: 8.5,
            //           decoration: BoxDecoration(
            //             color: const Color(0xff22C55E),
            //             shape: BoxShape.circle,
            //           ),
            //         ),
            //       ),
            //       Text('Normal', style: AppTextStyle.small()),
            //       SizedBox(width: 0.5.w),
            //       Padding(
            //         padding: EdgeInsets.only(left: 0.6.w, right: 0.3.w),
            //         child: Container(
            //           width: 8.5,
            //           height: 8.5,
            //           decoration: BoxDecoration(
            //             color: const Color.fromARGB(255, 226, 249, 22),
            //             shape: BoxShape.circle,
            //           ),
            //         ),
            //       ),
            //       Text('Low', style: AppTextStyle.small()),
            //       SizedBox(width: 0.5.w),
            //       Padding(
            //         padding: EdgeInsets.only(left: 0.6.w, right: 0.3.w),
            //         child: Container(
            //           width: 8.5,
            //           height: 8.5,
            //           decoration: BoxDecoration(
            //             color: const Color(0xff9CA3AF),
            //             shape: BoxShape.circle,
            //           ),
            //         ),
            //       ),
            //       Text('Negative', style: AppTextStyle.small()),
            //       SizedBox(width: 0.5.w),
            //     ],
            //   ),
            // ),
            CustomTable(
              key: ValueKey(_tableKey),
              height: 0,
              minWidth: MediaQuery.of(context).size.width,
              columns: columns,
              rows: rows,
              showCheckboxes: true,
              priorityColors: priorityColors,
              getRowDestination: (rowIndex) {
                final lead = pagedList[rowIndex];
                return RoutePaths.followUpPath(lead.id!, widget.fromCard);
              },
              // ── Row tap → lead details ──────────────────────
              onRowTap: (rowIndex) {
                final lead = pagedList[rowIndex];
                context
                    .push(RoutePaths.followUpPath(lead.id!, widget.fromCard))
                    .then((_) {
                      context.read<AddLeadCubit>().fetchDashboardLeads(
                        staffId: widget.staff?.id ?? '',
                        role: widget.staff?.staffType ?? 'Admin',
                        fromCard: widget.fromCard,
                        selectedDate: widget.selectedDate,
                      );
                    });
              },
              // ── Per-row checkbox ────────────────────────────
              onCheckChanged: (rowIndex, isChecked) {
                final lead = pagedList[rowIndex];
                if (lead.id != null) {
                  _toggleSelect(lead.id!, isChecked);
                }
              },
            ),

            // Divider(color: AppColors.divider),

            // ── Footer ─────────────────────────────────────────
            /// ── FOOTER & PAGINATION ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "SHOWING $showFrom TO $showTo OF $totalCount ENTRIES",
                    style: AppTextStyle.medium(
                      size: 10.sp,
                      weight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    children: [
                      /// Previous button
                      MouseRegion(
                        cursor: _currentPage > 1
                            ? SystemMouseCursors.click
                            : SystemMouseCursors.basic,
                        child: GestureDetector(
                          onTap: _currentPage > 1
                              ? () => _goToPage(_currentPage - 1, totalCount)
                              : null,
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Icon(
                              Icons.chevron_left,
                              size: 16,
                              color: _currentPage > 1
                                  ? const Color(0xFF475569)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),

                      /// Page Numbers
                      ..._buildPageNumbers(totalPages, totalCount),

                      /// Next button
                      MouseRegion(
                        cursor: _currentPage < totalPages
                            ? SystemMouseCursors.click
                            : SystemMouseCursors.basic,
                        child: GestureDetector(
                          onTap: _currentPage < totalPages
                              ? () => _goToPage(_currentPage + 1, totalCount)
                              : null,
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(left: 4, right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: _currentPage < totalPages
                                  ? const Color(0xFF475569)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),

                      ///Delete button
                      BlocBuilder<AddLeadCubit, AddLeadState>(
                        builder: (context, state) {
                          final List<AddLeadModel> rawList =
                              state.listStatus == LeadListStatus.loaded
                              ? state.leads
                              : [];
                          final filteredList = _filteredLeads(rawList);
                          if (filteredList.isEmpty)
                            return const SizedBox.shrink();
                          // ── Map selected IDs → actual lead objects ──
                          final selectedLeads = filteredList
                              .where(
                                (l) =>
                                    l.id != null && _selectedIds.contains(l.id),
                              )
                              .toList();

                          final hasSelection = selectedLeads.isNotEmpty;
                          return Row(
                            children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: hasSelection
                                      ? () {
                                          showDialog(
                                            context: context,
                                            builder: (dialogContext) => AlertDialog(
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
                                                      Navigator.pop(
                                                        dialogContext,
                                                      ),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        AppTheme.textSecondary,
                                                  ),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    Navigator.pop(
                                                      dialogContext,
                                                    );
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 0.8.w,
                                      vertical: 0.8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFEF4444,
                                      ), // Coral Red
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Selected Item',
                                          style: AppTextStyle.small(
                                            size: 10.sp,
                                            color: Colors.white,
                                            weight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 0.4.w),
                                        Icon(
                                          Icons.delete_outline,
                                          color: Colors.white,
                                          size: 13.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: hasSelection
                                      ? () => showAssignStaffDialog(
                                          "",
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

                                                String
                                                _resolveTransferredStageId(
                                                  BuildContext context,
                                                ) {
                                                  final stages = context
                                                      .read<AddLeadCubit>()
                                                      .state
                                                      .stages;
                                                  final match = stages.where(
                                                    (s) =>
                                                        s.name
                                                            .trim()
                                                            .toUpperCase() ==
                                                        'TRANSFERRED',
                                                  );
                                                  if (match.isEmpty) {
                                                    log(
                                                      '[Transfer] Could not resolve "TRANSFERRED" stage id — '
                                                      'stages loaded=${stages.map((s) => s.name).toList()}',
                                                    );
                                                    return '';
                                                  }
                                                  return match.first.id;
                                                }

                                                // ── Transfer only the leads that are actually different ──
                                                for (final lead
                                                    in selectedLeads) {
                                                  await context.read<AddLeadCubit>().transferLead(
                                                    leadId: lead.id!,
                                                    leadName: lead.clientName,
                                                    contactNumber:
                                                        lead.contactNumber,
                                                    leadCategory:
                                                        // lead.leadCategory,
                                                        resolveLeadName(
                                                          list:
                                                              state.categories,
                                                          id: lead
                                                              .leadCategoryId,
                                                          fallback:
                                                              lead.leadCategory,
                                                          idOf: (s) => s.id,
                                                          nameOf: (s) => s.name,
                                                        ),
                                                    leadCategoryId:
                                                        lead.leadCategoryId,
                                                    leadSubCategory:
                                                        // lead.leadSubCategory,
                                                        resolveLeadName(
                                                          list: state
                                                              .subCategories,
                                                          id: lead
                                                              .leadSubCategoryId,
                                                          fallback: lead
                                                              .leadSubCategory,
                                                          idOf: (s) => s.id,
                                                          nameOf: (s) => s.name,
                                                        ),
                                                    leadSubCategoryId:
                                                        lead.leadSubCategoryId,
                                                    leadStage: 'TRANSFERRED',
                                                    leadStageId:
                                                        _resolveTransferredStageId(
                                                          context,
                                                        ),
                                                    fromStaffId:
                                                        lead.assignedStaffId,
                                                    fromStaff:
                                                        lead.assignedStaff,
                                                    toStaffId: selectedStaffId,
                                                    toStaff: selectedStaffName,
                                                  );
                                                }

                                                // context.read<AddLeadCubit>().fetchLeads();
                                                context.pop();

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
                                                if (mounted) {
                                                  context
                                                      .read<AddLeadCubit>()
                                                      .fetchDashboardLeads(
                                                        staffId:
                                                            widget.staff?.id ??
                                                            '',
                                                        role:
                                                            widget
                                                                .staff
                                                                ?.staffType ??
                                                            'Admin',
                                                        fromCard:
                                                            widget.fromCard,
                                                        selectedDate:
                                                            widget.selectedDate,
                                                      );
                                                }
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 0.8.w,
                                      vertical: 0.8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppThemeColors.appPrimaryColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Selected Item',
                                          style: AppTextStyle.small(
                                            size: 10.sp,
                                            color: Colors.white,
                                            weight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 0.4.w),
                                        Icon(
                                          Icons.swap_horiz,
                                          color: Colors.white,
                                          size: 13.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      /// Selected Item Action Button (Transfer)
                      // _buildTransferButton(pagedList, state),
                    ],
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         'Showing $showFrom to $showTo of $totalCount entries',
            //         style: AppTextStyle.medium(weight: FontWeight.w400),
            //       ),
            //       Row(
            //         children: [
            //           PageButton(
            //             label: 'Previous',
            //             enabled: _currentPage > 1,
            //             isLeft: true,
            //             onTap: () => _goToPage(_currentPage - 1, totalCount),
            //           ),
            //           ..._buildPageNumbers(totalPages, totalCount),
            //           PageButton(
            //             label: 'Next',
            //             enabled: _currentPage < totalPages,
            //             isRight: true,
            //             onTap: () => _goToPage(_currentPage + 1, totalCount),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
          ],
        );
      },
    );
  }

  // ── Page number chips ───────────────────────
  List<Widget> _buildPageNumbers(int totalPages, int totalCount) {
    if (totalPages <= 1) {
      return [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: AppThemeColors.appPrimaryColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '1',
            style: AppTextStyle.small(
              size: 10.sp,
              color: Colors.white,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ];
    }

    List<Widget> pages = [];
    for (int i = 1; i <= totalPages; i++) {
      if (i == 1 ||
          i == totalPages ||
          (i >= _currentPage - 1 && i <= _currentPage + 1)) {
        final isSelected = i == _currentPage;
        pages.add(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _goToPage(i, totalCount),
              child: Container(
                constraints: const BoxConstraints(minWidth: 32),
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppThemeColors.appPrimaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? AppThemeColors.appPrimaryColor
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  '$i',
                  style: AppTextStyle.small(
                    size: 10.sp,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                    weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (i == _currentPage - 2 || i == _currentPage + 2) {
        pages.add(
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              '...',
              style: AppTextStyle.small(
                size: 10.sp,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        );
      }
    }
    return pages;
  }

  // -------export to excel-------
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

class HoverExportButton extends StatefulWidget {
  final VoidCallback? onExportExcel;
  final VoidCallback? onExportPDF;
  const HoverExportButton({super.key, this.onExportExcel, this.onExportPDF});

  @override
  State<HoverExportButton> createState() => _HoverExportButtonState();
}

class _HoverExportButtonState extends State<HoverExportButton> {
  OverlayEntry? _overlayEntry;

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // ✅ Full-screen barrier — catches any outside click
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideOverlay,
            ),
          ),
          // ✅ The actual dropdown menu
          Positioned(
            left: position.dx - 120,
            top: position.dy + renderBox.size.height + 5,
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
                    _item(
                      Icons.table_chart,
                      "Export Excel",
                      onTap: widget.onExportExcel,
                    ),
                    _item(
                      Icons.picture_as_pdf,
                      "Export PDF",
                      onTap: widget.onExportPDF,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    // ✅ Clean up overlay directly — no setState during dispose
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  Widget _item(IconData icon, String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: () {
        _hideOverlay(); // ✅ Close first
        onTap?.call(); // ✅ Then execute action
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
    return GestureDetector(
      onTap: () {
        // ✅ Toggle: click again to close, click to open
        if (_overlayEntry != null) {
          _hideOverlay();
        } else {
          _showOverlay();
        }
      },
      child: MouseRegion(
        onEnter: (_) => _showOverlay(),
        onExit: (_) {
          Future.delayed(const Duration(milliseconds: 150), () {});
        },
        cursor: SystemMouseCursors.click,
        child: Container(
          height: 4.5.h,
          width: 4.5.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.indigo.shade100,
          ),
          child: Icon(Icons.print, size: 18, color: Colors.indigo.shade900),
        ),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: getLeadStatusColor(status).withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: getLeadStatusColor(status).withOpacity(0.3),
          ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$leadName deleted successfully.',
                  style: AppTextStyle.medium(
                    color: AppColors.white,
                    weight: FontWeight.w400,
                  ),
                ),
                backgroundColor: AppColors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
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
