import 'package:flutter/material.dart';

class AppColors {
  /// 🔵 PRIMARY (Buttons like Transfer)
  static const primary = Color(0xff2F8FCE); // softer blue (UI match)

  /// 🟢 ACTION COLORS
  static const green = Color(0xff1BAA90); // View button (teal-green)
  static const orange = Color(0xffF97316);
  static const red = Color(0xffE53935);

  /// 🌫 BACKGROUND
  static const background = Color(0xffF3F4F6); // page bg (slightly warm)
  static const white = Color(0xffffffff);
  static const container = Color(0xffFAFAFB);

  /// 📝 TEXT COLORS
  static const black = Color(0xff111827); // softer than pure black
  static const grey = Color(0xff6B7280); // labels & secondary text
  static const lightGrey = Color(0xffD1D5DB); // borders

  /// 📦 CARD COLORS
  static const greyCard = Color(0xffF3F4F6); // header strip
  static const blueCard = Color(0xffEFF6FF);
  static const greenCard = Color(0xffECFDF5);
  static const orangeCard = Color(0xffFFF7ED);

  /// ✨ OPACITY
  static Color get greenLight => green.withOpacity(0.12);
  static Color get blueLight => primary.withOpacity(0.12);
  static Color get orangeLight => orange.withOpacity(0.12);

  /// ➖ DIVIDER
  static const divider = Color(0xffE5E7EB);

  ///gradient
  static const gradientBlue = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF495580), Color(0xFF303649)],
    // stops: [0.0, 0.5, 1.0],
  );
}

class AppTheme {
  static const Color primary = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color onlineGreen = Color(0xFF22C55E);
  static const Color actionView = Color(0xFF6366F1);
  static const Color actionEdit = Color(0xFF0EA5E9);
  static const Color actionHistory = Color(0xFF8B5CF6);
  static const Color actionDelete = Color.fromARGB(255, 180, 27, 24);
  static const Color sidebarBgClr = Color(0xffF6F6F6);
}
