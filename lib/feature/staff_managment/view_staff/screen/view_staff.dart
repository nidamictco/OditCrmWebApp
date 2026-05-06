import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/footer.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/staff_top_bar.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:oxdo/feature/staff_managment/add_staff/cubit/add_staff_cubit.dart';
import 'package:oxdo/feature/staff_managment/add_staff/cubit/add_staff_state.dart';
import 'package:oxdo/feature/staff_managment/add_staff/model/staff_model.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<StaffCubit>().fetchAll();
  }

  // ─── Filtering pipeline ────────────────────────────────────────────────────
  // FIX: single method applies all three filters in order:
  //   1. status (Active / Inactive / All)
  //   2. search query (name)
  //   3. entries limit
  List<StaffModel> _filtered(List<StaffModel> all) {
    List<StaffModel> result = all;

    // 1. Active/Inactive filter
    if (_activeFilter == 'Active') {
      result = result
          .where((s) => (s.staffType ?? '').toLowerCase() == 'active')
          .toList();
    } else if (_activeFilter == 'Inactive') {
      result = result
          .where((s) => (s.staffType ?? '').toLowerCase() != 'active')
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
    final limit = int.tryParse(_selectedEntries) ?? 10;
    return result.take(limit).toList();
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
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MainScreen(selectedIndex: 15),
                                    ),
                                  ),
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
                          child: Row(
                            children: [
                              _filterButton(
                                label: 'Active',
                                color: AppColors.green,
                                isSelected: _activeFilter == 'Active',
                                onTap: () => setState(
                                  () =>
                                      _activeFilter = _activeFilter == 'Active'
                                      ? 'All'
                                      : 'Active',
                                ),
                              ),
                              SizedBox(width: 0.6.w),
                              _filterButton(
                                label: 'Inactive',
                                color: AppColors.red,
                                isSelected: _activeFilter == 'Inactive',
                                onTap: () => setState(
                                  () => _activeFilter =
                                      _activeFilter == 'Inactive'
                                      ? 'All'
                                      : 'Inactive',
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // ✅ Callbacks write into parent state so _filtered() works
                        ShowEntries(
                          initialSearch: _searchQuery,
                          initialEntries: _selectedEntries,
                          onSearchChanged: (v) =>
                              setState(() => _searchQuery = v),
                          onEntriesChanged: (v) =>
                              setState(() => _selectedEntries = v),
                        ),

                        _buildTableSection(state),

                        Footer(),
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

  Widget _filterButton({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 5.h,
        width: 6.w,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.8),
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

    // StaffDeleted only carries deletedId — the cubit calls fetchAll() after
    // deletion which emits StaffListLoaded, so we only read the list from there.
    final List<StaffModel> rawList = state is StaffListLoaded
        ? state.staffList
        : [];

    // ✅ _filtered() applies status + search + limit in one pass
    final List<StaffModel> staffList = _filtered(rawList);

    // Empty state
    if (staffList.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                color: Colors.grey.shade400,
                size: 20.sp,
              ),
              SizedBox(height: 1.h),
              Text(
                'No staff members found.',
                style: AppTextStyle.medium(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    // ─── Populated table ───────────────────────────────────────────────────
    return CustomTable(
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
      rows: staffList.asMap().entries.map((entry) {
        final index = entry.key;
        final staff = entry.value;

        final createdAt = staff.createdAt != null
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
          Text(staff.staffType ?? '—', style: AppTextStyle.medium()),
          _statusBadge(staff.staffType),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MainScreen(selectedIndex: 15, staff: staff),
                      ),
                    ),
                    child: Tooltip(
                      message: 'Edit',
                      child: Icon(
                        Icons.edit_outlined,
                        size: 14.sp,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 0.4.w),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(selectedIndex: 29),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(0.1.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade900,
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: Icon(
                        Icons.ads_click_outlined, 
                        size: 10.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 0.4.w),
                MouseRegion(
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
              ],
            ),
          ),
        ];
      }).toList(),
    );
  }
}
