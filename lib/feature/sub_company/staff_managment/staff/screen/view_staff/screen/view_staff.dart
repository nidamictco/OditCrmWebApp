import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/cubit/designation_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/screen/add_staff/screen/add_staff.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/screen/view_staff/addStaffButton.dart';
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
import 'package:Odit_CRM/core/router/browser_aware_link.dart';
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
  String _activeFilter = 'All'; // 'All' | 'Active' | 'Inactive'
  String _searchQuery = '';
  String _selectedEntries = '10';

  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;
  List<StaffModel> _cachedStaffList = [];

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
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Delete Staff', style: AppTextStyle.medium(size: 14.sp)),
        content: Text(
          'Are you sure you want to delete "${staff.name}"? This action cannot be undone.',
          style: AppTextStyle.medium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTextStyle.medium(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
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
    return SizedBox(
      // padding: EdgeInsets.symmetric(horizontal: 0.6.w, vertical: 0.3.h),
      // decoration: BoxDecoration(
      //   color: isActive
      //       ? AppColors.green.withOpacity(0.12)
      //       : AppColors.red.withOpacity(0.12),
      //   borderRadius: BorderRadius.circular(4),
      //   border: Border.all(
      //     color: isActive
      //         ? AppColors.green.withOpacity(0.4)
      //         : AppColors.red.withOpacity(0.4),
      //   ),
      // ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: AppTextStyle.medium(
          size: 11.5,
          color: isActive ? AppColors.green : AppColors.red,
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

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
          if (state is StaffDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Staff member deleted successfully.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is StaffListLoaded) {
            _cachedStaffList = state.staffList;
          }
          if (state is StaffSaved) {
            context.read<StaffCubit>().fetchAll();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // StaffTopBar(
                //   title: 'Staff List',
                //   current: 'View Staff',
                //   parent: 'Staff Management',
                // ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Add New button ─────────────────────────────────
                      // Padding(
                      //   padding: EdgeInsets.only(
                      //     left: 2.w,
                      //     right: 2.w,
                      //     top: 2.h,
                      //     bottom: 1.h,
                      //   ),
                      //   child: Align(
                      //     alignment: Alignment.centerRight,
                      //     child: SizedBox(
                      //       width: 7.5.w,
                      //       height: 4.5.h,
                      //       child: MouseRegion(
                      //         onEnter: (_) =>
                      //             setState(() => isHovering = true),
                      //         onExit: (_) =>
                      //             setState(() => isHovering = false),
                      //         child: BrowserAwareLink(
                      //           destination: RoutePaths.addStaff,
                      //           usePush: false,
                      //           enableInkWell: false,
                      //           child: AnimatedContainer(
                      //             duration: const Duration(milliseconds: 200),
                      //             curve: Curves.easeInOut,
                      //             height: 5.h,
                      //             decoration: BoxDecoration(
                      //               border: Border.all(
                      //                 color: AppColors.orange,
                      //                 width: 0.02.w,
                      //               ),
                      //               color: isHovering
                      //                   ? AppColors.orange
                      //                   : AppColors.orange.withOpacity(0.1),
                      //               borderRadius: BorderRadius.circular(4),
                      //             ),
                      //             child: Center(
                      //               child: Text(
                      //                 "Add New",
                      //                 style: AppTextStyle.small(
                      //                   color: isHovering
                      //                       ? Colors.white
                      //                       : AppColors.orange,
                      //                   size: 10.sp,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Divider(color: AppColors.divider),
                      // SizedBox(height: 2.h),

                      // // ─── Active / Inactive filter buttons ───────────────
                      // Padding(
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: 2.w,
                      //     vertical: 1.h,
                      //   ),
                      //   child: BlocBuilder<StaffCubit, StaffState>(
                      //     builder: (context, state) {
                      //       final List<StaffModel> rawList =
                      //           state is StaffListLoaded
                      //           ? state.staffList
                      //           : [];

                      //       final activeCount = rawList
                      //           .where(
                      //             (s) => s.status.toLowerCase() == 'active',
                      //           )
                      //           .length;
                      //       final inactiveCount = rawList
                      //           .where(
                      //             (s) => s.status.toLowerCase() != 'active',
                      //           )
                      //           .length;

                      //       return Row(
                      //         children: [
                      //           _filterButton(
                      //             label: 'Active',
                      //             color: AppColors.green,
                      //             isSelected: _activeFilter == 'Active',
                      //             onTap: () => setState(
                      //               () => _activeFilter = 'Active',
                      //             ),
                      //             count: activeCount, // 👈 pass count
                      //           ),
                      //           SizedBox(width: 0.6.w),
                      //           _filterButton(
                      //             label: 'Inactive',
                      //             color: AppColors.red.withOpacity(0.9),
                      //             isSelected: _activeFilter == 'Inactive',
                      //             onTap: () => setState(
                      //               () => _activeFilter = 'Inactive',
                      //             ),
                      //             count: inactiveCount, // 👈 pass count
                      //           ),
                      //         ],
                      //       );
                      //     },
                      //   ),
                      // ),
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
                        middleWidget: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          child: BlocBuilder<StaffCubit, StaffState>(
                            builder: (context, state) {
                              final List<StaffModel> rawList =
                                  state is StaffListLoaded
                                  ? state.staffList
                                  : _cachedStaffList;

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

                              final activeStr = activeCount < 10
                                  ? '0$activeCount'
                                  : '$activeCount';
                              final inactiveStr = inactiveCount < 10
                                  ? '0$inactiveCount'
                                  : '$inactiveCount';

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _filterButton(
                                    label: 'All',
                                    isSelected: _activeFilter == 'All',
                                    onTap: () => setState(() {
                                      _activeFilter = 'All';
                                      _resetPage();
                                    }),
                                  ),
                                  SizedBox(width: 0.5.w),
                                  _filterButton(
                                    label: 'Active ($activeStr)',
                                    isSelected: _activeFilter == 'Active',
                                    onTap: () => setState(() {
                                      _activeFilter = 'Active';
                                      _resetPage();
                                    }),
                                  ),
                                  SizedBox(width: 0.5.w),
                                  _filterButton(
                                    label: 'Inactive ($inactiveStr)',
                                    isSelected: _activeFilter == 'Inactive',
                                    onTap: () => setState(() {
                                      _activeFilter = 'Inactive';
                                      _resetPage();
                                    }),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        exportWidget: AddNewStaffButton(),
                      ),
                      SizedBox(height: 13),
                      _buildTableSection(state),
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
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const selectedBg = Color(0xFF002660);
    const unselectedBorder = Color(0xFF8798B0);
    const unselectedText = Color(0xFF002660);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 0.8.w, vertical: 0.7.h),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.white,
            border: Border.all(
              color: isSelected
                  ? selectedBg
                  : unselectedBorder.withValues(alpha: 0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyle.medium(
                color: isSelected ? Colors.white : unselectedText,
                size: 11.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Table section ─────────────────────────────────────────────────────────

  Widget _buildTableSection(StaffState state) {
    // Loading (only show big spinner if we have no cached data)
    if (state is StaffLoading && _cachedStaffList.isEmpty) {
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
    if (state is StaffError && _cachedStaffList.isEmpty) {
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
        : _cachedStaffList;

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
    return Container(
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
          CustomTable(
            minWidth: MediaQuery.of(context).size.width,
            getRowDestination: (rowIndex) {
              final staff = pagedList[rowIndex];
              return RoutePaths.staffProfilePath(staff.id!,fromScreen: 'viewStaff');
            },
            onRowTap: (rowIndex) {
              final staff = pagedList[rowIndex];
              // log('stafff........$staff');
              context.push(RoutePaths.staffProfilePath(staff.id!,fromScreen: 'viewStaff'));
            },
            columns: [
              TableColumn(title: "No.", flex: 1),
              TableColumn(title: "Name", flex: 4),
              TableColumn(title: "Designation", flex: 4),
              TableColumn(title: "Staff Type", flex: 4),
              TableColumn(title: "Contact No.", flex: 3),
              TableColumn(title: "Created Date", flex: 3),
              TableColumn(title: "Joining Date", flex: 3),
              TableColumn(title: "Status", flex: 3),
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
                Text('$serial', style: AppTextStyle.medium(fontSize: 11.5)),
                Text(
                  staff.name,
                  style: AppTextStyle.medium(fontSize: 11.5),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  staff.designation ?? '—',
                  style: AppTextStyle.medium(fontSize: 11.5),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  staff.staffType ?? '—',
                  style: AppTextStyle.medium(fontSize: 11.5),
                ),
                Text(staff.phone, style: AppTextStyle.medium(fontSize: 11.5)),
                Text(createdAt, style: AppTextStyle.medium(fontSize: 11.5)),
                Text(
                  staff.joiningDate ?? '—',
                  style: AppTextStyle.medium(fontSize: 11.5),
                ),
                _statusBadge(staff.status),
                //action buttons
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (staff.designation != "Company_Admin")
                        GestureDetector(
                          onTap: () {
                            final staffCubit = context.read<StaffCubit>();
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (dialogContext) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: staffCubit),
                                  BlocProvider(
                                    create: (_) => DesignationCubit()..fetchAll(),
                                  ),
                                ],
                                child: AddStaff(staff: staff),
                              ),
                            );
                          },
                          child: Tooltip(
                            message: 'Edit',
                            child: Icon(
                              Icons.edit_outlined,
                              size: 13.sp,
                              color: Colors.blue,
                            ),
                          ),
                        ),
      
                      // Center(
                      //   child: BrowserAwareLink(
                      //     destination: RoutePaths.staffProfilePath(staff.id!),
                      //     onTap: () {
                      //       context
                      //           .push(RoutePaths.staffProfilePath(staff.id!))
                      //           .then((_) {
                      //             // ✅ Refresh the list when returning from profile screen
                      //             if (context.mounted) {
                      //               context.read<StaffCubit>().fetchAll();
                      //             }
                      //           });
                      //     },
                      //     usePush: true,
                      //     enableInkWell: false,
                      //     child: Container(
                      //       padding: EdgeInsets.all(0.1.w),
                      //       decoration: BoxDecoration(
                      //         color: Colors.blue.shade900,
                      //         borderRadius: BorderRadius.circular(1),
                      //       ),
                      //       child: Tooltip(
                      //         message: 'View profile',
                      //         child: Icon(
                      //           Icons.ads_click_outlined,
                      //           size: 10.sp,
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(width: 0.1.w),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            context
                                .push(RoutePaths.changePasswordPath(staff.id!))
                                .then((_) {
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
                  "SHOWING $showFrom TO $showTo OF $totalCount ENTRIES",
                  style: AppTextStyle.medium(
                    size: 11,
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
                  ],
                ),
              ],
            ),
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
            style: AppTextStyle.small(size: 11.5, color: AppColors.white),
          ),
        ),
      ),
    ];
  }
}
