import 'dart:developer';

import 'package:Odit_CRM/core/shared_preference/session_service.dart';
import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/utils/migration_functions.dart';
import 'package:Odit_CRM/core/utils/multi_select_dropdown.dart';
import 'package:Odit_CRM/core/utils/resolved_lead_name.dart';
import 'package:Odit_CRM/core/utils/table_checkbox.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/common_model/lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/cubit/sub_category_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/cubit/sub_category_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:Odit_CRM/core/utils/export_excel.dart';
import 'package:Odit_CRM/core/utils/input_date.dart';
import 'package:Odit_CRM/core/utils/page_button.dart';
import 'package:Odit_CRM/core/utils/show_entries.dart';
import 'package:Odit_CRM/core/utils/table.dart';
import 'package:Odit_CRM/core/utils/tool_tips.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import 'package:go_router/go_router.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/core/router/browser_aware_link.dart';
import 'package:Odit_CRM/core/utils/indian_location_service.dart';
import 'package:sizer/sizer.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_style.dart';

class LeadsReport extends StatefulWidget {
  const LeadsReport({super.key});

  @override
  State<LeadsReport> createState() => _LeadsReportState();
}

class _LeadsReportState extends State<LeadsReport> {
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();

  String? _currentUserRole;

  bool _isCreatedDate = true;

  String selectedValue = "10";

  // final List<String> dropdownItems = ["10", "100", "1200", "3000"];

  // ── Multi-select filter selections (temporary, pending "View" tap) ────────
  List<String> selectedCategories = [];
  List<String> selectedSources = [];
  List<String> selectedPriorities = [];
  List<String> selectedLeadStages = [];
  List<String> selectedSubCategories = [];
  List<String> selectedTags = [];
  List<String> selectedStaff = [];
  List<String> selectedCreatedBy = [];
  List<String> selectedStates = [];
  List<String> selectedDistricts = [];
  // List<String> selectedSubCategories = [];
  // List<String> selectedTags = [];
  List<String> selectedCallResults = [];

  String _searchQuery = '';
  String _selectedEntries = '10';

  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;

  Map<String, List<String>> stateDistrictMap = {};

  // Static variables to preserve filter state across screen navigation
  static bool _hasSavedState = false;
  static String? _staticFromDate;
  static String? _staticToDate;
  static bool _staticIsCreatedDate = true;
  static List<String> _staticCategories = [];
  static List<String> _staticSources = [];
  static List<String> _staticPriorities = [];
  static List<String> _staticLeadStages = [];
  static List<String> _staticStaff = [];
  static List<String> _staticCreatedBy = [];
  static List<String> _staticStates = [];
  static List<String> _staticDistricts = [];
  static List<String> _staticSubCategories = [];
  static List<String> _staticTags = [];
  static List<String> _staticCallResults = [];
  static String _staticSearchQuery = '';
  static String _staticSelectedEntries = '10';
  static int _staticCurrentPage = 1;

  // Static variables for applied (active) filter state
  static List<String> _staticAppliedCategories = [];
  static List<String> _staticAppliedLeadStages = [];
  static List<String> _staticAppliedPriorities = [];
  static List<String> _staticAppliedSources = [];
  static List<String> _staticAppliedStaff = [];
  static List<String> _staticAppliedCreatedBy = [];
  static List<String> _staticAppliedStates = [];
  static List<String> _staticAppliedDistricts = [];
  static List<String> _staticAppliedSubCategories = [];
  static List<String> _staticAppliedTags = [];
  static List<String> _staticAppliedCallResults = [];
  static DateTime? _staticAppliedFromDate;
  static DateTime? _staticAppliedToDate;
  static bool _staticAppliedIsCreatedDate = true;

  Future<void> _loadLocations() async {
    final map = await IndiaLocationService.loadStateDistricts();
    if (mounted) {
      setState(() {
        stateDistrictMap = map;
      });
    }
  }

  Future<void> _loadCurrentUserRole() async {
    final user = await SessionService().getSavedUser();
    if (!mounted) return;
    setState(() {
      _currentUserRole = user?.staffType;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLocations();
    _loadCurrentUserRole();
    if (_hasSavedState) {
      // Restore filter state from static variables
      fromDate.text = _staticFromDate ?? '';
      toDate.text = _staticToDate ?? '';
      _isCreatedDate = _staticIsCreatedDate;

      selectedCategories = List<String>.from(_staticCategories);
      selectedSources = List<String>.from(_staticSources);
      selectedPriorities = List<String>.from(_staticPriorities);
      selectedLeadStages = List<String>.from(_staticLeadStages);
      selectedStaff = List<String>.from(_staticStaff);
      selectedCreatedBy = List<String>.from(_staticCreatedBy);
      selectedStates = List<String>.from(_staticStates);
      selectedDistricts = List<String>.from(_staticDistricts);
      selectedSubCategories = List<String>.from(_staticSubCategories);
      selectedTags = List<String>.from(_staticTags);
      selectedCallResults = List<String>.from(_staticCallResults);
      _currentPage = _staticCurrentPage;

      _searchQuery = _staticSearchQuery;
      _selectedEntries = _staticSelectedEntries;

      // Restore applied (active) filter state
      _appliedCategories = List<String>.from(_staticAppliedCategories);
      _appliedLeadStages = List<String>.from(_staticAppliedLeadStages);
      _appliedPriorities = List<String>.from(_staticAppliedPriorities);
      _appliedSources = List<String>.from(_staticAppliedSources);
      _appliedStaff = List<String>.from(_staticAppliedStaff);
      _appliedCreatedBy = List<String>.from(_staticAppliedCreatedBy);
      _appliedStates = List<String>.from(_staticAppliedStates);
      _appliedDistricts = List<String>.from(_staticAppliedDistricts);
      _appliedSubCategories = List<String>.from(_staticAppliedSubCategories);
      _appliedTags = List<String>.from(_staticAppliedTags);
      _appliedCallResults = List<String>.from(_staticAppliedCallResults);
      _appliedFromDate = _staticAppliedFromDate;
      _appliedToDate = _staticAppliedToDate;
      _appliedIsCreatedDate = _staticAppliedIsCreatedDate;
    } else {
      fromDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      toDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

      _appliedFromDate = DateTime.now();
      _appliedToDate = DateTime.now();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<AddLeadCubit>();
      cubit.initialize(); // ← loads categories, sources, stages
      cubit.fetchStaff(); // ← loads staffList for staff/createdBy dropdowns
      cubit.fetchLeads();
      if (!_hasSavedState) {
        _applyFilters();
      }
    });
  }

  @override
  void dispose() {
    // Save current filter state to static variables before widget disposal
    _staticFromDate = fromDate.text;
    _staticToDate = toDate.text;
    _staticIsCreatedDate = _isCreatedDate;

    _staticCategories = List<String>.from(selectedCategories);
    _staticSources = List<String>.from(selectedSources);
    _staticPriorities = List<String>.from(selectedPriorities);
    _staticLeadStages = List<String>.from(selectedLeadStages);
    _staticStaff = List<String>.from(selectedStaff);
    _staticCreatedBy = List<String>.from(selectedCreatedBy);
    _staticStates = List<String>.from(selectedStates);
    _staticDistricts = List<String>.from(selectedDistricts);
    _staticSubCategories = List<String>.from(selectedSubCategories);
    _staticTags = List<String>.from(selectedTags);
    _staticCallResults = List<String>.from(selectedCallResults);
    _staticCurrentPage = _currentPage;

    _staticSearchQuery = _searchQuery;
    _staticSelectedEntries = _selectedEntries;

    _staticAppliedCategories = List<String>.from(_appliedCategories);
    _staticAppliedLeadStages = List<String>.from(_appliedLeadStages);
    _staticAppliedPriorities = List<String>.from(_appliedPriorities);
    _staticAppliedSources = List<String>.from(_appliedSources);
    _staticAppliedStaff = List<String>.from(_appliedStaff);
    _staticAppliedCreatedBy = List<String>.from(_appliedCreatedBy);
    _staticAppliedStates = List<String>.from(_appliedStates);
    _staticAppliedDistricts = List<String>.from(_appliedDistricts);
    _staticAppliedSubCategories = List<String>.from(_appliedSubCategories);
    _staticAppliedTags = List<String>.from(_appliedTags);
    _staticAppliedCallResults = List<String>.from(_appliedCallResults);
    _staticAppliedFromDate = _appliedFromDate;
    _staticAppliedToDate = _appliedToDate;
    _staticAppliedIsCreatedDate = _appliedIsCreatedDate;

    _hasSavedState = true;

    fromDate.dispose();
    toDate.dispose();
    super.dispose();
  }

  bool _hasActiveFilters() {
    return selectedCategories.isNotEmpty ||
        selectedSources.isNotEmpty ||
        selectedPriorities.isNotEmpty ||
        selectedLeadStages.isNotEmpty ||
        selectedStaff.isNotEmpty ||
        selectedCreatedBy.isNotEmpty ||
        selectedStates.isNotEmpty ||
        selectedDistricts.isNotEmpty ||
        selectedSubCategories.isNotEmpty ||
        selectedTags.isNotEmpty ||
        selectedCallResults.isNotEmpty ||
        fromDate.text.isNotEmpty ||
        toDate.text.isNotEmpty;
  }

  void _clearFilters() {
    setState(() {
      selectedCategories = [];
      selectedSources = [];
      selectedPriorities = [];
      selectedLeadStages = [];
      selectedSubCategories = [];
      selectedTags = [];
      selectedStaff = [];
      selectedCreatedBy = [];
      selectedStates = [];
      selectedDistricts = [];
      selectedSubCategories = [];
      selectedTags = [];
      selectedCallResults = [];
      fromDate.clear();
      toDate.clear();
      _isCreatedDate = true;

      // Clear applied filters immediately so the table updates
      _appliedCategories = [];
      _appliedLeadStages = [];
      _appliedPriorities = [];
      _appliedSources = [];
      _appliedTags = [];
      _appliedSubCategories = [];
      _appliedStaff = [];
      _appliedCreatedBy = [];
      _appliedStates = [];
      _appliedDistricts = [];
      _appliedSubCategories = [];
      _appliedTags = [];
      _appliedCallResults = [];
      _appliedFromDate = null;
      _appliedToDate = null;
      _appliedIsCreatedDate = true;

      _hasSavedState = false;

      _resetPage();
    });
    final cubit = context.read<AddLeadCubit>();
    cubit.selectCategory(null);
    cubit.selectLeadStage(null);
  }

  // ── Snapshot fields (applied only when "View" is tapped) ────────────────────
  List<String> _appliedCategories = [];
  List<String> _appliedLeadStages = [];
  List<String> _appliedPriorities = [];
  List<String> _appliedSources = [];
  List<String> _appliedTags = [];
  List<String> _appliedSubCategories = [];
  List<String> _appliedStaff = [];
  List<String> _appliedCreatedBy = [];
  List<String> _appliedStates = [];
  List<String> _appliedDistricts = [];
  // List<String> _appliedSubCategories = [];
  // List<String> _appliedTags = [];
  List<String> _appliedCallResults = [];
  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;
  bool _appliedIsCreatedDate = true;

  // ── Called ONLY when "View" is tapped ───────────────────────────────────────
  void _applyFilters() {
    setState(() {
      _appliedIsCreatedDate = _isCreatedDate;
      _appliedCategories = List<String>.from(selectedCategories);
      _appliedLeadStages = List<String>.from(selectedLeadStages);
      _appliedPriorities = List<String>.from(selectedPriorities);
      _appliedSources = List<String>.from(selectedSources);
      _appliedTags = List<String>.from(selectedTags);
      _appliedSubCategories = List<String>.from(selectedSubCategories);
      _appliedStaff = List<String>.from(selectedStaff);
      _appliedCreatedBy = List<String>.from(selectedCreatedBy);
      _appliedStates = List<String>.from(selectedStates);
      _appliedDistricts = List<String>.from(selectedDistricts);
      _appliedSubCategories = List<String>.from(selectedSubCategories);
      _appliedTags = List<String>.from(selectedTags);
      _appliedCallResults = List<String>.from(selectedCallResults);
      _appliedFromDate = fromDate.text.trim().isEmpty
          ? null
          : _parseDate(fromDate.text);
      _appliedToDate = toDate.text.trim().isEmpty
          ? null
          : _parseDate(toDate.text);

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

  // ── District options available for the currently selected State(s) ─────────
  List<String> _availableDistricts() {
    if (selectedStates.isEmpty) return [];
    final districts = <String>{};
    for (final state in selectedStates) {
      districts.addAll(stateDistrictMap[state] ?? []);
    }
    return districts.toList();
  }

  // ── Priority helpers ─────────────────────────────────────────────────────────
  Color getPriorityColor(String priority) {
    switch (priority.trim().toLowerCase()) {
      case 'high':
        return const Color(0xffEF4444); // Red
      case 'normal':
        return AppThemeColors.basicGreen; // Green
      case 'low':
        return Color.fromARGB(255, 226, 249, 22); // Orange-Yellow
      case 'negative':
        return const Color(0xff9CA3AF);
      default:
        return const Color(0xffFFFFFF);
    }
  }

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

    // ── Date range ─────────────────────────────────────────────────────────────
    if (_appliedFromDate != null) {
      final from = DateTime(
        _appliedFromDate!.year,
        _appliedFromDate!.month,
        _appliedFromDate!.day,
      );
      result = result.where((l) {
        final date = _appliedIsCreatedDate ? l.createdAt : l.updatedAt;
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
        final date = _appliedIsCreatedDate ? l.createdAt : l.updatedAt;
        return date != null && !date.isAfter(to);
      }).toList();
    }

    // ── Lead Category — stored UPPERCASE in Firestore — match ANY selected ───
    if (_appliedCategories.isNotEmpty) {
      final cats = _appliedCategories
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((l) => cats.contains(l.leadCategory.toUpperCase()))
          .toList();
    }

    // ── Lead Stage — stored UPPERCASE in Firestore — match ANY selected ──────
    if (_appliedLeadStages.isNotEmpty) {
      final stages = _appliedLeadStages
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((l) => stages.contains(l.leadStage.toUpperCase()))
          .toList();
    }

    // ── Lead Source — stored UPPERCASE in Firestore — match ANY selected ─────
    if (_appliedSources.isNotEmpty) {
      final sources = _appliedSources
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((l) => sources.contains(l.leadSource.toUpperCase()))
          .toList();
    }

    // ── Priority — stored as-is — match ANY selected ─────────────────────────
    if (_appliedPriorities.isNotEmpty) {
      final priorities = _appliedPriorities
          .map((e) => e.trim().toLowerCase())
          .toSet();
      result = result
          .where((l) => priorities.contains(l.priority.toLowerCase()))
          .toList();
    }

    // ── Assigned Staff — stored as-is — match ANY selected ───────────────────
    if (_appliedStaff.isNotEmpty) {
      final staffSet = _appliedStaff.map((e) => e.trim().toLowerCase()).toSet();
      result = result
          .where((l) => staffSet.contains(l.assignedStaff.toLowerCase()))
          .toList();
    }

    // ── Created By — stored as-is — match ANY selected ───────────────────────
    if (_appliedCreatedBy.isNotEmpty) {
      final createdBySet = _appliedCreatedBy
          .map((e) => e.trim().toLowerCase())
          .toSet();
      result = result
          .where((l) => createdBySet.contains(l.createdBy.toLowerCase()))
          .toList();
    }

    // ── State — stored as-is — match ANY selected ────────────────────────────
    if (_appliedStates.isNotEmpty) {
      final stateSet = _appliedStates
          .map((e) => e.trim().toLowerCase())
          .toSet();
      result = result
          .where((l) => stateSet.contains(l.state.toLowerCase()))
          .toList();
    }

    // ── District — stored as-is — match ANY selected ─────────────────────────
    if (_appliedDistricts.isNotEmpty) {
      final districtSet = _appliedDistricts
          .map((e) => e.trim().toLowerCase())
          .toSet();
      result = result
          .where((l) => districtSet.contains(l.district.toLowerCase()))
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

    // ── Call Result ──────────────────────────────────────────────────────────
    if (_appliedCallResults.isNotEmpty) {
      final callRes = _appliedCallResults
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where(
            (l) =>
                l.callResult != null &&
                callRes.contains(l.callResult!.toUpperCase()),
          )
          .toList();
    }

    // ── Search (live, no View button needed) ──────────────────────────────────
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (l) =>
                l.clientName.toLowerCase().contains(q) ||
                l.contactNumber.toLowerCase().contains(q),
          )
          .toList();
    }

    // ── Priority sort ─────────────────────────────────────────────────────────
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TopBreadcrumbBar(
            //   subTitle: 'Leads Report',
            //   title: 'Lead Management',
            // ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  // ── CARD 1: FILTERS CARD ───────────────────────────────────
                  Container(
                    padding: EdgeInsets.all(25),
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
                    child: Column(
                      children: [
                        /// 🔹 TITLE BAR
                        // Padding(
                        //   padding: EdgeInsets.symmetric(
                        //     horizontal: 2.w,
                        //     vertical: 2.h,
                        //   ),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Text(
                        //         "Leads Report",
                        //         style: AppTextStyle.medium(
                        //           size: 13.6.sp,
                        //           color: AppColors.black.withOpacity(0.77),
                        //           weight: FontWeight.w600,
                        //         ),
                        //       ),
                        //       // GestureDetector(
                        //       //   onTap: () {
                        //       //     final leads = context
                        //       //         .read<AddLeadCubit>()
                        //       //         .state
                        //       //         .leads;
                        //       //     final filtered = _filteredLeads(
                        //       //       leads,
                        //       //     ); // exports only filtered data
                        //       //     exportLeadsToExcel(filtered, 'leads_report_');
                        //       //   },
                        //       //   child: Container(
                        //       //     padding: EdgeInsets.symmetric(
                        //       //       horizontal: 1.4.w,
                        //       //       vertical: 1.2.h,
                        //       //     ),
                        //       //     decoration: BoxDecoration(
                        //       //       color: const Color(0xffE5E7EB),
                        //       //       borderRadius: BorderRadius.circular(4),
                        //       //     ),
                        //       //     child: Text(
                        //       //       "Export",
                        //       //       style: AppTextStyle.medium(
                        //       //         color: Colors.indigo[900],
                        //       //         weight: FontWeight.w400,
                        //       //       ),
                        //       //     ),
                        //       //   ),
                        //       // ),
                        //     ],
                        //   ),
                        // ),
                        // Divider(color: AppColors.divider),

                        /// 🔹 FILTERS
                        BlocBuilder<AddLeadCubit, AddLeadState>(
                          builder: (context, state) {
                            // ── Build dynamic lists from Firestore streams ──
                            final categoryItems = state.categories
                                .map((e) => e.name)
                                .toList();
                            // final subCategoryItems = state.subCategories
                            //     .map((e) => e.name)
                            //     .toList();
                            final sourceItems = state.sources
                                .map((e) => e.name)
                                .toList();
                            final stageItems = state.stages
                                .map((e) => e.name)
                                .toList();
                            final staffItems = state.staffList
                                .map((e) => e.name)
                                .toList();
                            final isAdmin =
                                (_currentUserRole ?? '').toLowerCase() ==
                                'admin';

                            // createdBy uses staff list too (same people create leads)
                            final createdByItems = state.staffList
                                .map((e) => e.name)
                                .toList();
                            // Priority is still static (not stored in Firestore)
                            const priorityItems = [
                              "High",
                              "Low",
                              "Negative",
                              "Normal",
                            ];

                            return Column(
                              children: [
                                // ── ROW 1: 5 Columns
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
                                      child: MultiSelectDropdown(
                                        showChips: true,
                                        showClear: true,
                                        hint: 'select category',
                                        showHelp: true,
                                        message:
                                            'Lead Category is the type\n of product, service, or solution \na potential customer is \ninterested in, helping businesses\n identify and classify inquiries \nfor better follow-up.',
                                        items: categoryItems,
                                        selectedValues: selectedCategories,
                                        onChanged: (vals) {
                                          setState(() {
                                            selectedCategories = vals;
                                            selectedSubCategories = [];
                                            _resetPage();
                                          });
                                          if (vals.isNotEmpty) {
                                            context
                                                .read<AddLeadCubit>()
                                                .selectCategory(vals.last);
                                          } else {
                                            context
                                                .read<AddLeadCubit>()
                                                .selectCategory(null);
                                          }
                                        },
                                        label: "Lead Category",
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: MultiSelectDropdown(
                                        showChips: true,
                                        label: "Lead Stage",
                                        hint: 'select stage',
                                        showHelp: true,
                                        message:
                                            'Lead Status lets you track \nthe stage of a lead, and you can \nadd new statuses as needed to match \nyour sales process.',
                                        items: stageItems,
                                        selectedValues: selectedLeadStages,
                                        onChanged: (vals) {
                                          setState(() {
                                            selectedLeadStages = vals;
                                            selectedTags = [];
                                            _resetPage();
                                          });
                                          if (vals.isNotEmpty) {
                                            context
                                                .read<AddLeadCubit>()
                                                .selectLeadStage(vals.last);
                                          } else {
                                            context
                                                .read<AddLeadCubit>()
                                                .selectLeadStage(null);
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: MultiSelectDropdown(
                                        showChips: true,
                                        label: "Priority",
                                        hint: 'select priority',
                                        items: priorityItems,
                                        selectedValues: selectedPriorities,
                                        onChanged: (vals) {
                                          setState(() {
                                            selectedPriorities = vals;
                                            _resetPage();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),

                                // ── ROW 2: 5 Columns
                                Row(
                                  children: [
                                    Expanded(
                                      child: MultiSelectDropdown(
                                        showChips: true,
                                        label: "Lead Source",
                                        hint: 'select source',
                                        showHelp: true,
                                        message:
                                            'It refers to the source of the \nlead, showing how the potential \ncustomer discovered or engaged with \nthe business, such as through marketing \ncampaigns, social media, referrals, events,\n or website inquiries.',
                                        items: sourceItems,
                                        selectedValues: selectedSources,
                                        onChanged: (vals) {
                                          setState(() {
                                            selectedSources = vals;
                                            _resetPage();
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    if (isAdmin) ...[
                                      Expanded(
                                        child: MultiSelectDropdown(
                                          showChips: true,
                                          label: "Staff",
                                          hint: 'select staff',
                                          items: staffItems,
                                          selectedValues: selectedStaff,
                                          onChanged: (vals) {
                                            setState(() {
                                              selectedStaff = vals;
                                              _resetPage();
                                            });
                                          },
                                          message: ".",
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                    ],
                                    Expanded(
                                      child: MultiSelectDropdown(
                                        showChips: true,
                                        label: "Created By",
                                        hint: 'select creator',
                                        items: createdByItems,
                                        selectedValues: selectedCreatedBy,
                                        onChanged: (vals) {
                                          setState(() {
                                            selectedCreatedBy = vals;
                                            _resetPage();
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: MultiSelectDropdown(
                                        showChips: true,
                                        label: "State",
                                        hint: "select state",
                                        items: stateDistrictMap.keys.toList(),
                                        selectedValues: selectedStates,
                                        onChanged: (vals) {
                                          setState(() {
                                            selectedStates = vals;
                                            final validDistricts =
                                                _availableDistricts();
                                            selectedDistricts =
                                                selectedDistricts
                                                    .where(
                                                      (d) => validDistricts
                                                          .contains(d),
                                                    )
                                                    .toList();
                                            _resetPage();
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: MultiSelectDropdown(
                                        showChips: true,
                                        label: "District",
                                        hint: "select district",
                                        items: _availableDistricts(),
                                        selectedValues: selectedDistricts,
                                        onChanged: (vals) {
                                          setState(() {
                                            selectedDistricts = vals;
                                            _resetPage();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                // ── ROW 3: Conditional Extra Fields
                                (() {
                                  final showSubCategory =
                                      selectedCategories.isNotEmpty &&
                                      state.subCategories.isNotEmpty;
                                  final showTags =
                                      selectedLeadStages.isNotEmpty &&
                                      state.leadTag.isNotEmpty;
                                  final showCallResult =
                                      selectedLeadStages.isNotEmpty &&
                                      selectedLeadStages.any(
                                        (s) => s.toUpperCase() != 'NEW',
                                      );

                                  final List<Widget> row3Cols = [];

                                  if (showSubCategory) {
                                    final subCategoryItems = state.subCategories
                                        .map((e) => e.name)
                                        .toList();
                                    row3Cols.add(
                                      MultiSelectDropdown(
                                        showChips: true,
                                        label: "Lead Sub Category",
                                        hint: "select sub category",
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

                                  if (showTags) {
                                    final tagItems = state.leadTag
                                        .map((e) => e.name)
                                        .toList();
                                    row3Cols.add(
                                      MultiSelectDropdown(
                                        showChips: true,
                                        label: "Tag",
                                        hint: "select tag",
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

                                  if (row3Cols.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Column(
                                    children: [
                                      SizedBox(height: 1.h),
                                      Row(
                                        children: [
                                          for (int i = 0; i < 5; i++) ...[
                                            if (i > 0) SizedBox(width: 2.w),
                                            Expanded(
                                              child: i < row3Cols.length
                                                  ? row3Cols[i]
                                                  : const SizedBox(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  );
                                })(),

                                SizedBox(height: 2.h),

                                // ── ROW 4: ACTIONS ROW
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        _applyFilters();
                                      },

                                      child: Container(
                                        height: 4.h,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 1.5.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff00b087),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "View Report",
                                          style: AppTextStyle.small(
                                            size: 11.sp,
                                            color: Colors.white,
                                            weight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_hasActiveFilters()) ...[
                                      SizedBox(width: 1.w),
                                      InkWell(
                                        onTap: _clearFilters,
                                        child: Container(
                                          height: 4.h,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 1.5.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffe95757),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Reset Filters',
                                            style: AppTextStyle.small(
                                              size: 11.sp,
                                              color: Colors.white,
                                              weight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                              // ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 13),

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
                    middleWidget: Container(
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
                            style: AppTextStyle.small(
                              size: 10.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 0.8.w),
                          _legendDot(AppThemeColors.basicGreen),
                          SizedBox(width: 0.3.w),
                          Text(
                            'Normal',
                            style: AppTextStyle.small(
                              size: 10.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 0.8.w),
                          _legendDot(const Color(0xffE2F916)),
                          SizedBox(width: 0.3.w),
                          Text(
                            'Low',
                            style: AppTextStyle.small(
                              size: 10.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 0.8.w),
                          _legendDot(const Color(0xff9CA3AF)),
                          SizedBox(width: 0.3.w),
                          Text(
                            'Negative',
                            style: AppTextStyle.small(
                              size: 10.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    exportWidget: GestureDetector(
                      onTap: () {
                        final leads = context.read<AddLeadCubit>().state.leads;
                        final filtered = _filteredLeads(
                          leads,
                        ); // exports only filtered data
                        exportLeadsToExcel(filtered, 'leads_report_');
                      },
                      child: Container(
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
                  SizedBox(height: 13),

                  // ── CARD 2: TABLE & DATA CARD ──────────────────────────────
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
                    child: Column(
                      children: [
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
                                ? state.leads.toList()
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

                            final selectedLeads = _selectedIndices
                                .where((i) => i < allFiltered.length)
                                .map((i) => allFiltered[i])
                                .toList();

                            final allPageIndices = List.generate(
                              pagedList.length,
                              (index) => (_currentPage - 1) * limit + index,
                            );
                            final isAllPageSelected =
                                pagedList.isNotEmpty &&
                                allPageIndices.every(
                                  (idx) => _selectedIndices.contains(idx),
                                );

                            return Column(
                              children: [
                                _ReportLeadsTable(
                                  leads: pagedList,
                                  selectedIndices: _selectedIndices,
                                  currentPage: _currentPage,
                                  limit: limit,
                                  isAllSelected: isAllPageSelected,
                                  onCheckChanged: (absoluteIndex) {
                                    setState(() {
                                      if (_selectedIndices.contains(
                                        absoluteIndex,
                                      )) {
                                        _selectedIndices.remove(absoluteIndex);
                                      } else {
                                        _selectedIndices.add(absoluteIndex);
                                      }
                                    });
                                  },
                                  onToggleSelectAll: () {
                                    setState(() {
                                      if (isAllPageSelected) {
                                        for (final idx in allPageIndices) {
                                          _selectedIndices.remove(idx);
                                        }
                                      } else {
                                        for (final idx in allPageIndices) {
                                          if (!_selectedIndices.contains(idx)) {
                                            _selectedIndices.add(idx);
                                          }
                                        }
                                      }
                                    });
                                  },
                                  onEdit: (lead) async {
                                    final didUpdate = await context.push<bool>(
                                      RoutePaths.leadEditPath(lead.id!,fromScreen: 'leadsReport'),
                                    );
                                    if (didUpdate == true && context.mounted) {
                                      context.read<AddLeadCubit>().fetchLeads();
                                    }
                                  },
                                  onDelete: (lead) {
                                    _confirmDelete(context, lead);
                                  },
                                  onTap: (lead) {
                                    context.push(
                                      RoutePaths.followUpPath(lead.id!, "NEW",fromScreen: 'leadsReport'),
                                    );
                                  },
                                  getPriorityColor: getPriorityColor,
                                  categories: state.categories,
                                  subCategories: state.subCategories,
                                  sources: state.sources,
                                  stages: state.stages,
                                  tags: state.leadTag,
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
                                          if (selectedLeads.isNotEmpty) ...[
                                            const SizedBox(width: 12),
                                            GestureDetector(
                                              onTap: () => _deleteSelectedLeads(
                                                selectedLeads,
                                              ),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 1.2.w,
                                                  vertical: 0.8.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xffEF4444,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "Selected Item",
                                                      style:
                                                          AppTextStyle.medium(
                                                            color: Colors.white,
                                                            weight:
                                                                FontWeight.w500,
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
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- WIDGETS ----------------

  // ─── Delete confirmation dialog ────────────────────────────────────────────

  void _confirmDelete(BuildContext ctx, AddLeadModel lead) {
    showDialog(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Delete Lead', style: AppTextStyle.medium(size: 14.sp)),
        content: Text(
          'Are you sure you want to delete "${lead.clientName}"? This action cannot be undone.',
          style: AppTextStyle.medium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTextStyle.medium(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              final cubit = context.read<AddLeadCubit>();
              Navigator.pop(dialogContext);
              await cubit.deleteLead(lead.id!, lead);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${lead.clientName} deleted successfully.',
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
              if (mounted) {
                setState(() {
                  _selectedIndices.clear();
                });
              }
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

  // -------------delete---------------
  void _deleteSelectedLeads(List<AddLeadModel> selectedLeads) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
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
              final cubit = context.read<AddLeadCubit>();
              for (final lead in selectedLeads) {
                await cubit.deleteLead(lead.id!, lead);
              }
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${selectedLeads.length} lead(s) deleted successfully.',
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
              setState(() => _selectedIndices = []);
              cubit.fetchLeads();
            },
            child: Text("Delete", style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

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

  // ── Legend Dot ──────────────────────────────
  Widget _legendDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // --------------export to excel----------------
  void exportLeadsToExcel(List<AddLeadModel> leads, String fileName) {
    exportToExcel<AddLeadModel>(
      fileName: fileName,
      wrapColumnIndices: [2],
      rows: leads,
      columns: [
        ExcelColumn(header: 'Sl No.', value: (l) => '${leads.indexOf(l) + 1}'),
        ExcelColumn(header: 'Name', value: (l) => l.clientName),
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

class _ReportLeadsTable extends StatefulWidget {
  final List<AddLeadModel> leads;
  final List<int> selectedIndices;
  final int currentPage;
  final int limit;
  final ValueChanged<int> onCheckChanged;
  final VoidCallback onToggleSelectAll;
  final bool isAllSelected;
  final void Function(AddLeadModel lead) onEdit;
  final void Function(AddLeadModel lead) onDelete;
  final void Function(AddLeadModel lead) onTap;
  final Color Function(String priority) getPriorityColor;
  final List<LeadsModel> categories;
  final List<LeadsModel> subCategories;
  final List<LeadsModel> sources;
  final List<LeadsModel> stages;
  final List<LeadsModel> tags;

  const _ReportLeadsTable({
    required this.leads,
    required this.selectedIndices,
    required this.currentPage,
    required this.limit,
    required this.onCheckChanged,
    required this.onToggleSelectAll,
    required this.isAllSelected,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    required this.getPriorityColor,
    required this.categories, // ADD
    required this.subCategories, // ADD
    required this.sources, // ADD
    required this.stages, // ADD
    required this.tags, // ADD
  });

  @override
  State<_ReportLeadsTable> createState() => _ReportLeadsTableState();
}

class _ReportLeadsTableState extends State<_ReportLeadsTable> {
  final ScrollController _hScrollController = ScrollController();

  @override
  void dispose() {
    _hScrollController.dispose();
    super.dispose();
  }

  // Color _getStatusColor(String stage) {
  //   switch (stage.trim().toLowerCase()) {
  //     case 'new':
  //       return const Color(0xff22C55E);
  //     case 'reject':
  //     case 'rejected':
  //       return const Color(0xffEF4444);
  //     case 'follow up':
  //     case 'follow-up':
  //       return const Color(0xff3B82F6);
  //     default:
  //       return const Color(0xff3B82F6);
  //   }
  // }
  Color _getStatusColor(String stage) {
    switch (stage.trim().toUpperCase()) {
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(child: Icon(icon, size: 13, color: color)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // local aliases so the rest of the build body is unchanged
    final leads = widget.leads;
    final selectedIndices = widget.selectedIndices;
    final currentPage = widget.currentPage;
    final limit = widget.limit;
    final onCheckChanged = widget.onCheckChanged;
    final onToggleSelectAll = widget.onToggleSelectAll;
    final isAllSelected = widget.isAllSelected;
    final onEdit = widget.onEdit;
    final onDelete = widget.onDelete;
    final onTap = widget.onTap;
    final getPriorityColor = widget.getPriorityColor;
    final categories = widget.categories;
    final subCategories = widget.subCategories;
    final sources = widget.sources;
    final stages = widget.stages;
    final tags = widget.tags;

    if (leads.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: const Center(
          child: Text(
            "No data available in table",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final tableWidth = screenWidth > 1100 ? screenWidth - 4.w : 1100.0;

    return Container(
      margin: EdgeInsets.only(bottom: .5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffE2E8F0)),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Scrollbar(
          controller: _hScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _hScrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Table Header
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xffF8FAFC),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 1.8.h,
                      horizontal: 1.5.w,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            "No.",
                            style: AppTextStyle.medium(
                              color: const Color(0xff475569),
                              weight: FontWeight.w600,
                              size: 11.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.radio_button_unchecked,
                                size: 12,
                                color: Color(0xff94A3B8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Name",
                                style: AppTextStyle.medium(
                                  color: const Color(0xff475569),
                                  weight: FontWeight.w600,
                                  size: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "Phone No.",
                            style: AppTextStyle.medium(
                              color: const Color(0xff475569),
                              weight: FontWeight.w600,
                              size: 11.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "Category",
                            style: AppTextStyle.medium(
                              color: const Color(0xff475569),
                              weight: FontWeight.w600,
                              size: 11.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "Staff",
                            style: AppTextStyle.medium(
                              color: const Color(0xff475569),
                              weight: FontWeight.w600,
                              size: 11.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "Status",
                            style: AppTextStyle.medium(
                              color: const Color(0xff475569),
                              weight: FontWeight.w600,
                              size: 11.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "Created Date",
                            style: AppTextStyle.medium(
                              color: const Color(0xff475569),
                              weight: FontWeight.w600,
                              size: 11.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "Lead Source",
                            style: AppTextStyle.medium(
                              color: const Color(0xff475569),
                              weight: FontWeight.w600,
                              size: 11.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Select All",
                                style: AppTextStyle.medium(
                                  color: const Color(0xff475569),
                                  weight: FontWeight.w600,
                                  size: 11.sp,
                                ),
                              ),
                              const SizedBox(width: 8),
                              buildRoundedCheckbox(
                                value: isAllSelected,
                                onTap: onToggleSelectAll,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xffE2E8F0)),
                  // Table Body
                  ...List.generate(leads.length, (index) {
                    final lead = leads[index];
                    final serial = (currentPage - 1) * limit + index + 1;
                    final absoluteIndex = (currentPage - 1) * limit + index;
                    final isChecked = selectedIndices.contains(absoluteIndex);
                    final priorityColor = getPriorityColor(lead.priority);

                    return InkWell(
                      onTap: () => onTap(lead),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 1.h,
                          horizontal: 1.5.w,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xffF1F5F9)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '$serial',
                                style: AppTextStyle.medium(
                                  color: const Color(0xff0F172A),
                                  weight: FontWeight.w400,
                                  size: 11.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: priorityColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      lead.clientName,
                                      style: AppTextStyle.medium(
                                        color: const Color(0xff0F172A),
                                        weight: FontWeight.w400,
                                        size: 11.sp,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                lead.contactNumber,
                                style: AppTextStyle.medium(
                                  color: const Color(0xff0F172A),
                                  weight: FontWeight.w400,
                                  size: 11.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                lead.leadSubCategory.isNotEmpty
                                    ? '${resolveLeadName(list: categories, id: lead.leadCategoryId, fallback: lead.leadCategory, idOf: (s) => s.id, nameOf: (s) => s.name)} - ${resolveLeadName(list: subCategories, id: lead.leadSubCategoryId, fallback: lead.leadSubCategory, idOf: (s) => s.id, nameOf: (s) => s.name)}'
                                    // : lead.leadCategory,
                                    : resolveLeadName(
                                        list: categories,
                                        id: lead.leadCategoryId,
                                        fallback: lead.leadCategory,
                                        idOf: (s) => s.id,
                                        nameOf: (s) => s.name,
                                      ),
                                style: AppTextStyle.medium(
                                  color: const Color(0xff0F172A),
                                  weight: FontWeight.w400,
                                  size: 11.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                lead.assignedStaff,
                                style: AppTextStyle.medium(
                                  color: const Color(0xff0F172A),
                                  weight: FontWeight.w400,
                                  size: 11.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                // lead.leadStage,
                                resolveLeadName(
                                  list: stages,
                                  id: lead.leadStageId,
                                  fallback: lead.leadStage,
                                  idOf: (s) => s.id,
                                  nameOf: (s) => s.name,
                                ),
                                style: AppTextStyle.medium(
                                  color: _getStatusColor(lead.leadStage),
                                  weight: FontWeight.w500,
                                  size: 11.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                lead.createdAt != null
                                    ? DateFormat(
                                        'dd-MM-yyyy',
                                      ).format(lead.createdAt!)
                                    : '-',
                                style: AppTextStyle.medium(
                                  color: const Color(0xff0F172A),
                                  weight: FontWeight.w400,
                                  size: 11.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                // lead.leadSource,
                                resolveLeadName(
                                  list: sources,
                                  id: lead.leadSourceId,
                                  fallback: lead.leadSource,
                                  idOf: (s) => s.id,
                                  nameOf: (s) => s.name,
                                ),
                                style: AppTextStyle.medium(
                                  color: const Color(0xff0F172A),
                                  weight: FontWeight.w400,
                                  size: 11.sp,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _buildActionButton(
                                    icon: Icons.edit_outlined,
                                    color: const Color(0xff3B82F6),
                                    onTap: () => onEdit(lead),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildActionButton(
                                    icon: Icons.delete_outline,
                                    color: const Color(0xffEF4444),
                                    onTap: () => onDelete(lead),
                                  ),
                                  const SizedBox(width: 12),
                                  buildRoundedCheckbox(
                                    value: isChecked,
                                    onTap: () => onCheckChanged(absoluteIndex),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
