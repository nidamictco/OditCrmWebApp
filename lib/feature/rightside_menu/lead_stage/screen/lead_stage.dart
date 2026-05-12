import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/popup_msg.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/feature/rightside_menu/common_model/lead_model.dart';
import 'package:oxdo/feature/rightside_menu/lead_stage/cubit/lead_stage_cubit.dart';
import 'package:oxdo/feature/rightside_menu/lead_stage/cubit/lead_stage_state.dart';
import 'package:sizer/sizer.dart';

class LeadStagesScreen extends StatefulWidget {
  const LeadStagesScreen({super.key});

  @override
  State<LeadStagesScreen> createState() => _LeadStagesScreenState();
}

class _LeadStagesScreenState extends State<LeadStagesScreen> {
  String selectedValue = '10';
  List<String> dropdownItems = ['10', '20', '30', '40', '50'];
  bool isHovering = false;

  final TextEditingController stagesController = TextEditingController();

  // ─── search query (wired to the search box) ───────────────────────────────
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Start the real-time Firestore listener
    context.read<LeadStageCubit>().watchCategories();
  }

  @override
  void dispose() {
    stagesController.dispose();
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
    stagesController.clear();
    // costController.clear();

    showDialog(
      context: context,
      builder: (ctx) {
        return AppDialog(
          title: 'Add Lead Category',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Lead Category
              const Text("Lead Stage"),
              const SizedBox(height: 8),
              TextField(
                controller: stagesController,
                decoration: InputDecoration(
                  hintText: "Enter Stage",
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
            final name = stagesController.text.trim();
            if (name.isEmpty) return;

            Navigator.pop(ctx);

            await context.read<LeadStageCubit>().addCategory(
              name: name,
              // createdBy: '-',
            );
          },
        );
      },
    );
  }

  void _showEditDialog(LeadsModel category) {
    stagesController.text = category.name;

    showDialog(
      context: context,
      builder: (ctx) {
        return AppDialog(
          title: 'Edit Lead Stages',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Lead Stages"),
              const SizedBox(height: 8),
              TextField(
                controller: stagesController,
                decoration: InputDecoration(
                  hintText: "Enter Stages",
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
            ],
          ),
          onSubmit: () async {
            // ✅ Capture value BEFORE pop
            final name = stagesController.text.trim();
            final id = category.id;

            if (name.isEmpty) return;

            Navigator.pop(ctx);
            await context.read<LeadStageCubit>().updateStage(
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
        title: 'Delete Lead Stages',
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
          context.read<LeadStageCubit>().deleteStage(id: category.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeadStageCubit, LeadStageState>(
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
              TopBreadcrumbBar(subTitle: "Lead Stages", title: "Dashboard"),
              Padding(
                padding: EdgeInsets.all(2.w),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: AppColors.lightGrey),
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
                                  "Lead Stages",
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
                                      "Lead Stages lets you track the\nstage of a lead, and you can\nadd new statuses as needed\nto match your sales process.",
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

                            BlocBuilder<LeadStageCubit, LeadStageState>(
                              buildWhen: (prev, cur) =>
                                  cur.isSubmitting != prev.isSubmitting,
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

                      /// 🔹 SWITCH
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Row(
                          children: [
                            Text(
                              "Priority Required for All Stages",
                              style: AppTextStyle.medium(),
                            ),
                            SizedBox(width: 0.4.w),
                            Transform.scale(
                              scale: 0.6,
                              child: Switch(
                                value: false,
                                activeColor: AppColors.primary,
                                onChanged: (value) {},
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 3.h),

                      /// 🔹 FILTER
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

                      /// 🔹 TABLE
                      BlocBuilder<LeadStageCubit, LeadStageState>(
                        // bloc: leadStageCubit,
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

                          final rows = _filtered(state.stages);

                          return SizedBox(
                            child: CustomTable(
                              columns: [
                                TableColumn(title: "#", flex: 1),
                                TableColumn(title: "Lead Source", flex: 4),
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
                                              MainAxisAlignment.center,
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

                      /// 🔹 FOOTER
                      Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Showing 1 to 5 of 5 entries",
                              style: AppTextStyle.medium(
                                weight: FontWeight.w400,
                              ),
                            ),
                            Row(
                              children: [
                                _paginationButton("Previous", false),
                                SizedBox(width: 0.1.w),
                                _pageNumber("1", true),
                                SizedBox(width: 0.1.w),
                                _paginationButton("Next", false),
                              ],
                            ),
                          ],
                        ),
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

  Widget _paginationButton(String text, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.container,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Text(text),
    );
  }

  Widget _pageNumber(String text, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.container,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: active ? Colors.white : Colors.black),
      ),
    );
  }
}
