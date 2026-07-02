import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sizer/sizer.dart';

import '../../feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import '../../feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import '../../feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'dropdown.dart';
import 'popup_msg.dart';

// void showAssignStaffDialog(List<AddLeadModel> selectedLeads, BuildContext context, {required Function(String? selectedStaffId, String? selectedStaffName) onSubmit}) {
//   String? selectedStaffId;
//   String? selectedStaffName;

//   showDialog(
//     context: context,
//     builder: (dialogContext) {
//       return BlocProvider.value(
//         value: context.read<AddLeadCubit>(),
//         child: StatefulBuilder(
//           builder: (context, setDialogState) {
//             return BlocBuilder<AddLeadCubit, AddLeadState>(
//               builder: (context, state) {
//                 // 🔹 Use staffList directly from AddLeadState
//                 final staffList = state.staffList;
//                 final staffNames = staffList.map((s) => s.name).toList();

//                 return AppDialog(
//                   title: 'Assign Staff',
//                   width: 40.w,
//                   body: Padding(
//                     padding: EdgeInsets.all(1.w),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "${selectedLeads!.length} lead(s) selected",
//                           style: AppTextStyle.medium(
//                             color: AppColors.black,
//                             weight: FontWeight.w500,
//                           ),
//                         ),
//                         SizedBox(height: 1.5.h),
//                         Dropdown(
//                           label: 'Staff',
//                           hint: 'Select Staff',
//                           items: staffNames,
//                           selectedValue: selectedStaffName,
//                           onChanged: (val) {
//                             setDialogState(() {
//                               selectedStaffName = val;
//                               selectedStaffId = staffList
//                                   .firstWhere((s) => s.name == val)
//                                   .id;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   onClose: () => Navigator.pop(dialogContext),
//                   onSubmit: () => onSubmit(selectedStaffId, selectedStaffName),
//                 );
//               },
//             );
//           },
//         ),
//       );
//     },
//   );
// }

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

  showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: context.read<AddLeadCubit>(),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocBuilder<AddLeadCubit, AddLeadState>(
              builder: (context, state) {
                final staffList = state.staffList;
                final staffNames = staffList.map((s) => s.name).toList();

                // ── Disable transfer if every selected lead already belongs
                //    to the chosen staff ────────────────────────────────────
                final isSameAsExisting =
                    selectedStaffName != null &&
                    selectedLeads.every(
                      (l) => l.assignedStaff == selectedStaffName,
                    );

                return AppDialog(
                  title: 'Assign Staff',
                  width: 40.w,
                  body: Padding(
                    padding: EdgeInsets.all(1.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (fromPage != "followup")
                          Text(
                            "${selectedLeads.length} lead(s) selected",
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
                              selectedStaffId = val != null
                                  ? staffList
                                        .firstWhere((s) => s.name == val)
                                        .id
                                  : null;
                            });
                          },
                        ),
                        // ── Warning shown when same staff is re-selected ──
                        // if (isSameAsExisting) ...[
                        //   SizedBox(height: 1.h),
                        //   Text(
                        //     'This lead is already assigned to the selected staff.',
                        //     style: AppTextStyle.small(
                        //       color: Colors.orange,
                        //       weight: FontWeight.w500,
                        //     ),
                        //   ),
                        // ],
                      ],
                    ),
                  ),
                  onClose: () => Navigator.pop(dialogContext),
                  // ── Block submit when same staff is selected ──────────────
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
