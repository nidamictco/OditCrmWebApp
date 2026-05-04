import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/popup_msg.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/feature/rightside_menu/lead_category/model/lead_category_model.dart';
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

  String selectedValue = "10";
  final List<String> dropdownItems = ["10", "25", "50", "100"];

  // ─── search query (wired to the search box) ───────────────────────────────
  String _searchQuery = '';

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
    sourceController.clear();

    showDialog(
      context: context,
      builder: (ctx) {
        return AppDialog(
          title: 'Add Lead Source',
          body: Column(
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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Lead Category"),
              const SizedBox(height: 8),
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
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Text(
            'Are you sure you want to delete "${category.name}"?\nThis action cannot be undone.',
            style: AppTextStyle.medium(size: 11.sp, color: AppColors.grey),
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
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 2.h),

                      /// 🔹 TABLE
                      BlocBuilder<LeadSourceCubit, LeadSourceState>(
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

                          final rows = _filtered(state.sources);

                         
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
                            Text("Showing 1 to 8 of 8 entries"),

                            Row(
                              children: [
                                _paginationButton("Previous", false),
                                SizedBox(width: 0.1.w),
                                _paginationNumber("1", true),
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

  DataColumn _column(String title) {
    return DataColumn(
      label: Text(title, style: AppTextStyle.small(weight: FontWeight.w600)),
    );
  }

  DataRow _row(int index) {
    final item = _data[index];

    return DataRow(
      cells: [
        DataCell(Text("${index + 1}")),
        DataCell(Text(item['name'] ?? '—')),
        DataCell(Text(item['createdBy'] ?? "-")),
        DataCell(
          item['createdBy'] == null
              ? Text("-")
              : Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue, size: 18),
                    SizedBox(width: 1.w),
                    Icon(Icons.delete, color: Colors.red, size: 18),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _paginationButton(String text, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text),
    );
  }

  Widget _paginationNumber(String text, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: active ? Colors.white : Colors.black),
      ),
    );
  }
}

/// MOCK DATA
final List<Map<String, String?>> _data = [
  {"name": "Direct Entry", "createdBy": null},
  {"name": "Lead From Facebook", "createdBy": null},
  {"name": "Lead From CSV", "createdBy": null},
  {"name": "Lead From IVR", "createdBy": null},
  {"name": "Lead from Website", "createdBy": null},
  {"name": "Lead From Official WhatsApp", "createdBy": null},
  {"name": "Ads", "createdBy": "Boss"},
  {"name": "WhatsApp", "createdBy": "Oxdo technologies pvt ltd"},
];
