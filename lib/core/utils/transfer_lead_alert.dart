import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/utils/popup_msg.dart';
import 'package:sizer/sizer.dart';

import '../../feature/lead_managment/leads/cubit/add_lead_cubit.dart';
import '../../feature/lead_managment/leads/cubit/add_lead_state.dart';
import '../../feature/lead_managment/leads/model/add_lead_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'dropdown.dart';

void showAssignStaffDialog(List<AddLeadModel> selectedLeads, BuildContext context, {required Function(String? selectedStaffId, String? selectedStaffName) onSubmit}) {
  String? selectedStaffId;
  String? selectedStaffName;


  showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: context.read<AddLeadCubit>(),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocBuilder<AddLeadCubit, AddLeadState>(
              builder: (context, state) {
                // 🔹 Use staffList directly from AddLeadState
                final staffList = state.staffList;
                final staffNames = staffList.map((s) => s.name).toList();

                return AppDialog(
                  title: 'Assign Staff',
                  width: 40.w,
                  body: Padding(
                    padding: EdgeInsets.all(1.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${selectedLeads!.length} lead(s) selected",
                          style: AppTextStyle.medium(
                            color: AppColors.black,
                            weight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Dropdown(
                          label: 'Staff',
                          hint: 'Select Staff',
                          items: staffNames,
                          selectedValue: selectedStaffName,
                          onChanged: (val) {
                            setDialogState(() {
                              selectedStaffName = val;
                              selectedStaffId = staffList
                                  .firstWhere((s) => s.name == val)
                                  .id;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  onClose: () => Navigator.pop(dialogContext),
                  onSubmit: () => onSubmit(selectedStaffId, selectedStaffName),
                );
              },
            );
          },
        ),
      );
    },
  );
}