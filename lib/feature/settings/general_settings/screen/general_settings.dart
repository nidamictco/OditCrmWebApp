import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  int selectedTab = 0;

  // Switch states
  bool newLead = true;
  bool facebookLead = true;
  bool transferLead = true;

  bool whatsapp = false;
  bool cloudCall = true;
  bool phoneCall = false;
  bool autoAssign = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            SizedBox(height: 2.h),
            _cardContainer(),
          ],
        ),
      ),
    );
  }

  /// 🔷 TOP HEADER
  Widget _header() {
    return Container(
      height: 18.h,
      width: double.infinity,
      decoration: BoxDecoration( 
        gradient: AppColors.gradientBlue,
      ),
    );
  }

  /// 🔷 MAIN CARD
  Widget _cardContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.05),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabs(),
            Divider(),
            SizedBox(height: 1.h),
            selectedTab == 0 ? _pushNotifications() : _otherSettings(),
          ],
        ),
      ),
    );
  }

  /// 🔷 TAB BAR
  Widget _tabs() {
    return Row(
      children: [
        _tabItem("Push Notifications", 0),
        SizedBox(width: 6.w),
        _tabItem("Other Settings", 1),
      ],
    );
  }

  Widget _tabItem(String title, int index) {
    final isSelected = selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.medium(
              color: isSelected ? AppColors.primary : AppColors.grey,
              weight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.7.h),
          Container(
            height: 2,
            width: 25.w,
            color: isSelected ? AppColors.primary : Colors.transparent,
          )
        ],
      ),
    );
  }

  /// 🔷 PUSH NOTIFICATIONS
  Widget _pushNotifications() {
    return Column(
      children: [
        _switchTile(
          title: "New lead assigned",
          subtitle:
              "Send a push notification to the staff when a new lead is assigned.",
          value: newLead,
          onChanged: (v) => setState(() => newLead = v),
        ),
        _switchTile(
          title: "Facebook Leads",
          subtitle:
              "Send a push notification to the assigned staff member whenever a new lead is generated from Facebook.",
          value: facebookLead,
          onChanged: (v) => setState(() => facebookLead = v),
        ),
        _switchTile(
          title: "Transfer Leads",
          subtitle:
              "Send a push notification to the staff member to whom the lead is transferred.",
          value: transferLead,
          onChanged: (v) => setState(() => transferLead = v),
        ),
      ],
    );
  }

  /// 🔷 OTHER SETTINGS
  Widget _otherSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Official WhatsApp:"),
        _switchTile(
          title: "Auto Convert Official WhatsApp chat to lead",
          subtitle: "Immediately create lead from Official WhatsApp chat",
          value: whatsapp,
          onChanged: (v) => setState(() => whatsapp = v),
        ),

        _sectionTitle("Cloud Call:"),
        _switchTile(
          title: "Auto Convert Cloud call to lead",
          subtitle: "Immediately create lead from incoming call",
          value: cloudCall,
          onChanged: (v) => setState(() => cloudCall = v),
        ),

        _sectionTitle("Phone Call:"),
        _switchTile(
          title: "Auto Convert Phone call to lead",
          subtitle: "Immediately create a lead from incoming call",
          value: phoneCall,
          onChanged: (v) => setState(() => phoneCall = v),
        ),

        _sectionTitle("Unassigned Lead:"),
        _switchTile(
          title: "Auto assign lead to selected staff",
          subtitle: "Unassigned lead automatic assign to selected staff",
          value: autoAssign,
          onChanged: (v) => setState(() => autoAssign = v),
        ),
      ],
    );
  }

  /// 🔷 SECTION TITLE
  Widget _sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 1.h, bottom: 0.5.h),
      child: Text(
        text,
        style: AppTextStyle.link(),
      ),
    );
  }

  /// 🔷 REUSABLE SWITCH TILE
  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.medium()),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: AppTextStyle.small(),
                ),
              ],
            ),
          ),

          /// SWITCH
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              activeColor: AppColors.primary,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}