import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/footer.dart';
import 'package:oxdo/core/utils/input_date.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/feature/staff_managment/add_staff/cubit/add_staff_cubit.dart';
import 'package:oxdo/feature/staff_managment/add_staff/cubit/add_staff_state.dart';
import 'package:oxdo/feature/staff_managment/add_staff/model/staff_model.dart';
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

    // Entries limit
    final limit = int.tryParse(_selectedEntries) ?? 10;
    return result.take(limit).toList();
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

                        Footer(),
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

    // Empty state
    if (staffList.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.grey.shade400,
                size: 20.sp,
              ),
              SizedBox(height: 1.h),
              Text(
                'No deleted staff found.',
                style: AppTextStyle.medium(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    // ─── Populated table ──────────────────────────────────────────────────
    return CustomTable(
      columns: [
        TableColumn(title: "#", flex: 1),
        TableColumn(title: "Name", flex: 4),
        TableColumn(title: "Phone Number", flex: 4),
        TableColumn(title: "Designation", flex: 4),
        TableColumn(title: "Delete Date", flex: 4),
        TableColumn(title: "Action", flex: 2),
      ],
      rows: staffList.asMap().entries.map((entry) {
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
            mainAxisAlignment: MainAxisAlignment.center,
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
                        color: Colors.green,
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
    );
  }
}
