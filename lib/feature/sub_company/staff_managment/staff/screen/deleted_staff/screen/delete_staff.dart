import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/confirm_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_text_style.dart';
import '../../../../../../../core/utils/footer.dart';
import '../../../../../../../core/utils/page_button.dart';
import '../../../../../../../core/utils/show_entries.dart';
import '../../../../../../../core/utils/table.dart';
import '../../../../../../../core/utils/top_bread_crumb_bar.dart';
import '../../../cubit/add_staff_cubit.dart';
import '../../../cubit/add_staff_state.dart';
import '../../../model/staff_model.dart';
import 'package:sizer/sizer.dart';

class DeletedStaffScreen extends StatefulWidget {
  const DeletedStaffScreen({super.key});

  @override
  State<DeletedStaffScreen> createState() => _DeletedStaffScreenState();
}

class _DeletedStaffScreenState extends State<DeletedStaffScreen> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  String _searchQuery = '';
  String _selectedEntries = '10';
  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    // ✅ This is what fetches deleted staff from DELETED_STAFF collection
    context.read<StaffCubit>().fetchDeletedStaff();
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  // ─── Filter pipeline ───────────────────────────────────────────────────────
  List<StaffModel> _filtered(List<StaffModel> all) {
    List<StaffModel> result = all;

    // Search filter
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (s) =>
                s.name.toLowerCase().contains(q) ||
                s.phone.toLowerCase().contains(q) ||
                (s.designation ?? '').toLowerCase().contains(q),
          )
          .toList();
    }

    return result;
  }

  List<StaffModel> _pagedLeads(List<StaffModel> allFiltered) {
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

  // ─── Restore confirmation dialog ───────────────────────────────────────────
  void _confirmRestore(BuildContext ctx, StaffModel staff) {
    // showDialog(
    //   context: ctx,
    //   builder: (dialogContext) => AlertDialog(
    //     backgroundColor: AppColors.white,
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //     title: Text('Restore Staff', style: AppTextStyle.medium(size: 14.sp)),
    //     content: Text(
    //       'Restore "${staff.name}" back to active staff?',
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
    //           ctx.read<StaffCubit>().restoreStaff(staff);
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             SnackBar(
    //               backgroundColor: AppColors.green,
    //               content: Text('Staff "${staff.name}" restored!'),
    //             ),
    //           );
    //         },
    //         child: Text(
    //           'Restore',
    //           style: AppTextStyle.medium(color: Colors.green),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    ConfirmAlertWidget.show(
      context,
      type: ConfirmAlertType.restore,
      title: 'Restore Staff',
      message: 'Restore "${staff.name}" back to active staff?',
      onRestore: () {
        context.pop();
        ctx.read<StaffCubit>().restoreStaff(staff);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Staff "${staff.name}" restored!'),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext ctx, StaffModel staff) {
    // showDialog(
    //   context: ctx,
    //   builder: (dialogContext) => AlertDialog(
    //     backgroundColor: AppColors.white,
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //     title: Text('Delete Staff', style: AppTextStyle.medium(size: 14.sp)),
    //     content: Text(
    //       'Delete "${staff.name}" permanently?',
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
    //           ctx.read<StaffCubit>().deleteStaffPermanently(staff.id ?? '');
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             SnackBar(
    //               backgroundColor: Colors.red,
    //               content: Text('Staff "${staff.name}" deleted permanently!'),
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
    ConfirmAlertWidget.show(
      context,
      type: ConfirmAlertType.delete,
      title: 'Delete Staff',
      message: 'Delete "${staff.name}" permanently?',
      onDelete: () {
        context.pop();
        ctx.read<StaffCubit>().deleteStaffPermanently(staff.id ?? '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Staff "${staff.name}" deleted permanently!'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.scaffoldBg,
      body: BlocConsumer<StaffCubit, StaffState>(
        listener: (context, state) {
          if (state is StaffError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Show entries + search ─────────────────────────
                      ShowEntries(
                        initialSearch: _searchQuery,
                        initialEntries: _selectedEntries,
                        onSearchChanged: (v) =>
                            setState(() => _searchQuery = v),
                        onEntriesChanged: (v) =>
                            setState(() => _selectedEntries = v),
                      ),
                      SizedBox(height: 2.h),
                      // ─── Table ─────────────────────────────────────────
                      _buildTableSection(state),

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

  // ─── Table section ─────────────────────────────────────────────────────────
  Widget _buildTableSection(StaffState state) {
    // Loading
    if (state is StaffLoading) {
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

    // Error
    if (state is StaffError) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 2.w),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 18.sp),
              SizedBox(height: 1.h),
              Text(
                'Failed to load deleted staff.',
                style: AppTextStyle.medium(color: Colors.red),
              ),
              SizedBox(height: 1.5.h),
              GestureDetector(
                onTap: () => context.read<StaffCubit>().fetchDeletedStaff(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
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

    final List<StaffModel> rawList = state is StaffListLoaded
        ? state.staffList
        : [];

    final List<StaffModel> staffList = _filtered(rawList);
    final allFiltered = _filtered(rawList);
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
    final showFrom = totalCount == 0 ? 0 : (_currentPage - 1) * limit + 1;
    final showTo = (showFrom + pagedList.length - 1).clamp(0, totalCount);

    // ─── Populated table ──────────────────────────────────────────────────
    return Container(
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
          CustomTable(
            columns: [
              TableColumn(title: "No."),
              TableColumn(title: "Name"),
              TableColumn(title: "Phone Number"),
              TableColumn(title: "Designation"),
              TableColumn(title: "Delete Date"),
              TableColumn(title: "Action"),
            ],
            rows: pagedList.asMap().entries.map((entry) {
              final index = entry.key;
              final staff = entry.value;

              final deletedAt = staff.createdAt != null
                  ? '${staff.createdAt!.day.toString().padLeft(2, '0')}/'
                        '${staff.createdAt!.month.toString().padLeft(2, '0')}/'
                        '${staff.createdAt!.year}'
                  : '—';

              return [
                Text('${index + 1}', style: AppTextStyle.medium()),
                Text(
                  staff.name,
                  style: AppTextStyle.medium(),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(staff.phone, style: AppTextStyle.medium()),
                Text(staff.designation ?? '—', style: AppTextStyle.medium()),
                Text(deletedAt, style: AppTextStyle.medium()),
                // ─── Action: Restore button ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildActionButton(
                      icon: Icons.restore,
                      color: AppColors.green,
                      onTap: () => _confirmRestore(context, staff),
                    ),
                    SizedBox(width: 0.5.w),
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      color: Colors.red,
                      onTap: () => _confirmDelete(context, staff),
                    ),
                  ],
                ),
              ];
            }).toList(),
          ),

          /// 🔹 FOOTER
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      onTap: () => _goToPage(_currentPage - 1, totalCount),
                      child: const Icon(
                        Icons.chevron_left,
                        size: 16,
                        color: Color(0xff94A3B8),
                      ),
                    ),
                    ..._buildCustomPageNumbers(totalPages, totalCount),
                    _buildPaginationButton(
                      enabled: _currentPage < totalPages,
                      onTap: () => _goToPage(_currentPage + 1, totalCount),
                      child: const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Color(0xff94A3B8),
                      ),
                    ),
                    // if (selectedLeads.isNotEmpty) ...[
                    //   const SizedBox(width: 12),
                    //   GestureDetector(
                    //     onTap: () => _deleteSelectedLeads(
                    //       selectedLeads,
                    //     ),
                    //     child: Container(
                    //       padding: EdgeInsets.symmetric(
                    //         horizontal: 1.2.w,
                    //         vertical: 0.8.h,
                    //       ),
                    //       decoration: BoxDecoration(
                    //         color: const Color(
                    //           0xffEF4444,
                    //         ),
                    //         borderRadius:
                    //             BorderRadius.circular(6),
                    //       ),
                    //       child: Row(
                    //         mainAxisSize:
                    //             MainAxisSize.min,
                    //         children: [
                    //           Text(
                    //             "Selected Item",
                    //             style:
                    //                 AppTextStyle.medium(
                    //                   color: Colors.white,
                    //                   weight:
                    //                       FontWeight.w500,
                    //                   size: 9.sp,
                    //                 ),
                    //           ),
                    //           const SizedBox(width: 6),
                    //           const Icon(
                    //             Icons.delete_outline,
                    //             color: Colors.white,
                    //             size: 16,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}
