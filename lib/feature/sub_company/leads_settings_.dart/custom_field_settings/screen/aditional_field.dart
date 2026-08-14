import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:Odit_CRM/core/utils/alert_dialog/confirm_alert.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/widget/new_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/utils/show_entries.dart';
import 'package:Odit_CRM/core/utils/table.dart';
import 'package:Odit_CRM/core/utils/top_bread_crumb_bar.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/custom_field_settings/cubit/custom_field_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/custom_field_settings/cubit/custom_field_state.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/custom_field_settings/data/custom_field_repo.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/custom_field_settings/model/custom_field_model.dart';
import 'package:sizer/sizer.dart';

class AdditionalFieldsSection extends StatefulWidget {
  const AdditionalFieldsSection({super.key});

  @override
  State<AdditionalFieldsSection> createState() =>
      _AdditionalFieldsSectionState();
}

class _AdditionalFieldsSectionState extends State<AdditionalFieldsSection> {
  String _searchQuery = '';
  String _selectedEntries = '10';
  int _currentPage = 1;

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
    return q.isEmpty
        ? all
        : all.where((e) => e.fieldName.toLowerCase().contains(q)).toList();
  }

  List<AdditionalFieldModel> _pagedFields(
    List<AdditionalFieldModel> allFiltered,
  ) {
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
    setState(() => _currentPage = page);
  }

  void _resetPage() {
    _currentPage = 1;
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
        backgroundColor: AppThemeColors.scaffoldBg,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 2.w, right: 2.w, bottom: 1.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── HEADER ──────────────────────────────────────────────
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Additional Fields",
                            style: AppTextStyle.medium(
                              size: 14.5,
                              color: AppThemeColors.sidebarTxtClr,
                              weight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "If you require extra fields on the lead creation form, kindly generate the fields here.",
                            style: AppTextStyle.medium(
                              size: 11.5,
                              color: AppThemeColors.hintColor,
                              weight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        // SizedBox(width: 0.5.w),
                        // Tooltip(
                        //   textAlign: TextAlign.center,
                        //   message:
                        //       'Custom Field Settings allow\nyou to add extra fields as\nneeded to capture specific\ninformation that isn\'t covered\nby the default options.',
                        //   decoration: BoxDecoration(
                        //     color: Colors.black,
                        //     borderRadius: BorderRadius.circular(6),
                        //   ),
                        //   textStyle: const TextStyle(
                        //     color: Colors.white,
                        //     fontSize: 12,
                        //   ),
                        //   waitDuration: const Duration(milliseconds: 200),
                        //   child: Container(
                        //     height: 2.h,
                        //     width: 2.w,
                        //     decoration: BoxDecoration(
                        //       shape: BoxShape.circle,
                        //       border: Border.all(
                        //         color: AppColors.green,
                        //         width: 1,
                        //       ),
                        //     ),
                        //     child: Icon(
                        //       Icons.question_mark_rounded,
                        //       size: 10.sp,
                        //       color: AppColors.green,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),

                    // // ── INPUT FIELDS ─────────────────────────────────────────
                    // Column(
                    //   children: List.generate(_controllers.length, (index) {
                    //     return Padding(
                    //       padding: EdgeInsets.only(bottom: 1.5.h),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           // TEXT FIELD
                    //           Container(
                    //             height: 5.5.h,
                    //             width: 40.w,
                    //             decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.circular(6),
                    //               border: Border.all(
                    //                 color: AppColors.lightGrey,
                    //               ),
                    //               color: AppColors.container,
                    //             ),
                    //             child: Center(
                    //               child: TextField(
                    //                 controller: _controllers[index],
                    //                 style: AppTextStyle.medium(),
                    //                 textAlign: TextAlign.left,
                    //                 textAlignVertical: TextAlignVertical.center,
                    //                 decoration: InputDecoration(
                    //                   hintText: "Enter field name",
                    //                   hintStyle: AppTextStyle.small(
                    //                     size: 11.sp,
                    //                   ),
                    //                   border: InputBorder.none,
                    //                   isCollapsed: true,
                    //                   contentPadding: EdgeInsets.only(
                    //                     left: 2.w,
                    //                     right: 2.w,
                    //                     top: 0,
                    //                     bottom: 0,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),

                    //           SizedBox(width: 1.w),

                    //           BlocBuilder<
                    //             AdditionalFieldsCubit,
                    //             AdditionalFieldsState
                    //           >(
                    //             buildWhen: (prev, curr) =>
                    //                 prev.isSaving != curr.isSaving,
                    //             builder: (context, state) {
                    //               return Center(
                    //                 child: SizedBox(
                    //                   width: 7.w,
                    //                   height: 5.5.h,
                    //                   child: ElevatedButton(
                    //                     style: ElevatedButton.styleFrom(
                    //                       backgroundColor: Colors.indigo,
                    //                       shape: RoundedRectangleBorder(
                    //                         borderRadius: BorderRadius.circular(
                    //                           3,
                    //                         ),
                    //                       ),
                    //                       elevation: 0,
                    //                     ),
                    //                     onPressed: state.isSaving
                    //                         ? null
                    //                         : _submit,
                    //                     child: state.isSaving
                    //                         ? SizedBox(
                    //                             height: 2.h,
                    //                             width: 2.h,
                    //                             child:
                    //                                 const CircularProgressIndicator(
                    //                                   color: Colors.white,
                    //                                   strokeWidth: 2,
                    //                                 ),
                    //                           )
                    //                         : Text(
                    //                             "Submit",
                    //                             style: AppTextStyle.medium(
                    //                               color: AppColors.white,
                    //                             ),
                    //                           ),
                    //                   ),
                    //                 ),
                    //               );
                    //             },
                    //           ),
                    //         ],
                    //       ),
                    //     );
                    //   }),
                    // ),
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
                      exportWidget: GestureDetector(
                        onTap: () {
                          final cubit = context
                              .read<
                                AdditionalFieldsCubit
                              >(); // outer, provider-scoped context

                          showDialog(
                            context: context,
                            builder: (dialogContext) => LeadSettingsAlert(
                              title: 'Add Field',
                              fieldLabel: 'Field',
                              onSubmit: (String value) async {
                                final exists = cubit.state.savedFields.any(
                                  (f) =>
                                      f.fieldName.toLowerCase() ==
                                      value.toLowerCase(),
                                );

                                if (exists) {
                                  _showSnackBar(
                                    'This field already exists.',
                                    isError: true,
                                  );
                                  return; // keep dialog open
                                }

                                Navigator.pop(
                                  dialogContext,
                                ); // close LeadSettingsAlert
                                await cubit.saveFields([value]);
                              },
                            ),
                          );
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
                              "Add Field",
                              style: AppTextStyle.small(
                                color: Colors.white,
                                size: 10.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
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
                      child: BlocBuilder<AdditionalFieldsCubit, AdditionalFieldsState>(
                        builder: (context, state) {
                          if (state.isLoading) {
                            return SizedBox(
                              height: 20.h,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final allFiltered = _filtered(state.savedFields);
                          final totalCount = allFiltered.length;
                          final totalPages = _totalPages(totalCount);
                          final limit = int.tryParse(_selectedEntries) ?? 10;

                          if (_currentPage > totalPages) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() => _currentPage = totalPages);
                            });
                          }

                          final pagedList = _pagedFields(allFiltered);

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
                                    TableColumn(title: "Field Name"),
                                    TableColumn(title: "Action"),
                                  ],
                                  rows: pagedList.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final field = entry.value;
                                    final serial =
                                        (_currentPage - 1) * limit + index + 1;

                                    return [
                                      Text(
                                        '$serial',
                                        style: AppTextStyle.medium(),
                                      ),
                                      Text(
                                        field.fieldName,
                                        style: AppTextStyle.medium(),
                                      ),
                                      Center(
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                // _showEditDialog(cat),
                                                // if (!state.isSubmitting) {
                                                final cubit = context
                                                    .read<
                                                      AdditionalFieldsCubit
                                                    >();

                                                showDialog(
                                                  context: context,
                                                  builder: (dialogContext) => LeadSettingsAlert(
                                                    fieldLabel: 'Edit Field',
                                                    title: 'Edit Field',
                                                    constrainsWidth: 700,
                                                    initialValue:
                                                        field.fieldName,
                                                    onSubmit: (String value) async {
                                                      final exists = cubit
                                                          .state
                                                          .savedFields
                                                          .any(
                                                            (f) =>
                                                                f.fieldName
                                                                    .toLowerCase() ==
                                                                value
                                                                    .toLowerCase(),
                                                          );

                                                      if (exists) {
                                                        _showSnackBar(
                                                          'This field already exists.',
                                                          isError: true,
                                                        );
                                                        return; // keep dialog open
                                                      }
                                                      Navigator.pop(
                                                        dialogContext,
                                                      ); // close LeadSettingsAlert
                                                      await cubit.updateField(
                                                        field.id!,
                                                        value,
                                                      );
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "$value updated successfully!",
                                                          ),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                                // }
                                              },
                                              child: Container(
                                                height: 28,
                                                width: 28,
                                                decoration: BoxDecoration(
                                                  // color: const Color(
                                                  //   0xFFFEF2F2,
                                                  // ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xff3B82F6,
                                                    ),
                                                  ),
                                                ),
                                                child: Image.asset(
                                                  AssetResources.edit,
                                                  scale: 1.7,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 1.w),
                                            GestureDetector(
                                              onTap: () {
                                                // context.read<AdditionalFieldsCubit>().deleteField(field.id!);
                                                // ScaffoldMessenger.of(context).showSnackBar(
                                                //   SnackBar(
                                                //     content: Text("${field.fieldName} deleted successfully!"),
                                                //     backgroundColor: Colors.red,
                                                //   ),
                                                // );
                                                final cubit = context
                                                    .read<
                                                      AdditionalFieldsCubit
                                                    >();

                                                showDialog(
                                                  context: context,
                                                  builder: (dialogContext) =>
                                                      ConfirmAlertWidget(
                                                        type: ConfirmAlertType
                                                            .delete,
                                                        title:
                                                            'Delete Additional Field',
                                                        message:
                                                            'Are you sure you want to delete this ${field.fieldName} Additional Field?',
                                                        onCancel: () {
                                                          Navigator.pop(
                                                            dialogContext,
                                                          );
                                                        },
                                                        onDelete: () {
                                                          Navigator.pop(
                                                            dialogContext,
                                                          );
                                                          cubit.deleteField(
                                                            field.id!,
                                                          );
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                "${field.fieldName} deleted successfully!",
                                                              ),
                                                              backgroundColor:
                                                                  Colors.red,
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
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFFCA5A5,
                                                    ),
                                                  ),
                                                ),
                                                child: Image.asset(
                                                  AssetResources.deleteIcon,
                                                  scale: 1.7,
                                                ),
                                              ),
                                            ),
                                          ],
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
