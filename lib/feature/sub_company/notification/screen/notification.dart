import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/shared_preference/session_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/input_date.dart';
import '../../../../core/utils/page_button.dart';
import '../../../../core/utils/show_entries.dart';
import '../../../../core/utils/staff_top_bar.dart';
import '../../../../core/utils/table.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../model/notification_model.dart';
import 'package:sizer/sizer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();

  String _searchQuery = '';
  String _selectedEntries = '10';
  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;
  String _staffId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final user = await SessionService().getSavedUser();
      if (!mounted) return;
      _staffId = user?.id ?? '';
      // context.read<NotificationCubit>().load(_staffId);
      context.read<NotificationCubit>().markAllRead(_staffId);
    });

    fromDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    toDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _appliedFromDate = DateTime.now();
    _appliedToDate = DateTime.now();
  }

  DateTime? _appliedFromDate;
  DateTime? _appliedToDate;

  void _applyFilters() {
    setState(() {
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

  // ── Skip placeholder "Select …" values ──────────────────────────────────────
  bool _isPlaceholder(String? val) =>
      val == null ||
      val.trim().isEmpty ||
      val.toLowerCase().startsWith('select');

  ///-------filtering-----------
  List<NotificationModel> _filteredLeads(List<NotificationModel> leads) {
    List<NotificationModel> result = leads;

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
    // Search filter
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (lead) =>
                (lead.message).toLowerCase().contains(q) ||
                (lead.createdAt != null
                    ? lead.createdAt!.toString().toLowerCase().contains(q)
                    : false),
          )
          .toList();
    }

    // Entries limit
    // final limit = int.tryParse(_selectedEntries) ?? 10;
    return result;
  }

  List<NotificationModel> _pagedLeads(List<NotificationModel> allFiltered) {
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

  void _deleteSelected(List<NotificationModel> notifications) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Delete Selected'),
        content: Text(
          'Are you sure you want to delete ${_selectedIndices.length} selected notification(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final cubit = context.read<NotificationCubit>();
              for (final index in _selectedIndices) {
                cubit.deleteOne(notifications[index].id);
              }
              setState(() => _selectedIndices.clear());
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteAll() {
    context.read<NotificationCubit>().deleteAll(_staffId);
    setState(() => _selectedIndices.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Column(
                children: [
                  // ── Filter Row (unchanged) ──────────────────────────
                  BlocBuilder<NotificationCubit, NotificationState>(
                    builder: (context, state) {
                      return Row(
                        children: [
                          SizedBox(
                            width: 20.w,
                            child: InputDate(
                              label: "From Date",
                              fromController: fromDate,
                              toController: toDate,
                              isFrom: true,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          SizedBox(
                            width: 20.w,
                            child: InputDate(
                              label: "To Date",
                              fromController: fromDate,
                              toController: toDate,
                              isFrom: false,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: InkWell(
                              onTap: () {
                                _applyFilters();
                              },
                              child: SizedBox(
                                width: 7.w,
                                height: 4.5.h,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: const Color(0xff1BAA90),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Apply",
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
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 1.5.h),
                  // ── Show Entries (unchanged) ──────────────
                  ShowEntries(
                    initialSearch: _searchQuery,
                    initialEntries: _selectedEntries,
                    onSearchChanged: (v) => setState(() => _searchQuery = v),
                    onEntriesChanged: (v) =>
                        setState(() => _selectedEntries = v),
                  ),
                  SizedBox(height: 2.h),

                  // ── BlocConsumer ────────────────────────────────────
                  BlocConsumer<NotificationCubit, NotificationState>(
                    listener: (context, state) {
                      if (state is NotificationDeleteError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      final notifications = switch (state) {
                        NotificationLoaded() => state.notifications,
                        NotificationDeleting() => state.notifications,
                        NotificationDeleteError() => state.notifications,
                        _ => <NotificationModel>[],
                      };

                      final allFiltered = _filteredLeads(notifications);
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

                      final isDeleting = state is NotificationDeleting;

                      // ── Loading ──────────────────────────────────
                      if (state is NotificationLoading) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // ── Error ────────────────────────────────────
                      if (state is NotificationError) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Center(
                            child: Text(
                              'Error: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      }

                      return Container(
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
                            // ── Table (unchanged) ─────────────────────
                            CustomTable(
                              columns: [
                                TableColumn(title: '#'),
                                TableColumn(title: 'Title'),
                                TableColumn(title: 'Reminder'),
                                TableColumn(title: 'Created At'),
                                TableColumn(title: 'Select All'),
                              ],
                              rows: pagedList.asMap().entries.map((entry) {
                                final index = entry.key;
                                final serial =
                                    (_currentPage - 1) * limit + index + 1;

                                final item = entry.value;
                                return [
                                  Text('${serial}'),
                                  Text(item.title),
                                  Text(item.message),
                                  Text(
                                    item.createdAt != null
                                        ? DateFormat(
                                            'dd-MM-yyyy HH:mm',
                                          ).format(item.createdAt!)
                                        : '—',
                                  ),
                                  SizedBox(),
                                ];
                              }).toList(),
                              showCheckboxes: true,
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
                            ),

                            /// ── FOOTER & PAGINATION ──
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
                                              ? () => _goToPage(
                                                  _currentPage - 1,
                                                  totalCount,
                                                )
                                              : null,
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.only(
                                              right: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(6),
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
                                      ..._buildPageNumbers(
                                        totalPages,
                                        totalCount,
                                      ),

                                      /// Next button
                                      MouseRegion(
                                        cursor: _currentPage < totalPages
                                            ? SystemMouseCursors.click
                                            : SystemMouseCursors.basic,
                                        child: GestureDetector(
                                          onTap: _currentPage < totalPages
                                              ? () => _goToPage(
                                                  _currentPage + 1,
                                                  totalCount,
                                                )
                                              : null,
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.only(
                                              left: 4,
                                              right: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(6),
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
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // ── Empty State ───────────────────────────
                            if (notifications.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                child: Center(
                                  child: Text(
                                    'No notifications found.',
                                    style: AppTextStyle.small(
                                      size: 11.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),

                            // ── Delete Buttons below table ────────────
                            if (notifications.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 1.5.h,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Delete Selected — only when rows checked
                                    if (_selectedIndices.isNotEmpty) ...[
                                      InkWell(
                                        onTap: isDeleting
                                            ? null
                                            : () => _deleteSelected(
                                                notifications,
                                              ),
                                        child: SizedBox(
                                          width: 10.w,
                                          height: 4.5.h,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: isDeleting
                                                  ? Colors.red.withOpacity(0.5)
                                                  : Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Center(
                                              child: isDeleting
                                                  ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                    )
                                                  : Text(
                                                      'Delete (${_selectedIndices.length})',
                                                      style: AppTextStyle.small(
                                                        size: 10.sp,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 1.w),
                                    ],

                                    // Clear All
                                    InkWell(
                                      onTap: isDeleting
                                          ? null
                                          : () => showDialog(
                                              context: context,
                                              builder: (dialogContext) =>
                                                  AlertDialog(
                                                    title: const Text(
                                                      'Clear All',
                                                    ),
                                                    content: const Text(
                                                      'Are you sure you want to delete all notifications?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              dialogContext,
                                                            ),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                            dialogContext,
                                                          );
                                                          _deleteAll();
                                                        },
                                                        child: const Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            ),
                                      child: SizedBox(
                                        width: 9.w,
                                        height: 4.5.h,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: isDeleting
                                                ? Colors.redAccent.withOpacity(
                                                    0.5,
                                                  )
                                                : Colors.redAccent,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Clear All',
                                              style: AppTextStyle.small(
                                                size: 10.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
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
}
