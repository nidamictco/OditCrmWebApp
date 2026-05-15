import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/footer.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/staff_top_bar.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:oxdo/feature/staff_managment/designation/cubit/designation_cubit.dart';
import 'package:oxdo/feature/staff_managment/designation/model/designation_model.dart';
import 'package:sizer/sizer.dart';

class DesignationScreen extends StatefulWidget {
  const DesignationScreen({super.key});

  @override
  State<DesignationScreen> createState() => _DesignationScreenState();
}

class _DesignationScreenState extends State<DesignationScreen> {
  bool isHovering = false;
  String _selectedEntries = '10';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<DesignationCubit>().fetchAll();
  }

  // ─── Filtered list based on search + entries limit ────────────────────────
  List<DesignationModel> _filtered(List<DesignationModel> all) {
    final q = _searchQuery.trim().toLowerCase();
    final limit = int.tryParse(_selectedEntries) ?? 10;
    final filtered = q.isEmpty
        ? all
        : all
              .where((e) => e.designationName.toLowerCase().contains(q))
              .toList();
    return filtered.take(limit).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StaffTopBar(
              title: 'Designation',
              current: 'Designation',
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
                    /// 🔹 Add New Button
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
                            onEnter: (_) => setState(() => isHovering = true),
                            onExit: (_) => setState(() => isHovering = false),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MainScreen(selectedIndex: 27),
                                  ),
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.orange,
                                    width: 0.02.w,
                                  ),
                                  color: isHovering
                                      ? AppColors.orange
                                      : AppColors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
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
                    ShowEntries(
                      initialEntries: _selectedEntries,
                      initialSearch: _searchQuery,
                      onEntriesChanged: (value) {
                        setState(() {
                          _selectedEntries = value;
                        });
                      },
                      onSearchChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),

                    /// 🔹 Table Section
                    BlocConsumer<DesignationCubit, DesignationState>(
                      listener: (context, state) {
                        if (state is DesignationError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${state.message}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        /// 🔄 Loading
                        if (state is DesignationLoading) {
                          return SizedBox(
                            height: 20.h,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        /// ✅ Data Loaded
                        if (state is DesignationListLoaded) {
                          final filtered = _filtered(state.designations);

                          if (filtered.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              child: Center(
                                child: Text(
                                  'No designations found.',
                                  style: AppTextStyle.medium(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            );
                          }
                          final rows = filtered.asMap().entries.map((entry) {
                            final index = entry.key + 1;
                            final designation = entry.value;

                            return [
                              Text('$index', style: AppTextStyle.medium()),
                              Text(
                                designation.designationName,
                                style: AppTextStyle.medium(),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    /// ✏️ Edit
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider.value(
                                              value: context
                                                  .read<DesignationCubit>(),
                                              child: MainScreen(
                                                selectedIndex: 27,
                                                designation: designation,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.edit_outlined,
                                        size: 13.sp,
                                        color: Colors.blue,
                                      ),
                                    ),

                                    SizedBox(width: 0.5.w),

                                    /// 🗑 Delete
                                    GestureDetector(
                                      onTap: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            backgroundColor: AppColors.white,
                                            title: const Text(
                                              'Delete Designation',
                                            ),
                                            content: Text(
                                              'Are you sure you want to delete "${designation.designationName}"?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true &&
                                            context.mounted) {
                                          context
                                              .read<DesignationCubit>()
                                              .deleteDesignation(
                                                designation.id!,
                                              );
                                        }
                                      },

                                      child: Icon(
                                        Icons.delete_outline,
                                        size: 13.sp,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ];
                          }).toList();

                          return CustomTable(
                            columns: [
                              TableColumn(title: "#", flex: 1),
                              TableColumn(title: "Designation", flex: 4),
                              TableColumn(title: "Action", flex: 2),
                            ],
                            rows: rows,
                          );
                        }

                        /// ❌ Error UI
                        if (state is DesignationError) {
                          return Center(child: Text('Error: ${state.message}'));
                        }

                        /// 💤 Initial state
                        return const SizedBox();
                      },
                    ),

                    Footer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
