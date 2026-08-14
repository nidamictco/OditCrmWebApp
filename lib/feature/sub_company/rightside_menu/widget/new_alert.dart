import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// A reusable "Add Field" alert dialog.
///
/// Usage:
/// ```dart
/// final result = await showDialog<String>(
///   context: context,
///   builder: (context) => const LeadSettingsAlert(),
/// );
///
/// if (result != null && result.isNotEmpty) {
///   // Handle the submitted field name.
/// }
/// ```
///
/// Pass [initialValue] to pre-fill the field (e.g. when editing).
class LeadSettingsAlert extends StatefulWidget {
  final String? initialValue;
  final String title;
  final String fieldLabel;
  final String hintText;
  final double constrainsWidth;
  final ValueChanged<String> onSubmit; // instead of VoidCallback onPressed
  const LeadSettingsAlert({
    super.key,
    this.initialValue,
    this.title = 'Add Field',
    this.fieldLabel = 'Field',
    this.hintText = 'Enter',
    this.constrainsWidth = 400,
    required this.onSubmit,
  });

  @override
  State<LeadSettingsAlert> createState() => _LeadSettingsAlertState();
}

class _LeadSettingsAlertState extends State<LeadSettingsAlert> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onClose() {
    Navigator.pop(context);
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 540 ? screenWidth * 0.9 : 500.0;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  widget.title,
                  style: AppTextStyle.medium(
                    color: AppThemeColors.sidebarTxtClr,
                    fontWeight: FontWeight.bold,
                    size: 14.5,
                    weight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                // Underline: dark segment + light grey remainder
                _TitleUnderline(width: widget.constrainsWidth),
                SizedBox(height: 2.h),
                // Field label
                Text(
                  widget.fieldLabel,
                  style: AppTextStyle.medium(
                    color: AppThemeColors.sidebarTxtClr,
                  ),
                ),

                SizedBox(height: 0.5.h),
                // Reusable text field
                _AddFieldTextField(
                  controller: _controller,
                  hintText: widget.hintText,
                ),
                SizedBox(height: 2.h),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _CloseButton(onPressed: _onClose),
                    SizedBox(width: 0.5.w),
                    _SubmitButton(onPressed: _onSubmit),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin underline: dark/black active portion + light grey remainder.
class _TitleUnderline extends StatelessWidget {
  final double width; // renamed from `constraints` to avoid shadowing
  const _TitleUnderline({required this.width});

  @override
  Widget build(BuildContext context) {
    final activeWidth = width * 0.18;
    return SizedBox(
      width: width, // ← this is what actually sets the underline's width
      height: 2,
      child: Row(
        children: [
          Container(
            width: activeWidth,
            height: 2,
            color: AppThemeColors.appPrimaryColor,
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppThemeColors.subText.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable rounded text field used inside LeadSettingsAlert (and elsewhere,
/// if needed) matching the app's existing border/theme conventions.
class _AddFieldTextField extends StatelessWidget {
  const _AddFieldTextField({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: AppTextStyle.medium(color: AppThemeColors.sidebarTxtClr),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyle.medium(color: AppThemeColors.subText),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppThemeColors.textfieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppThemeColors.textfieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppThemeColors.textfieldBorder),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
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
        foregroundColor: AppThemeColors.sidebarTxtClr,
        side: BorderSide(color: AppThemeColors.textfieldBorder),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        'Close',
        style: AppTextStyle.medium(color: AppThemeColors.sidebarTxtClr),
      ),
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
        backgroundColor: AppThemeColors.statusActive,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text('Submit', style: AppTextStyle.medium(color: Colors.white)),
    );
  }
}
