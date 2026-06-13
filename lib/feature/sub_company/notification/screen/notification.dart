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
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.white,
      title: const Text('Delete Selected'),
      content: Text(
        'Are you sure you want to delete ${_selectedIndices.length} selected notification(s)?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            final cubit = context.read<NotificationCubit>();
            for (final index in _selectedIndices) {
              cubit.deleteOne(notifications[index].id);
            }
            setState(() => _selectedIndices.clear());
          },
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
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
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StaffTopBar(
              title: 'Lead Notifications',
              parent: 'Dashboard',
              current: 'Notifications',
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
                    // ── Filter Row (unchanged) ──────────────────────────
                    BlocBuilder<NotificationCubit, NotificationState>(
                      builder: (context, state) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 2.w,
                            right: 2.w,
                            top: 2.w,
                            bottom: 1.h,
                          ),
                          child: Row(
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
                              SizedBox(width: 2.w),
                              SizedBox(
                                width: 20.w,
                                child: InputDate(
                                  label: "To Date",
                                  fromController: fromDate,
                                  toController: toDate,
                                  isFrom: false,
                                ),
                              ),
                              SizedBox(width: 2.w),
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
                                          "Search",
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
                          ),
                        );
                      },
                    ),

                    Divider(color: AppColors.divider),

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

                        return Column(
                          children: [
                            // ── Show Entries (unchanged) ──────────────
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 1.h,
                              ),
                              child: ShowEntries(
                                initialSearch: _searchQuery,
                                initialEntries: _selectedEntries,
                                onSearchChanged: (v) =>
                                    setState(() => _searchQuery = v),
                                onEntriesChanged: (v) =>
                                    setState(() => _selectedEntries = v),
                              ),
                            ),

                            // ── Table (unchanged) ─────────────────────
                            CustomTable(
                              columns: [
                                TableColumn(title: '#', flex: 1),
                                TableColumn(title: 'Title', flex: 4),
                                TableColumn(title: 'Reminder', flex: 4),
                                TableColumn(title: 'Created At', flex: 4),
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
                                            : () => _deleteSelected(notifications),
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
                                              builder: (_) => AlertDialog(
                                                title: const Text('Clear All'),
                                                content: const Text(
                                                  'Are you sure you want to delete all notifications?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
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
          style: AppTextStyle.small(
            size: 11.sp,
            color: AppColors.white,
          ),
        ),
      ),
    ),
  ];
}

}
