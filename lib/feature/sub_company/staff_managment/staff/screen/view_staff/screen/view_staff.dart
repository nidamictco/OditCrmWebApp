import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_text_style.dart';
import '../../../../../../../core/utils/footer.dart';
import '../../../../../../../core/utils/page_button.dart';
import '../../../../../../../core/utils/show_entries.dart';
import '../../../../../../../core/utils/staff_top_bar.dart';
import '../../../../../../../core/utils/table.dart';
import 'package:go_router/go_router.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import '../../../cubit/add_staff_cubit.dart';
import '../../../cubit/add_staff_state.dart';
import '../../../model/staff_model.dart';
import 'package:sizer/sizer.dart';

class ViewStaff extends StatefulWidget {
  const ViewStaff({super.key});

  @override
  State<ViewStaff> createState() => _ViewStaffState();
}

class _ViewStaffState extends State<ViewStaff> {
  bool isHovering = false;
  String _activeFilter = 'Active'; // 'All' | 'Active' | 'Inactive'
  String _searchQuery = '';
  String _selectedEntries = '10';

  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    context.read<StaffCubit>().fetchAll();
  }

  // ─── Filtering────────────────────────────────────────────────────

  List<StaffModel> _filtered(List<StaffModel> all) {
    List<StaffModel> result = all;

    // 1. Active/Inactive filter
    if (_activeFilter == 'Active') {
      result = result
          .where((s) => (s.status).toLowerCase() == 'active')
          .toList();
    } else if (_activeFilter == 'Inactive') {
      result = result
          .where((s) => (s.status).toLowerCase() != 'active')
          .toList();
    }

    // 2. Search query — matches name (extend with more fields as needed)
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (s) =>
                s.name.toLowerCase().contains(q) ||
                (s.phone.toLowerCase().contains(q)) ||
                (s.designation ?? '').toLowerCase().contains(q),
          )
          .toList();
    }

    // 3. Entries limit
    // final limit = int.tryParse(_selectedEntries) ?? 10;
    // return result.take(limit).toList();
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

  // ─── Delete confirmation dialog ────────────────────────────────────────────

  void _confirmDelete(BuildContext ctx, StaffModel staff) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Delete Staff', style: AppTextStyle.medium(size: 14.sp)),
        content: Text(
          'Are you sure you want to delete "${staff.name}"? This action cannot be undone.',
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
              // ctx.read<StaffCubit>().restoreStaff(staff);
              ctx.read<StaffCubit>().deleteStaff(staff.id!, staff);
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

  // ─── Status badge ──────────────────────────────────────────────────────────

  Widget _statusBadge(String? status) {
    final isActive = (status ?? '').toLowerCase() == 'active';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.6.w, vertical: 0.3.h),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.green.withOpacity(0.12)
            : AppColors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive
              ? AppColors.green.withOpacity(0.4)
              : AppColors.red.withOpacity(0.4),
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: AppTextStyle.small(
          size: 9.sp,
          color: isActive ? AppColors.green : AppColors.red,
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

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
          if (state is StaffDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Staff member deleted successfully.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is StaffSaved) {
            context.read<StaffCubit>().fetchAll();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                StaffTopBar(
                  title: 'Staff List',
                  current: 'View Staff',
                  parent: 'Staff Management',
                ),
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Add New button ─────────────────────────────────
                        Padding(
                          padding: EdgeInsets.only(
                            left: 2.w,
                            right: 2.w,
                            top: 2.h,
                            bottom: 1.h,
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 7.5.w,
                              height: 4.5.h,
                              child: MouseRegion(
                                onEnter: (_) =>
                                    setState(() => isHovering = true),
                                onExit: (_) =>
                                    setState(() => isHovering = false),
                                child: GestureDetector(
                                  onTap: () => context.go(RoutePaths.addStaff),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    height: 5.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.orange,
                                        width: 0.02.w,
                                      ),
                                      color: isHovering
                                          ? AppColors.orange
                                          : AppColors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Add New",
                                        style: AppTextStyle.small(
                                          color: isHovering
                                              ? Colors.white
                                              : AppColors.orange,
                                          size: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Divider(color: AppColors.divider),
                        SizedBox(height: 2.h),

                        // ─── Active / Inactive filter buttons ───────────────
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 1.h,
                          ),
                          child: BlocBuilder<StaffCubit, StaffState>(
                            builder: (context, state) {
                              final List<StaffModel> rawList =
                                  state is StaffListLoaded
                                  ? state.staffList
                                  : [];

                              final activeCount = rawList
                                  .where(
                                    (s) => s.status.toLowerCase() == 'active',
                                  )
                                  .length;
                              final inactiveCount = rawList
                                  .where(
                                    (s) => s.status.toLowerCase() != 'active',
                                  )
                                  .length;

                              return Row(
                                children: [
                                  _filterButton(
                                    label: 'Active',
                                    color: AppColors.green,
                                    isSelected: _activeFilter == 'Active',
                                    onTap: () => setState(
                                      () => _activeFilter = 'Active',
                                    ),
                                    count: activeCount, // 👈 pass count
                                  ),
                                  SizedBox(width: 0.6.w),
                                  _filterButton(
                                    label: 'Inactive',
                                    color: AppColors.red.withOpacity(0.9),
                                    isSelected: _activeFilter == 'Inactive',
                                    onTap: () => setState(
                                      () => _activeFilter = 'Inactive',
                                    ),
                                    count: inactiveCount, // 👈 pass count
                                  ),
                                ],
                              );
                            },
                          ),
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

                        _buildTableSection(state),
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

  // ─── Filter toggle button ──────────────────────────────────────────────────

  // Widget _filterButton({
  //   required String label,
  //   required Color color,
  //   required bool isSelected,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 150),
  //       height: 5.h,
  //       width: 6.w,
  //       decoration: BoxDecoration(
  //         color: isSelected ? color : color.withOpacity(0.65),
  //         border: Border.all(
  //           color: isSelected ? color : AppColors.divider,
  //           width: isSelected ? 2 : 1,
  //         ),
  //         borderRadius: BorderRadius.circular(6),
  //       ),
  //       child: Center(
  //         child: Text(
  //           label,
  //           style: AppTextStyle.small(color: Colors.white, size: 11.sp),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _filterButton({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required int count, // 👈 add this
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 5.h,
            width: 6.w,
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.65),
              border: Border.all(
                color: isSelected ? color : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyle.small(color: Colors.white, size: 11.sp),
              ),
            ),
          ),

          // 👇 Count badge at top-left
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: color,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
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
                'Failed to load staff data.',
                style: AppTextStyle.medium(color: Colors.red),
              ),
              SizedBox(height: 0.5.h),
              Text(
                state.message,
                style: AppTextStyle.small(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.5.h),
              GestureDetector(
                onTap: () => context.read<StaffCubit>().fetchAll(),
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

    // ─── Populated table ───────────────────────────────────────────────────
    return Column(
      children: [
        CustomTable(
          getRowDestination: (rowIndex) {
            final staff = pagedList[rowIndex];
            return RoutePaths.staffProfilePath(staff.id!);
          },
          onRowTap: (rowIndex) {
            final staff = pagedList[rowIndex];
            // log('stafff........$staff');
            context.push(RoutePaths.staffProfilePath(staff.id!));
          },
          columns: [
            TableColumn(title: "#", flex: 1),
            TableColumn(title: "Name", flex: 4),
            TableColumn(title: "Staff Type", flex: 4),
            TableColumn(title: "Status", flex: 4),
            TableColumn(title: "Phone Number", flex: 4),
            TableColumn(title: "Designation", flex: 4),
            TableColumn(title: "Joining Date", flex: 4),
            TableColumn(title: "Created At", flex: 4),
            TableColumn(title: "Action", flex: 2),
          ],
          rows: pagedList.asMap().entries.map((entry) {
            final index = entry.key;
            final staff = entry.value;
            final serial = (_currentPage - 1) * limit + index + 1;

            final createdAt = staff.createdAt != null
                ? '${staff.createdAt!.day.toString().padLeft(2, '0')}/'
                      '${staff.createdAt!.month.toString().padLeft(2, '0')}/'
                      '${staff.createdAt!.year}'
                : '—';

            return [
              Text('$serial', style: AppTextStyle.medium()),
              Text(
                staff.name,
                style: AppTextStyle.medium(),
                overflow: TextOverflow.ellipsis,
              ),
              Text(staff.staffType ?? '—', style: AppTextStyle.medium()),
              _statusBadge(staff.status),
              Text(staff.phone, style: AppTextStyle.medium()),
              Text(
                staff.designation ?? '—',
                style: AppTextStyle.medium(),
                overflow: TextOverflow.ellipsis,
              ),
              Text(staff.joiningDate ?? '—', style: AppTextStyle.medium()),
              Text(createdAt, style: AppTextStyle.medium()),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if(staff.designation != "Company_Admin")
                    GestureDetector( 
                      onTap: () =>
                          context.push(RoutePaths.staffEditPath(staff.id!)).then((_) {
                            if (context.mounted) {
                              context.read<StaffCubit>().fetchAll();
                            }
                          }),
                      child: Tooltip(
                        message: 'Edit',
                        child: Icon(
                          Icons.edit_outlined,
                          size: 13.sp,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          context.push(RoutePaths.staffProfilePath(staff.id!)).then((_) {
                            // ✅ Refresh the list when returning from profile screen
                            if (context.mounted) {
                              context.read<StaffCubit>().fetchAll();
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(0.1.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade900,
                            borderRadius: BorderRadius.circular(1),
                          ),
                          child: Tooltip(
                            message: 'View profile',
                            child: Icon(
                              Icons.ads_click_outlined,
                              size: 10.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 0.1.w),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          context.push(RoutePaths.changePasswordPath(staff.id!)).then((_) {
                            if (context.mounted) {
                              context.read<StaffCubit>().fetchAll();
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(0.1.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(1),
                          ),
                          child: Tooltip(
                            message: 'Change Password',
                            child: Icon(
                              Icons.vpn_key_outlined,
                              size: 10.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (staff.designation != "Company_Admin")
                      GestureDetector(
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
                  ],
                ),
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
