import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import '../../feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import '../../feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'dropdown.dart';

void showAssignStaffDialog(
  String fromPage,
  List<AddLeadModel> selectedLeads,
  BuildContext context, {
  required Function(String? selectedStaffId, String? selectedStaffName)
  onSubmit,
}) {
  // ── Pre-populate if all selected leads share the same assigned staff ──
  final firstStaff = selectedLeads.first.assignedStaff;
  final allSameStaff = selectedLeads.every(
    (l) => l.assignedStaff == firstStaff,
  );

  String? selectedStaffId = allSameStaff
      ? selectedLeads.first.assignedStaffId
      : null;
  String? selectedStaffName = allSameStaff ? firstStaff : null;
  bool showSameStaffWarning = false;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: context.read<AddLeadCubit>(),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocBuilder<AddLeadCubit, AddLeadState>(
              builder: (context, state) {
                final staffList = state.staffList
                    .where((s) => !isInactiveStatus(s.status))
                    .toList();
                final staffNames = staffList.map((s) => s.name).toList();

                // ── Disable transfer if every selected lead already belongs
                //    to the chosen staff ────────────────────────────────────
                final isSameAsExisting =
                    selectedStaffName != null &&
                    selectedLeads.every(
                      (l) => l.assignedStaff == selectedStaffName,
                    );

                final screenWidth = MediaQuery.of(context).size.width;
                final dialogWidth = screenWidth < 540
                    ? screenWidth * 0.9
                    : 500.0;

                return Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: dialogWidth),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            'Assign Staff',
                            style: AppTextStyle.medium(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                              size: 14.5,
                              weight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          // Underline: green active segment + grey remainder
                          _TitleUnderline(width: dialogWidth),
                          SizedBox(height: 2.h),

                          if (fromPage != "followup") ...[
                            Text(
                              "${selectedLeads.length} lead(s) selected",
                              style: AppTextStyle.medium(
                                color: AppColors.black,
                                weight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 1.5.h),
                          ],

                          // // Field label
                          // Text(
                          //   'Staff',
                          //   style: AppTextStyle.medium(color: AppColors.black),
                          // ),
                          SizedBox(height: 0.5.h),

                          // ── Existing dropdown — untouched functionality ──
                          Dropdown(
                            label: 'Staff',
                            hint: 'Select Staff',
                            items: staffNames,
                            selectedValue: selectedStaffName,
                            onChanged: (val) {
                              setDialogState(() {
                                selectedStaffName = val;
                                selectedStaffId = val != null
                                    ? staffList
                                          .firstWhere((s) => s.name == val)
                                          .id
                                    : null;
                                showSameStaffWarning = false;
                              });
                            },
                          ),
                          // ── Warning shown when same staff is re-selected ──
                          if (showSameStaffWarning && isSameAsExisting) ...[
                            SizedBox(height: 1.h),
                            Text(
                              'This lead is already assigned to $selectedStaffName.',
                              style: AppTextStyle.small(
                                color: AppColors.red,
                                // weight: FontWeight.w400,
                              ),
                            ),
                          ],
                          SizedBox(height: 2.h),

                          // Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _CloseButton(
                                onPressed: () => Navigator.pop(dialogContext),
                              ),
                              SizedBox(width: 0.5.w),
                              _SubmitButton(
                                onPressed: () {
                                  if (isSameAsExisting) {
                                    setDialogState(() {
                                      showSameStaffWarning = true;
                                    });
                                    return;
                                  }
                                  onSubmit(
                                    selectedStaffId,
                                    selectedStaffName,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    },
  );
}

bool isInactiveStatus(dynamic statusValue) {
  if (statusValue == null) return false;
  if (statusValue is bool) return statusValue == false;
  if (statusValue is String) return statusValue.toUpperCase() == 'INACTIVE';
  return false;
}

/// Thin underline: green active portion + light grey remainder.
/// Mirrors `_TitleUnderline` from `LeadSettingsAlert`.
class _TitleUnderline extends StatelessWidget {
  final double width;
  const _TitleUnderline({required this.width});

  @override
  Widget build(BuildContext context) {
    final activeWidth = width * 0.18;
    return SizedBox(
      width: width,
      height: 2,
      child: Row(
        children: [
          Container(
            width: activeWidth,
            height: 2,
            color:
                AppThemeColors.primary, // adjust if your green lives elsewhere
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.black.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.black,
        side: BorderSide(color: AppColors.black.withOpacity(0.2)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text('Close', style: AppTextStyle.medium(color: AppColors.black)),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            AppThemeColors.statusActive, // matches statusActive green
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text('Submit', style: AppTextStyle.medium(color: Colors.white)),
    );
  }
}
