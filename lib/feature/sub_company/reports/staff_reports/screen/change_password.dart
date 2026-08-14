import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/feature/auth/cubit/auth/auth_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/cubit/add_staff_state.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Validation state for a [PasswordTextField]'s border/indicator treatment.
enum PasswordFieldState { none, valid, invalid }

/// A single password requirement rule shown under the "Password Requirements"
/// heading. Add more instances to the list passed into [ChangePasswordDialog]
/// to extend the rule set later.
class PasswordRequirement {
  const PasswordRequirement(this.text);

  final String text;
}

/// Shows the [ChangePasswordDialog] using [showDialog].
///
/// Must be called from a context that sits below a [StaffCubit] provider
/// (e.g. the same `BlocProvider<StaffCubit>` scope as the staff list /
/// staff detail screen), since the dialog reads and listens to it directly.
///
/// Usage:
/// ```dart
/// showChangePasswordDialog(context, staff: staff);
/// ```
Future<void> showChangePasswordDialog(
  BuildContext context, {
  required StaffModel staff,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: context.read<StaffCubit>(),
      child: ChangePasswordDialog(staff: staff),
    ),
  );
}

/// A reusable "Change Password" alert dialog.
///
/// Wraps its own controllers/obscure-flags/validation state and drives the
/// actual password update through [StaffCubit.updateStaffField], mirroring
/// the behaviour of the original `ChangePasswordScreen`.
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({
    super.key,
    required this.staff,
    this.onForgotPassword,
    this.requirements = const [
      PasswordRequirement('Please add 6–12 characters to create safe password'),
    ],
  });

  final StaffModel staff;
  final VoidCallback? onForgotPassword;
  final List<PasswordRequirement> requirements;

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  static const double _dialogWidth = 500;
  static const double _dialogPadding = 32;
  static const double _sectionSpacing = 10;
  static const double _fieldSpacing = 15;
  static const double _labelSpacing = 8;
  static const double _buttonRowTopSpacing = 28;

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  // Snapshot of the staff's existing password, captured once when the
  // dialog opens. The Old Password field is validated against this value
  // in real time as the user types (see [_onOldPasswordChanged]).
  late final String? _currentPassword;

  PasswordFieldState _oldPasswordState = PasswordFieldState.none;
  PasswordFieldState _newPasswordState = PasswordFieldState.none;
  PasswordFieldState _confirmPasswordState = PasswordFieldState.none;

  @override
  void initState() {
    super.initState();
    _currentPassword = widget.staff.password;
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Real-time validation for the Old Password field, wired to its
  /// `onChanged` callback. Compares the entered value against the
  /// staff's stored password and updates the border/indicator state.
  void _onOldPasswordChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _oldPasswordState = PasswordFieldState.none;
      } else if (value == _currentPassword) {
        _oldPasswordState = PasswordFieldState.valid;
      } else {
        _oldPasswordState = PasswordFieldState.invalid;
      }
    });
  }

  bool _validate() {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (_oldPasswordState != PasswordFieldState.valid) {
      setState(() {
        _oldPasswordState = _oldPasswordController.text.isEmpty
            ? PasswordFieldState.none
            : PasswordFieldState.invalid;
      });
      _showSnack('Old password is incorrect.', AppThemeColors.statusSuspended);
      return false;
    }

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _newPasswordState = newPassword.isEmpty
            ? PasswordFieldState.invalid
            : PasswordFieldState.valid;
        _confirmPasswordState = confirmPassword.isEmpty
            ? PasswordFieldState.invalid
            : PasswordFieldState.valid;
      });
      _showSnack('Please fill in both fields.', AppThemeColors.statusSuspended);
      return false;
    }

    if (newPassword.length < 6) {
      setState(() => _newPasswordState = PasswordFieldState.invalid);
      _showSnack(
        'Password must be at least 6 characters.',
        AppThemeColors.statusSuspended,
      );
      return false;
    }

    if (newPassword.length > 12) {
      setState(() => _newPasswordState = PasswordFieldState.invalid);
      _showSnack(
        'Password must be at most 12 characters.',
        AppThemeColors.statusSuspended,
      );
      return false;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _newPasswordState = PasswordFieldState.valid;
        _confirmPasswordState = PasswordFieldState.invalid;
      });
      _showSnack('Passwords do not match.', AppThemeColors.statusSuspended);
      return false;
    }

    if (widget.staff.id == null) {
      _showSnack('Staff ID not found.', AppThemeColors.statusSuspended);
      return false;
    }

    setState(() {
      _newPasswordState = PasswordFieldState.valid;
      _confirmPasswordState = PasswordFieldState.valid;
    });
    return true;
  }

  void _handleChangePassword() {
    if (_isSaving) return;
    if (!_validate()) return;

    setState(() => _isSaving = true);

    context.read<StaffCubit>().updateStaffField(widget.staff.id!, {
      'password': _newPasswordController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffCubit, StaffState>(
      listener: (context, state) {
        if (state is StaffLoaded) {
          setState(() => _isSaving = false);
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          _showSnack(
            'Password changed successfully.',
            AppThemeColors.statusActive,
          );

          // Firestore and StaffCubit's own state are already up to date at
          // this point (updateStaffField() re-fetches internally). If the
          // staff member whose password just changed is the currently
          // logged-in user, AuthCubit's cached Authenticated(user) and the
          // session persisted via SessionService are a *separate* stale
          // copy that won't pick up the new password until the next login.
          // refreshUser() re-fetches from Firestore and re-saves the
          // session, keeping all three in sync without duplicating any
          // session logic here. Changing another staff member's password
          // (admin flow) intentionally leaves the current session alone.
          final authState = context.read<AuthCubit>().state;
          if (authState is Authenticated &&
              authState.user.id == widget.staff.id) {
            context.read<AuthCubit>().refreshUser(widget.staff.id!);
          }

          Navigator.of(context).pop();
        }
        if (state is StaffError) {
          setState(() => _isSaving = false);
          _showSnack(state.message, AppThemeColors.statusSuspended);
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: _dialogWidth,
          padding: const EdgeInsets.all(_dialogPadding),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DialogHeader(title: 'Change Password'),
              const SizedBox(height: _sectionSpacing),
              _PasswordFieldLabel(
                label: 'Old Password',
                showValidIndicator:
                    _oldPasswordState == PasswordFieldState.valid,
              ),
              const SizedBox(height: _labelSpacing),
              PasswordTextField(
                controller: _oldPasswordController,
                obscureText: _obscureOld,
                validationState: _oldPasswordState,
                hintText: 'Enter old password',
                onVisibilityChanged: () =>
                    setState(() => _obscureOld = !_obscureOld),
                onChanged: _onOldPasswordChanged,
              ),
              const SizedBox(height: _fieldSpacing),
              const _PasswordFieldLabel(label: 'New Password'),
              const SizedBox(height: _labelSpacing),
              PasswordTextField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                validationState: _newPasswordState,
                hintText: 'Enter new password',
                onVisibilityChanged: () =>
                    setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: _sectionSpacing),
              PasswordRequirementsSection(requirements: widget.requirements),
              const SizedBox(height: _sectionSpacing),
              const _PasswordFieldLabel(label: 'Confirm New Password'),
              const SizedBox(height: _labelSpacing),
              PasswordTextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                validationState: _confirmPasswordState,
                hintText: 'Enter new password',
                onVisibilityChanged: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: _buttonRowTopSpacing),
              _DialogActionsRow(
                isSaving: _isSaving,
                onForgotPassword: widget.onForgotPassword ?? () {},
                onCancel: () => Navigator.of(context).pop(),
                onChangePassword: _handleChangePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Title + underline divider shown at the top of the dialog.
class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.heading(
            color: AppThemeColors.sidebarTxtClr,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 160,
              height: 2,
              color: AppThemeColors.appPrimaryColor,
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.grey.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Field label row, optionally showing a green "valid" check indicator
/// next to it (used for the Old Password field in the design).
class _PasswordFieldLabel extends StatelessWidget {
  const _PasswordFieldLabel({
    required this.label,
    this.showValidIndicator = false,
  });

  final String label;
  final bool showValidIndicator;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyle.medium(color: AppThemeColors.sidebarTxtClr),
        ),
        if (showValidIndicator) ...[
          const SizedBox(width: 8),
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppThemeColors.statusActive,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          ),
        ],
      ],
    );
  }
}

/// A reusable password input with a visibility-toggle suffix icon and a
/// border color driven by [validationState].
///
/// Can be reused for any password field outside of [ChangePasswordDialog]
/// as well.
class PasswordTextField extends StatelessWidget {
  const PasswordTextField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.onVisibilityChanged,
    this.validationState = PasswordFieldState.none,
    this.hintText,
    this.label,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onVisibilityChanged;
  final PasswordFieldState validationState;
  final String? hintText;

  /// Optional label rendered above the field. Leave null when the label
  /// is rendered separately (as [ChangePasswordDialog] does via
  /// [_PasswordFieldLabel]) to avoid duplication.
  final String? label;

  /// Optional real-time change callback (e.g. used by the Old Password
  /// field to validate against the staff's stored password as the user
  /// types).
  final ValueChanged<String>? onChanged;

  Color get _borderColor {
    switch (validationState) {
      case PasswordFieldState.valid:
        return AppThemeColors.statusActive;
      case PasswordFieldState.invalid:
        return AppThemeColors.statusSuspended;
      case PasswordFieldState.none:
        return AppColors.grey.withOpacity(0.35);
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 1.4),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              onChanged: onChanged,
              style: AppTextStyle.medium(color: AppThemeColors.sidebarTxtClr),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: AppTextStyle.medium(color: AppThemeColors.subText),
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: onVisibilityChanged,
            child: Icon(
              obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 15,
              color: AppThemeColors.subText,
            ),
          ),
        ],
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PasswordFieldLabel(label: label!),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}

/// "Password Requirements" heading plus a bulleted list of rules.
/// Pass additional [PasswordRequirement]s to extend the rule set — no
/// changes to this widget are needed when new rules are added.
class PasswordRequirementsSection extends StatelessWidget {
  const PasswordRequirementsSection({super.key, required this.requirements});

  final List<PasswordRequirement> requirements;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password Requirements',
          style: AppTextStyle.medium(color: AppThemeColors.sidebarTxtClr),
        ),
        const SizedBox(height: 8),
        ...requirements.map(
          (rule) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _RequirementBullet(text: rule.text),
          ),
        ),
      ],
    );
  }
}

class _RequirementBullet extends StatelessWidget {
  const _RequirementBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 8),
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: AppThemeColors.subText,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(child: Text(text, style: AppTextStyle.subText)),
      ],
    );
  }
}

/// Bottom row: "Forgot Password?" link on the left, Cancel / Change
/// Password buttons on the right. Shows a spinner on the filled button
/// while [isSaving] is true, matching the original screen's save state.
class _DialogActionsRow extends StatelessWidget {
  const _DialogActionsRow({
    required this.isSaving,
    required this.onForgotPassword,
    required this.onCancel,
    required this.onChangePassword,
  });

  final bool isSaving;
  final VoidCallback onForgotPassword;
  final VoidCallback onCancel;
  final VoidCallback onChangePassword;

  static const double _buttonHeight = 44;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: isSaving ? null : onForgotPassword,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('Forgot Password?', style: AppTextStyle.link()),
        ),
        const Spacer(),
        _OutlinedDialogButton(
          label: 'Cancel',
          height: _buttonHeight,
          onPressed: isSaving ? null : onCancel,
        ),
        const SizedBox(width: 12),
        _FilledDialogButton(
          label: 'Change Password?',
          height: _buttonHeight,
          isLoading: isSaving,
          onPressed: isSaving ? null : onChangePassword,
        ),
      ],
    );
  }
}

class _OutlinedDialogButton extends StatelessWidget {
  const _OutlinedDialogButton({
    required this.label,
    required this.height,
    required this.onPressed,
  });

  final String label;
  final double height;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          side: BorderSide(color: AppThemeColors.subText.withOpacity(0.35)),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.medium(color: AppThemeColors.subText),
        ),
      ),
    );
  }
}

class _FilledDialogButton extends StatelessWidget {
  const _FilledDialogButton({
    required this.label,
    required this.height,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final double height;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppThemeColors.statusActive,
          disabledBackgroundColor: AppThemeColors.statusActive.withOpacity(0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(label, style: AppTextStyle.medium(color: Colors.white)),
      ),
    );
  }
}
