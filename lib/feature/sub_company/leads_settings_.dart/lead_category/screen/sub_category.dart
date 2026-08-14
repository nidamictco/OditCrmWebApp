import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/confirm_alert.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/status_alert.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/widget/new_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/asset_resources.dart';
import '../../../../../core/utils/page_button.dart';
import '../../../../../core/utils/show_entries.dart';
import '../../../../../core/utils/table.dart';
import '../../../../../core/utils/top_bread_crumb_bar.dart';
import '../../../../../core/utils/alert_dialog/popup_msg.dart';
import 'package:sizer/sizer.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/common_model/lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/lead_category/cubit/sub_category_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/lead_category/cubit/sub_category_state.dart';

class LeaSubCategoryScreen extends StatefulWidget {
  final String categoryName;
  final String categoryId;
  const LeaSubCategoryScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<LeaSubCategoryScreen> createState() => _LeaSubCategoryScreenState();
}

class _LeaSubCategoryScreenState extends State<LeaSubCategoryScreen> {
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
    context.read<SubCategoryCubit>().watchSubCategories();
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
          title: 'Add Lead Sub Category- ${widget.categoryName}',
          width: 35.w,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Lead Category
                const Text("Lead Sub Category"),
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
            final cubit = context.read<SubCategoryCubit>();

            if (cubit.subcategoryExists(name)) {
              StatusAlertWidget.show(
                ctx,
                title: 'Validation',
                message: 'This sub category already exists.',
                isSuccess: false,
                onButtonPressed: () {
                  context.pop();
                },
              );
              return; // keep the dialog open, don't pop
            }
            Navigator.pop(ctx);

            await context.read<SubCategoryCubit>().addSubCategory(name: name);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$name added successfully!"),
                backgroundColor: Colors.green,
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
          title: 'Edit Lead Sub Category',
          width: 35.w,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Lead Sub Category",
                  style: AppTextStyle.medium(size: 11.sp),
                ),
                SizedBox(height: 0.5.h),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    hintText: "Enter Sub Category",
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
            // ✅ Capture value BEFORE pop
            final name = categoryController.text.trim();
            final id = category.id; // ✅ capture id too

            if (name.isEmpty) return;

            final cubit = context.read<SubCategoryCubit>();

            if (cubit.subcategoryExists(name)) {
              StatusAlertWidget.show(
                ctx,
                title: 'Validation',
                message: 'This sub category already exists.',
                isSuccess: false,
                onButtonPressed: () {
                  context.pop();
                },
              );
              return; // keep the dialog open, don't pop
            }

            Navigator.pop(ctx); // pop first

            // ✅ Use outer screen context, not ctx
            await context.read<SubCategoryCubit>().updateSubCategory(
              id: id,
              name: name,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${category.name} updated successfully!"),
                backgroundColor: Colors.green,
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
        title: 'Delete Sub Category',
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
          context.read<SubCategoryCubit>().deleteSubCategory(id: category.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${category.name} deleted successfully!"),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubCategoryCubit, SubCategoryState>(
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
        backgroundColor: AppThemeColors.scaffoldBg,
        body: SingleChildScrollView(
          child: Column(
            children: [
              /// 🔹 MAIN CONTENT
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Container(
                  padding: EdgeInsets.only(bottom: 2.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // /// 🔹 HEADER
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 2.w),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Row(
                      //         children: [
                      //           Text(
                      //             "Lead Sub Category - ${widget.categoryName}",
                      //             style: AppTextStyle.medium(
                      //               size: 13.6.sp,
                      //               color: AppColors.black.withOpacity(0.77),
                      //               weight: FontWeight.w600,
                      //             ),
                      //           ),
                      //           SizedBox(width: 0.2.w),
                      //         ],
                      //       ),

                      //       // 🔹 Add New button
                      //       BlocBuilder<SubCategoryCubit, SubCategoryState>(
                      //         buildWhen: (p, c) =>
                      //             p.isSubmitting != c.isSubmitting,
                      //         builder: (context, state) {
                      //           return Row(
                      //             children: [
                      //               _actionBtn(
                      //                 0,
                      //                 "Add New",
                      //                 AppColors.greenLight,
                      //                 AppColors.green,
                      //                 state.isSubmitting
                      //                     ? null // disabled during submit
                      //                     : _showAddDialog,
                      //                 isLoading: state.isSubmitting,
                      //               ),
                      //               SizedBox(width: 1.w),
                      //             ],
                      //           );
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      // SizedBox(height: 1.h),
                      // Divider(color: AppColors.divider),
                      // SizedBox(height: 3.h),

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
                        exportWidget: BlocBuilder<SubCategoryCubit, SubCategoryState>(
                          buildWhen: (p, c) => p.isSubmitting != c.isSubmitting,
                          builder: (context, state) {
                            return Row(
                              children: [
                                _actionBtn(
                                  0,
                                  "New Sub Category",
                                  AppColors.greenLight,
                                  AppThemeColors.statusActive,
                                  state.isSubmitting
                                      ? null // disabled during submit
                                      : () {
                                          if (!state.isSubmitting) {
                                            final cubit = context
                                                .read<SubCategoryCubit>();

                                            showDialog(
                                              context: context,
                                              builder: (dialogContext) =>
                                                  LeadSettingsAlert(
                                                    constrainsWidth: 1000,
                                                    fieldLabel:
                                                        'Lead Sub Category',
                                                    title:
                                                        'Add Lead Sub Category',
                                                    onSubmit: (String value) async {
                                                      if (cubit
                                                          .subcategoryExists(
                                                            value,
                                                          )) {
                                                        StatusAlertWidget.show(
                                                          dialogContext,
                                                          title: 'Validation',
                                                          message:
                                                              'This category already exists.',
                                                          isSuccess: false,
                                                          onButtonPressed: () =>
                                                              Navigator.pop(
                                                                dialogContext,
                                                              ),
                                                        );
                                                        return;
                                                      }
                                                      Navigator.pop(
                                                        dialogContext,
                                                      );
                                                      await cubit
                                                          .addSubCategory(
                                                            name: value,
                                                          );
                                                    },
                                                  ),
                                            );
                                          }
                                        },
                                  isLoading: state.isSubmitting,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 2.h),

                      /// 🔹 TABLE
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x14000000),
                              offset: const Offset(0, 1),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: BlocBuilder<SubCategoryCubit, SubCategoryState>(
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

                            final rows = _filtered(state.subCategories);
                            final allFiltered = _filtered(rows);
                            final totalCount = allFiltered.length;
                            final totalPages = _totalPages(totalCount);
                            final limit = int.tryParse(_selectedEntries) ?? 10;

                            if (_currentPage > totalPages && totalPages > 0) {
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
                                      TableColumn(title: "No."),
                                      TableColumn(title: "Category Name"),
                                      TableColumn(title: "Created By"),
                                      TableColumn(title: "Action"),
                                    ],
                                    rows: pagedList.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final cat = entry.value;
                                      final isDeleting =
                                          state.deletingId == cat.id;
                                      final serial =
                                          (_currentPage - 1) * limit +
                                          index +
                                          1;

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
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.red,
                                                    ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  // 🔹 Edit — opens edit dialog
                                                  GestureDetector(
                                                   onTap: () {
  final id = cat.id;

  if (!state.isSubmitting) {
    final cubit = context.read<SubCategoryCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => LeadSettingsAlert(
        constrainsWidth: 1000,
        fieldLabel: 'Lead Sub Category',
        title: 'Edit Lead Sub Category',
        initialValue: cat.name, // pre-fill with current name
        onSubmit: (String value) async {
          if (value != cat.name && cubit.subcategoryExists(value)) {
            StatusAlertWidget.show(
              dialogContext,
              title: 'Validation',
              message: 'This sub category already exists',
              isSuccess: false,
              onButtonPressed: () => Navigator.pop(dialogContext),
            );
            return;
          }
          Navigator.pop(dialogContext);
          await cubit.updateSubCategory(id: id, name: value); // use `value`, not `name`
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$value updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

                                                        },
                                                    child: Container(
                                                      height: 28,
                                                      width: 28,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(
                                                          color: const Color(
                                                            0xff3B82F6,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Image.asset(
                                                        AssetResources.edit,
                                                        scale: 1.7,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 1.w),
                                                  // 🔹 Delete — opens confirm dialog
                                                  GestureDetector(
                                                    onTap: () {
                                                      final cubit = context
                                                        .read<SubCategoryCubit>();

                                                    showDialog(
                                                      context: context,
                                                      builder: (dialogContext) =>
                                                          ConfirmAlertWidget(
                                                            type:
                                                                ConfirmAlertType
                                                                    .delete,
                                                            title:
                                                                'Delete Sub Category',
                                                            message:
                                                                'Are you sure you want to delete this ${cat.name} Sub Category?',
                                                            onCancel: () {
                                                              Navigator.pop(
                                                                dialogContext,
                                                              );
                                                            },
                                                            onDelete: () {
                                                              Navigator.pop(
                                                                dialogContext,
                                                              );
                                                              cubit
                                                                  .deleteSubCategory(
                                                                    id: cat.id,
                                                                  );
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    "${cat.name} deleted successfully!",
                                                                  ),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                    );
                                                    },
                                                    child: Container(
                                                      height: 28,
                                                      width: 28,
                                                      decoration: BoxDecoration(
                                                        // color: const Color(0xFFFEF2F2),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(
                                                          color: const Color(
                                                            0xFFFCA5A5,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Image.asset(
                                                        AssetResources
                                                            .deleteIcon,
                                                        scale: 1.7,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
                                          /// Previous button
                                          MouseRegion(
                                            cursor: _currentPage > 1
                                                ? SystemMouseCursors.click
                                                : SystemMouseCursors.basic,
                                            child: GestureDetector(
                                              onTap: _currentPage > 1
                                                  ? () => _goToPage(
                                                      _currentPage - 1,
                                                      totalCount,
                                                    )
                                                  : null,
                                              child: Container(
                                                width: 32,
                                                height: 32,
                                                alignment: Alignment.center,
                                                margin: const EdgeInsets.only(
                                                  right: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFE2E8F0,
                                                    ),
                                                  ),
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

                                          ..._buildPageNumbers(
                                            totalPages,
                                            totalCount,
                                          ),

                                          /// Next button
                                          MouseRegion(
                                            cursor: _currentPage < totalPages
                                                ? SystemMouseCursors.click
                                                : SystemMouseCursors.basic,
                                            child: GestureDetector(
                                              onTap: _currentPage < totalPages
                                                  ? () => _goToPage(
                                                      _currentPage + 1,
                                                      totalCount,
                                                    )
                                                  : null,
                                              child: Container(
                                                width: 32,
                                                height: 32,
                                                alignment: Alignment.center,
                                                margin: const EdgeInsets.only(
                                                  left: 4,
                                                  right: 12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFE2E8F0,
                                                    ),
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.chevron_right,
                                                  size: 16,
                                                  color:
                                                      _currentPage < totalPages
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
                            );
                          },
                        ),
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 4.h,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Text(
                  text,
                  style: AppTextStyle.small(color: Colors.white, size: 10.sp),
                ),
        ),
      ),
    );
  }

  // ── Page number chips ───────────────────────
  List<Widget> _buildPageNumbers(int totalPages, int totalCount) {
    if (totalPages <= 1) {
      return [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: AppThemeColors.appPrimaryColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '1',
            style: AppTextStyle.small(
              size: 10.sp,
              color: Colors.white,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ];
    }

    List<Widget> pages = [];
    for (int i = 1; i <= totalPages; i++) {
      if (i == 1 ||
          i == totalPages ||
          (i >= _currentPage - 1 && i <= _currentPage + 1)) {
        final isSelected = i == _currentPage;
        pages.add(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _goToPage(i, totalCount),
              child: Container(
                constraints: const BoxConstraints(minWidth: 32),
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppThemeColors.appPrimaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? AppThemeColors.appPrimaryColor
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  '$i',
                  style: AppTextStyle.small(
                    size: 10.sp,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                    weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (i == _currentPage - 2 || i == _currentPage + 2) {
        pages.add(
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              '...',
              style: AppTextStyle.small(
                size: 10.sp,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        );
      }
    }
    return pages;
  }
}
