import 'package:Odit_CRM/core/router/browser_aware_link.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/status_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/utils/page_button.dart';
import '../../../../../core/utils/show_entries.dart';
import '../../../../../core/utils/table.dart';
import '../../../../../core/utils/top_bread_crumb_bar.dart';
import '../../../../../core/utils/alert_dialog/popup_msg.dart';
import 'package:sizer/sizer.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/cubit/lead_category_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/cubit/lead_category_state.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/common_model/lead_model.dart';

class LeadCategory extends StatefulWidget {
  const LeadCategory({super.key});

  @override
  State<LeadCategory> createState() => _LeadCategoryState();
}

class _LeadCategoryState extends State<LeadCategory> {
  int? hoveringIndex;

  final TextEditingController categoryController = TextEditingController();
  final TextEditingController costController = TextEditingController();

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
    context.read<LeadCategoryCubit>().watchCategories();
  }

  @override
  void dispose() {
    categoryController.dispose();
    costController.dispose();
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
    categoryController.clear();
    costController.clear();

    showDialog(
      context: context,
      builder: (ctx) {
        return AppDialog(
          title: 'Add Lead Category',
          width: 35.w,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Lead Category
                const Text("Lead Category"),
                const SizedBox(height: 8),
                TextField(
                  style: AppTextStyle.medium(weight: FontWeight.w400),
                  controller: categoryController,
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

                SizedBox(height: 1.5.h),
              ],
            ),
          ),
          onSubmit: () async {
            final name = categoryController.text.trim();
            if (name.isEmpty) return;

             final cubit = context.read<LeadCategoryCubit>();

  if (cubit.categoryExists(name)) {
    StatusAlertWidget.show(
      ctx,
      title: 'Validation',
      message: 'This category already exists.', isSuccess: false, onButtonPressed: () {  
context.pop();
      },
    );
    return; // keep the dialog open, don't pop
  }

            Navigator.pop(ctx);

            await context.read<LeadCategoryCubit>().addCategory(name: name);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$name added successfully'),
                backgroundColor: AppColors.green,
              ),
            );
          },
        );
      },
    );
  }

  void _showEditDialog(LeadsModel category) {
    categoryController.text = category.name;
    costController.clear();

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
                Text("Lead Category", style: AppTextStyle.medium(size: 11.sp)),
                SizedBox(height: 0.5.h),
                TextField(
                  controller: categoryController,
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
            final name = categoryController.text.trim();
            final id = category.id; // ✅ capture id too

            if (name.isEmpty) return;

 final cubit = context.read<LeadCategoryCubit>();

             if (cubit.categoryExists(name)) {
    StatusAlertWidget.show(
      ctx,
      title: 'Validation',
      message: 'This category already exists.', isSuccess: false, onButtonPressed: () {  
        context.pop();
      },
    );
    return; // keep the dialog open, don't pop
  }

            Navigator.pop(ctx); // pop first

            // ✅ Use outer screen context, not ctx
            await context.read<LeadCategoryCubit>().updateCategory(
              id: id,
              name: name,
            );
             ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name updated successfully'),
              backgroundColor: AppColors.green,
            ),
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
        width: 30.w,
        submitText: 'Delete',
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
          context.read<LeadCategoryCubit>().deleteCategory(id: category.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${category.name} deleted successfully!'),
              backgroundColor: AppColors.red,
            ),
          );
        },
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeadCategoryCubit, LeadCategoryState>(
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
              TopBreadcrumbBar(subTitle: 'Lead Category', title: 'Dashboard'),

              /// 🔹 MAIN CONTENT
              Padding(
                padding: EdgeInsets.all(2.w),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
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
                                  "Lead Category",
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
                                      "Lead Category is the type of\nproduct, service, or solution a\npotential customer is\ninterested in, helping\nbusinesses identify and\nclassify inquiries for better\nfollow-up.",
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  textStyle: AppTextStyle.medium(
                                    color: Colors.white,
                                    size: 11.sp,
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

                            // 🔹 Add New button — shows loader while submitting
                            BlocBuilder<LeadCategoryCubit, LeadCategoryState>(
                              buildWhen: (p, c) =>
                                  p.isSubmitting != c.isSubmitting,
                              builder: (context, state) {
                                return Row(
                                  children: [
                                    _actionBtn(
                                      0,
                                      "Add New",
                                      AppColors.greenLight,
                                      AppColors.green,
                                      state.isSubmitting
                                          ? null // disabled during submit
                                          : _showAddDialog,
                                      isLoading: state.isSubmitting,
                                    ),
                                    // SizedBox(width: 1.w),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 1.h),
                      Divider(color: AppColors.divider),
                      SizedBox(height: 3.h),

                      /// 🔹 FILTER ROW
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

                      /// 🔹 TABLE — driven by Firestore via cubit
                      BlocBuilder<LeadCategoryCubit, LeadCategoryState>(
                        builder: (context, state) {
                          // Loading skeleton
                          if (state.isLoading) {
                            return SizedBox(
                              height: 20.h,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final rows = _filtered(state.categories);
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
                          final showTo = (showFrom + pagedList.length - 1)
                              .clamp(0, totalCount);

                          return Column(
                            children: [
                              SizedBox(
                                child: CustomTable(
                                  columns: [
                                    TableColumn(title: "Sl No."),
                                    TableColumn(title: "Category Name"),
                                    TableColumn(title: "Created By"),
                                    TableColumn(title: "Action"),
                                  ],
                                  rows: pagedList.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final cat = entry.value;
                                    final isDeleting =
                                        state.deletingId == cat.id;
                                    final serial =
                                        (_currentPage - 1) * limit + index + 1;

                                    return [
                                      Text(
                                        '$serial',
                                        style: AppTextStyle.medium(),
                                      ),
                                      Text(
                                        cat.name,
                                        style: AppTextStyle.medium(),
                                      ),
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
                                          : Align(
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  BrowserAwareLink(
                                                    destination:
                                                        RoutePaths.subCategoryPath(
                                                          cat.name,
                                                          cat.id,
                                                        ),
                                                    usePush: true,
                                                    enableInkWell: false,
                                                    child: Icon(
                                                      Icons.list,
                                                      size: 14.sp,
                                                      color: Colors.lightGreen,
                                                    ),
                                                  ),
                                                  // 🔹 Edit — opens edit dialog
                                                  GestureDetector(
                                                    onTap: () =>
                                                        _showEditDialog(cat),
                                                    child: Icon(
                                                      Icons.edit_outlined,
                                                      size: 14.sp,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                  // 🔹 Delete — opens confirm dialog
                                                  GestureDetector(
                                                    onTap: () =>
                                                        _confirmDelete(cat),
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
                                  }).toList(),
                                ),
                              ),
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

                      SizedBox(height: 2.h),
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

  // ─── Unchanged helper widgets ─────────────────────────────────────────────

  /// 🔹 ACTION BUTTON — added optional isLoading flag
  Widget _actionBtn(
    int index,
    String text,
    Color bg,
    Color color,
    VoidCallback? onTap, {
    bool isLoading = false,
  }) {
    final isHovering = hoveringIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveringIndex = index),
      onExit: (_) => setState(() => hoveringIndex = null),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 5.h,
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: isHovering ? color : bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isHovering ? Colors.white : color,
                    ),
                  )
                : Text(
                    text,
                    style: AppTextStyle.small(
                      color: isHovering ? Colors.white : color,
                      size: 10.sp,
                    ),
                  ),
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
            style: AppTextStyle.small(size: 11.sp, color: AppColors.white),
          ),
        ),
      ),
    ];
  }
}
