import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/input_date.dart';
import 'package:oxdo/core/utils/page_button.dart';
import 'package:oxdo/core/utils/popup_msg.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import 'package:oxdo/feature/sub_company/sidebar/main_screen.dart';
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

  String _searchQuery = '';
  String _selectedEntries = '10';

  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AddLeadCubit>();
    cubit.initialize();
    cubit.fetchLeads();
    cubit.fetchStaff();
    _fromDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilters());
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
    // result.sort(
    //   (a, b) =>
    //       _priorityOrder(a.priority).compareTo(_priorityOrder(b.priority)),
    // );
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
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBreadcrumbBar(
              subTitle: 'Transfer Leads',
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
                            "Transfer Leads",
                            style: AppTextStyle.medium(
                              size: 13.6.sp,
                              color: AppColors.black.withOpacity(0.77),
                              weight: FontWeight.w600,
                            ),
                          ),
                          // _topButton("Transfer"),
                        ],
                      ),
                    ),

                    Divider(color: AppColors.divider),

                    /// 🔹 FILTERS
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
                                      label: "From Date",
                                      fromController: _fromDateController,
                                      toController: _toDateController,
                                      isFrom: true,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: InputDate(
                                      label: "To Date",
                                      fromController: _fromDateController,
                                      toController: _toDateController,
                                      isFrom: false,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Dropdown(
                                      label: "Lead Category",
                                      hint: 'select category',
                                      showHelp: true,
                                      message:
                                          'Lead Category is the type\n of product, service, or solution \na potential customer is \ninterested in, helping businesses\n identify and classify inquiries \nfor better follow-up.',
                                      items: categoryItems,
                                      selectedValue: selectedCategory,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedCategory = val;
                                          _resetPage();
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Dropdown(
                                      label: "Lead Status",
                                      hint: 'select status',
                                      showHelp: true,
                                      message:
                                          'Lead Status lets you track \nthe stage of a lead, and you can \nadd new statuses as needed to match \nyour sales process.',
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

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Dropdown(
                                      label: "Lead Source",
                                      hint: 'select source',
                                      showHelp: true,
                                      message:
                                          'It refers to the source of the \nlead, showing how the potential \ncustomer discovered or engaged with \nthe business, such as through marketing \ncampaigns, social media, referrals, events,\n or website inquiries.',
                                      items: sourceItems,
                                      selectedValue: selectedSource,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedSource = val;
                                          _resetPage();
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Dropdown(
                                      label: "Priority",
                                      hint: 'select priority',
                                      items: priority,
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
                                  SizedBox(width: 1.4.w),
                                  Expanded(child: SizedBox()),
                                ],
                              ),
                              Row(
                                children: [
                                  _viewButton(),
                                  SizedBox(width: 1.w),
                                  if (selectedCategory != null ||
                                      selectedSource != null ||
                                      selectedPriority != null ||
                                      selectedLeadStage != null ||
                                      selectedStaff != null)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedCategory = null;
                                          selectedSource = null;
                                          selectedPriority = null;
                                          selectedLeadStage = null;
                                          selectedStaff = null;
                                          _resetPage();
                                        });
                                      },
                                      child: Container(
                                        width: 7.w,
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
                    SizedBox(height: 2.h),
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

                    /// 🔹 TABLE HEADER
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
                                  height: 0,
                                  priorityColors: pagedList
                                      .map(
                                        (lead) =>
                                            getPriorityColor(lead.priority),
                                      )
                                      .toList(),
                                  //      onRowTap: (rowIndex) {
                                  //   final lead = pagedList[rowIndex];
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (context) => MainScreen(
                                  //         selectedIndex: 31,
                                  //         lead: lead,
                                  //       ),
                                  //     ),
                                  //   );
                                  //   print('Row $rowIndex tapped');
                                  // },
                                  columns: [
                                    TableColumn(title: "Sl No.", flex: 1),
                                    TableColumn(title: "Name", flex: 4),
                                    TableColumn(
                                      title: "Contact Number",
                                      flex: 4,
                                    ),
                                    TableColumn(
                                      title: "Lead Category",
                                      flex: 4,
                                    ),
                                    TableColumn(title: "Staff", flex: 4),
                                    TableColumn(title: "Lead Status", flex: 4),
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
                                        '${serial}',
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
                                            : "",
                                        style: AppTextStyle.medium(),
                                      ),
                                      // Text(row[7], style: AppTextStyle.medium()),

                                      /// ACTION
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => MainScreen(
                                                    selectedIndex: 31,
                                                    lead: lead,
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
                                          GestureDetector(
                                            onTap: () =>
                                                _confirmDelete(context, lead),
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
                                ),
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
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),

                    /// 🔹 BOTTOM TRANSFER BUTTON
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
                        return Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: Center(
                            child: GestureDetector(
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

                                            // for (final lead in selectedLeads) {
                                            //   await context.read<AddLeadCubit>().assignStaff(
                                            //     leadId: lead.id!,
                                            //     staffId: selectedStaffId!,
                                            //     staffName: selectedStaffName!,
                                            //   );
                                            // }
                                            Navigator.pop(context);
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
                                                    style: AppTextStyle.medium(
                                                      color: AppColors.white,
                                                      weight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      Colors.orange,
                                                  behavior:
                                                      SnackBarBehavior.floating,
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

                                            for (final lead in selectedLeads) {
                                              await context
                                                  .read<AddLeadCubit>()
                                                  .transferLead(
                                                    leadId: lead.id!,
                                                    leadName: lead.clientName,
                                                    contactNumber:
                                                        lead.contactNumber,
                                                    leadCategory:
                                                        lead.leadCategory,
                                                    leadStage: lead.leadStage,
                                                    fromStaffId:
                                                        lead.assignedStaffId,
                                                    fromStaff:
                                                        lead.assignedStaff,
                                                    toStaffId: selectedStaffId,
                                                    toStaff: selectedStaffName,
                                                  );
                                            }

                                            // Navigator.pop(context);

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
                                                  seconds: 3,
                                                ),
                                              ),
                                            );
                                            setState(() {
                                              _selectedIndices = [];
                                              _tableKey++; // 🔹 forces CustomTable to rebuild fresh with all boxes unchecked
                                            });
                                            // context.read<AddLeadCubit>().fetchLeads();
                                          },
                                    )
                                  : () => ScaffoldMessenger.of(context)
                                        .showSnackBar(
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
                                  color: AppColors.primary,
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

  /// ================= UI COMPONENTS =================

  Widget _viewButton() {
    return InkWell(
      onTap: () {
        _applyFilters();
      },
      child: Container(
        width: 8.w,
        height: 4.5.h,
        margin: EdgeInsets.only(top: 2.h),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            "View",
            style: AppTextStyle.small(size: 10.sp, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _topButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.1.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyle.small(
          size: 11.sp,
          weight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }
  // ------------functions-------------

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
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<AddLeadCubit>().deleteLead(lead.id!, lead);
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

  Widget _checkbox() {
    return SizedBox(
      width: 4.w,
      child: Checkbox(
        value: false,
        onChanged: (v) {},
        activeColor: AppColors.primary,
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      border: Border.all(color: AppColors.lightGrey),
      borderRadius: BorderRadius.circular(4),
      color: AppColors.white,
    );
  }
}
