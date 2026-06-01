import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/export_excel.dart';
import 'package:oxdo/core/utils/input_date.dart';
import 'package:oxdo/core/utils/page_button.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/tool_tips.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';

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

  String? selectedCategory;
  String? selectedSource;
  String? selectedPriority;
  String? selectedLeadStage;
  String? selectedStatus;
  String? selectedStaff;
  String? selectedCreatedBy;
  String? selectedState;
  String? selectedDistrict;

  String _searchQuery = '';
  String _selectedEntries = '10';

  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();

    fromDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    toDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

   _appliedFromDate = DateTime.now();
  _appliedToDate = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddLeadCubit>().fetchLeads();
      _applyFilters();
    });
  }

  // ── Snapshot fields (add alongside your existing selected* fields) ──────────
  String? _appliedCategory;
  String? _appliedLeadStage;
  String? _appliedPriority;
  String? _appliedSource;
  String? _appliedStaff;
  String? _appliedCreatedBy;
  String? _appliedState;
  String? _appliedDistrict;
  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;
  bool _appliedIsCreatedDate = true;

  // ── Called ONLY when "View" is tapped ───────────────────────────────────────
  void _applyFilters() {
    setState(() {
      _appliedIsCreatedDate = _isCreatedDate;
      _appliedCategory = selectedCategory;
      _appliedLeadStage = selectedLeadStage;
      _appliedPriority = selectedPriority;
      _appliedSource = selectedSource;
      _appliedStaff = selectedStaff;
      _appliedCreatedBy = selectedCreatedBy;
      _appliedState = selectedState;
      _appliedDistrict = selectedDistrict;
      // _appliedFromDate = _parseDate(fromDate.text);
      // _appliedToDate = _parseDate(toDate.text);
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
      // result = result
      //     .where((l) => l.createdAt != null && !l.createdAt!.isBefore(from))
      //     .toList();
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
      // result = result
      //     .where((l) => l.createdAt != null && !l.createdAt!.isAfter(to))
      //     .toList();
      result = result.where((l) {
      final date = _appliedIsCreatedDate ? l.createdAt : l.updatedAt;
      return date != null && !date.isAfter(to);
    }).toList();
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

    // ── Created By — stored as-is ─────────────────────────────────────────────
    if (!_isPlaceholder(_appliedCreatedBy)) {
      result = result
          .where(
            (l) =>
                l.createdBy.toLowerCase() ==
                _appliedCreatedBy!.trim().toLowerCase(),
          )
          .toList();
    }

    // ── State — stored as-is ──────────────────────────────────────────────────
    if (!_isPlaceholder(_appliedState)) {
      result = result
          .where(
            (l) => l.state.toLowerCase() == _appliedState!.trim().toLowerCase(),
          )
          .toList();
    }

    // ── District — stored as-is ───────────────────────────────────────────────
    if (!_isPlaceholder(_appliedDistrict)) {
      result = result
          .where(
            (l) =>
                l.district.toLowerCase() ==
                _appliedDistrict!.trim().toLowerCase(),
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
                              exportLeadsToExcel(filtered);
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
                        final sourceItems = state.sources
                            .map((e) => e.name)
                            .toList();
                        final stageItems = state.stages
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
                                  _radio("Created Date", _isCreatedDate,'Created Date allows you to \nfilter leads based on when they \nwere added to the system.'),
                                  SizedBox(width: 3.w),
                                  _radio("Updated Date", !_isCreatedDate,'Updated Date allows you to \nfilter leads based on the most \nrecent changes made to them.'),
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
                                    child: Dropdown(
                                      hint: 'select category',
                                      showHelp: true,
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
                                      showHelp: true,
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

                              SizedBox(height: 1.h),

                              Row(
                                children: [
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
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Dropdown(
                                      label: "Lead Source",
                                      hint: 'select source',
                                      showHelp: true,
                                      items: sourceItems,
                                      selectedValue: selectedSource,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedSource = val;
                                          _resetPage();
                                        });
                                      },
                                      message: '.',
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
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
                                      message: ".",
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Dropdown(
                                      label: "Created By",
                                      hint: 'select creator',
                                      items: createdByItems,
                                      selectedValue: selectedCreatedBy,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedCreatedBy = val;
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
                                    // width: 17.45.w,
                                    child: Dropdown(
                                      label: "State",
                                      hint: "select state",

                                      onChanged: (val) {
                                        setState(() {
                                          selectedState = val;
                                          _resetPage();
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    // width: 17.45.w,
                                    child: Dropdown(
                                      label: "District",
                                      hint: "select district",
                                      onChanged: (val) {
                                        setState(() {
                                          selectedDistrict = val;
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
                                  if (selectedCategory != null ||
                                      selectedSource != null ||
                                      selectedPriority != null ||
                                      selectedLeadStage != null ||
                                      selectedStaff != null ||
                                      selectedState != null ||
                                      selectedDistrict != null)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedCategory = null;
                                          selectedSource = null;
                                          selectedPriority = null;
                                          selectedLeadStage = null;
                                          selectedStaff = null;
                                          selectedState = null;
                                          selectedDistrict = null;
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
                              CustomTable(
                                key: ValueKey(_tableKey),
                                onTap: () {
                                  print('Row tapped ');
                                },
                                columns: [
                                  TableColumn(title: "#", flex: 1),
                                  TableColumn(title: "Name", flex: 4),
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
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MainScreen(
                                                      selectedIndex: 31,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Icon(
                                            Icons.visibility_outlined,
                                            size: 13.sp,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                        // ── EDIT — await pop then re-fetch ──
                                        GestureDetector(
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => MainScreen(
                                                  selectedIndex: 1,
                                                  lead: lead,
                                                ),
                                              ),
                                            );
                                            if (context.mounted) {
                                              context
                                                  .read<AddLeadCubit>()
                                                  .fetchLeads();
                                            }
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            size: 14.sp,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        // ── DELETE ──
                                        GestureDetector(
                                          onTap: () =>_confirmDelete(context, lead),
                                          child: Icon(
                                            Icons.delete_outline,
                                            size: 14.sp,
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
                              // SizedBox(width: 0.5.w),
                              // GestureDetector(
                              //   // onTap: hasSelection
                              //   //     ? () =>
                              //   //           _showAssignStaffDialog(selectedLeads)
                              //   //     : null,
                              //   child: Container(
                              //     padding: EdgeInsets.symmetric(
                              //       horizontal: 1.w,
                              //       vertical: 1.h,
                              //     ),
                              //     decoration: BoxDecoration(
                              //       color: AppColors.primary.withOpacity(0.3),
                              //       borderRadius: BorderRadius.circular(4),
                              //     ),
                              //     child: Icon(
                              //       Icons.edit,
                              //       size: 14.sp,
                              //       color: AppColors.primary,
                              //     ),
                              //   ),
                              // ),
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

  Widget _radio(String text, bool selected,String message) {
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
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Delete Lead', style: AppTextStyle.medium(size: 14.sp)),
        content: Text(
          'Are you sure you want to delete "${lead.clientName}"? This action cannot be undone.',
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
            onPressed: () async {
              Navigator.pop(ctx);
             await  context.read<AddLeadCubit>().deleteLead(lead.id!, lead);
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

    final List<Widget> widgets = [];

    // Show at most 5 page buttons centered around current page
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
}
