import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/core/utils/popup_msg.dart';
import 'package:sizer/sizer.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/feature/rightside_menu/lead_category/cubit/lead_category_cubit.dart';
import 'package:oxdo/feature/rightside_menu/lead_category/cubit/lead_category_state.dart';
import 'package:oxdo/feature/rightside_menu/common_model/lead_model.dart';

class LeadCategory extends StatefulWidget {
  const LeadCategory({super.key});

  @override
  State<LeadCategory> createState() => _LeadCategoryState();
}

class _LeadCategoryState extends State<LeadCategory> {
  int? hoveringIndex;

  final TextEditingController categoryController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  int selectedEntries = 10;
  String selectedValue = '10';
  final List<String> dropdownItems = ['10', '20', '30', '40', '50'];

  // ─── search query (wired to the search box) ───────────────────────────────
  String _searchQuery = '';

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
    final limit = int.tryParse(selectedValue) ?? 10;
    final filtered = q.isEmpty
        ? all
        : all
              .where(
                (e) =>
                    e.name.toLowerCase().contains(q) ||
                    e.createdBy.toLowerCase().contains(q),
              )
              .toList();
    return filtered.take(limit).toList();
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
            
                const SizedBox(height: 16),
            
                /// Cost
                const Text("Cost"),
                const SizedBox(height: 8),
                TextField(
                  style: AppTextStyle.medium(weight: FontWeight.w400),
                  controller: costController,
                  decoration: InputDecoration(
                    hintText: "Enter Cost",
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
            final name = categoryController.text.trim();
            if (name.isEmpty) return;

            Navigator.pop(ctx);

            await context.read<LeadCategoryCubit>().addCategory(
              name: name,
              // createdBy: '-',
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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Lead Category"),
              const SizedBox(height: 8),
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
              const SizedBox(height: 16),
              const Text("Cost"),
              const SizedBox(height: 8),
              TextField(
                controller: costController,
                decoration: InputDecoration(
                  hintText: "Enter Cost",
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
          onSubmit: () async {
            // ✅ Capture value BEFORE pop
            final name = categoryController.text.trim();
            final id = category.id; // ✅ capture id too

            if (name.isEmpty) return;

            Navigator.pop(ctx); // pop first

            // ✅ Use outer screen context, not ctx
            await context.read<LeadCategoryCubit>().updateCategory(
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
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Text(
            'Are you sure you want to delete "${category.name}"?\nThis action cannot be undone.',
            style: AppTextStyle.medium(size: 11.sp, color: AppColors.grey),
          ),
        ),
        onSubmit: () {
          Navigator.pop(ctx);
          context.read<LeadCategoryCubit>().deleteCategory(id: category.id);
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
                                  textStyle: const TextStyle(
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
                                    SizedBox(width: 1.w),
                                    _actionBtn(
                                      1,
                                      "Import",
                                      AppColors.blueLight,
                                      AppColors.primary,
                                      () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AppDialog(
                                              title: 'Bulk Upload',
                                              body: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Import CSV File",
                                                    style: AppTextStyle.medium(
                                                      size: 11.sp,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Container(
                                                    height: 5.h,
                                                    width: 50.w,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.white,
                                                      border: Border.all(
                                                        color:
                                                            AppColors.divider,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.file_upload,
                                                        ),
                                                        SizedBox(width: 1.h),
                                                        Text(
                                                          "Upload CSV File",
                                                          style:
                                                              AppTextStyle.medium(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Simple File',
                                                    style: AppTextStyle.small(
                                                      color: Colors.indigo,
                                                      size: 11.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              onSubmit: () =>
                                                  Navigator.pop(context),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    SizedBox(width: 1.w),
                                    _actionBtn(
                                      2,
                                      "Bulk Add",
                                      AppColors.orangeLight,
                                      AppColors.orange,
                                      () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AppDialog(
                                              title: 'Bulk Add Category',
                                              body: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text("Lead Category"),
                                                  const SizedBox(height: 8),
                                                  TextField(
                                                    controller:
                                                        categoryController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "Enter Category",
                                                      hintStyle:
                                                          AppTextStyle.medium(
                                                            size: 11.sp,
                                                            color:
                                                                AppColors.grey,
                                                          ),
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                ],
                                              ),
                                              onSubmit: () =>
                                                  Navigator.pop(context),
                                            );
                                          },
                                        );
                                      },
                                    ),
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Show ",
                                  style: AppTextStyle.medium(
                                    size: 11.sp,
                                    weight: FontWeight.w400,
                                  ),
                                ),
                                _smallDropdown(),
                                Text(
                                  " entries",
                                  style: AppTextStyle.medium(
                                    size: 11.sp,
                                    weight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Text(
                                  "Search:",
                                  style: AppTextStyle.medium(
                                    size: 11.sp,
                                    weight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(width: 1.w),
                                Container(
                                  width: 12.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.lightGrey,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    color: AppColors.white,
                                  ),
                                  // 🔹 wired to _searchQuery
                                  child: TextField(
                                    onChanged: (v) =>
                                        setState(() => _searchQuery = v),
                                    style: AppTextStyle.small(
                                      size: 10.sp,
                                      color: AppColors.black,
                                    ),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 10,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

                          return SizedBox(
                            child: CustomTable(
                              columns: [
                                TableColumn(title: "#", flex: 1),
                                TableColumn(title: "Category Name", flex: 4),
                                TableColumn(title: "Created By", flex: 4),
                                TableColumn(title: "Action", flex: 2),
                              ],
                              rows: rows.asMap().entries.map((entry) {
                                final index = entry.key;
                                final cat = entry.value;
                                final isDeleting = state.deletingId == cat.id;

                                return [
                                  Text(
                                    '${index + 1}',
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
                                            SizedBox(width: 1.w),
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
                          );
                        },
                      ),

                      SizedBox(height: 2.h),

                      /// 🔹 FOOTER — entry count from cubit state
                      BlocBuilder<LeadCategoryCubit, LeadCategoryState>(
                        builder: (context, state) {
                          final total = state.categories.length;
                          final shown = _filtered(state.categories).length;

                          return Padding(
                            padding: EdgeInsets.all(2.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Showing 1 to $shown of $total entries",
                                  style: AppTextStyle.medium(
                                    weight: FontWeight.w400,
                                  ),
                                ),

                                Row(
                                  children: [
                                    _paginationBtn("Previous", false),
                                    SizedBox(width: 0.2.w),
                                    _paginationBtn("1", true),
                                    SizedBox(width: 0.2.w),
                                    _paginationBtn("Next", false),
                                  ],
                                ),
                              ],
                            ),
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

  Widget _smallDropdown() {
    return Container(
      width: 4.2.w,
      height: 4.h,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(4),
        color: AppColors.white,
      ),
      alignment: Alignment.center,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 16),
          style: AppTextStyle.small(size: 11.sp),
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue!;
            });
          },
          items: dropdownItems.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: AppTextStyle.small(size: 11.sp)),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 🔹 PAGINATION BUTTON
  Widget _paginationBtn(String text, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.container,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyle.body(
          color: active ? AppColors.white : AppColors.grey,
        ),
      ),
    );
  }
}

/// 🔹 HEADER TEXT — unchanged
class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: Text(text, style: AppTextStyle.medium(weight: FontWeight.w600)),
    );
  }
}
