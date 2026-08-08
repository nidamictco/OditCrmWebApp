import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
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
      backgroundColor: AppThemeColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          child: Column(
            children: [
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
                exportWidget: SizedBox(
                  // width: 7.5.w,
                  // height: 4.5.h,
                  child: MouseRegion(
                    onEnter: (_) => setState(() => isHovering = true),
                    onExit: (_) => setState(() => isHovering = false),
                    child: BrowserAwareLink(
                      destination: RoutePaths.designationPermissionsPath("new"),
                      onTap: () async {
                        await context.push(
                          RoutePaths.designationPermissionsPath("new"),
                        );
                        if (context.mounted) {
                          context.read<DesignationCubit>().fetchAll();
                        }
                      },
                      usePush: true,
                      enableInkWell: false,
                      child: AnimatedContainer(
                        padding: EdgeInsets.all(0.5.w),
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: AppThemeColors.basicGreen,
                          border: Border.all(
                            color: AppThemeColors.basicGreen,
                            width: 0.02.w,
                          ),
                          // color: isHovering
                          //     ? AppThemeColors.basicGreen
                          //     : AppThemeColors.basicGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                "Designation",
                                style: AppTextStyle.small(
                                  color: Colors.white,
                                  size: 10.sp,
                                ),
                              ),
                            ),
                            Image.asset(
                              AssetResources.designation,
                              height: 2.h,
                              width: 2.w,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

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
                      child: const Center(child: CircularProgressIndicator()),
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
                    final showTo = (showFrom + pagedList.length - 1).clamp(
                      0,
                      totalCount,
                    );

                    final rows = pagedList.asMap().entries.map((entry) {
                      final index = (_currentPage - 1) * limit + entry.key + 1;
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
                              // BrowserAwareLink(
                              //   destination:
                              //       RoutePaths.designationPermissionsPath(
                              //         designation.id!,
                              //       ),
                              //   onTap: () async {
                              //     await context.push(
                              //       RoutePaths.designationPermissionsPath(
                              //         designation.id!,
                              //       ),
                              //     );
                              //     if (context.mounted) {
                              //       context.read<DesignationCubit>().fetchAll();
                              //     }
                              //   },
                              //   usePush: true,
                              //   enableInkWell: false,
                              //   child: Icon(
                              //     Icons.edit_outlined,
                              //     size: 14.sp,
                              //     color: Colors.blue,
                              //   ),
                              // ),
                              BrowserAwareLink(
                                destination:
                                    RoutePaths.designationPermissionsPath(
                                      designation.id!,
                                    ),
                                usePush: true,
                                enableInkWell: false,
                                child: _buildActionButton(
                                  icon: Icons.edit_outlined,
                                  color: Colors.blue,
                                  // onTap: () => _confirmRestore(context, staff),
                                  onTap: () async {
                                    await context.push(
                                      RoutePaths.designationPermissionsPath(
                                        designation.id!,
                                      ),
                                    );
                                    if (context.mounted) {
                                      context
                                          .read<DesignationCubit>()
                                          .fetchAll();
                                    }
                                  },
                                ),
                              ),

                              SizedBox(width: 0.5.w),

                              /// 🗑 Delete
                              // GestureDetector(

                              //   child: Icon(
                              //     Icons.delete_outline,
                              //     size: 14.sp,
                              //     color: Colors.red,
                              //   ),
                              // ),
                              _buildActionButton(
                                icon: Icons.delete_outline,
                                color: Colors.red,
                                // onTap: () => _confirmDelete(context, staff),
                                onTap: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: AppColors.white,
                                      title: const Text('Delete Designation'),
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
                                          onPressed: () {
                                            Navigator.pop(ctx, true);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor: AppColors.red,
                                                content: Text(
                                                  'Designation "${designation.designationName}" deleted!',
                                                ),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true && context.mounted) {
                                    context
                                        .read<DesignationCubit>()
                                        .deleteDesignation(designation.id!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ];
                    }).toList();

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
                            columns: [
                              TableColumn(title: "Sl No."),
                              TableColumn(title: "Designation"),
                              TableColumn(title: "Action"),
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
                                      onTap: () => _goToPage(
                                        _currentPage - 1,
                                        totalCount,
                                      ),
                                      child: const Icon(
                                        Icons.chevron_left,
                                        size: 16,
                                        color: Color(0xff94A3B8),
                                      ),
                                    ),
                                    ..._buildCustomPageNumbers(
                                      totalPages,
                                      totalCount,
                                    ),
                                    _buildPaginationButton(
                                      enabled: _currentPage < totalPages,
                                      onTap: () => _goToPage(
                                        _currentPage + 1,
                                        totalCount,
                                      ),
                                      child: const Icon(
                                        Icons.chevron_right,
                                        size: 16,
                                        color: Color(0xff94A3B8),
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

                  /// ❌ Error UI
                  if (state is DesignationError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  /// 💤 Initial state
                  return const SizedBox();
                },
              ),
              // ],
              // ),
              // ),
              // ),
            ],
          ),
        ),
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
