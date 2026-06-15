import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/data/add_lead_repo.dart';
import 'package:Odit_CRM/feature/sub_company/sidebar/main_screen.dart';
import 'package:sizer/sizer.dart';

class AddLeadsButton extends StatefulWidget {
  const AddLeadsButton({super.key});

  @override
  State<AddLeadsButton> createState() => _AddLeadsButtonState();
}

class _AddLeadsButtonState extends State<AddLeadsButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),

      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(selectedIndex: 1),
            ),
          );
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,

          height: 6.h,
          padding: const EdgeInsets.symmetric(horizontal: 12),

          decoration: BoxDecoration(
            color: isHovering
                ? AppColors.green
                : AppColors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),

          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: isHovering ? Colors.white : AppColors.green,
                size: 2.5.h,
              ),
              const SizedBox(width: 5),
              Text(
                "Add Leads",
                style: AppTextStyle.small(
                  color: isHovering ? Colors.white : AppColors.green,
                  size: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}