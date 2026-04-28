import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'app_colors.dart';

class AppTextStyle {
  /// SMALL TEXT
  static TextStyle small({Color? color, double? size, FontWeight? weight}) {
    return GoogleFonts.poppins(

      color: color ?? AppColors.grey,
      fontSize: size ?? 9.sp, // 🔥 responsive
      fontWeight: weight ?? FontWeight.w400,
      letterSpacing: 0.2,
    );
  }


  

  /// BODY TEXT
  static TextStyle body({Color? color, double? size, FontWeight? weight}) {
    return GoogleFonts.poppins(
      color: color ?? AppColors.black,
      fontSize: size ?? 10.sp,
      fontWeight: weight ?? FontWeight.w400,
      letterSpacing: 0.2,
    );
  }

  /// MEDIUM (SUB TITLE)
  static TextStyle medium({Color? color, double? size, FontWeight? weight}) {
    return GoogleFonts.poppins(
      color: color ?? AppColors.black,
      fontSize: size ?? 11.sp,
      fontWeight: weight ?? FontWeight.w500,
      letterSpacing: 0.2
    );
  }

  /// TITLE (CARD TITLE)
  static TextStyle title({Color? color, double? size, FontWeight? weight}) {
    return GoogleFonts.poppins(
      color: color ?? AppColors.grey,
      fontSize: size ?? 10.sp,
      fontWeight: weight ?? FontWeight.w500,
      letterSpacing: 0.2,
    );
  }

  /// HEADING (PAGE TITLE)
  static TextStyle heading({Color? color, double? size, FontWeight? weight}) {
    return GoogleFonts.poppins(
      color: color ?? AppColors.black,
      fontSize: size ?? 18.sp,
      fontWeight: weight ?? FontWeight.w600,
      letterSpacing: 0.2,
    );
  }

  /// LARGE NUMBER (0 count in cards)
  static TextStyle number({Color? color, double? size, FontWeight? weight}) {
    return GoogleFonts.inter(
      color: color ?? AppColors.black,
      fontSize: size ?? 16.sp,
      fontWeight: weight ?? FontWeight.w700,
      letterSpacing: 0.2,
    );
  }

  /// LINK TEXT
  static TextStyle link({Color? color, double? size, FontWeight? weight, Color? decorationColor}) {
    return GoogleFonts.poppins(
      color: color ?? AppColors.primary,
      fontSize: size ?? 11.sp,
      fontWeight: weight ?? FontWeight.w500,
      decoration: TextDecoration.underline,
      decorationColor: color ?? AppColors.primary,
      // decorationThickness: 1.5,
      decorationStyle: TextDecorationStyle.solid,
      letterSpacing: 0.2,
    );
  }
}
