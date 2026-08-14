import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeColors {
  AppThemeColors._();

  // Primary
  static const Color primary = Color(0xFF1A2B6B);
  static const Color primaryLight = Color(0xFF2A3F8F);

  // Sidebar
  static const Color sidebarBg = Color(0xffF6F6F6);
  static const Color sidebarActiveItem = Color(0xFF1A2B6B);
  static const Color sidebarActiveText = Color(0xFFFFFFFF);
  static const Color sidebarInactiveText = Color(0xFF4A5568);

  // Background
  static const Color scaffoldBg = Color(0xffFEFEFE); //Color(0xFFF4F6FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color contentBg = Color(0xFFFFFFFF);

  // Stat Card Icon backgrounds
  static const Color statCompanyIcon = Color(0xff4C3F77); //Color(0xFF2A3F8F);
  static const Color statLeadsIcon = Color(0xFF00B4D8);
  static const Color statStaffIcon = Color(0xFF9B5DE5);
  static const Color statUptimeIcon = Color(0xFF00B388);

  static const Color statCompanyBg = Color(0xFFEEF1FF);
  static const Color statLeadsBg = Color(0xFFE0F7FC);
  static const Color statStaffBg = Color(0xFFF3EEFF);
  static const Color statUptimeBg = Color(0xFFE6F9F5);

  // Text
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textMuted = Color(0xFFA0AEC0);
  static const Color tableHeader = Color(0xFF002660);
  static const Color subText = Color(0xff747474);

  // Status
  static const Color statusActive = Color(0xff00B16E); //Color(0xFF38A169);
  static const Color statusPending = Color(0xffD5AE2E); //Color(0xFFD97706);
  static const Color statusSuspended = Color(0xFFE53E3E);

  // Accent
  static const Color growthGreen = Color(0xFF38A169);
  static const Color growthGreenBg = Color(0xFFE6F9EE);

  // Chart
  static const Color chartReceipt = Color(0xFF1A2B6B);
  static const Color chartPayment = Color(0xFFB0BEC5);
  static const Color chartFill = Color(0xFFEEF1FF);
  static const Color chartDot = Color(0xFF1A2B6B);

  // Donut
  static const Color donutReceivable = Color(0xFF00C896);
  static const Color donutPayable = Color(0xFF00E5BB);

  // Border
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderLight2 = Color.fromARGB(255, 220, 218, 228);
  static Color borderLight3 = Color(0xff747474).withValues(alpha: 0.1);
  static const Color divider = Color(0xFFF1F5F9);

  // Plan badges
  static const Color planBorder = Color(0xFFCBD5E0);
  static const Color planText = Color(0xFF4A5568);

  // Button color
  static const Color appPrimaryColor = Color(0xff002660);

  static const Color hintColor = Color(0xff747474);

  static Color textfieldBorder = Color(0xff8798B0).withValues(alpha: 0.12);
  static Color followupCardBorder = Color(0xff8798B0).withValues(alpha: 0.3);
  static Color switchBorder = Color(0xff8798B0);
  static Color switchhidecolor = Color(0xff8798B0).withValues(alpha: 0.25);
  static Color borderClr = Color(0xff8798B0);

  static const Color sidebarLogoTxtClr = Color(0xff2D2D2D);
  static const Color sidebarTxtClr = Color(0xff2D2D2D);
  static const Color basicGreen = Color(0xff00B16E);

  static const Color dashboardCard = Color(0xffFEFEFE);
  static const Color cardText = Color(0xff2D2D2D);
  static const Color followupDateCardBg = Color(0xffF4F6F8);

  static const Color commonText = Color(0xff2D2D2D);
}

Color getStageColor(String stage) {
  switch (stage.trim().toUpperCase()) {
    case 'FOLLOWUP':
    case 'FOLLOW UP':
    case 'FOLLOW-UP':
      return const Color(0xFFF59E0B);
    case 'NEW':
      return const Color(0xFF10B981);
    case 'TRANSFERRED':
      return const Color(0xFF3B82F6);
    case 'REJECTED':
      return const Color(0xFFEF4444);
    case 'CLOSED':
      return const Color(0xFF0D31E8);
    case 'CONNECTED':
      return const Color(0xFF059669);
    case 'MISSED':
      return const Color(0xFFEF4444);
    default:
      return const Color(0xFFF59E0B);
  }
}

// class AppTextStyles {
//   AppTextStyles._();
//
//   static const String fontFamily = 'Inter';
//
//
// }
