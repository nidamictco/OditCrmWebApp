import 'package:Odit_CRM/core/router/browser_aware_link.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/status_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/utils/page_button.dart';
import 'package:Odit_CRM/core/utils/popup_msg.dart';
import 'package:Odit_CRM/core/utils/show_entries.dart';
import 'package:Odit_CRM/core/utils/table.dart';
import 'package:Odit_CRM/core/utils/top_bread_crumb_bar.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/common_model/lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_stage/cubit/lead_stage_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_stage/cubit/lead_stage_state.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

class LeadStagesScreen extends StatefulWidget {
  const LeadStagesScreen({super.key});

  @override
  State<LeadStagesScreen> createState() => _LeadStagesScreenState();
}

class _LeadStagesScreenState extends State<LeadStagesScreen> {
  bool isHovering = false;

  final TextEditingController stagesController = TextEditingController();

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
    stagesController.clear();
    // costController.clear();

    showDialog(
      context: context,
      builder: (ctx) {
        return AppDialog(
          title: 'Add Lead Stage',
          width: 35.w,
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

 final cubit = context.read<LeadStageCubit>();

             if (cubit.stageExists(name)) {
    StatusAlertWidget.show(
      ctx,
      title: 'Validation',
      message: 'This stage already exists.', isSuccess: false, onButtonPressed: () {  
        context.pop();
      },
    );
    return; // keep the dialog open, don't pop
  }

            Navigator.pop(ctx);

            await context.read<LeadStageCubit>().addCategory(
              name: name,tagMandatory: false
              // createdBy: '-',
            );
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

  void _showWarningSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditDialog(LeadsModel category) {
    if (category.isDefault) {
      _showWarningSnack(
        "This is a default lead stage and cannot be edited or deleted.",
      );
      return;
    }
    stagesController.text = category.name;

    showDialog(
      context: context,
      builder: (ctx) {
        return AppDialog(
          title: 'Edit Lead Stages',
          width: 35.w,
          body: Padding(
            padding: EdgeInsets.all(1.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Lead Stages", style: AppTextStyle.medium(size: 12.sp)),
                SizedBox(height: 0.5.h),
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
          ),
          onSubmit: () async {
            // ✅ Capture value BEFORE pop
            final name = stagesController.text.trim();
            final id = category.id;

            if (name.isEmpty) return;
 final cubit = context.read<LeadStageCubit>();

             if (cubit.stageExists(name)) {
    StatusAlertWidget.show(
      ctx,
      title: 'Validation',
      message: 'This stage already exists.', isSuccess: false, onButtonPressed: () {  
        context.pop();
      },
    );
    return; // keep the dialog open, don't pop
  }
            Navigator.pop(ctx);
            await context.read<LeadStageCubit>().updateStage(
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
    if (category.isDefault) {
      _showWarningSnack(
        "This is a default lead stage and cannot be edited or deleted.",
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AppDialog(
        title: 'Delete Lead Stages',
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
          context.read<LeadStageCubit>().deleteStage(id: category.id);
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
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 2.w),
                      //   child: Row(
                      //     children: [
                      //       Text(
                      //         "Priority Required for All Stages",
                      //         style: AppTextStyle.medium(),
                      //       ),
                      //       SizedBox(width: 0.4.w),
                      //       Transform.scale(
                      //         scale: 0.6,
                      //         child: Switch(
                      //           value: false,
                      //           activeColor: AppColors.primary,
                      //           onChanged: (value) {},
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      // SizedBox(height: 3.h),

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
                                    TableColumn(title: "Sl No.", flex: 1),
                                    TableColumn(title: "Lead Status", flex: 4),
                                    TableColumn(title: "Created By", flex: 4),
                                    TableColumn(title: "Action", flex: 2),
                                  ],
                                  rows: pagedList.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final cat = entry.value;
                                    final isDeleting =
                                        state.deletingId == cat.id;

                                    return [
                                      Text(
                                        '${index + 1}',
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
                                          : cat.isDefault
                                          // ? Tooltip(
                                          //     message:
                                          //         "Default stage cannot be modified.",
                                          //     child: Icon(
                                          //       Icons.lock_outline,
                                          //       size: 14.sp,
                                          //       color: AppColors.grey,
                                          //     ),
                                          //   )
                                          ?BrowserAwareLink(
                                                    destination:
                                                        RoutePaths.leadTagPath(
                                                          cat.name,
                                                          cat.id,
                                                          cat.tagMandatory
                                                        ),
                                                    usePush: true,
                                                    enableInkWell: false,
                                                    child: Icon(
                                                      Icons.list,
                                                      size: 14.sp,
                                                      color: Colors.lightGreen,
                                                    ),
                                                  )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                BrowserAwareLink(
                                                    destination:
                                                        RoutePaths.leadTagPath(
                                                          cat.name,
                                                          cat.id,
                                                          cat.tagMandatory
                                                        ),
                                                    usePush: true,
                                                    enableInkWell: false,
                                                    child: Icon(
                                                      Icons.list,
                                                      size: 14.sp,
                                                      color: Colors.lightGreen,
                                                    ),
                                                  ),
                                                  SizedBox(width: 1.w),
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
                                                SizedBox(width: 1.w),
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
            style: AppTextStyle.small(size: 11.sp, color: AppColors.white),
          ),
        ),
      ),
    ];
  }
}
