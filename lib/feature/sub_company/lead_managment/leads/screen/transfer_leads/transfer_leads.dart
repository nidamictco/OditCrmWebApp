import 'dart:developer';

import 'package:Odit_CRM/core/shared_preference/session_service.dart';
import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/utils/resolved_lead_name.dart';

import 'package:Odit_CRM/core/utils/export_excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:Odit_CRM/core/utils/dropdown.dart';
import 'package:Odit_CRM/core/utils/input_date.dart';
import 'package:Odit_CRM/core/utils/show_entries.dart';
import 'package:Odit_CRM/core/utils/table.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import 'package:go_router/go_router.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/core/router/browser_aware_link.dart';
import 'package:sizer/sizer.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_style.dart';

import '../../../../../../core/utils/transfer_lead_alert.dart';

class TransferLeads extends StatefulWidget {
  const TransferLeads({super.key});

  @override
  State<TransferLeads> createState() => _TransferLeadsState();
}

class _TransferLeadsState extends State<TransferLeads> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  final List<String> priority = ["High", "Low", "Negative", "Normal"];

  String? selectedCategory;
  String? selectedSource;
  String? selectedPriority;
  String? selectedLeadStage;
  String? selectedStaff;
  String? _currentUserRole;

  String _searchQuery = '';
  String _selectedEntries = '10';

  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;

  // Static variables to preserve filter state across screen navigation
  static bool _hasSavedState = false;
  static String? _staticFromDate;
  static String? _staticToDate;
  static String? _staticCategory;
  static String? _staticSource;
  static String? _staticPriority;
  static String? _staticLeadStage;
  static String? _staticStaff;
  static String _staticSearchQuery = '';
  static String _staticSelectedEntries = '10';
  static int _staticCurrentPage = 1;

  // Static variables for applied (active) filter state
  static String? _staticAppliedCategory;
  static String? _staticAppliedLeadStage;
  static String? _staticAppliedPriority;
  static String? _staticAppliedSource;
  static String? _staticAppliedStaff;
  static DateTime? _staticAppliedFromDate;
  static DateTime? _staticAppliedToDate;

  @override
  void dispose() {
    // Save current filter state to static variables before widget disposal
    _staticFromDate = _fromDateController.text;
    _staticToDate = _toDateController.text;
    _staticCategory = selectedCategory;
    _staticSource = selectedSource;
    _staticPriority = selectedPriority;
    _staticLeadStage = selectedLeadStage;
    _staticStaff = selectedStaff;

    _staticSearchQuery = _searchQuery;
    _staticSelectedEntries = _selectedEntries;
    _staticCurrentPage = _currentPage;

    _staticAppliedCategory = _appliedCategory;
    _staticAppliedLeadStage = _appliedLeadStage;
    _staticAppliedPriority = _appliedPriority;
    _staticAppliedSource = _appliedSource;
    _staticAppliedStaff = _appliedStaff;
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
    final cubit = context.read<AddLeadCubit>();
    cubit.initialize();
    cubit.fetchLeads();
    cubit.fetchStaff();
    _loadCurrentUserRole();

    if (_hasSavedState) {
      // Restore filter state from static variables
      _fromDateController.text = _staticFromDate ?? '';
      _toDateController.text = _staticToDate ?? '';
      selectedCategory = _staticCategory;
      selectedSource = _staticSource;
      selectedPriority = _staticPriority;
      selectedLeadStage = _staticLeadStage;
      selectedStaff = _staticStaff;

      _searchQuery = _staticSearchQuery;
      _selectedEntries = _staticSelectedEntries;
      _currentPage = _staticCurrentPage;

      _appliedCategory = _staticAppliedCategory;
      _appliedLeadStage = _staticAppliedLeadStage;
      _appliedPriority = _staticAppliedPriority;
      _appliedSource = _staticAppliedSource;
      _appliedStaff = _staticAppliedStaff;
      _appliedFromDate = _staticAppliedFromDate;
      _appliedToDate = _staticAppliedToDate;
    } else {
      _fromDateController.text = DateFormat(
        'dd-MM-yyyy',
      ).format(DateTime.now());
      _toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSavedState) {
        _applyFilters();
      }
    });
  }

  Future<void> _loadCurrentUserRole() async {
    final user = await SessionService().getSavedUser();
    if (!mounted) return;
    setState(() {
      _currentUserRole = user?.staffType;
    });
  }

  // bool _hasActiveFilters() {
  //   return selectedCategory != null ||
  //       selectedSource != null ||
  //       selectedPriority != null ||
  //       selectedLeadStage != null ||
  //       selectedStaff != null ||
  //       _fromDateController.text.isNotEmpty ||
  //       _toDateController.text.isNotEmpty;
  // }

  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      selectedSource = null;
      selectedPriority = null;
      selectedLeadStage = null;
      selectedStaff = null;
      _fromDateController.clear();
      _toDateController.clear();

      _appliedCategory = null;
      _appliedLeadStage = null;
      _appliedPriority = null;
      _appliedSource = null;
      _appliedStaff = null;
      _appliedFromDate = null;
      _appliedToDate = null;

      _hasSavedState = false;

      context.read<AddLeadCubit>().selectCategory(null);
      context.read<AddLeadCubit>().selectLeadStage(null);

      _resetPage();
    });
  }

  String? _appliedCategory;
  String? _appliedLeadStage;
  String? _appliedPriority;
  String? _appliedSource;
  String? _appliedStaff;
  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;

  // ── Called ONLY when "View" is tapped ───────────────────────────────────────
  void _applyFilters() {
    setState(() {
      _appliedCategory = selectedCategory;
      _appliedLeadStage = selectedLeadStage;
      _appliedPriority = selectedPriority;
      _appliedSource = selectedSource;
      _appliedStaff = selectedStaff;
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

    // ── Lead Stage — stored UPPERCASE in Firestore ────────────────────────────
    if (!_isPlaceholder(_appliedLeadStage)) {
      final stage = _appliedLeadStage!.trim().toUpperCase();
      result = result.where((l) => l.leadStage.toUpperCase() == stage).toList();
    }

    // ── Lead Source — stored UPPERCASE in Firestore ───────────────────────────
    if (!_isPlaceholder(_appliedSource)) {
      final source = _appliedSource!.trim().toUpperCase();
      result = result
          .where((l) => l.leadSource.toUpperCase() == source)
          .toList();
    }

    // ── Priority — stored as-is (no .toUpperCase() in toFirestore) ───────────
    if (!_isPlaceholder(_appliedPriority)) {
      result = result
          .where(
            (l) =>
                l.priority.toLowerCase() ==
                _appliedPriority!.trim().toLowerCase(),
          )
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

    // Entries limit
    // final limit = int.tryParse(_selectedEntries) ?? 10;
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      /// ── FILTER CARD ──
                      _buildFilterCard(state),

                      SizedBox(height: 2.h),

                      /// ── SHOW ENTRIES + PRIORITY LEGEND + EXPORT ──
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
                      ),

                      SizedBox(height: 2.h),

                      /// ── TABLE & CONTROLS CONTAINER ──
                      Container(
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
                        child: Column(
                          children: [
                            /// Table Section
                            _buildTableSection(state),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
          _legendDot(const Color(0xff22C55E)),
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

  Widget _priorityDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.5,
          height: 8.5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4),
        Text(label, style: AppTextStyle.small()),
      ],
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

    final showSubCategory =
        selectedCategory != null && state.subCategories.isNotEmpty;
    final showTags = selectedLeadStage != null && state.leadTag.isNotEmpty;

    // Collect all filter widgets in display order
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
      Dropdown(
        label: "Lead Category",
        hint: 'Select Category',
        showHelp: true,
        message: 'Lead Category is the type of product/service inquiries.',
        items: categoryItems,
        selectedValue: selectedCategory,
        onChanged: (val) {
          setState(() {
            selectedCategory = val;
            _resetPage();
          });
          if (val != null) {
            context.read<AddLeadCubit>().selectCategory(val);
          } else {
            context.read<AddLeadCubit>().selectCategory(null);
          }
        },
      ),
    ];

    // Sub-Category directly next to Category if visible
    if (showSubCategory) {
      filterWidgets.add(
        Dropdown(
          label: "Lead Sub-Category",
          hint: 'Select Sub-Category',
          items: subCategoryItems,
          selectedValue: null,
          onChanged: (val) {
            setState(() {
              _resetPage();
            });
          },
        ),
      );
    }

    filterWidgets.add(
      Dropdown(
        label: "Lead Status",
        hint: 'Select Status',
        showHelp: true,
        message: 'Lead Status lets you track the stage of a lead.',
        items: stageItems,
        selectedValue: selectedLeadStage,
        onChanged: (val) {
          setState(() {
            selectedLeadStage = val;
            _resetPage();
          });
          if (val != null) {
            context.read<AddLeadCubit>().selectLeadStage(val);
          } else {
            context.read<AddLeadCubit>().selectLeadStage(null);
          }
        },
      ),
    );

    // Tag directly next to Stage if visible
    if (showTags) {
      filterWidgets.add(
        Dropdown(
          label: "Tag",
          hint: 'Select Tag',
          items: tagItems,
          selectedValue: null,
          onChanged: (val) {
            setState(() {
              _resetPage();
            });
          },
        ),
      );
    }

    filterWidgets.add(
      Dropdown(
        label: "Lead Source",
        hint: 'Select Source',
        showHelp: true,
        message: 'Refers to the source of the lead.',
        items: sourceItems,
        selectedValue: selectedSource,
        onChanged: (val) {
          setState(() {
            selectedSource = val;
            _resetPage();
          });
        },
      ),
    );

    filterWidgets.add(
      Dropdown(
        label: "Priority",
        hint: 'Select Field',
        items: priority,
        selectedValue: selectedPriority,
        onChanged: (val) {
          setState(() {
            selectedPriority = val;
            _resetPage();
          });
        },
      ),
    );

    if (isAdmin) {
      filterWidgets.add(
        Dropdown(
          label: "Staff",
          hint: 'Select Field',
          items: staffItems,
          selectedValue: selectedStaff,
          onChanged: (val) {
            setState(() {
              selectedStaff = val;
              _resetPage();
            });
          },
        ),
      );
    }

    // Group filter widgets into rows of 4 columns
    List<List<Widget>> rows = [];
    for (int i = 0; i < filterWidgets.length; i += 4) {
      rows.add(
        filterWidgets.sublist(
          i,
          i + 4 > filterWidgets.length ? filterWidgets.length : i + 4,
        ),
      );
    }

    return Container(
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
                  // Fill remaining space if row has fewer than 4 items
                  ...List.generate(
                    4 - rowItems.length,
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
      ),
    );
  }

  /// ── Table Section ──
  Widget _buildTableSection(AddLeadState leadState) {
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
                'Failed to load leads.',
                style: AppTextStyle.medium(color: Colors.red),
              ),
              SizedBox(height: 1.5.h),
              GestureDetector(
                onTap: () => context.read<AddLeadCubit>().fetchLeads(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.1),
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

    final showFrom = totalCount == 0 ? 0 : (_currentPage - 1) * limit + 1;
    final showTo = (showFrom + pagedList.length - 1).clamp(0, totalCount);

    return Column(
      children: [
        SizedBox(
          child: CustomTable(
            key: ValueKey(_tableKey),
            showCheckboxes: true,
            initialCheckedStates: List.generate(
              pagedList.length,
              (index) => _selectedIndices.contains(index),
            ),
            onCheckChanged: (rowIndex, isChecked) {
              setState(() {
                if (isChecked) {
                  if (!_selectedIndices.contains(rowIndex)) {
                    _selectedIndices.add(rowIndex);
                  }
                } else {
                  _selectedIndices.remove(rowIndex);
                }
              });
            },
            priorityColors: pagedList
                .map((lead) => getPriorityColor(lead.priority))
                .toList(),
            columns: [
              TableColumn(title: "No.", width: 40),
              TableColumn(title: "Name", flex: 4),
              TableColumn(title: "Contact No.", flex: 3),
              TableColumn(title: "Category", flex: 4),
              TableColumn(title: "Staff", flex: 4),
              TableColumn(title: "Status", flex: 4),
              TableColumn(title: "Created Date", flex: 2),
              TableColumn(title: "Select All", flex: 3),
            ],
            rows: pagedList.asMap().entries.map((entry) {
              final index = entry.key;
              final lead = entry.value;
              final serial = (_currentPage - 1) * limit + index + 1;

              final categoryName = lead.leadSubCategory.isEmpty
                  ? resolveLeadName(
                      list: leadState.categories,
                      id: lead.leadCategoryId,
                      fallback: lead.leadCategory,
                      idOf: (s) => s.id,
                      nameOf: (s) => s.name,
                    )
                  : '${resolveLeadName(list: leadState.categories, id: lead.leadCategoryId, fallback: lead.leadCategory, idOf: (s) => s.id, nameOf: (s) => s.name)} - ${resolveLeadName(list: leadState.subCategories, id: lead.leadSubCategoryId, fallback: lead.leadSubCategory, idOf: (s) => s.id, nameOf: (s) => s.name)}';

              final stageName = resolveLeadName(
                list: leadState.stages,
                id: lead.leadStageId,
                fallback: lead.leadStage,
                idOf: (s) => s.id,
                nameOf: (s) => s.name,
              );

              final stageColor = getStageColor(stageName);

              final isChecked = _selectedIndices.contains(index);

              return [
                Text(
                  '$serial',
                  style: AppTextStyle.medium(weight: FontWeight.w500),
                ),
                Text(
                  lead.clientName,
                  style: AppTextStyle.medium(
                    weight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(lead.contactNumber, style: AppTextStyle.medium()),
                Text(categoryName, style: AppTextStyle.medium()),
                Text(lead.assignedStaff, style: AppTextStyle.medium()),

                /// Lead Status with styled text color
                Text(
                  stageName,
                  style: AppTextStyle.medium(
                    weight: FontWeight.w600,
                    color: stageColor,
                  ),
                ),
                Text(
                  lead.createdAt != null
                      ? DateFormat('dd-MM-yyyy').format(lead.createdAt!)
                      : "",
                  style: AppTextStyle.medium(),
                ),

                /// Action Buttons & Row Checkbox
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    /// View Icon Button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: BrowserAwareLink(
                        destination: RoutePaths.followUpPath(
                          lead.id!,
                          "TRANSFERED",
                          fromScreen: 'transferLeads'
                        ),
                        usePush: true,
                        enableInkWell: false,
                        child: Tooltip(
                          message: 'View',
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              // color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF4E9CDB),
                              ),
                            ),
                            child: Image.asset(
                              "assets/icon/eye.png",
                              height: 13.sp,
                              width: 13.sp,
                              color: const Color(0xFF4E9CDB),
                            ),
                            // child: Icon(
                            //   Icons.eye,
                            //   size: 13.sp,
                            //   color: const Color(0xFF4E9CDB),
                            // ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),

                    /// Delete Icon Button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _confirmDelete(context, lead),
                        child: Tooltip(
                          message: 'Delete',
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              // color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFFCA5A5),
                              ),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              size: 13.sp,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// Row Selection Checkbox
                    // Checkbox(
                    //   value: isChecked,
                    //   activeColor: const Color(0xFF10B981),
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(3),
                    //   ),
                    //   onChanged: (val) {
                    //     setState(() {
                    //       if (val == true) {
                    //         if (!_selectedIndices.contains(index)) {
                    //           _selectedIndices.add(index);
                    //         }
                    //       } else {
                    //         _selectedIndices.remove(index);
                    //       }
                    //     });
                    //   },
                    // ),
                  ],
                ),
              ];
            }).toList(),
          ),
        ),

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
                          border: Border.all(color: const Color(0xFFE2E8F0)),
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
                          border: Border.all(color: const Color(0xFFE2E8F0)),
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

                  /// Selected Item Action Button (Transfer)
                  _buildTransferButton(pagedList, leadState),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ── Transfer Button ──
  Widget _buildTransferButton(
    List<AddLeadModel> pagedList,
    AddLeadState state,
  ) {
    final List<AddLeadModel> rawList = state.listStatus == LeadListStatus.loaded
        ? state.leads
        : [];
    final filteredList = _filteredLeads(rawList);

    // Map selected indices → actual lead objects
    final selectedLeads = _selectedIndices
        .where((i) => i < filteredList.length)
        .map((i) => filteredList[i])
        .toList();

    final hasSelection = selectedLeads.isNotEmpty;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: hasSelection
            ? () => showAssignStaffDialog(
                "",
                selectedLeads,
                context,
                onSubmit: (String? selectedStaffId, String? selectedStaffName) async {
                  if (selectedStaffId == null || selectedStaffName == null)
                    return;

                  context.read<AddLeadCubit>().fetchLeads();
                  context.pop();

                  // ── Only transfer leads not already assigned to the selected staff ──
                  final leadsToTransfer = selectedLeads
                      .where((l) => l.assignedStaff != selectedStaffName)
                      .toList();

                  if (leadsToTransfer.isEmpty) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'All selected leads are already assigned to $selectedStaffName.',
                          style: AppTextStyle.medium(
                            color: AppColors.white,
                            weight: FontWeight.w400,
                          ),
                        ),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                  String _resolveTransferredStageId(BuildContext context) {
                    final stages = context.read<AddLeadCubit>().state.stages;
                    final match = stages.where(
                      (s) => s.name.trim().toUpperCase() == 'TRANSFERRED',
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
                  for (final lead in selectedLeads) {
                    await context.read<AddLeadCubit>().transferLead(
                      leadId: lead.id!,
                      leadName: lead.clientName,
                      contactNumber: lead.contactNumber,
                      leadCategory: lead.leadCategory,
                      leadCategoryId: lead.leadCategoryId,
                      leadSubCategory: lead.leadSubCategory,
                      leadSubCategoryId: lead.leadSubCategoryId,
                      leadStage: 'TRANSFERRED',
                      leadStageId: _resolveTransferredStageId(context),
                      fromStaffId: lead.assignedStaffId,
                      fromStaff: lead.assignedStaff,
                      toStaffId: selectedStaffId,
                      toStaff: selectedStaffName,
                    );
                  }

                  context.read<AddLeadCubit>().fetchDashboardCounts(
                    DateTime.now(),
                    forceFetch: true,
                  );

                  // ── Show how many were transferred vs skipped ──
                  final skippedCount =
                      selectedLeads.length - leadsToTransfer.length;
                  final message = skippedCount > 0
                      ? '${leadsToTransfer.length} lead(s) transferred. $skippedCount already assigned to $selectedStaffName (skipped).'
                      : '${leadsToTransfer.length} lead(s) transferred successfully.';

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        message,
                        style: AppTextStyle.medium(
                          color: AppColors.white,
                          weight: FontWeight.w400,
                        ),
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  setState(() {
                    _selectedIndices = [];
                    _tableKey++;
                  });
                },
              )
            : () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Please select at least one lead to transfer leads.',
                    style: AppTextStyle.medium(
                      color: AppColors.white,
                      weight: FontWeight.w400,
                    ),
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 0.8.w, vertical: 0.8.h),
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
              Icon(Icons.swap_vert, color: Colors.white, size: 13.sp),
            ],
          ),
        ),
      ),
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

  // ── Delete confirmation dialog ───────────────────────────────────────────
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
            onPressed: () {
              Navigator.pop(dialogContext);
              ctx.read<AddLeadCubit>().deleteLead(lead.id!, lead);
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

  void _deleteSelectedLeads(List<AddLeadModel> selectedLeads) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
}
