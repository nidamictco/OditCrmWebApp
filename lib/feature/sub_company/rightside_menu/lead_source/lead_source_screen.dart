import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/page_button.dart';
import 'package:oxdo/core/utils/popup_msg.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/feature/rightside_menu/common_model/lead_model.dart';
import 'package:oxdo/feature/rightside_menu/lead_source/cubit/lead_source_cubit.dart';
import 'package:oxdo/feature/rightside_menu/lead_source/cubit/lead_source_state.dart';
import 'package:sizer/sizer.dart';

class LeadSourceScreen extends StatefulWidget {
  const LeadSourceScreen({super.key});

  @override
  State<LeadSourceScreen> createState() => _LeadSourceScreenState();
}

class _LeadSourceScreenState extends State<LeadSourceScreen> {
  bool isHovering = false;

  final TextEditingController sourceController = TextEditingController();

  // String selectedValue = "10";
  // final List<String> dropdownItems = ["10", "25", "50", "100"];

  // ─── search query (wired to the search box) ───────────────────────────────
  String _searchQuery = '';
  String _selectedEntries = '10';
  
  List<int> _selectedIndices = [];
  int _tableKey = 0;
  int _currentPage = 1;


  @override
  void initState() {
    super.initState();
    // Start the real-time Firestore listener
    context.read<LeadSourceCubit>().watchSources();
  }

  @override
  void dispose() {
    sourceController.dispose();
    super.dispose();
  }

  // ─── Filtered list based on search + entries limit ────────────────────────
  List<LeadsModel> _filtered(List<LeadsModel> all) {
    final q = _searchQuery.trim().toLowerCase();
    final limit = int.tryParse(_selectedEntries) ?? 10;
    final filtered = q.isEmpty
        ? all
        : all
              .where(
                (e) =>
                    e.name.toLowerCase().contains(q) ||
                    e.createdBy.toLowerCase().contains(q),
              )
              .toList();
    return filtered;
  }

  
  List<LeadsModel> _pagedLeads(List<LeadsModel> allFiltered) {
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

  // ─── Dialogs ──────────────────────────────────────────────────────────────

  void _showAddDialog() {
    sourceController.clear();

    showDialog(
      context: context,
      builder: (ctx) {
        return AppDialog(
          title: 'Add Lead Source',
          width: 35.w,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Lead Category
                const Text("Lead Source"),
                const SizedBox(height: 8),
                TextField(
                  controller: sourceController,
                  decoration: InputDecoration(
                    hintText: "Enter Source",
                    hintStyle: AppTextStyle.medium(
                      size: 11.sp,
                      color: AppColors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          onSubmit: () async {
            final name = sourceController.text.trim();
            if (name.isEmpty) return;

            Navigator.pop(ctx);

            await context.read<LeadSourceCubit>().addSource(name: name);
          },
        );
      },
    );
  }

  void _showEditDialog(LeadsModel category) {
    sourceController.text = category.name;

    showDialog(
      context: context,
      builder: (ctx) {
        return AppDialog(
          title: 'Edit Lead Category',
          width: 35.w,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text("Lead Category",style: AppTextStyle.medium(size: 12.sp),),
                 SizedBox(height: 0.5.h),
                TextField(
                  controller: sourceController,
                  decoration: InputDecoration(
                    hintText: "Enter Category",
                    hintStyle: AppTextStyle.medium(
                      size: 11.sp,
                      color: AppColors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          onSubmit: () async {
            // ✅ Capture value BEFORE pop
            final name = sourceController.text.trim();
            final id = category.id; // ✅ capture id too

            if (name.isEmpty) return;

            Navigator.pop(ctx); // pop first

            // ✅ Use outer screen context, not ctx
            await context.read<LeadSourceCubit>().updateSource(
              id: id,
              name: name,
            );
          },
        );
      },
    );
  }

  void _confirmDelete(LeadsModel category) {
    showDialog(
      context: context,
      builder: (ctx) => AppDialog(
        title: 'Delete Category',
        submitText: 'Delete',
        width: 35.w,
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Are you sure you want to delete "${category.name}"?\nThis action cannot be undone.',
              style: AppTextStyle.medium(size: 11.5.sp, color: AppColors.black),
            ),
          ),
        ),
        onSubmit: () {
          Navigator.pop(ctx);
          context.read<LeadSourceCubit>().deleteSource(id: category.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeadSourceCubit, LeadSourceState>(
      listenWhen: (prev, cur) =>
          cur.errorMessage != null && cur.errorMessage != prev.errorMessage,

      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,

        body: SingleChildScrollView(
          child: Column(
            children: [
              TopBreadcrumbBar(subTitle: "Dashboard", title: "Lead Source"),

              Padding(
                padding: EdgeInsets.all(2.w),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),

                  /// ✅ INNER COLUMN SAFE NOW
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔹 HEADER
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Lead Source",
                                  style: AppTextStyle.medium(
                                    size: 13.6.sp,
                                    color: AppColors.black.withOpacity(0.77),
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 0.2.w),
                                Tooltip(
                                  textAlign: TextAlign.center,
                                  message:
                                      "It refers to the source of the\nlead, showing how the\npotential customer discovered\nor engaged with the business,\nsuch as through marketing\ncampaigns, social media,\nreferrals, events, or website\ninquiries.",
                                  decoration: BoxDecoration(
                                    color: AppColors.black,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  waitDuration: const Duration(
                                    milliseconds: 200,
                                  ),
                                  child: Container(
                                    height: 2.h,
                                    width: 2.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.green,
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.question_mark_rounded,
                                      size: 10.sp,
                                      color: AppColors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            BlocBuilder<LeadSourceCubit, LeadSourceState>(
                              buildWhen: (p, c) =>
                                  p.isSubmitting != c.isSubmitting,
                              builder: (context, state) {
                                return MouseRegion(
                                  onEnter: (_) =>
                                      setState(() => isHovering = true),
                                  onExit: (_) =>
                                      setState(() => isHovering = false),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!state.isSubmitting) _showAddDialog();
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      curve: Curves.easeInOut,
                                      height: 5.h,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isHovering
                                            ? AppColors.green
                                            : AppColors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Add New",
                                          style: AppTextStyle.small(
                                            color: isHovering
                                                ? Colors.white
                                                : AppColors.green,
                                            size: 10.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 1.h),
                      Divider(color: AppColors.divider),
                      SizedBox(height: 3.h),

                      /// 🔹 FILTER
                      
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

                      SizedBox(height: 2.h),

                      /// 🔹 TABLE
                      BlocBuilder<LeadSourceCubit, LeadSourceState>(
                        builder: (context, state) {
                          // Loading skeleton
                          if (state.isLoading) {
                            return Column(
                              children: [
                                SizedBox(
                                  height: 20.h,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ],
                            );
                          }

                          final rows = _filtered(state.sources);

                          final allFiltered = _filtered(rows);
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
                                    TableColumn(title: "Sl No.", flex: 1),
                                    TableColumn(title: "Lead Source", flex: 4),
                                    TableColumn(title: "Created By", flex: 4),
                                    TableColumn(title: "Action", flex: 2),
                                  ],
                                  rows: pagedList.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final cat = entry.value;
                                    final isDeleting = state.deletingId == cat.id;
                                    final serial =
                                          (_currentPage - 1) * limit + index + 1;
                                    return [
                                      Text(
                                        serial.toString(),
                                        style: AppTextStyle.medium(),
                                      ),
                                      Text(cat.name, style: AppTextStyle.medium()),
                                      Text(
                                        cat.createdBy,
                                        style: AppTextStyle.medium(),
                                      ),
                              
                                      /// ACTION
                                      isDeleting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.red,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                // 🔹 Edit — opens edit dialog
                                                GestureDetector(
                                                  onTap: () => _showEditDialog(cat),
                                                  child: Icon(
                                                    Icons.edit_outlined,
                                                    size: 14.sp,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                SizedBox(width: 1.w,),
                                                // 🔹 Delete — opens confirm dialog
                                                GestureDetector(
                                                  onTap: () => _confirmDelete(cat),
                                                  child: Icon(
                                                    Icons.delete_outline,
                                                    size: 14.sp,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
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
          style: AppTextStyle.small(
            size: 11.sp,
            color: AppColors.white,
          ),
        ),
      ),
    ),
  ];
}

}
