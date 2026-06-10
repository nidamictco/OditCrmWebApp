import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/footer.dart';
import 'package:oxdo/core/utils/page_button.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/staff_top_bar.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/feature/sub_company/sidebar/main_screen.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/cubit/add_staff_state.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/model/staff_model.dart';
import 'package:sizer/sizer.dart';

class StaffReports extends StatefulWidget {
  const StaffReports({super.key});

  @override
  State<StaffReports> createState() => _StaffReportsState();
}

class _StaffReportsState extends State<StaffReports> {
  bool isHovering = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StaffTopBar(
              title: 'Staff Reports',
              parent: 'Staff Management',
              current: 'Staff Reports',
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
                  children: [
                    ///TITLE BAR
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
                                        MainScreen(selectedIndex: 15),
                                  ),
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                height: 5.h,
                                // padding: EdgeInsets.symmetric(horizontal: 3.w),
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
                    BlocBuilder<StaffCubit, StaffState>(
                      builder: (context, state) {
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
                            padding: EdgeInsets.symmetric(
                              vertical: 6.h,
                              horizontal: 2.w,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 18.sp,
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'Failed to load staff data.',
                                    style: AppTextStyle.medium(
                                      color: Colors.red,
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    state.message,
                                    style: AppTextStyle.small(
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 1.5.h),
                                  GestureDetector(
                                    onTap: () =>
                                        context.read<StaffCubit>().fetchAll(),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.w,
                                        vertical: 0.8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.orange.withOpacity(
                                          0.1,
                                        ),
                                        border: Border.all(
                                          color: AppColors.orange,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Retry',
                                        style: AppTextStyle.small(
                                          color: AppColors.orange,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        //  final List<StaffModel> rawList = state is StaffListLoaded
                        //       ? state.staffList
                        //       : [];

                        //   final List<StaffModel> staffList = _filtered(rawList);

                        final List<StaffModel> rawList =
                            state is StaffListLoaded ? state.staffList : [];

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
                        final showFrom = totalCount == 0
                            ? 0
                            : (_currentPage - 1) * limit + 1;
                        final showTo = (showFrom + pagedList.length - 1).clamp(
                          0,
                          totalCount,
                        );

                        return Column(
                          children: [
                            SizedBox(
                              child: CustomTable(
                                columns: [
                                  TableColumn(title: "#", flex: 1),
                                  TableColumn(title: "Name", flex: 4),
                                  TableColumn(title: "Phone Number", flex: 4),
                                  TableColumn(title: "Designation", flex: 4),
                                  TableColumn(title: "Action", flex: 2),
                                ],
                                rows: pagedList.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final staff = entry.value;
                                  final serial =
                                      (_currentPage - 1) * limit + index + 1;
                                  return [
                                    Text(
                                      '$serial',
                                      style: AppTextStyle.medium(),
                                    ),
                                    Text(
                                      staff.name,
                                      style: AppTextStyle.medium(),
                                    ),
                                    Text(
                                      staff.phone,
                                      style: AppTextStyle.medium(),
                                    ),
                                    Text(
                                      staff.designation ?? '---',
                                      style: AppTextStyle.medium(),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MainScreen(
                                              selectedIndex: 29,
                                              staff: staff,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(0.1.w),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade900,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.ads_click_outlined,
                                          size: 12.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ];
                                }).toList(),
                              ),
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
