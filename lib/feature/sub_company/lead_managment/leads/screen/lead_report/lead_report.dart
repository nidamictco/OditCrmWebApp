import 'dart:developer';

import 'package:Odit_CRM/core/utils/multi_select_dropdown.dart';
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
import 'package:Odit_CRM/core/utils/top_bread_crumb_bar.dart';
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
  static List<String> _staticAppliedTags = [];
  static List<String> _staticAppliedSubCategories = [];
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

  @override
  void initState() {
    super.initState();
    _loadLocations();

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
      _appliedTags = List<String>.from(_staticAppliedTags);
      _appliedSubCategories = List<String>.from(_staticAppliedSubCategories);
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
    _staticAppliedTags = List<String>.from(_appliedTags);
    _staticAppliedSubCategories = List<String>.from(_appliedSubCategories);
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
      _appliedFromDate = null;
      _appliedToDate = null;
      _appliedIsCreatedDate = true;

      _hasSavedState = false;

      _resetPage();
    });
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
        return const Color(0xff22C55E); // Green
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

    // ── Lead Tag — stored as-is — match ANY selected ──────────────────────────
    if (_appliedTags.isNotEmpty) {
      final tagSet = _appliedTags.map((e) => e.trim().toLowerCase()).toSet();
      result = result
          .where((l) => tagSet.contains(l.leadTag.trim().toLowerCase()))
          .toList();
    }

    // ── Lead Sub Category — stored as-is — match ANY selected ────────────────
    if (_appliedSubCategories.isNotEmpty) {
      final subCatSet = _appliedSubCategories
          .map((e) => e.trim().toLowerCase())
          .toSet();
      result = result
          .where(
            (l) => subCatSet.contains(l.leadSubCategory.trim().toLowerCase()),
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
                          GestureDetector(
                            onTap: () {
                              final leads = context
                                  .read<AddLeadCubit>()
                                  .state
                                  .leads;
                              final filtered = _filteredLeads(
                                leads,
                              ); // exports only filtered data
                              exportLeadsToExcel(filtered, 'leads_report_');
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

                    /// 🔹 FILTERS
                    BlocBuilder<AddLeadCubit, AddLeadState>(
                      builder: (context, state) {
                        // ── Build dynamic lists from Firestore streams ──
                        final categoryItems = state.categories
                            .map((e) => e.name)
                            .toList();
                        // Sub-category is populated by the per-category Firestore
                        // watcher (triggered below when exactly 1 category is selected).
                        final subCategoryItems = state.subCategories
                            .map((e) => e.name)
                            .toList();
                        final sourceItems = state.sources
                            .map((e) => e.name)
                            .toList();
                        final stageItems = state.stages
                            .map((e) => e.name)
                            .toList();
                        // Tag is populated by the per-stage Firestore watcher
                        // (triggered below when exactly 1 stage is selected).
                        final tagItems = state.leadTag
                            .map((e) => e.name)
                            .toList();
                        final staffItems = state.staffList
                            .map((e) => e.name)
                            .toList();
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
                                  _radio(
                                    "Created Date",
                                    _isCreatedDate,
                                    'Created Date allows you to \nfilter leads based on when they \nwere added to the system.',
                                  ),
                                  SizedBox(width: 3.w),
                                  _radio(
                                    "Updated Date",
                                    !_isCreatedDate,
                                    'Updated Date allows you to \nfilter leads based on the most \nrecent changes made to them.',
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),

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
                                          // Clear sub-category whenever the
                                          // category selection changes.
                                          selectedSubCategories = [];
                                          _resetPage();
                                        });
                                        final cubit = context
                                            .read<AddLeadCubit>();
                                        if (vals.length == 1) {
                                          // Exactly one category → start the
                                          // sub-category Firestore watcher.
                                          cubit.selectCategory(vals.first);
                                        } else {
                                          // Zero or many → clear sub-categories.
                                          cubit.selectCategory(null);
                                        }
                                      },
                                      label: "Lead Category",
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: MultiSelectDropdown(
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
                                          // Clear tag whenever the stage
                                          // selection changes.
                                          selectedTags = [];
                                          _resetPage();
                                        });
                                        final cubit = context
                                            .read<AddLeadCubit>();
                                        if (vals.length == 1) {
                                          // Exactly one stage → start the
                                          // tag Firestore watcher.
                                          cubit.selectLeadStage(vals.first);
                                        } else {
                                          // Zero or many → clear tags.
                                          cubit.selectLeadStage(null);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              // Show the dependent row when at least one watcher has data:
                              // - Tag section appears only when exactly 1 stage is selected and tags exist.
                              // - Sub Category section appears only when exactly 1 category is selected and sub-cats exist.
                              if (selectedLeadStages.length == 1 &&
                                      tagItems.isNotEmpty ||
                                  selectedCategories.length == 1 &&
                                      subCategoryItems.isNotEmpty)
                                Column(
                                  children: [
                                    SizedBox(height: 1.h),
                                    Row(
                                      children: [
                                        Expanded(child: SizedBox()),
                                        SizedBox(width: 2.w),
                                        Expanded(child: SizedBox()),
                                        SizedBox(width: 2.w),
                                        if (selectedCategories.length == 1 &&
                                            subCategoryItems.isNotEmpty)
                                          Expanded(
                                            child: MultiSelectDropdown(
                                              label: "Lead Sub Category",
                                              hint: 'select sub category',
                                              items: subCategoryItems,
                                              selectedValues:
                                                  selectedSubCategories,
                                              onChanged: (vals) {
                                                setState(() {
                                                  selectedSubCategories = vals;
                                                  _resetPage();
                                                });
                                              },
                                            ),
                                          )
                                        else
                                          const Expanded(child: SizedBox()),
                                        SizedBox(width: 2.w),
                                        if (selectedLeadStages.length == 1 &&
                                            tagItems.isNotEmpty)
                                          Expanded(
                                            child: MultiSelectDropdown(
                                              label: "Tag",
                                              hint: 'select Tag',
                                              items: tagItems,
                                              selectedValues: selectedTags,
                                              onChanged: (vals) {
                                                setState(() {
                                                  selectedTags = vals;
                                                  _resetPage();
                                                });
                                              },
                                            ),
                                          )
                                        else
                                          const Expanded(child: SizedBox()),

                                        // SizedBox(width: 2.w),
                                      ],
                                    ),
                                  ],
                                ),

                              SizedBox(height: 1.h),

                              Row(
                                children: [
                                  Expanded(
                                    child: MultiSelectDropdown(
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
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: MultiSelectDropdown(
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
                                  Expanded(
                                    child: MultiSelectDropdown(
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
                                  Expanded(
                                    child: MultiSelectDropdown(
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
                                ],
                              ),

                              SizedBox(height: 1.h),

                              Row(
                                children: [
                                  Expanded(
                                    child: MultiSelectDropdown(
                                      label: "State",
                                      hint: "select state",
                                      items: stateDistrictMap.keys.toList(),
                                      selectedValues: selectedStates,
                                      onChanged: (vals) {
                                        setState(() {
                                          selectedStates = vals;
                                          // Keep only districts still valid
                                          // for the newly selected states.
                                          final validDistricts =
                                              _availableDistricts();
                                          selectedDistricts = selectedDistricts
                                              .where(
                                                (d) =>
                                                    validDistricts.contains(d),
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
                                  SizedBox(width: 2.w),
                                  Expanded(child: SizedBox()),
                                  SizedBox(width: 2.w),
                                  Expanded(child: SizedBox()),
                                ],
                              ),
                              Row(
                                children: [
                                  /// 🔥 VIEW BUTTON
                                  InkWell(
                                    onTap: () {
                                      _applyFilters();
                                    },
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
                                  if (_hasActiveFilters())
                                    InkWell(
                                      onTap: _clearFilters,
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

                    /// 🔹 TABLE CONTROLS
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
                          return Column(
                            children: [
                              SizedBox(height: 2.w),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 2.w,
                                  bottom: 0.5.h,
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 0.6.w,
                                        right: 0.3.w,
                                      ),
                                      child: Container(
                                        width: 8.5,
                                        height: 8.5,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffEF4444),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Text('High', style: AppTextStyle.small()),
                                    SizedBox(width: 0.5.w),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 0.6.w,
                                        right: 0.3.w,
                                      ),
                                      child: Container(
                                        width: 8.5,
                                        height: 8.5,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff22C55E),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Text('Normal', style: AppTextStyle.small()),
                                    SizedBox(width: 0.5.w),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 0.6.w,
                                        right: 0.3.w,
                                      ),
                                      child: Container(
                                        width: 8.5,
                                        height: 8.5,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            226,
                                            249,
                                            22,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Text('Low', style: AppTextStyle.small()),
                                    SizedBox(width: 0.5.w),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 0.6.w,
                                        right: 0.3.w,
                                      ),
                                      child: Container(
                                        width: 8.5,
                                        height: 8.5,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff9CA3AF),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Negative',
                                      style: AppTextStyle.small(),
                                    ),
                                    SizedBox(width: 0.5.w),
                                  ],
                                ),
                              ),

                              CustomTable(
                                key: ValueKey(_tableKey),
                                height: 0,
                                minWidth: MediaQuery.of(context).size.width,
                                priorityColors: pagedList
                                    .map(
                                      (lead) => getPriorityColor(lead.priority),
                                    )
                                    .toList(),
                                getRowDestination: (rowIndex) {
                                  final lead = pagedList[rowIndex];
                                  return RoutePaths.followUpPath(
                                    lead.id!,
                                    "NEW",
                                  );
                                },
                                onRowTap: (rowIndex) {
                                  final lead = pagedList[rowIndex];
                                  // log('Row $rowIndex tapped');
                                  context.push(
                                    RoutePaths.followUpPath(lead.id!, "NEW"),
                                  );
                                },
                                columns: [
                                  TableColumn(title: "Sl No.", flex: 1),
                                  TableColumn(title: "  Name", flex: 4),
                                  TableColumn(title: "Phone No", flex: 4),
                                  TableColumn(title: "Category", flex: 4),
                                  TableColumn(title: "Staff", flex: 4),
                                  TableColumn(title: "Status", flex: 4),
                                  TableColumn(title: "Created Date", flex: 4),
                                  TableColumn(title: "Lead Source", flex: 4),
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
                                      lead.leadSubCategory.isNotEmpty
                                          ? '${lead.leadCategory} - ${lead.leadSubCategory}'
                                          : lead.leadCategory,
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
                                      lead.createdAt != null
                                          ? DateFormat(
                                              'dd-MM-yyyy',
                                            ).format(lead.createdAt!)
                                          : '-',
                                      style: AppTextStyle.medium(),
                                    ),
                                    Text(
                                      lead.leadSource,
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
                                          ),
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
                                          destination: RoutePaths.leadEditPath(
                                            lead.id!,
                                          ),
                                          onTap: () async {
                                            final didUpdate = await context
                                                .push<bool>(
                                                  RoutePaths.leadEditPath(
                                                    lead.id!,
                                                  ),
                                                );
                                            if (didUpdate == true &&
                                                context.mounted) {
                                              context
                                                  .read<AddLeadCubit>()
                                                  .fetchLeads();
                                            }
                                          },
                                          usePush: true,
                                          enableInkWell: false,
                                          child: Icon(
                                            Icons.edit,
                                            size: 14.sp,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        SizedBox(width: 0.1.w),
                                        // ── DELETE ──
                                        GestureDetector(
                                          onTap: () =>
                                              _confirmDelete(context, lead),
                                          child: Icon(
                                            Icons.delete_outline,
                                            size: 13.sp,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ];
                                }).toList(),
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
                              ),

                              /// 🔹 FOOTER
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
                        }

                        return const SizedBox();
                      },
                    ),
                    SizedBox(height: 2.h),
                    BlocBuilder<AddLeadCubit, AddLeadState>(
                      builder: (context, state) {
                        final List<AddLeadModel> rawList =
                            state.listStatus == LeadListStatus.loaded
                            ? state.leads
                            : [];
                        final filteredList = _filteredLeads(rawList);

                        if (filteredList.isEmpty)
                          return const SizedBox.shrink();

                        // 🔹 Map selected indices → actual lead objects
                        final selectedLeads = _selectedIndices
                            .where((i) => i < filteredList.length)
                            .map((i) => filteredList[i])
                            .toList();

                        final hasSelection = selectedLeads.isNotEmpty;
                        // final staff=state.assignedStaffName.map((e) => e.name).toList();
                        return Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: hasSelection
                                    ? () => _deleteSelectedLeads(selectedLeads)
                                    : () => ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Please select at least one lead before deleting.',
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
                            ],
                          ),
                        );
                      },
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

  Widget _radio(String text, bool selected, String message) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isCreatedDate = (text == 'Created Date');
          _appliedIsCreatedDate = _isCreatedDate; // ✅ sync immediately
        });
        // ✅ re-apply filters so table updates right away
        _applyFilters();
      },
      child: Row(
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
          ToolTipWidget(message: message),
        ],
      ),
    );
  }

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
              Navigator.pop(dialogContext);
              await context.read<AddLeadCubit>().deleteLead(lead.id!, lead);
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
                  _tableKey++;
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
              for (final lead in selectedLeads) {
                await context.read<AddLeadCubit>().deleteLead(lead.id!, lead);
              }
              Navigator.pop(dialogContext);
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
            style: AppTextStyle.small(size: 11.sp, color: AppColors.white),
          ),
        ),
      ),
    ];
  }

  // --------------export to excel----------------
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
