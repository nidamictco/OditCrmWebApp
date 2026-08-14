import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/utils/multi_select_dropdown.dart';
import 'package:Odit_CRM/core/utils/resolved_lead_name.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/lead_source/data/lead_source_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/utils/dropdown.dart';
import 'package:Odit_CRM/core/utils/footer.dart';
import 'package:Odit_CRM/core/utils/input_date.dart';
import 'package:Odit_CRM/core/utils/page_button.dart';
import 'package:Odit_CRM/core/utils/show_entries.dart';
import 'package:Odit_CRM/core/utils/staff_top_bar.dart';
import 'package:Odit_CRM/core/utils/table.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import 'package:sizer/sizer.dart';

class TransferLeadsReport extends StatefulWidget {
  final String currentUserId;
  final String currentUserRole;
  final String currentUserName;
  const TransferLeadsReport({
    super.key,
    required this.currentUserId,
    required this.currentUserRole,
    required this.currentUserName,
  });

  @override
  State<TransferLeadsReport> createState() => _TransferLeadsReportState();
}

class _TransferLeadsReportState extends State<TransferLeadsReport> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  // ── Multi-select filter selections (temporary, pending "View" tap) ────────
  List<String> selectedCategories = [];
  List<String> selectedStatuses = [];
  List<String> selectedfromstaffs = [];
  List<String> selectedtostaffs = [];

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
  static List<String> _staticStatuses = [];
  static List<String> _staticFromStaffs = [];
  static List<String> _staticToStaffs = [];
  static String _staticSearchQuery = '';
  static String _staticSelectedEntries = '10';
  static int _staticCurrentPage = 1;

  // Static variables for applied (active) filter state
  static List<String> _staticAppliedCategories = [];
  static List<String> _staticAppliedLeadStatuses = [];
  static List<String> _staticAppliedFromStaffs = [];
  static List<String> _staticAppliedToStaffs = [];
  static DateTime? _staticAppliedFromDate;
  static DateTime? _staticAppliedToDate;

  // ── Snapshot fields (applied only when "View" is tapped) ────────────────────
  List<String> _appliedCategories = [];
  List<String> _appliedLeadStatuses = [];
  List<String> _appliedfromstaffs = [];
  List<String> _appliedtostaffs = [];
  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;

  List<TransferDetails> _getTransfersForRole(List<AddLeadModel> leads) {
    final allTransfers = leads
        .where((l) => l.transferLeads != null && l.transferLeads!.isNotEmpty)
        .expand((l) => l.transferLeads!)
        .where(
          (t) =>
              t.fromStaff.trim().toLowerCase() !=
              t.toStaff.trim().toLowerCase(),
        )
        .toList();

    if (widget.currentUserRole.toLowerCase() == 'admin') {
      // Admin sees all transfers
      return allTransfers;
    } else {
      // Staff sees only transfers they were involved in
      return allTransfers
          .where(
            (t) =>
                t.fromStaffId == widget.currentUserId ||
                t.toStaffId == widget.currentUserId,
          )
          .toList();
    }
  }

  @override
  void dispose() {
    // Save current filter state to static variables before widget disposal
    _staticFromDate = _fromDateController.text;
    _staticToDate = _toDateController.text;
    _staticCategories = List<String>.from(selectedCategories);
    _staticStatuses = List<String>.from(selectedStatuses);
    _staticFromStaffs = List<String>.from(selectedfromstaffs);
    _staticToStaffs = List<String>.from(selectedtostaffs);

    _staticSearchQuery = _searchQuery;
    _staticSelectedEntries = _selectedEntries;
    _staticCurrentPage = _currentPage;

    _staticAppliedCategories = List<String>.from(_appliedCategories);
    _staticAppliedLeadStatuses = List<String>.from(_appliedLeadStatuses);
    _staticAppliedFromStaffs = List<String>.from(_appliedfromstaffs);
    _staticAppliedToStaffs = List<String>.from(_appliedtostaffs);
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

    if (_hasSavedState) {
      // Restore filter state from static variables
      _fromDateController.text = _staticFromDate ?? '';
      _toDateController.text = _staticToDate ?? '';
      selectedCategories = List<String>.from(_staticCategories);
      selectedStatuses = List<String>.from(_staticStatuses);
      selectedfromstaffs = List<String>.from(_staticFromStaffs);
      selectedtostaffs = List<String>.from(_staticToStaffs);

      _searchQuery = _staticSearchQuery;
      _selectedEntries = _staticSelectedEntries;
      _currentPage = _staticCurrentPage;

      _appliedCategories = List<String>.from(_staticAppliedCategories);
      _appliedLeadStatuses = List<String>.from(_staticAppliedLeadStatuses);
      _appliedfromstaffs = List<String>.from(_staticAppliedFromStaffs);
      _appliedtostaffs = List<String>.from(_staticAppliedToStaffs);
      _appliedFromDate = _staticAppliedFromDate;
      _appliedToDate = _staticAppliedToDate;
    } else {
      _fromDateController.text = DateFormat(
        'dd-MM-yyyy',
      ).format(DateTime.now());
      _toDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddLeadCubit>().fetchLeads(); // ← only once
      if (!_hasSavedState) {
        _applyFilters();
      }
    });
  }

  bool _hasActiveFilters() {
    return selectedCategories.isNotEmpty ||
        selectedStatuses.isNotEmpty ||
        selectedfromstaffs.isNotEmpty ||
        selectedtostaffs.isNotEmpty ||
        _fromDateController.text.isNotEmpty ||
        _toDateController.text.isNotEmpty;
  }

  void _clearFilters() {
    setState(() {
      selectedCategories = [];
      selectedStatuses = [];
      selectedfromstaffs = [];
      selectedtostaffs = [];
      _fromDateController.clear();
      _toDateController.clear();

      _appliedCategories = [];
      _appliedLeadStatuses = [];
      _appliedfromstaffs = [];
      _appliedtostaffs = [];
      _appliedFromDate = null;
      _appliedToDate = null;

      _hasSavedState = false;

      _resetPage();
    });
  }

  // ── Called ONLY when "View" is tapped ───────────────────────────────────────
  void _applyFilters() {
    setState(() {
      _appliedCategories = List<String>.from(selectedCategories);
      _appliedLeadStatuses = List<String>.from(selectedStatuses);
      _appliedfromstaffs = List<String>.from(selectedfromstaffs);
      _appliedtostaffs = List<String>.from(selectedtostaffs);
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

    // ── Lead Category — match ANY selected ───────────────────────────────────
    if (_appliedCategories.isNotEmpty) {
      final cats = _appliedCategories
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((t) => cats.contains(t.leadCategory.toUpperCase()))
          .toList();
    }

    // ── Lead Status — match ANY selected ─────────────────────────────────────
    if (_appliedLeadStatuses.isNotEmpty) {
      final statuses = _appliedLeadStatuses
          .map((e) => e.trim().toUpperCase())
          .toSet();
      result = result
          .where((t) => statuses.contains(t.leadStage.toUpperCase()))
          .toList();
    }

    // ── From Staff — match ANY selected ──────────────────────────────────────
    if (_appliedfromstaffs.isNotEmpty) {
      final fromSet = _appliedfromstaffs
          .map((e) => e.trim().toLowerCase())
          .toSet();
      result = result
          .where((t) => fromSet.contains(t.fromStaff.toLowerCase()))
          .toList();
    }

    // ── To Staff — match ANY selected ────────────────────────────────────────
    if (_appliedtostaffs.isNotEmpty) {
      final toSet = _appliedtostaffs.map((e) => e.trim().toLowerCase()).toSet();
      result = result
          .where((t) => toSet.contains(t.toStaff.toLowerCase()))
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
      backgroundColor: AppThemeColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: Column(
            children: [
              Column(
                children: [
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
                        /// 🔹 FILTERS
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
                            return Column(
                              children: [
                                _buildFilterCard(state),

                                // // ── ROW 1: 5 Columns
                                // Row(
                                //   children: [
                                //     Expanded(
                                //       child: InputDate(
                                //         label: "From Date",
                                //         fromController: _fromDateController,
                                //         toController: _toDateController,
                                //         isFrom: true,
                                //       ),
                                //     ),
                                //     SizedBox(width: 2.w),
                                //     Expanded(
                                //       child: InputDate(
                                //         label: "To Date",
                                //         fromController: _fromDateController,
                                //         toController: _toDateController,
                                //         isFrom: false,
                                //       ),
                                //     ),
                                //     SizedBox(width: 2.w),
                                //     Expanded(
                                //       child: MultiSelectDropdown(
                                //         showChips: true,
                                //         showClear: true,
                                //         hint: 'select category',
                                //         // showHelp: true,
                                //         // message:
                                //         //     'Lead Category is the type\n of product, service, or solution \na potential customer is \ninterested in, helping businesses\n identify and classify inquiries \nfor better follow-up.',
                                //         items: categoryItems,
                                //         selectedValues: selectedCategories,
                                //         onChanged: (val) {
                                //           setState(() {
                                //             selectedCategories = val;
                                //             _resetPage();
                                //           });
                                //         },
                                //         label: "Lead Category",
                                //       ),
                                //     ),
                                //     SizedBox(width: 2.w),
                                //     Expanded(
                                //       child: MultiSelectDropdown(
                                //         showChips: true,
                                //         showClear: true,
                                //         label: "Status",
                                //         hint: 'select Status',
                                //         // showHelp: false,
                                //         // message:
                                //         //     'Lead Status lets you track \nthe stage of a lead, and you can \nadd new statuses as needed to match \nyour sales process.',
                                //         items: stageItems,
                                //         selectedValues: selectedStatuses,
                                //         onChanged: (val) {
                                //           setState(() {
                                //             selectedStatuses = val;
                                //             _resetPage();
                                //           });
                                //         },
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                // SizedBox(height: 1.h),

                                // // ── ROW 2: 5 Columns
                                // Row(
                                //   children: [
                                //     Expanded(
                                //       child: MultiSelectDropdown(
                                //         showChips: true,
                                //         label: "From Staff",
                                //         hint: 'select staff',
                                //         showHelp: true,
                                //         message:
                                //             'It refers to the source of the \nlead, showing how the potential \ncustomer discovered or engaged with \nthe business, such as through marketing \ncampaigns, social media, referrals, events,\n or website inquiries.',
                                //         items: staffItems,
                                //         selectedValues: selectedfromstaffs,
                                //         onChanged: (vals) {
                                //           setState(() {
                                //             selectedfromstaffs = vals;
                                //             _resetPage();
                                //           });
                                //         },
                                //       ),
                                //     ),
                                //     SizedBox(width: 2.w),

                                //     Expanded(
                                //       child: MultiSelectDropdown(
                                //         showChips: true,
                                //         label: "To Staff",
                                //         hint: 'select staff',
                                //         items: staffItems,
                                //         selectedValues: selectedtostaffs,
                                //         onChanged: (vals) {
                                //           setState(() {
                                //             selectedtostaffs = vals;
                                //             _resetPage();
                                //           });
                                //         },
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ],
                              // ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

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
              Container(
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

                        final List<TransferDetails> allTransfers =
                            _getTransfersForRole(rawList)..sort((a, b) {
                              if (a.transferTime == null &&
                                  b.transferTime == null)
                                return 0;
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
                        final showTo = (showFrom + pagedList.length - 1).clamp(
                          0,
                          totalCount,
                        );

                        // Loaded with data
                        if (state.listStatus == LeadListStatus.loaded) {
                          return Column(
                            children: [
                              SizedBox(
                                child: CustomTable(
                                  key: ValueKey(_tableKey),
                                  columns: [
                                    TableColumn(title: "No."),
                                    TableColumn(title: "Name"),
                                    TableColumn(title: "Contact Number"),
                                    TableColumn(title: "From Staff"),
                                    TableColumn(title: "To Staff"),
                                    TableColumn(title: "Lead Category"),
                                    TableColumn(title: "Transfer Date"),
                                  ],
                                  rows: pagedList.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final transfer = entry.value;
                                    final serial =
                                        (_currentPage - 1) * limit + index + 1;

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
                                        // transfer.leadCategory,
                                        // transfer.leadSubCategory.isEmpty
                                        // ? transfer.leadCategory
                                        // : '${transfer.leadCategory} - ${transfer.leadSubCategory}',
                                        resolveLeadName(
                                          list: state.categories,
                                          id: transfer.leadCategoryId,
                                          fallback: transfer.leadCategory,
                                          idOf: (s) => s.id,
                                          nameOf: (s) => s.name,
                                        ),
                                        style: AppTextStyle.medium(),
                                      ),
                                      Text(
                                        transfer.transferTime != null
                                            ? DateFormat(
                                                'dd-MM-yyyy hh:mm a',
                                              ).format(transfer.transferTime!)
                                            : '-',
                                        style: AppTextStyle.medium(),
                                      ),
                                    ];
                                  }).toList(),
                                ),
                              ),

                              // Padding(
                              //   padding: EdgeInsets.symmetric(
                              //     horizontal: 2.w,
                              //     vertical: 1.5.h,
                              //   ),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Text(
                              //         "Showing $showFrom to $showTo of $totalCount entries",
                              //         style: AppTextStyle.medium(
                              //           weight: FontWeight.w400,
                              //         ),
                              //       ),
                              //       Row(
                              //         children: [
                              //           PageButton(
                              //             label: 'Previous',
                              //             enabled: _currentPage > 1,
                              //             isLeft: true,
                              //             onTap: () => _goToPage(
                              //               _currentPage - 1,
                              //               totalCount,
                              //             ),
                              //           ),
                              //           ..._buildPageNumbers(
                              //             totalPages,
                              //             totalCount,
                              //           ),
                              //           PageButton(
                              //             label: 'Next',
                              //             enabled:
                              //                 _currentPage < totalPages,
                              //             isRight: true,
                              //             onTap: () => _goToPage(
                              //               _currentPage + 1,
                              //               totalCount,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Page number chips ───────────────────────
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

  /// ── Filter Card (matches TransferLeads screen UX) ──
  Widget _buildFilterCard(AddLeadState state) {
    final categoryItems = state.categories.map((e) => e.name).toList();
    final stageItems = state.stages.map((e) => e.name).toList();
    final staffItems = state.staffList.map((e) => e.name).toList();

    // Same "rows of 4" grouping pattern used in TransferLeads' _buildFilterCard,
    // applied to this screen's own report-specific fields.
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
        showChips: true,
        showClear: true,
        hint: 'select category',
        items: categoryItems,
        selectedValues: selectedCategories,
        onChanged: (val) {
          setState(() {
            selectedCategories = val;
            _resetPage();
          });
        },
        label: "Lead Category",
      ),
      MultiSelectDropdown(
        showChips: true,
        showClear: true,
        label: "Status",
        hint: 'select Status',
        items: stageItems,
        selectedValues: selectedStatuses,
        onChanged: (val) {
          setState(() {
            selectedStatuses = val;
            _resetPage();
          });
        },
      ),
      MultiSelectDropdown(
        showChips: true,
        label: "From Staff",
        hint: 'select staff',
        showHelp: true,
        message:
            'It refers to the source of the \nlead, showing how the potential \ncustomer discovered or engaged with \nthe business, such as through marketing \ncampaigns, social media, referrals, events,\n or website inquiries.',
        items: staffItems,
        selectedValues: selectedfromstaffs,
        onChanged: (vals) {
          setState(() {
            selectedfromstaffs = vals;
            _resetPage();
          });
        },
      ),
      MultiSelectDropdown(
        showChips: true,
        label: "To Staff",
        hint: 'select staff',
        items: staffItems,
        selectedValues: selectedtostaffs,
        onChanged: (vals) {
          setState(() {
            selectedtostaffs = vals;
            _resetPage();
          });
        },
      ),
    ];

    // Group into rows of 4, same as TransferLeads.
    List<List<Widget>> rows = [];
    for (int i = 0; i < filterWidgets.length; i += 4) {
      rows.add(
        filterWidgets.sublist(
          i,
          i + 4 > filterWidgets.length ? filterWidgets.length : i + 4,
        ),
      );
    }

    return Column(
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
                // Fill remaining space if row has fewer than 4 items,
                // exactly like TransferLeads does for its own uneven rows.
                ...List.generate(
                  4 - rowItems.length,
                  (_) => Expanded(child: SizedBox()),
                ),
              ],
            ),
          );
        }),

        // ── Action buttons: same style, order, and behavior as TransferLeads ──
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                _applyFilters();
              },

              child: Container(
                height: 4.h,
                padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                decoration: BoxDecoration(
                  color: const Color(0xff00b087),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Apply",
                  style: AppTextStyle.small(
                    size: 11.5,
                    color: Colors.white,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(width: 1.w),
            InkWell(
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
                    size: 11.5,
                    color: Colors.white,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
