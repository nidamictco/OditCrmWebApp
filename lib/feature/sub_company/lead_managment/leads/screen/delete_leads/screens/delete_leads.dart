import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/confirm_alert.dart';
import 'package:Odit_CRM/core/utils/multi_select_dropdown.dart';
import 'package:Odit_CRM/core/utils/resolved_lead_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/utils/dropdown.dart';
import 'package:Odit_CRM/core/utils/export_excel.dart';
import 'package:Odit_CRM/core/utils/input_date.dart';
import 'package:Odit_CRM/core/utils/show_entries.dart';
import 'package:Odit_CRM/core/utils/table.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import 'package:sizer/sizer.dart';

class DeleteLeads extends StatefulWidget {
  const DeleteLeads({super.key});

  @override
  State<DeleteLeads> createState() => _DeleteLeadsState();
}

class _DeleteLeadsState extends State<DeleteLeads> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  // ── Multi-select & Single-select filter selections ────────
  List<String> selectedCategories = [];
  List<String> selectedSubCategories = [];
  List<String> selectedLeadStages = [];
  List<String> selectedTags = [];
  List<String> selectedSources = [];
  String? selectedDeletedBy;
  String? selectedAssignedStaff;

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
  static List<String> _staticSubCategories = [];
  static List<String> _staticLeadStages = [];
  static List<String> _staticTags = [];
  static List<String> _staticSources = [];
  static String? _staticDeletedBy;
  static String? _staticAssignedStaff;
  static String _staticSearchQuery = '';
  static String _staticSelectedEntries = '10';
  static int _staticCurrentPage = 1;

  // Static variables for applied (active) filter state
  static List<String> _staticAppliedCategories = [];
  static List<String> _staticAppliedSubCategories = [];
  static List<String> _staticAppliedStages = [];
  static List<String> _staticAppliedTags = [];
  static List<String> _staticAppliedSources = [];
  static String? _staticAppliedStaff;
  static String? _staticAppliedDeletedBy;
  static DateTime? _staticAppliedFromDate;
  static DateTime? _staticAppliedToDate;

  // ── Snapshot fields (applied only when "View" is tapped) ────────────────────
  List<String> _appliedCategories = [];
  List<String> _appliedSubCategories = [];
  List<String> _appliedStages = [];
  List<String> _appliedTags = [];
  List<String> _appliedSources = [];
  String? _appliedStaff;
  String? _appliedDeletedBy;
  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;

  @override
  void dispose() {
    // Save current filter state to static variables before widget disposal
    _staticFromDate = _fromDateController.text;
    _staticToDate = _toDateController.text;
    _staticCategories = List<String>.from(selectedCategories);
    _staticSubCategories = List<String>.from(selectedSubCategories);
    _staticLeadStages = List<String>.from(selectedLeadStages);
    _staticTags = List<String>.from(selectedTags);
    _staticSources = List<String>.from(selectedSources);
    _staticDeletedBy = selectedDeletedBy;
    _staticAssignedStaff = selectedAssignedStaff;

    _staticSearchQuery = _searchQuery;
    _staticSelectedEntries = _selectedEntries;
    _staticCurrentPage = _currentPage;

    _staticAppliedCategories = List<String>.from(_appliedCategories);
    _staticAppliedSubCategories = List<String>.from(_appliedSubCategories);
    _staticAppliedStages = List<String>.from(_appliedStages);
    _staticAppliedTags = List<String>.from(_appliedTags);
    _staticAppliedSources = List<String>.from(_appliedSources);
    _staticAppliedStaff = _appliedStaff;
    _staticAppliedDeletedBy = _appliedDeletedBy;
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
    context.read<AddLeadCubit>().fetchDeletedLeads();
    context.read<AddLeadCubit>().fetchStaff();
    context.read<AddLeadCubit>().initialize();

    if (_hasSavedState) {
      // Restore filter state from static variables
      _fromDateController.text = _staticFromDate ?? '';
      _toDateController.text = _staticToDate ?? '';
      selectedCategories = List<String>.from(_staticCategories);
      selectedSubCategories = List<String>.from(_staticSubCategories);
      selectedLeadStages = List<String>.from(_staticLeadStages);
      selectedTags = List<String>.from(_staticTags);
      selectedSources = List<String>.from(_staticSources);
      selectedDeletedBy = _staticDeletedBy;
      selectedAssignedStaff = _staticAssignedStaff;

      _searchQuery = _staticSearchQuery;
      _selectedEntries = _staticSelectedEntries;
      _currentPage = _staticCurrentPage;

      _appliedCategories = List<String>.from(_staticAppliedCategories);
      _appliedSubCategories = List<String>.from(_staticAppliedSubCategories);
      _appliedStages = List<String>.from(_staticAppliedStages);
      _appliedTags = List<String>.from(_staticAppliedTags);
      _appliedSources = List<String>.from(_staticAppliedSources);
      _appliedStaff = _staticAppliedStaff;
      _appliedDeletedBy = _staticAppliedDeletedBy;
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

  void _clearFilters() {
    setState(() {
      selectedCategories = [];
      selectedSubCategories = [];
      selectedLeadStages = [];
      selectedTags = [];
      selectedSources = [];
      selectedAssignedStaff = null;
      selectedDeletedBy = null;
      _fromDateController.clear();
      _toDateController.clear();

      _appliedCategories = [];
      _appliedSubCategories = [];
      _appliedStages = [];
      _appliedTags = [];
      _appliedSources = [];
      _appliedStaff = null;
      _appliedDeletedBy = null;
      _appliedFromDate = null;
      _appliedToDate = null;

      _hasSavedState = false;

      context.read<AddLeadCubit>().selectCategory(null);
      context.read<AddLeadCubit>().selectLeadStage(null);

      _resetPage();
    });
  }

  // ── Called ONLY when "View" is tapped ───────────────────────────────────────
  void _applyFilters() {
    setState(() {
      _appliedCategories = List<String>.from(selectedCategories);
      _appliedSubCategories = List<String>.from(selectedSubCategories);
      _appliedStages = List<String>.from(selectedLeadStages);
      _appliedTags = List<String>.from(selectedTags);
      _appliedSources = List<String>.from(selectedSources);
      _appliedStaff = selectedAssignedStaff;
      _appliedDeletedBy = selectedDeletedBy;
      _appliedFromDate = _fromDateController.text.trim().isEmpty
          ? null
          : _parseDate(_fromDateController.text);
      _appliedToDate = _toDateController.text.trim().isEmpty
          ? null
          : _parseDate(_toDateController.text);
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

    // ── Lead Category ──────────────────────────────────────────────────────────
    if (_appliedCategories.isNotEmpty) {
      final cats = _appliedCategories
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((l) => cats.contains(l.leadCategory.toUpperCase()))
          .toList();
    }

    // ── Sub Category ───────────────────────────────────────────────────────────
    if (_appliedSubCategories.isNotEmpty) {
      final subCats = _appliedSubCategories
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((l) => subCats.contains(l.leadSubCategory.toUpperCase()))
          .toList();
    }

    // ── Lead Stage ────────────────────────────────────────────────────────────
    if (_appliedStages.isNotEmpty) {
      final stages = _appliedStages.map((e) => e.trim().toUpperCase()).toSet();
      result = result
          .where((l) => stages.contains(l.leadStage.toUpperCase()))
          .toList();
    }

    // ── Tag ───────────────────────────────────────────────────────────────────
    if (_appliedTags.isNotEmpty) {
      final tags = _appliedTags.map((e) => e.trim().toUpperCase()).toSet();
      result = result
          .where((l) => tags.contains(l.leadTag.toUpperCase()))
          .toList();
    }

    // ── Lead Source ───────────────────────────────────────────────────────────
    if (_appliedSources.isNotEmpty) {
      final sources = _appliedSources
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((l) => sources.contains(l.leadSource.toUpperCase()))
          .toList();
    }

    // ── Assigned Staff ────────────────────────────────────────────────────────
    if (!_isPlaceholder(_appliedStaff)) {
      result = result
          .where(
            (l) =>
                l.assignedStaff.toLowerCase() ==
                _appliedStaff!.trim().toLowerCase(),
          )
          .toList();
    }

    // ── Deleted By ────────────────────────────────────────────────────────────
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

  // Color _getStageColor(String stageName) {
  //   final lower = stageName.toLowerCase();
  //   if (lower.contains('follow') || lower.contains('follow up')) {
  //     return const Color(0xFF3B82F6); // Blue
  //   } else if (lower.contains('closed') || lower.contains('won')) {
  //     return const Color(0xFF10B981); // Green
  //   } else if (lower.contains('reject') || lower.contains('lost')) {
  //     return const Color(0xFFEF4444); // Red
  //   }
  //   return const Color(0xFF64748B);
  // }

  Color _getStageColor(String stage) {
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
                /// ── TOP BAR (Matching Mockup Design) ──
                // _buildTopNavigationHeader(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      /// ── FILTER CARD ──
                      _buildFilterCard(state),

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
                        exportWidget: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              final leads = context
                                  .read<AddLeadCubit>()
                                  .state
                                  .leads;
                              final filtered = _filteredLeads(leads);
                              exportLeadsToExcel(filtered, 'deleted_leads_');
                            },
                            child: Container(
                              height: 4.h,
                              padding: EdgeInsets.symmetric(horizontal: 0.8.w),
                              decoration: BoxDecoration(
                                color:
                                    AppThemeColors.appPrimaryColor, // Dark Navy
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Export",
                                    style: AppTextStyle.medium(
                                      color: Colors.white,
                                      weight: FontWeight.w500,
                                      size: 10.sp,
                                    ),
                                  ),
                                  SizedBox(width: 0.4.w),
                                  Icon(
                                    Icons.file_upload_outlined,
                                    color: Colors.white,
                                    size: 12.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                            /// Table Controls (Show entries & Search)

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

  /// ── Top Header Navigation Bar matching mock ──
  Widget _buildTopNavigationHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Left side: Breadcrumb
          Row(
            children: [
              Icon(
                Icons.chevron_left,
                size: 16.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(width: 0.2.w),
              Icon(
                Icons.chevron_right,
                size: 16.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(width: 0.8.w),
              Text(
                'Lead Management',
                style: AppTextStyle.medium(
                  size: 11.sp,
                  color: Colors.grey.shade500,
                  weight: FontWeight.w400,
                ),
              ),
              Text(
                ' / ',
                style: AppTextStyle.medium(
                  size: 11.sp,
                  color: Colors.grey.shade400,
                ),
              ),
              Text(
                'Deleted Leads',
                style: AppTextStyle.medium(
                  size: 11.sp,
                  color: const Color(0xFF1E293B),
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),

          /// Right side: Search, Export, and Action Icon Buttons
          Row(
            children: [
              /// Top Search Bar
              Container(
                width: 18.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  onChanged: (v) => setState(() {
                    _searchQuery = v;
                    _resetPage();
                  }),
                  style: AppTextStyle.small(size: 10.sp),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: AppTextStyle.small(
                      size: 10.sp,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 14.sp,
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 0.8.h),
                  ),
                ),
              ),
              SizedBox(width: 1.w),

              /// Navy Export Button
              SizedBox(width: 0.8.w),

              /// Filter list icon button (=)
              _buildHeaderIconButton(Icons.filter_list),
              SizedBox(width: 0.5.w),

              /// Bell notification icon button with red badge
              Stack(
                children: [
                  _buildHeaderIconButton(Icons.notifications_none_outlined),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 0.5.w),

              /// Settings icon button
              _buildHeaderIconButton(Icons.settings_outlined),
              SizedBox(width: 0.5.w),

              /// Fullscreen icon button
              _buildHeaderIconButton(Icons.crop_free),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton(IconData icon) {
    return Container(
      width: 4.h,
      height: 4.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Icon(icon, size: 12.sp, color: const Color(0xFF64748B)),
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
    final deletedByItems = state.staffList.map((e) => e.name).toList();

    final showSubCategory =
        selectedCategories.length == 1 && state.subCategories.isNotEmpty;
    final showTags = selectedLeadStages.length == 1 && state.leadTag.isNotEmpty;

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

    // Lead Stage
    // filterWidgets.add(
    //   MultiSelectDropdown(
    //     label: "Lead Stage",
    //     hint: 'Select Lead Stage',
    //     items: stageItems,
    //     selectedValues: selectedLeadStages,
    //     onChanged: (vals) {
    //       setState(() {
    //         selectedLeadStages = vals;
    //         selectedTags = [];
    //         _resetPage();
    //       });
    //       if (vals.length == 1) {
    //         context.read<AddLeadCubit>().selectLeadStage(vals.first);
    //       } else {
    //         context.read<AddLeadCubit>().selectLeadStage(null);
    //       }
    //     },
    //   ),
    // );

    // // Tag directly next to Stage if visible
    // if (showTags) {
    //   filterWidgets.add(
    //     MultiSelectDropdown(
    //       showChips: true,
    //       label: "Tag",
    //       hint: 'Select Tag',
    //       items: tagItems,
    //       selectedValues: selectedTags,
    //       onChanged: (vals) {
    //         setState(() {
    //           selectedTags = vals;
    //           _resetPage();
    //         });
    //       },
    //     ),
    //   );
    // }

    filterWidgets.add(
      MultiSelectDropdown(
        label: "Lead Source",
        hint: 'Select Lead Source',
        showHelp: true,
        message: 'Refers to the source of the lead.',
        items: sourceItems,
        selectedValues: selectedSources,
        onChanged: (val) {
          setState(() {
            selectedSources = val;
            _resetPage();
          });
        },
      ),
    );

    filterWidgets.add(
      Dropdown(
        label: "Assigned Staff",
        hint: 'Select Field',
        items: staffItems,
        selectedValue: selectedAssignedStaff,
        onChanged: (val) {
          setState(() {
            selectedAssignedStaff = val;
            _resetPage();
          });
        },
      ),
    );

    filterWidgets.add(
      Dropdown(
        label: "Deleted By",
        hint: 'Select Field',
        items: deletedByItems,
        selectedValue: selectedDeletedBy,
        onChanged: (val) {
          setState(() {
            selectedDeletedBy = val;
            _resetPage();
          });
        },
      ),
    );

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
      padding: EdgeInsets.all(25),
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
              /// View Button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _applyFilters,
                  child: Container(
                    height: 4.h,
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: const Color(0xff00b087), // Emerald Green
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Apply",
                      style: AppTextStyle.small(
                        size: 10.sp,
                        color: Colors.white,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 1.w),

              /// Clear All Button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: _clearFilters,
                  child: Container(
                    height: 4.h,
                    padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                    decoration: BoxDecoration(
                      color: const Color(0xffe95757),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Reset',
                      style: AppTextStyle.small(
                        size: 11.sp,
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
                'Failed to load deleted leads.',
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
            columns: [
              TableColumn(title: "No."),
              TableColumn(title: "Name"),
              TableColumn(title: "Contact No."),
              TableColumn(title: "Lead Category"),
              TableColumn(title: "Assigned Staff"),
              TableColumn(title: "Lead Status"),
              TableColumn(title: "Deleted Date"),
              TableColumn(title: "Deleted By"),
              TableColumn(title: "Select All"),
            ],
            rows: pagedList.asMap().entries.map((entry) {
              final index = entry.key;
              final lead = entry.value;
              final serial = (_currentPage - 1) * limit + index + 1;
              final deletedAt = lead.deletedAt != null
                  ? DateFormat('dd-MM-yyyy').format(lead.deletedAt!)
                  : '—';

              final categoryName = resolveLeadName(
                list: leadState.categories,
                id: lead.leadCategoryId,
                fallback: lead.leadCategory,
                idOf: (s) => s.id,
                nameOf: (s) => s.name,
              );

              final subCategoryName = resolveLeadName(
                list: leadState.subCategories,
                id: lead.leadSubCategoryId,
                fallback: lead.leadSubCategory,
                idOf: (s) => s.id,
                nameOf: (s) => s.name,
              );

              final stageName = resolveLeadName(
                list: leadState.stages,
                id: lead.leadStageId,
                fallback: lead.leadStage,
                idOf: (s) => s.id,
                nameOf: (s) => s.name,
              );

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
                Text(
                  subCategoryName.isEmpty
                      ? categoryName
                      : "$categoryName - $subCategoryName",
                  style: AppTextStyle.medium(),
                ),
                Text(lead.assignedStaff, style: AppTextStyle.medium()),

                /// Lead Status with styled text color
                Text(
                  stageName,
                  style: AppTextStyle.medium(
                    weight: FontWeight.w600,
                    color: _getStageColor(stageName),
                  ),
                ),
                Text(deletedAt, style: AppTextStyle.medium()),
                Text(lead.assignedStaff, style: AppTextStyle.medium()),

                /// Action Buttons & Row Checkbox
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /// Restore Icon Button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _confirmRestore(context, lead),
                        child: Tooltip(
                          message: 'Restore',
                          child: Container(
                            height: 28,
                            width: 28,
                            decoration: BoxDecoration(
                              // color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.green.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.restore,
                              size: 15,
                              color: AppColors.green,
                            ),
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
                          message: 'Delete Permanently',
                          child: Container(
                            height: 28,
                            width: 28,
                            decoration: BoxDecoration(
                              // color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFFCA5A5),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                AssetResources.deleteIcon,
                                scale: 1.7,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(width: 0.2.w),

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
                  size: 10.5,
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

                  /// Selected Item Action Button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedIndices.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No items selected.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        _confirmBulkAction(context, pagedList);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 0.8.w,
                          vertical: 0.8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeColors.appPrimaryColor, // Coral Red
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Selected Items Action',
                              style: AppTextStyle.small(
                                size: 10.5,
                                color: Colors.white,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
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
              size: 10.5,
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
                    size: 10.5,
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
                size: 10.5,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        );
      }
    }
    return pages;
  }

  // ── Bulk action dialog for selected items ───────────────────
  void _confirmBulkAction(BuildContext ctx, List<AddLeadModel> pagedList) {
    final addLeadCubit = ctx.read<AddLeadCubit>();
    final selectedLeads = _selectedIndices
        .where((i) => i < pagedList.length)
        .map((i) => pagedList[i])
        .toList();

    // showDialog(
    //   context: ctx,
    //   builder: (dialogContext) {
    //     return AlertDialog(
    //       backgroundColor: AppColors.white,
    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //       title: Text(
    //         'Selected Items (${selectedLeads.length})',
    //         style: AppTextStyle.medium(size: 14.sp),
    //       ),
    //       content: Text(
    //         'What would you like to do with the ${selectedLeads.length} selected lead(s)?',
    //         style: AppTextStyle.medium(),
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(dialogContext),
    //           child: Text(
    //             'Cancel',
    //             style: AppTextStyle.medium(color: AppColors.grey),
    //           ),
    //         ),
    //         TextButton(
    //           onPressed: () async {
    //             // Navigator.pop(dialogContext);
    //             await addLeadCubit.bulkRestoreLeads(selectedLeads);
    //             if (!mounted) return;
    //             Navigator.pop(dialogContext);

    //             ScaffoldMessenger.of(context).showSnackBar(
    //               SnackBar(
    //                 content: Text(
    //                   '${selectedLeads.length} Lead(s) restored successfully.',
    //                 ),
    //                 behavior: SnackBarBehavior.floating,
    //                 backgroundColor: AppColors.green,
    //               ),
    //             );
    //             setState(() => _selectedIndices.clear());
    //           },
    //           child: Text(
    //             'Restore Selected',
    //             style: AppTextStyle.medium(color: Colors.green),
    //           ),
    //         ),
    //         TextButton(
    //           onPressed: () async {
    //             await addLeadCubit.bulkDeleteLeads(selectedLeads);
    //             if (!mounted) return;
    //             Navigator.pop(dialogContext);

    //             ScaffoldMessenger.of(context).showSnackBar(
    //               SnackBar(
    //                 content: Text(
    //                   '${selectedLeads.length} Lead(s) deleted successfully.',
    //                 ),
    //                 behavior: SnackBarBehavior.floating,
    //                 backgroundColor: AppColors.red,
    //               ),
    //             );
    //             setState(() => _selectedIndices.clear());
    //           },
    //           child: Text(
    //             'Delete Selected',
    //             style: AppTextStyle.medium(color: Colors.red),
    //           ),
    //         ),
    //       ],
    //     );
    //   },
    // );
    ConfirmAlertWidget.show(
      context,
      title: 'Selected Items (${selectedLeads.length})',
      message:
          'What would you like to do with the ${selectedLeads.length} selected lead(s)?',
      type: ConfirmAlertType.both,
      onDelete: () {
        context.pop();
        addLeadCubit.bulkDeleteLeads(selectedLeads);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${selectedLeads.length} Lead(s) deleted successfully.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.red,
          ),
        );
        setState(() => _selectedIndices.clear());
      },
      onRestore: () {
        context.pop();
        addLeadCubit.bulkRestoreLeads(selectedLeads);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${selectedLeads.length} Lead(s) restored successfully.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.green,
          ),
        );
        setState(() => _selectedIndices.clear());
      },
    );
  }

  // ─── Restore confirmation dialog ───────────────────────────────────────────
  void _confirmRestore(BuildContext ctx, AddLeadModel lead) {
    final addLeadCubit = ctx.read<AddLeadCubit>();

    // showDialog(
    //   context: ctx,
    //   builder: (dialogContext) {
    //     return AlertDialog(
    //       backgroundColor: AppColors.white,
    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //       title: Text('Restore Lead', style: AppTextStyle.medium(size: 14.sp)),
    //       content: Text(
    //         'Restore "${lead.clientName}" back to leads reports?',
    //         style: AppTextStyle.medium(),
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(dialogContext).pop();
    //           },
    //           child: Text(
    //             'Cancel',
    //             style: AppTextStyle.medium(color: AppColors.grey),
    //           ),
    //         ),
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(dialogContext).pop();
    //             addLeadCubit.restoreLead(lead);
    //             ScaffoldMessenger.of(context).showSnackBar(
    //               SnackBar(
    //                 content: Text('${lead.clientName} restored successfully.'),
    //                 behavior: SnackBarBehavior.floating,
    //                 backgroundColor: AppColors.green,
    //               ),
    //             );
    //           },
    //           child: Text(
    //             'Restore',
    //             style: AppTextStyle.medium(color: Colors.green),
    //           ),
    //         ),
    //       ],
    //     );
    //   },
    // );
    ConfirmAlertWidget.show(
      context,
      title: 'Restore Lead',
      message: 'Restore "${lead.clientName}" back to leads reports?',
      type: ConfirmAlertType.restore,
      onRestore: () {
        context.pop();
        addLeadCubit.restoreLead(lead);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${lead.clientName} restored successfully.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.green,
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext ctx, AddLeadModel lead) {
    final addLeadCubit = ctx.read<AddLeadCubit>();
    ConfirmAlertWidget.show(
      context,
      title: 'Delete Lead',
      message: 'Delete "${lead.clientName}" permanently?',
      type: ConfirmAlertType.delete,
      onDelete: () {
        context.pop();
        addLeadCubit.deleteLead(lead.id!, lead);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lead(s) deleted successfully.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.red,
          ),
        );
      },
    );
    // showDialog(
    //   context: ctx,
    //   builder: (dialogContext) => AlertDialog(
    //     backgroundColor: AppColors.white,
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //     title: Text('Delete Lead', style: AppTextStyle.medium(size: 14.sp)),
    //     content: Text(
    //       'Delete "${lead.clientName}" permanently?',
    //       style: AppTextStyle.medium(),
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(dialogContext),
    //         child: Text(
    //           'Cancel',
    //           style: AppTextStyle.medium(color: AppColors.grey),
    //         ),
    //       ),
    //       TextButton(
    //         onPressed: () {
    //           Navigator.pop(dialogContext);
    //           // addLeadCubit.permanentlyDeleteLead(lead.id ?? '');
    //           addLeadCubit.deleteLead(lead.id!, lead);
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             const SnackBar(
    //               content: Text('Lead(s) deleted successfully.'),
    //               behavior: SnackBarBehavior.floating,
    //               backgroundColor: AppColors.red,
    //             ),
    //           );
    //         },
    //         child: Text(
    //           'Delete',
    //           style: AppTextStyle.medium(color: Colors.red),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  // -------------export to excel function (filtered)-------------
  void exportLeadsToExcel(List<AddLeadModel> leads, String fileName) {
    exportToExcel<AddLeadModel>(
      fileName: fileName,
      wrapColumnIndices: [2],
      rows: leads,
      columns: [
        ExcelColumn(header: 'No.', value: (l) => '${leads.indexOf(l) + 1}'),
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
