import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/theme/asset_resources.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// Adjust this import to wherever your AssetResources class lives.
// import 'package:your_app/resources/asset_resources.dart';

// Sizer scales by percentage of the CURRENT screen's width/height. Your
// actual Figma frame is the desktop one, 1512 x 1043, so every px value is
// converted against that (e.g. 318 / 1512 * 100 ≈ 21.03.w).
//
// On Flutter Web, a raw .w/.h can look right at 1512px wide and then blow up
// (or shrink too far) on a very wide monitor or a small laptop screen. So
// each converted value is wrapped in .clamp(min, max), the same pattern
// ChatGPT suggested: `width: (21.03.w).clamp(300.0, 380.0)`. Tune the
// min/max pairs below to taste — they don't need to be exact, just sane
// floors/ceilings.
const double _designWidth = 1512;
const double _designHeight = 1043;

/// Converts a Figma px value (against the 1512-wide desktop frame) into a
/// sizer `.w` percentage, then clamps it to [min]–[max] logical pixels.
double wPx(double px, double min, double max) =>
    ((px / _designWidth) * 100).w.clamp(min, max);

/// Same as [wPx] but scaled against frame height (1043) and using `.h`.
double hPx(double px, double min, double max) =>
    ((px / _designHeight) * 100).h.clamp(min, max);

/// A single reusable widget for both "Success" and "Error" result dialogs.
///
/// Everything that differs between success/error (image, label color,
/// accent color, button text) is driven by [isSuccess].
/// Everything that differs between *calls* (the heading and the body
/// message, e.g. "FOLLOW-UP CREATED!" / "The follow-up has been added
/// to your schedule.") is passed in by the caller via [title] and [message],
/// since that text is different depending on which action triggered the alert.
class StatusAlertWidget extends StatelessWidget {
  final bool isSuccess;
  final String title;
  final String message;
  final VoidCallback onButtonPressed;

  const StatusAlertWidget({
    super.key,
    required this.isSuccess,
    required this.title,
    required this.message,
    required this.onButtonPressed,
  });

  /// Convenience helper so callers don't need to build a Dialog manually.
  ///
  /// Usage:
  /// ```dart
  /// StatusAlertWidget.show(
  ///   context,
  ///   isSuccess: true,
  ///   title: 'FOLLOW-UP CREATED!',
  ///   message: 'The follow-up has been added to your schedule.',
  ///   onButtonPressed: () => Navigator.of(context).pop(),
  /// );
  /// ```
  static Future<void> show(
    BuildContext dialogContext, {
    required bool isSuccess,
    required String title,
    required String message,
    required VoidCallback onButtonPressed,
  }) {
    return showDialog(
      context: dialogContext,

      barrierDismissible: false,
      builder: (_) => StatusAlertWidget(
        isSuccess: isSuccess,
        title: title,
        message: message,
        onButtonPressed: onButtonPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = isSuccess
        ? const Color(0xFF17B26A)
        : const Color(0xFFF04438);
    final String statusLabel = isSuccess ? 'Success' : 'Error';
    final String buttonText = isSuccess ? 'Done' : 'Try Again';
    final String imagePath = isSuccess
        ? AssetResources
              .successImage // replace with actual asset constant, e.g. AssetResources.successImage
        : AssetResources
              .errorImage; // replace with actual asset constant, e.g. AssetResources.errorImage

    // Figma tokens (Layout panel, 1512x1043 desktop frame):
    // Width: Hug (318px)  Height: Hug (330.58px)  Radius: 24px  Border: 1px
    // Padding: top 30 / right 60 / bottom 30 / left 60   Gap: 25px
    // Background: #FFFFFF
    final double gap = hPx(25, 20, 30);

    return Dialog(
      // backgroundColor: AppThemeColors.appPrimaryColor,
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: wPx(60, 20, 36)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: EdgeInsets.only(left: wPx(4, 3, 6), bottom: hPx(8, 6, 10)),
          //   child: Text(
          //     statusLabel,
          //     style: AppTextStyle.medium(
          //       color: Colors.black54,
          //       fontSize: 12.sp,
          //     ),
          //   ),
          // ),
          Container(
            width: wPx(318, 300, 380),
            constraints: BoxConstraints(minHeight: hPx(330.58, 320, 400)),
            padding: EdgeInsets.only(top: 30, right: 60, bottom: 30, left: 60),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(wPx(24, 18, 28)),
              border: Border.all(
                color: accentColor.withOpacity(0.3),
                width: wPx(1, 1, 2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(imagePath, height: 119.58, width: 198),
                SizedBox(height: gap),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.medium(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5.sp,
                    color: accentColor,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: gap),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.small(
                    fontSize: 11.4.sp,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: gap),
                SizedBox(
                  width: 132,
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: onButtonPressed,
                    child: Text(
                      buttonText,
                      style: AppTextStyle.small(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.4.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
