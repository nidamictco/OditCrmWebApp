import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'app_colors.dart';
import 'app_theme.dart';

class AppTextStyle {
  /// SMALL TEXT
  static TextStyle small({
    Color? color,
    double? size,
    double? fontSize,
    FontWeight? weight,
    FontWeight? fontWeight,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      color: color ?? AppColors.grey,
      fontSize: fontSize ?? size ?? 9.sp,
      fontWeight: fontWeight ?? weight ?? FontWeight.w400,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
      letterSpacing: letterSpacing ?? 0.2,
    );
  }

  /// BODY TEXT
  static TextStyle body({
    Color? color,
    double? size,
    double? fontSize,
    FontWeight? weight,
    FontWeight? fontWeight,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      color: color ?? AppColors.black,
      fontSize: fontSize ?? size ?? 10.sp,
      fontWeight: fontWeight ?? weight ?? FontWeight.w400,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
      letterSpacing: letterSpacing ?? 0.2,
    );
  }

  /// MEDIUM (SUB TITLE)
  static TextStyle medium({
    Color? color,
    double? size,
    double? fontSize,
    FontWeight? weight,
    FontWeight? fontWeight,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      color: color ?? AppColors.black,
      fontSize: fontSize ?? size ?? 10.5.sp,
      fontWeight: fontWeight ?? weight ?? FontWeight.w500,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
      letterSpacing: letterSpacing ?? 0.2,
    );
  }

  /// TITLE (CARD TITLE)
  static TextStyle title({
    Color? color,
    double? size,
    double? fontSize,
    FontWeight? weight,
    FontWeight? fontWeight,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      color: color ?? AppColors.grey,
      fontSize: fontSize ?? size ?? 10.sp,
      fontWeight: fontWeight ?? weight ?? FontWeight.w500,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
      letterSpacing: letterSpacing ?? 0.2,
    );
  }

  /// HEADING (PAGE TITLE)
  static TextStyle heading({
    Color? color,
    double? size,
    double? fontSize,
    FontWeight? weight,
    FontWeight? fontWeight,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      color: color ?? AppColors.black,
      fontSize: fontSize ?? size ?? 18.sp,
      fontWeight: fontWeight ?? weight ?? FontWeight.w600,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
      letterSpacing: letterSpacing ?? 0.2,
    );
  }

  /// LARGE NUMBER (0 count in cards)
  static TextStyle number({
    Color? color,
    double? size,
    double? fontSize,
    FontWeight? weight,
    FontWeight? fontWeight,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      color: color ?? AppColors.black,
      fontSize: fontSize ?? size ?? 16.sp,
      fontWeight: fontWeight ?? weight ?? FontWeight.w700,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
      letterSpacing: letterSpacing ?? 0.2,
    );
  }

  /// LINK TEXT
  static TextStyle link({
    Color? color,
    double? size,
    double? fontSize,
    FontWeight? weight,
    FontWeight? fontWeight,
    double? height,
    FontStyle? fontStyle,
    Color? decorationColor,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      color: color ?? AppColors.primary,
      fontSize: fontSize ?? size ?? 11.sp,
      fontWeight: fontWeight ?? weight ?? FontWeight.w500,
      height: height,
      fontStyle: fontStyle,
      decoration: TextDecoration.underline,
      decorationColor: decorationColor ?? color ?? AppColors.primary,
      decorationStyle: TextDecorationStyle.solid,
      letterSpacing: letterSpacing ?? 0.2,
    );
  }

  /// HEADING 1
  // static TextStyle heading1({
  //   Color? color,
  //   double? size,
  //   double? fontSize,
  //   FontWeight? weight,
  //   FontWeight? fontWeight,
  //   double? height,
  //   FontStyle? fontStyle,
  //   TextDecoration? decoration,
  //   double? letterSpacing,
  // }) {
  //   return GoogleFonts.poppins(
  //     color: color ?? AppThemeColors.textPrimary,
  //     fontSize: fontSize ?? size ?? 16.sp,
  //     fontWeight: fontWeight ?? weight ?? FontWeight.w700,
  //     height: height,
  //     fontStyle: fontStyle,
  //     decoration: decoration,
  //     letterSpacing: letterSpacing ?? -0.3,
  //   );
  // }

  // /// HEADING 2
  // static TextStyle heading2({
  //   Color? color,
  //   double? size,
  //   double? fontSize,
  //   FontWeight? weight,
  //   FontWeight? fontWeight,
  //   double? height,
  //   FontStyle? fontStyle,
  //   TextDecoration? decoration,
  //   double? letterSpacing,
  // }) {
  //   return GoogleFonts.poppins(
  //     color: color ?? AppThemeColors.textPrimary,
  //     fontSize: fontSize ?? size ?? 13.sp,
  //     fontWeight: fontWeight ?? weight ?? FontWeight.w600,
  //     height: height,
  //     fontStyle: fontStyle,
  //     decoration: decoration,
  //     letterSpacing: letterSpacing ?? -0.2,
  //   );
  // }

  // /// STAT VALUE
  // static TextStyle statValue({
  //   Color? color,
  //   double? size,
  //   double? fontSize,
  //   FontWeight? weight,
  //   FontWeight? fontWeight,
  //   double? height,
  //   FontStyle? fontStyle,
  //   TextDecoration? decoration,
  //   double? letterSpacing,
  // }) {
  //   return GoogleFonts.poppins(
  //     color: color ?? AppThemeColors.textPrimary,
  //     fontSize: fontSize ?? size ?? 22.sp,
  //     fontWeight: fontWeight ?? weight ?? FontWeight.w700,
  //     height: height,
  //     fontStyle: fontStyle,
  //     decoration: decoration,
  //     letterSpacing: letterSpacing ?? -0.5,
  //   );
  // }

  // /// STAT LABEL
  // static TextStyle statLabel({
  //   Color? color,
  //   double? size,
  //   double? fontSize,
  //   FontWeight? weight,
  //   FontWeight? fontWeight,
  //   double? height,
  //   FontStyle? fontStyle,
  //   TextDecoration? decoration,
  //   double? letterSpacing,
  // }) {
  //   return GoogleFonts.poppins(
  //     color: color ?? AppThemeColors.textSecondary,
  //     fontSize: fontSize ?? size ?? 13.sp,
  //     fontWeight: fontWeight ?? weight ?? FontWeight.w400,
  //     height: height,
  //     fontStyle: fontStyle,
  //     decoration: decoration,
  //     letterSpacing: letterSpacing ?? 0.2,
  //   );
  // }

  // /// BODY MEDIUM
  // static TextStyle bodyMedium({
  //   Color? color,
  //   double? size,
  //   double? fontSize,
  //   FontWeight? weight,
  //   FontWeight? fontWeight,
  //   double? height,
  //   FontStyle? fontStyle,
  //   TextDecoration? decoration,
  //   double? letterSpacing,
  // }) {
  //   return GoogleFonts.poppins(
  //     color: color ?? AppThemeColors.textPrimary,
  //     fontSize: fontSize ?? size ?? 14.sp,
  //     fontWeight: fontWeight ?? weight ?? FontWeight.w500,
  //     height: height,
  //     fontStyle: fontStyle,
  //     decoration: decoration,
  //     letterSpacing: letterSpacing ?? 0.2,
  //   );
  // }

  // /// BODY SMALL
  // static TextStyle bodySmall({
  //   Color? color,
  //   double? size,
  //   double? fontSize,
  //   FontWeight? weight,
  //   FontWeight? fontWeight,
  //   double? height,
  //   FontStyle? fontStyle,
  //   TextDecoration? decoration,
  //   double? letterSpacing,
  // }) {
  //   return GoogleFonts.poppins(
  //     color: color ?? AppThemeColors.textSecondary,
  //     fontSize: fontSize ?? size ?? 12.sp,
  //     fontWeight: fontWeight ?? weight ?? FontWeight.w500,
  //     height: height,
  //     fontStyle: fontStyle,
  //     decoration: decoration,
  //     letterSpacing: letterSpacing ?? 0.2,
  //   );
  // }

  // /// CAPTION
  // static TextStyle caption({
  //   Color? color,
  //   double? size,
  //   double? fontSize,
  //   FontWeight? weight,
  //   FontWeight? fontWeight,
  //   double? height,
  //   FontStyle? fontStyle,
  //   TextDecoration? decoration,
  //   double? letterSpacing,
  // }) {
  //   return GoogleFonts.poppins(
  //     color: color ?? AppThemeColors.textMuted,
  //     fontSize: fontSize ?? size ?? 11.sp,
  //     fontWeight: fontWeight ?? weight ?? FontWeight.w400,
  //     height: height,
  //     fontStyle: fontStyle,
  //     decoration: decoration,
  //     letterSpacing: letterSpacing ?? 0.2,
  //   );
  // }

  // /// TABLE HEADER
  // static TextStyle tableHeader({
  //   Color? color,
  //   double? size,
  //   double? fontSize,
  //   FontWeight? weight,
  //   FontWeight? fontWeight,
  //   double? height,
  //   FontStyle? fontStyle,
  //   TextDecoration? decoration,
  //   double? letterSpacing,
  // }) {
  //   return GoogleFonts.poppins(
  //     color: color ?? AppThemeColors.tableHeader,
  //     fontSize: fontSize ?? size ?? 11.sp,
  //     fontWeight: fontWeight ?? weight ?? FontWeight.w600,
  //     height: height,
  //     fontStyle: fontStyle,
  //     decoration: decoration,
  //     letterSpacing: letterSpacing ?? 0.8,
  //   );
  // }

  // /// TABLE CELL
  // static TextStyle tableCell({
  //   Color? color,
  //   double? size,
  //   double? fontSize,
  //   FontWeight? weight,
  //   FontWeight? fontWeight,
  //   double? height,
  //   FontStyle? fontStyle,
  //   TextDecoration? decoration,
  //   double? letterSpacing,
  // }) {
  //   return GoogleFonts.poppins(
  //     color: color ?? AppThemeColors.textPrimary,
  //     fontSize: 13,
  //     fontWeight: fontWeight ?? weight ?? FontWeight.w400,
  //     height: height,
  //     fontStyle: fontStyle,
  //     decoration: decoration,
  //     letterSpacing: letterSpacing ?? 0.2,
  //   );
  // }
  static final TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppThemeColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle statValue = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppThemeColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle statLabel = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppThemeColors.textSecondary,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppThemeColors.textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppThemeColors.textSecondary,
  );

  static TextStyle subText = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppThemeColors.subText,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppThemeColors.textMuted,
  );

  static TextStyle tableHeader = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppThemeColors.tableHeader,
    letterSpacing: 0.8,
  );

  static TextStyle tableCell = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppThemeColors.textPrimary,
  );
}
