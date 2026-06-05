import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/footer.dart';
import 'package:oxdo/core/utils/input_date.dart';
import 'package:oxdo/core/utils/page_button.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/staff_top_bar.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';
import 'package:sizer/sizer.dart';

class TransferLeadsReport extends StatefulWidget {
  final String currentUserId;
  final String currentUserRole;
  final String currentUserName;
  const TransferLeadsReport({super.key, required this.currentUserId,
    required this.currentUserRole,
    required this.currentUserName,});

  @override
  State<TransferLeadsReport> createState() => _TransferLeadsReportState();
}

class _TransferLeadsReportState extends State<TransferLeadsReport> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  String? selectedStatus;
  String? selectedCategory;
  String? selectedfromstaff;
  String? selectedtostaff;
  String _searchQuery = '';
  String _selectedEntries = '10';

  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;

   List<TransferDetails> _getTransfersForRole(List<AddLeadModel> leads) {
  final allTransfers = leads
      .where((l) => l.transferLeads != null && l.transferLeads!.isNotEmpty)
      .expand((l) => l.transferLeads!)
      .where((t) =>
          t.fromStaff.trim().toLowerCase() !=
          t.toStaff.trim().toLowerCase())
      .toList();

  if (widget.currentUserRole.toLowerCase() == 'admin') {
    // Admin sees all transfers
    return allTransfers;
  } else {
    // Staff sees only transfers they were involved in
    return allTransfers.where((t) =>
        t.fromStaffId == widget.currentUserId ||
        t.toStaffId   == widget.currentUserId,
    ).toList();
  }
}
            

  @override
  void initState() {
    super.initState();
    context.read<AddLeadCubit>().fetchLeads();
    final cubit = context.read<AddLeadCubit>();
    cubit.initialize();
    cubit.fetchLeads();
    cubit.fetchStaff();

    _fromDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddLeadCubit>().fetchLeads(); // ← only once
      _applyFilters();
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   context.read<AddLeadCubit>().fetchLeads();
  // }

  // ── Snapshot fields (add alongside your existing selected* fields) ──────────
  String? _appliedCategory;
  String? _appliedLeadStatus;
  String? _appliedfromstaff;
  String? _appliedtostaff;
  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;

  // ── Called ONLY when "View" is tapped ───────────────────────────────────────
  void _applyFilters() {
    setState(() {
      _appliedCategory = selectedCategory;
      _appliedLeadStatus = selectedStatus;
      _appliedfromstaff = selectedfromstaff;
      _appliedtostaff = selectedtostaff;
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

  List<TransferDetails> _filteredLeads(List<TransferDetails> transfers) {
    List<TransferDetails> result = transfers;

    // ── Date range ────────────────────────────────────────────────────────────
    if (_appliedFromDate != null) {
      final from = DateTime(
        _appliedFromDate!.year,
        _appliedFromDate!.month,
        _appliedFromDate!.day,
      );
      result = result
          .where(
            (t) => t.transferTime != null && !t.transferTime!.isBefore(from),
          )
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
          .where((t) => t.transferTime != null && !t.transferTime!.isAfter(to))
          .toList();
    }

    // ── Lead Category ─────────────────────────────────────────────────────────
    if (!_isPlaceholder(_appliedCategory)) {
      final cat = _appliedCategory!.trim().toUpperCase();
      result = result
          .where((t) => t.leadCategory.toUpperCase() == cat)
          .toList();
    }

    // ── Lead Status ─────────────────────────────────────────────────────────
    if (!_isPlaceholder(_appliedLeadStatus)) {
      final status = _appliedLeadStatus!.trim().toUpperCase();
      result = result
          .where((t) => t.leadStage.toUpperCase() == status)
          .toList();
    }

    // ── From Staff ────────────────────────────────────────────────────────────
    if (!_isPlaceholder(_appliedfromstaff)) {
      result = result
          .where(
            (t) =>
                t.fromStaff.toLowerCase() ==
                _appliedfromstaff!.trim().toLowerCase(),
          )
          .toList();
    }

    // ── To Staff ──────────────────────────────────────────────────────────────
    if (!_isPlaceholder(_appliedtostaff)) {
      result = result
          .where(
            (t) =>
                t.toStaff.toLowerCase() ==
                _appliedtostaff!.trim().toLowerCase(),
          )
          .toList();
    }

    // ── Search ────────────────────────────────────────────────────────────────
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (t) =>
                t.leadName.toLowerCase().contains(q) ||
                t.contactNumber.toLowerCase().contains(q),
          )
          .toList();
    }

    return result;
  }

  List<TransferDetails> _pagedLeads(List<TransferDetails> allFiltered) {
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
            StaffTopBar(
              title: 'Transferred Leads Report',
              parent: 'Reports',
              current: 'Transferred Leads',
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.divider),
                ),
                child: BlocBuilder<AddLeadCubit, AddLeadState>(
                  builder: (context, state) {
                    final categoryItems = state.categories
                        .map((e) => e.name)
                        .toList();
                    final stageItems = state.stages.map((e) => e.name).toList();
                    final staffItems = state.staffList
                        .map((e) => e.name)
                        .toList();
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Row(
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
                                  label: "Status",
                                  hint: ' select status',
                                  showHelp: false,
                                  items: stageItems,
                                  selectedValue: selectedStatus,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedStatus = val;
                                      _resetPage();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 17.45.w,
                                child: Dropdown(
                                  label: "From Staff",
                                  hint: "select staff",
                                  items: staffItems,
                                  selectedValue: selectedfromstaff,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedfromstaff = val;
                                      _resetPage();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 2.w),
                              SizedBox(
                                width: 17.45.w,
                                child: Dropdown(
                                  label: "To Staff",
                                  hint: "select staff",
                                  items: staffItems,
                                  selectedValue: selectedtostaff,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedtostaff = val;
                                      _resetPage();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 2.w),

                              /// 🔥 VIEW BUTTON (perfect aligned)
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
                                      selectedStatus != null ||
                                      selectedfromstaff != null ||
                                      selectedtostaff != null)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedCategory = null;
                                          selectedStatus = null;
                                          selectedfromstaff = null;
                                          selectedtostaff = null;

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
                        ),

                        SizedBox(height: 1.w),
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
                            // final List<TransferDetails> allTransfers =
                            //     rawList
                            //         .where(
                            //           (l) =>
                            //               l.transferLeads != null &&
                            //               l.transferLeads!.isNotEmpty,
                            //         )
                            //         .expand((l) => l.transferLeads!)
                            //         .where(
                            //           (t) =>
                            //               t.fromStaff.trim().toLowerCase() !=
                            //               t.toStaff.trim().toLowerCase(),
                            //         )
                            //         .toList()
                            //       ..sort((a, b) {
                            //         // nulls go to the end
                            //         if (a.transferTime == null &&
                            //             b.transferTime == null)
                            //           return 0;
                            //         if (a.transferTime == null) return 1;
                            //         if (b.transferTime == null) return -1;
                            //         // latest first
                            //         return b.transferTime!.compareTo(
                            //           a.transferTime!,
                            //         );
                            //       });
                                          final List<TransferDetails> allTransfers = _getTransfersForRole(rawList)
  ..sort((a, b) {
    if (a.transferTime == null && b.transferTime == null) return 0;
    if (a.transferTime == null) return 1;
    if (b.transferTime == null) return -1;
    return b.transferTime!.compareTo(a.transferTime!);
  });

                            final allFiltered = _filteredLeads(allTransfers);
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
                            final showTo = (showFrom + pagedList.length - 1)
                                .clamp(0, totalCount);

                            // Loaded with data
                            if (state.listStatus == LeadListStatus.loaded) {
                              return Column(
                                children: [
                                  SizedBox(
                                    child: CustomTable(
                                      columns: [
                                        TableColumn(title: "#", flex: 1),
                                        TableColumn(title: "Name", flex: 4),
                                        TableColumn(
                                          title: "Contact Number",
                                          flex: 4,
                                        ),
                                        TableColumn(
                                          title: "From Staff",
                                          flex: 4,
                                        ),
                                        TableColumn(title: "To Staff", flex: 4),
                                        TableColumn(
                                          title: "Lead Category",
                                          flex: 4,
                                        ),
                                        TableColumn(
                                          title: "Transfer Date",
                                          flex: 4,
                                        ),
                                      ],
                                      rows: pagedList.asMap().entries.map((
                                        entry,
                                      ) {
                                        final index = entry.key;
                                        final transfer = entry.value;
                                        final serial =
                                            (_currentPage - 1) * limit +
                                            index +
                                            1;

                                        return [
                                          Text(
                                            serial.toString(),
                                            style: AppTextStyle.medium(),
                                          ),
                                          Text(
                                            transfer.leadName,
                                            style: AppTextStyle.medium(),
                                          ),
                                          Text(
                                            transfer.contactNumber.toString(),
                                            style: AppTextStyle.medium(),
                                          ),
                                          Text(
                                            transfer.fromStaff,
                                            style: AppTextStyle.medium(),
                                          ),
                                          Text(
                                            transfer.toStaff,
                                            style: AppTextStyle.medium(),
                                          ),
                                          Text(
                                            transfer.leadCategory,
                                            style: AppTextStyle.medium(),
                                          ),
                                          Text(
                                            transfer.transferTime != null
                                                ? DateFormat(
                                                    'dd-MM-yyyy hh:mm a',
                                                  ).format(
                                                    transfer.transferTime!,
                                                  )
                                                : '-',
                                            style: AppTextStyle.medium(),
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
                                              enabled:
                                                  _currentPage < totalPages,
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
                            return SizedBox.shrink();
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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
