import 'package:flutter/material.dart';

extension AppTextThemeExtension on TextTheme {
  TextTheme withLetterSpacing(double spacing, double fontSize) {
    return copyWith(
      displayLarge: displayLarge?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),
      displayMedium: displayMedium?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),
      displaySmall: displaySmall?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),

      headlineLarge: headlineLarge?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),
      headlineMedium: headlineMedium?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),
      headlineSmall: headlineSmall?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),

      titleLarge: titleLarge?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),
      titleMedium: titleMedium?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),
      titleSmall: titleSmall?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),

      bodyLarge: bodyLarge?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),
      bodyMedium: bodyMedium?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),
      bodySmall: bodySmall?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),

      labelLarge: labelLarge?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),
      labelMedium: labelMedium?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),
      labelSmall: labelSmall?.copyWith(
        letterSpacing: spacing,
        fontSize: fontSize,
      ),
    );
  }
}
