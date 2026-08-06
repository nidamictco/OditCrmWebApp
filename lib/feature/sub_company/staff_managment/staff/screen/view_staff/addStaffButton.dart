import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../add_staff/screen/add_staff.dart';
import '../../cubit/add_staff_cubit.dart';
import '../../../designation/cubit/designation_cubit.dart';

class AddNewStaffButton extends StatefulWidget {
  final VoidCallback? onTap;
  const AddNewStaffButton({super.key, this.onTap});

  @override
  State<AddNewStaffButton> createState() => _AddNewStaffButtonState();
}

class _AddNewStaffButtonState extends State<AddNewStaffButton> {
  bool isHovering = false;

  void _showAddStaffDialog(BuildContext context) {
    final staffCubit = context.read<StaffCubit>();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: staffCubit),
          BlocProvider(create: (_) => DesignationCubit()..fetchAll()),
        ],
        child: const AddStaff(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 7.5.w,
      height: 4.5.h,
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovering = true),
        onExit: (_) => setState(() => isHovering = false),
        child: GestureDetector(
          onTap: widget.onTap ?? () => _showAddStaffDialog(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: 5.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppThemeColors.basicGreen,
                width: 0.02.w,
              ),
              color: AppThemeColors.basicGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Add Staff",
                    style: AppTextStyle.small(
                      color: Colors.white,
                      size: 11.5,
                    ),
                  ),
                  SizedBox(width: 0.5.w),
                  const Icon(
                    Icons.person_add_alt_1_outlined,
                    color: Colors.white,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
