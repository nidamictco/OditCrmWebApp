import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

// ─────────────────────────────────────────────
// HELPER — call from anywhere with a BuildContext
// ─────────────────────────────────────────────

void showAlertDialog(
  BuildContext context, {
  required String message,
  required IconData icon,
  required Color iconColor,
  String buttonLabel = 'OK',
  VoidCallback? onConfirm,
}) {
  showDialog(
    context: context,
    builder: (_) => AppAlertDialog(
      message: message,
      icon: icon,
      iconColor: iconColor,
      buttonLabel: buttonLabel,
      onConfirm: onConfirm,
    ),
  );
}

// ─────────────────────────────────────────────
// WIDGET
// ─────────────────────────────────────────────

class AppAlertDialog extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final String buttonLabel;
  final VoidCallback? onConfirm;

  const AppAlertDialog({
    super.key,
    required this.message,
    required this.icon,
    required this.iconColor,
    this.buttonLabel = 'OK',
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.greyCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Icon(icon, color: iconColor, size: 85)],
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyle.medium(
          color: const Color(0xFF555555),
          size: 12.5.sp,
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('OK', style: AppTextStyle.medium(color: AppColors.white)),
        ),
      ],
    );
  }
}


// // ERROR
// showAlertDialog(
//   context,
//   message: state.message,
//   icon: Icons.error_outline,
//   iconColor: Colors.red,
// );

// // success
// showAlertDialog(
//   context,
//   message: 'Staff updated successfully',
//   icon: Icons.check_circle_outline,
//   iconColor: Colors.green,
// );


// //conform call back 

// showAlertDialog(
//   context,
//   message: 'Are you sure?',
//   icon: Icons.warning_amber_rounded,
//   iconColor: Colors.orange,
//   buttonLabel: 'Confirm',
//   onConfirm: () => doSomething(),
// );