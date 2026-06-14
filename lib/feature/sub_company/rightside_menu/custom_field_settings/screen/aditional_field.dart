import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/show_entries.dart';
import 'package:oxdo/core/utils/table.dart';
import 'package:oxdo/core/utils/top_bread_crumb_bar.dart';
import 'package:oxdo/feature/sub_company/rightside_menu/custom_field_settings/cubit/custom_field_cubit.dart';
import 'package:oxdo/feature/sub_company/rightside_menu/custom_field_settings/cubit/custom_field_state.dart';
import 'package:oxdo/feature/sub_company/rightside_menu/custom_field_settings/data/custom_field_repo.dart';
import 'package:oxdo/feature/sub_company/rightside_menu/custom_field_settings/model/custom_field_model.dart';
import 'package:sizer/sizer.dart';

class AdditionalFieldsSection extends StatefulWidget {
  const AdditionalFieldsSection({super.key});

  @override
  State<AdditionalFieldsSection> createState() =>
      _AdditionalFieldsSectionState();
}

class _AdditionalFieldsSectionState extends State<AdditionalFieldsSection> {
 
 
  String _searchQuery = '';
  String _selectedEntries = '1';
 

  /// Local text controllers for the dynamic input rows
  final List<TextEditingController> _controllers = [TextEditingController()];

  

  // ─── Submit — delegates to Cubit ──────────────────────────────────────────

  Future<void> _submit() async {
    final values = _controllers.map((c) => c.text.trim()).toList();
    final hasContent = values.any((v) => v.isNotEmpty);

    if (!hasContent) {
      _showSnackBar('Please enter at least one field name.', isError: true);
      return;
    }

    await context.read<AdditionalFieldsCubit>().saveFields(values);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.red : Colors.teal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Filtered list based on search + entries limit ────────────────────────
   List<AdditionalFieldModel> _filtered(List<AdditionalFieldModel> all) {
    final q = _searchQuery.trim().toLowerCase();
    final limit = int.tryParse(_selectedEntries) ?? 10;
    final filtered = q.isEmpty
        ? all
        : all.where((e) => e.fieldName.toLowerCase().contains(q)).toList();
    return filtered.take(limit).toList();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdditionalFieldsCubit, AdditionalFieldsState>(
      listenWhen: (prev, curr) =>
          prev.isSaving != curr.isSaving ||
          prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        // Show success after saving completes
        if (!state.isSaving &&
            state.status == AdditionalFieldsStatus.success &&
            state.errorMessage == null) {
          _showSnackBar('Fields saved successfully!');
          // Clear local inputs after successful save
          setState(() {
            for (var c in _controllers) {
              c.clear();
            }
          });
        }

        // Show error if any
        if (state.errorMessage != null) {
          _showSnackBar(state.errorMessage!, isError: true);
          context.read<AdditionalFieldsCubit>().clearError();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            children: [
              TopBreadcrumbBar(
                subTitle: "Additional Fields",
                title: "Dashboard",
              ),
              Padding(
                padding: EdgeInsets.all(2.w),
                child: Container(
                  // height: 50.h,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── HEADER ──────────────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.all(1.w),
                        child: Row(
                          children: [
                            Text(
                              "Additional Fields",
                              style: AppTextStyle.medium(
                                size: 13.6.sp,
                                color: AppColors.black.withOpacity(0.77),
                                weight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 0.5.w),
                            Tooltip(
                              textAlign: TextAlign.center,
                              message:
                                  'Custom Field Settings allow\nyou to add extra fields as\nneeded to capture specific\ninformation that isn\'t covered\nby the default options.',
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              waitDuration: const Duration(milliseconds: 200),
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
                      ),

                      Padding(
                        padding: EdgeInsets.only(
                          left: 1.w,
                          right: 1.w,
                          bottom: 2.h,
                        ),
                        child: Text(
                          "If you require extra fields on the lead creation form, kindly generate the fields here.",
                          style: AppTextStyle.medium(size: 11.sp),
                        ),
                      ),

                      Divider(color: AppColors.divider),
                      SizedBox(height: 3.h),

                      // ── INPUT FIELDS ─────────────────────────────────────────
                      Column(
                        children: List.generate(_controllers.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 1.5.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // TEXT FIELD
                                Container(
                                  height: 5.5.h,
                                  width: 40.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.lightGrey,
                                    ),
                                    color: AppColors.container,
                                  ),
                                  child: Center(
                                    child: TextField(
                                      controller: _controllers[index],
                                      style: AppTextStyle.medium(),
                                      textAlign: TextAlign.left,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        hintText: "Enter field name",
                                        hintStyle: AppTextStyle.small(
                                          size: 11.sp,
                                        ),
                                        border: InputBorder.none,
                                        isCollapsed: true,
                                        contentPadding: EdgeInsets.only(
                                          left: 2.w,
                                          right: 2.w,
                                          top: 0,
                                          bottom: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 1.w),

                                BlocBuilder<
                                  AdditionalFieldsCubit,
                                  AdditionalFieldsState
                                >(
                                  buildWhen: (prev, curr) =>
                                      prev.isSaving != curr.isSaving,
                                  builder: (context, state) {
                                    return Center(
                                      child: SizedBox(
                                        width: 7.w,
                                        height: 5.5.h,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.indigo,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: state.isSaving
                                              ? null
                                              : _submit,
                                          child: state.isSaving
                                              ? SizedBox(
                                                  height: 2.h,
                                                  width: 2.h,
                                                  child:
                                                      const CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : Text(
                                                  "Submit",
                                                  style: AppTextStyle.medium(
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 3.h),

                      SizedBox(height: 0.5.h),
                      ShowEntries(
                        initialSearch: _searchQuery,
                        initialEntries: _selectedEntries,
                        onSearchChanged: (v) =>
                            setState(() => _searchQuery = v),
                        onEntriesChanged: (v) =>
                            setState(() => _selectedEntries = v),
                      ),
                      BlocBuilder<AdditionalFieldsCubit, AdditionalFieldsState>(
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

                          final rows = _filtered(state.savedFields);

                          return SizedBox(
                            child: CustomTable(
                              columns: [
                                TableColumn(title: "Sl No.", flex: 1),
                                TableColumn(title: "Field Name", flex: 4),
                                TableColumn(title: "Action", flex: 2),
                              ],
                              rows: rows.asMap().entries.map((entry) {
                                final index = entry.key;
                                final field = entry.value;
                                // final isDeleting = state.deletingId == cat.id;

                                return [
                                  Text(
                                    '${index + 1}',
                                    style: AppTextStyle.medium(),
                                  ),
                                  Text(
                                    field.fieldName,
                                    style: AppTextStyle.medium(),
                                  ),

                                  /// ACTION
                                  Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        context
                                            .read<AdditionalFieldsCubit>()
                                            .deleteField(field.id!);
                                      },
                                      child: Icon(
                                        Icons.delete_outline,
                                        size: 14.sp,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ];
                              }).toList(),
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
}
