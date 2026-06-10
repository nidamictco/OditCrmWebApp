import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/footer.dart';
import 'package:oxdo/core/utils/page_button.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/cubit/add_staff_state.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/model/staff_model.dart';
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
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Restore Staff', style: AppTextStyle.medium(size: 14.sp)),
        content: Text(
          'Restore "${staff.name}" back to active staff?',
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
              ctx.read<StaffCubit>().restoreStaff(staff);
            },
            child: Text(
              'Restore',
              style: AppTextStyle.medium(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, StaffModel staff) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Delete Staff', style: AppTextStyle.medium(size: 14.sp)),
        content: Text(
          'Delete "${staff.name}" permanently?',
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
              ctx.read<StaffCubit>().deleteStaffPermanently(
                staff.id ?? '',
              ); // see cubit addition below
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                TopBreadcrumbBar(
                  subTitle: 'Deleted Staff',
                  title: 'Staff Management',
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Title bar ─────────────────────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 2.h,
                          ),
                          child: Text(
                            "Deleted Staff",
                            style: AppTextStyle.medium(
                              size: 13.6.sp,
                              color: AppColors.black.withOpacity(0.77),
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Divider(color: AppColors.divider),

                        // ─── Show entries + search ─────────────────────────
                        ShowEntries(
                          initialSearch: _searchQuery,
                          initialEntries: _selectedEntries,
                          onSearchChanged: (v) =>
                              setState(() => _searchQuery = v),
                          onEntriesChanged: (v) =>
                              setState(() => _selectedEntries = v),
                        ),

                        // ─── Table ─────────────────────────────────────────
                        _buildTableSection(state),

                        SizedBox(height: 2.h),
                      ],
                    ),
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
    return Column(
      children: [
        CustomTable(
          columns: [
            TableColumn(title: "#", flex: 1),
            TableColumn(title: "Name", flex: 4),
            TableColumn(title: "Phone Number", flex: 4),
            TableColumn(title: "Designation", flex: 4),
            TableColumn(title: "Delete Date", flex: 4),
            TableColumn(title: "Action", flex: 2),
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
                  Center(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _confirmRestore(context, staff),
                        child: Tooltip(
                          message: 'Restore',
                          child: Icon(
                            Icons.restore,
                            size: 14.sp,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 0.5.w),
                  Center(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _confirmDelete(context, staff),
                        child: Tooltip(
                          message: 'Delete',
                          child: Icon(
                            Icons.delete_outline,
                            size: 14.sp,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
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
                "Showing $showFrom to $showTo of $totalCount entries",
                style: AppTextStyle.medium(weight: FontWeight.w400),
              ),
              Row(
                children: [
                  PageButton(
                    label: 'Previous',
                    enabled: _currentPage > 1,
                    isLeft: true,
                    onTap: () => _goToPage(_currentPage - 1, totalCount),
                  ),
                  ..._buildPageNumbers(totalPages, totalCount),
                  PageButton(
                    label: 'Next',
                    enabled: _currentPage < totalPages,
                    isRight: true,
                    onTap: () => _goToPage(_currentPage + 1, totalCount),
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
