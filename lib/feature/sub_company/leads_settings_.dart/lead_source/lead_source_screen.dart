import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/confirm_alert.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/status_alert.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/widget/new_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/utils/page_button.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/popup_msg.dart';
import 'package:Odit_CRM/core/utils/show_entries.dart';
import 'package:Odit_CRM/core/utils/table.dart';
import 'package:Odit_CRM/core/utils/top_bread_crumb_bar.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/common_model/lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/lead_source/cubit/lead_source_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/lead_source/cubit/lead_source_state.dart';
import 'package:go_router/go_router.dart';
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

            final cubit = context.read<LeadSourceCubit>();

            if (cubit.sourceExists(name)) {
              StatusAlertWidget.show(
                ctx,
                title: 'Validation',
                message: 'This source already exists.',
                isSuccess: false,
                onButtonPressed: () {
                  context.pop();
                },
              );
              return; // keep the dialog open, don't pop
            }

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
                Text("Lead Category", style: AppTextStyle.medium(size: 12.sp)),
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

            final cubit = context.read<LeadSourceCubit>();
            if (cubit.sourceExists(name)) {
              StatusAlertWidget.show(
                ctx,
                title: 'Validation',
                message: 'This source already exists.',
                isSuccess: false,
                onButtonPressed: () {
                  context.pop();
                },
              );
              return; // keep the dialog open, don't pop
            }

            Navigator.pop(ctx); // pop first

            // ✅ Use outer screen context, not ctx
            await context.read<LeadSourceCubit>().updateSource(
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

  void _confirmDelete(LeadsModel source) {
    showDialog(
      context: context,
      builder: (ctx) => AppDialog(
        title: 'Delete source',
        submitText: 'Delete',
        width: 35.w,
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Are you sure you want to delete "${source.name}"?\nThis action cannot be undone.',
              style: AppTextStyle.medium(size: 11.5.sp, color: AppColors.black),
            ),
          ),
        ),
        onSubmit: () {
          Navigator.pop(ctx);
          context.read<LeadSourceCubit>().deleteSource(id: source.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${source.name} deleted successfully!"),
              backgroundColor: Colors.red,
            ),
          );
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
        backgroundColor: AppThemeColors.scaffoldBg,

        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 2.w, right: 2.w, bottom: 1.w),
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
                    //             "Lead Source",
                    //             style: AppTextStyle.medium(
                    //               size: 13.6.sp,
                    //               color: AppColors.black.withOpacity(0.77),
                    //               weight: FontWeight.w600,
                    //             ),
                    //           ),
                    //           SizedBox(width: 0.2.w),
                    //           Tooltip(
                    //             textAlign: TextAlign.center,
                    //             message:
                    //                 "It refers to the source of the\nlead, showing how the\npotential customer discovered\nor engaged with the business,\nsuch as through marketing\ncampaigns, social media,\nreferrals, events, or website\ninquiries.",
                    //             decoration: BoxDecoration(
                    //               color: AppColors.black,
                    //               borderRadius: BorderRadius.circular(6),
                    //             ),
                    //             textStyle: TextStyle(
                    //               color: Colors.white,
                    //               fontSize: 12,
                    //             ),
                    //             waitDuration: const Duration(
                    //               milliseconds: 200,
                    //             ),
                    //             child: Container(
                    //               height: 2.h,
                    //               width: 2.w,
                    //               decoration: BoxDecoration(
                    //                 shape: BoxShape.circle,
                    //                 border: Border.all(
                    //                   color: AppColors.green,
                    //                   width: 1,
                    //                 ),
                    //               ),
                    //               child: Icon(
                    //                 Icons.question_mark_rounded,
                    //                 size: 10.sp,
                    //                 color: AppColors.green,
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),

                    // BlocBuilder<LeadSourceCubit, LeadSourceState>(
                    //   buildWhen: (p, c) =>
                    //       p.isSubmitting != c.isSubmitting,
                    //   builder: (context, state) {
                    //     return MouseRegion(
                    //       onEnter: (_) =>
                    //           setState(() => isHovering = true),
                    //       onExit: (_) =>
                    //           setState(() => isHovering = false),
                    //       child: GestureDetector(
                    //         onTap: () {
                    //           if (!state.isSubmitting) _showAddDialog();
                    //         },
                    //         child: AnimatedContainer(
                    //           duration: const Duration(
                    //             milliseconds: 200,
                    //           ),
                    //           curve: Curves.easeInOut,
                    //           height: 5.h,
                    //           padding: EdgeInsets.symmetric(
                    //             horizontal: 3.w,
                    //           ),
                    //           decoration: BoxDecoration(
                    //             color: isHovering
                    //                 ? AppColors.green
                    //                 : AppColors.green.withOpacity(0.1),
                    //             borderRadius: BorderRadius.circular(6),
                    //           ),
                    //           child: Center(
                    //             child: Text(
                    //               "Add New",
                    //               style: AppTextStyle.small(
                    //                 color: isHovering
                    //                     ? Colors.white
                    //                     : AppColors.green,
                    //                 size: 10.sp,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
                    //     ],
                    //   ),
                    // ),

                    // SizedBox(height: 1.h),
                    // Divider(color: AppColors.divider),
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
                      exportWidget: BlocBuilder<LeadSourceCubit, LeadSourceState>(
                        buildWhen: (p, c) => p.isSubmitting != c.isSubmitting,
                        builder: (context, state) {
                          return MouseRegion(
                            onEnter: (_) => setState(() => isHovering = true),
                            onExit: (_) => setState(() => isHovering = false),
                            child: GestureDetector(
                              onTap: () {
                                if (!state.isSubmitting) {
                                  final cubit = context
                                      .read<
                                        LeadSourceCubit
                                      >(); // outer context — known-good

                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => LeadSettingsAlert(
                                      fieldLabel: 'Lead Source',
                                      title: 'Add Lead Source',
                                      constrainsWidth: 700,
                                      onSubmit: (String value) async {
                                        if (cubit.sourceExists(value)) {
                                          StatusAlertWidget.show(
                                            dialogContext,
                                            title: 'Validation',
                                            message:
                                                'This source already exists.',
                                            isSuccess: false,
                                            onButtonPressed: () =>
                                                Navigator.pop(dialogContext),
                                          );
                                          return;
                                        }
                                        Navigator.pop(
                                          dialogContext,
                                        ); // close LeadSettingsAlert
                                        await cubit.addSource(name: value);
                                      },
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                height: 4.h,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppThemeColors.statusActive,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    "Add Source",
                                    style: AppTextStyle.small(
                                      color: Colors.white,
                                      size: 10.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                      child: BlocBuilder<LeadSourceCubit, LeadSourceState>(
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
                          final showTo = (showFrom + pagedList.length - 1)
                              .clamp(0, totalCount);

                          return Column(
                            children: [
                              SizedBox(
                                child: CustomTable(
                                  columns: [
                                    TableColumn(title: "No."),
                                    TableColumn(title: "Lead Source"),
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
                                        serial.toString(),
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
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                // 🔹 Edit — opens edit dialog
                                                GestureDetector(
                                                  // onTap: () =>
                                                  //     _showEditDialog(cat),
                                                  onTap: () {
                                                    // showDialog(
                                                    //   context: context,
                                                    //   builder: (dialogContext) =>
                                                    //       LeadSettingsAlert(
                                                    //         constrainsWidth: 600,
                                                    //         fieldLabel:
                                                    //             'Lead Sub Category',
                                                    //         title:
                                                    //             'Edit Lead Sub Category',
                                                    //         initialValue:
                                                    //             subCat.name,
                                                    //         onSubmit: (name) {
                                                    //           if (name.isEmpty) {
                                                    //             return;
                                                    //           }
                                                    //           final cubit =
                                                    //               context.read<
                                                    //                   LeadSourceCubit>();
                                                    //           if (cubit.sourceExists(
                                                    //             name,
                                                    //             parent: widget.category,
                                                    //           )) {
                                                    //             StatusAlertWidget.show(
                                                    //               dialogContext,
                                                    //               title: 'Validation',
                                                    //               message:
                                                    //                   'This sub category already exists.',
                                                    //               isSuccess: false,
                                                    //               onButtonPressed: () {
                                                    //                 context.pop();
                                                    //               },
                                                    //             );
                                                    //             return;
                                                    //           }
                                                    //           Navigator.pop(dialogContext);
                                                    //           cubit.updateSubCategory(
                                                    //             id: subCat.id,
                                                    //             name: name,
                                                    //             parent: widget.category,
                                                    //           );
                                                    //         },
                                                    //       ),
                                                    // );
                                                    if (!state.isSubmitting) {
                                            final cubit = context
                                                .read<LeadSourceCubit>();

                                            showDialog(
                                              context: context,
                                              builder: (dialogContext) => LeadSettingsAlert(
                                                fieldLabel: 'Lead Source',
                                                title: 'Edit Lead Source',
                                                constrainsWidth: 700,
                                                initialValue: cat.name,
                                                onSubmit: (String value) async {
                                                  if (cubit.sourceExists(value)) {
                                                    StatusAlertWidget.show(
                                                      dialogContext,
                                                      title: 'Validation',
                                                      message:
                                                          'This source already exists.',
                                                      isSuccess: false,
                                                      onButtonPressed: () =>
                                                          Navigator.pop(dialogContext),
                                                    );
                                                    return;
                                                  }
                                                  Navigator.pop(
                                                    dialogContext,
                                                  ); // close LeadSettingsAlert
                                                  await cubit.updateSource(name: value, id: cat.id,  );
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
                                                      // color: const Color(
                                                      //   0xFFFEF2F2,
                                                      // ),
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
                                                      // color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 1.w),
                                                // 🔹 Delete — opens confirm dialog
                                                GestureDetector(
                                                  onTap: () {
                                                      // _confirmDelete(cat);
                                                      
                                                    final cubit = context
                                                        .read<LeadSourceCubit>();

                                                    showDialog(
                                                      context: context,
                                                      builder: (dialogContext) =>
                                                          ConfirmAlertWidget(
                                                            type:
                                                                ConfirmAlertType
                                                                    .delete,
                                                            title:
                                                                'Delete Lead Source',
                                                            message:
                                                                'Are you sure you want to delete this ${cat.name} lead source?',
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
                                                                  .deleteSource(
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
                                                      AssetResources.deleteIcon,
                                                      scale: 1.7,
                                                      // color: Colors.red,
                                                    ),
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
                                                color: _currentPage < totalPages
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
                  ],
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
