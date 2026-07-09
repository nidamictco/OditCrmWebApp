import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_style.dart';
import '../../../../../core/utils/footer.dart';
import '../../../../../core/utils/page_button.dart';
import '../../../../../core/utils/show_entries.dart';
import '../../../../../core/utils/staff_top_bar.dart';
import '../../../../../core/utils/table.dart';
import 'package:go_router/go_router.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/core/router/browser_aware_link.dart';
import '../cubit/designation_cubit.dart';
import '../model/designation_model.dart';
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

  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;

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
    return filtered;
  }

  List<DesignationModel> _pagedLeads(List<DesignationModel> allFiltered) {
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
                            child: BrowserAwareLink(
                              destination: RoutePaths.designationPermissionsPath("new"),
                              onTap: () async {
                                await context.push(RoutePaths.designationPermissionsPath("new"));
                                if (context.mounted) {
                                  context.read<DesignationCubit>().fetchAll();
                                }
                              },
                              usePush: true,
                              enableInkWell: false,
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
                          final allFiltered = _filtered(state.designations);
                          final totalCount = allFiltered.length;
                          final totalPages = _totalPages(totalCount);
                          final limit = int.tryParse(_selectedEntries) ?? 10;

                          if (_currentPage > totalPages) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() => _currentPage = totalPages);
                            });
                          }
                          final pagedList = _pagedLeads(allFiltered);
                          final showFrom = totalCount == 0
                              ? 0
                              : (_currentPage - 1) * limit + 1;
                          final showTo = (showFrom + pagedList.length - 1)
                              .clamp(0, totalCount);

                          final rows = pagedList.asMap().entries.map((entry) {
                            final index =
                                (_currentPage - 1) * limit + entry.key + 1;
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
                                    BrowserAwareLink(
                                      destination: RoutePaths.designationPermissionsPath(designation.id!),
                                      onTap: () async {
                                        await context.push(RoutePaths.designationPermissionsPath(designation.id!));
                                        if (context.mounted) {
                                          context
                                              .read<DesignationCubit>()
                                              .fetchAll();
                                        }
                                      },
                                      usePush: true,
                                      enableInkWell: false,
                                      child: Icon(
                                        Icons.edit_outlined,
                                        size: 14.sp,
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
                                        size: 14.sp,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ];
                          }).toList();

                          return Column(
                            children: [
                              CustomTable(
                                columns: [
                                  TableColumn(title: "#", flex: 1),
                                  TableColumn(title: "Designation", flex: 4),
                                  TableColumn(title: "Action", flex: 2),
                                ],
                                rows: rows,
                              ),

                              /// 🔹 FOOTER
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
                            ],
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
            style: AppTextStyle.small(size: 11.sp, color: AppColors.white),
          ),
        ),
      ),
    ];
  }
}
