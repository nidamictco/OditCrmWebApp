import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final Color activeContainerColor;
  final Color? inactiveContainerColor;
  final Color inactiveCircleColor;
  final ValueChanged<bool>? onChanged;
  final bool? notHaveBoader;

  const CustomSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.inactiveContainerColor,
    required this.inactiveCircleColor,
    required this.activeContainerColor,
    this.notHaveBoader = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 40,
        height: 21,
        padding: value
            ? const EdgeInsets.symmetric(vertical: 2.5)
            : const EdgeInsets.symmetric(vertical: 2.5),
        decoration: BoxDecoration(
          color: value
              ? activeContainerColor
              : inactiveContainerColor ?? AppColors.white,
          borderRadius: BorderRadius.circular(99),
          border: value == false
              ? notHaveBoader == false
                  ? Border.all(color: Colors.grey.shade400)
                  : Border.all(color: Colors.transparent)
              : Border.all(color: activeContainerColor),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: value == false ? inactiveCircleColor : AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
