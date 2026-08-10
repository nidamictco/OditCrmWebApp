import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

// Sizer scales by percentage of the CURRENT screen's width. Figma frame is
// the desktop one, 1512 x 1043, so px values are converted against that.
const double _designWidth = 1512;

/// Converts a Figma px value (against the 1512-wide desktop frame) into a
/// sizer `.w` percentage, then clamps it to [min]–[max] logical pixels.
double wPx(double px, double min, double max) =>
    ((px / _designWidth) * 100).w.clamp(min, max);

/// Which flavor of confirm alert to show. Drives which image is used and
/// which action button(s) appear alongside Cancel.
enum ConfirmAlertType { delete, restore, both }

/// A single reusable widget for the "Delete Lead" / "Restore leads" /
/// "Selected Items" confirm dialogs.
///
/// Everything that differs between delete/restore/both (image, container
/// width, which action button(s) show, their color) is driven by [type].
/// Everything that differs between *calls* (heading + body text, e.g.
/// "DELETE LEAD" / "Are you sure want to delete "Nidha"? This action
/// cannot be undone.") is passed in by the caller via [title] and
/// [message], since that text depends on which action triggered the alert.
class ConfirmAlertWidget extends StatelessWidget {
  final ConfirmAlertType type;
  final String title;
  final String message;
  final VoidCallback onCancel;

  /// Required when [type] is delete or both.
  final VoidCallback? onDelete;

  /// Required when [type] is restore or both.
  final VoidCallback? onRestore;

  const ConfirmAlertWidget({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.onCancel,
    this.onDelete,
    this.onRestore,
  }) : assert(type != ConfirmAlertType.delete || onDelete != null),
       assert(type != ConfirmAlertType.restore || onRestore != null),
       assert(
         type != ConfirmAlertType.both ||
             (onDelete != null && onRestore != null),
       );

  /// Convenience helper so callers don't need to build a Dialog manually.
  ///
  /// Usage:
  /// ```dart
  /// ConfirmAlertWidget.show(
  ///   context,
  ///   type: ConfirmAlertType.delete,
  ///   title: 'DELETE LEAD',
  ///   message: 'Are you sure want to delete "Nidha"?\nThis action cannot be undone.',
  ///   onCancel: () => Navigator.of(context).pop(),
  ///   onDelete: () { ... },
  /// );
  /// ```
  static Future<void> show(
    BuildContext dialogContext, {
    required ConfirmAlertType type,
    required String title,
    required String message,
    VoidCallback? onCancel,
    VoidCallback? onDelete,
    VoidCallback? onRestore,
  }) {
    return showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (_) => ConfirmAlertWidget(
        type: type,
        title: title,
        message: message,
        onCancel: dialogContext.pop,
        onDelete: onDelete,
        onRestore: onRestore,
      ),
    );
  }

  static const Color _deleteColor = Color(0xFFF04438);
  static const Color _restoreColor = Color(0xFF17B26A);
  static const Color _cancelBg = Color(0xFFF2F4F7);
  static const Color _cancelText = Color(0xFF344054);

  String get _imagePath {
    switch (type) {
      case ConfirmAlertType.delete:
        return AssetResources.delete;
      case ConfirmAlertType.restore:
        return AssetResources.restore;
      case ConfirmAlertType.both:
        return AssetResources.bothDeleteAndRestore;
    }
  }

  // Figma tokens (Layout panel, 1512x1043 desktop frame):
  // Width: 423px (delete/restore) or 574px (both)  Height: 312.58px (all)
  // Radius: 24px  Padding: top 30 / right 60 / bottom 30 / left 60  Gap: 20px
  double get _containerWidth => type == ConfirmAlertType.both ? 574 : 423;

  @override
  Widget build(BuildContext context) {
    final double gap = 20;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Container(
        width: _containerWidth,
        height: MediaQuery.of(context).size.height * 0.5,
        // constraints: const BoxConstraints(minHeight: 330.58),
        padding: const EdgeInsets.only(
          top: 30,
          right: 60,
          bottom: 30,
          left: 60,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12, width: wPx(1, 1, 2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(_imagePath, height: 119.58, width: 198),
            SizedBox(height: gap),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyle.medium(
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
                color: Colors.black87,
                letterSpacing: 0.6,
              ),
            ),
            SizedBox(height: gap * 0.5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.small(fontSize: 11.sp, color: Colors.black54),
            ),
            SizedBox(height: gap),
            _buildButtonRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow() {
    final List<Widget> buttons = [_cancelButton()];

    switch (type) {
      case ConfirmAlertType.delete:
        buttons.add(const SizedBox(width: 12));
        buttons.add(
          _actionButton(
            label: 'Delete',
            color: _deleteColor,
            onPressed: onDelete!,
          ),
        );
        break;
      case ConfirmAlertType.restore:
        buttons.add(const SizedBox(width: 14));
        buttons.add(
          _actionButton(
            label: 'Restore',
            color: _restoreColor,
            onPressed: onRestore!,
          ),
        );
        break;
      case ConfirmAlertType.both:
        buttons.add(const SizedBox(width: 14));
        buttons.add(
          _actionButton(
            label: 'Restore',
            color: _restoreColor,
            onPressed: onRestore!,
          ),
        );
        buttons.add(const SizedBox(width: 14));
        buttons.add(
          _actionButton(
            label: 'Delete',
            color: _deleteColor,
            onPressed: onDelete!,
          ),
        );
        break;
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: buttons);
  }

  Widget _cancelButton() {
    return SizedBox(
      height: 5.h,
      width: 139,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _cancelBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        onPressed: onCancel,
        child: Text(
          'Cancel',
          style: AppTextStyle.small(
            color: _cancelText,
            fontWeight: FontWeight.w600,
            fontSize: 11.4.sp,
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 5.h,
      width: 139,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: AppTextStyle.small(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 11.4.sp,
          ),
        ),
      ),
    );
  }
}
