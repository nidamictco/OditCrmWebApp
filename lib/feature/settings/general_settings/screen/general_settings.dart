// import 'package:flutter/material.dart';
// import 'package:oxdo/core/theme/app_colors.dart';
// import 'package:oxdo/core/theme/app_text_style.dart';
// import 'package:oxdo/feature/settings/general_settings/model/general_settings_model.dart';
// import 'package:sizer/sizer.dart';

// class GeneralSettings extends StatefulWidget {
//   const GeneralSettings({super.key});

//   @override
//   State<GeneralSettings> createState() => _GeneralSettingsState();
// }

// class _GeneralSettingsState extends State<GeneralSettings> {
//   int selectedTab = 0;

//   // Switch states
//   bool newLead = true;
//   bool facebookLead = true;
//   bool transferLead = true;

//   bool whatsapp = false;
//   bool cloudCall = true;
//   bool phoneCall = false;
//   bool autoAssign = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 // ── Blue gradient header ──
//                 _header(),
//                 // ── Card overlapping the header ──
//                 Positioned(
//                   top: 10.h, // starts 10h from top of header (overlaps bottom)
//                   left: 4.w,
//                   right: 4.w,
//                   child: _cardContainer(),
//                 ),
//               ],
//             ),

//             // _header(),
//             // SizedBox(height: 2.h),
//             // _cardContainer(),
//             SizedBox(height: 8.h),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 🔷 TOP HEADER
//   Widget _header() {
//     return Container(
//       height: 18.h,
//       width: double.infinity,
//       decoration: BoxDecoration(gradient: AppColors.gradientBlue),
//     );
//   }

//   /// 🔷 MAIN CARD
//   Widget _cardContainer() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 4.w),
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.all(3.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(5),
//           boxShadow: [
//             BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _tabs(),
//             SizedBox(height: 1.h),
//             selectedTab == 0 ? _pushNotifications() : _otherSettings(),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 🔷 TAB BAR
//   Widget _tabs() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             _tabItem("Push Notifications", 0),
//             SizedBox(width: 6.w),
//             _tabItem("Other Settings", 1),
//           ],
//         ),

//         Divider(height: 1, thickness: 1, color: AppColors.divider),
//       ],
//     );
//   }

//   Widget _tabItem(String title, int index) {
//     final isSelected = selectedTab == index;

//     return GestureDetector(
//       onTap: () => setState(() => selectedTab = index),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: AppTextStyle.medium(
//               color: isSelected ? AppColors.primary : AppColors.grey,
//               weight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: 0.7.h),
//           Container(
//             height: 2,
//             width: 15.w,
//             // ✅ active tab line drawn ON TOP of the divider
//             color: isSelected ? AppColors.primary : Colors.transparent,
//           ),
//         ],
//       ),
//     );
//   }

//   /// 🔷 PUSH NOTIFICATIONS
//   Widget _pushNotifications() {
//     return Column(
//       children: [
//         _switchTile(
//           title: "New lead assigned",
//           subtitle:
//               "Send a push notification to the staff when a new lead is assigned.",
//           value: newLead,
//           onChanged: (v) => setState(() => newLead = v),
//         ),
//         _switchTile(
//           title: "Facebook Leads",
//           subtitle:
//               "Send a push notification to the assigned staff member whenever a new lead is generated from Facebook.",
//           value: facebookLead,
//           onChanged: (v) => setState(() => facebookLead = v),
//         ),
//         _switchTile(
//           title: "Transfer Leads",
//           subtitle:
//               "Send a push notification to the staff member to whom the lead is transferred.",
//           value: transferLead,
//           onChanged: (v) => setState(() => transferLead = v),
//         ),
//       ],
//     );
//   }

//   /// 🔷 OTHER SETTINGS
//   Widget _otherSettings() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionTitle("Official WhatsApp:"),
//         _switchTile(
//           title: "Auto Convert Official WhatsApp chat to lead",
//           subtitle: "Immediately create lead from Official WhatsApp chat",
//           value: whatsapp,
//           onChanged: (v) => setState(() => whatsapp = v),
//         ),

//         _sectionTitle("Cloud Call:"),
//         _switchTile(
//           title: "Auto Convert Cloud call to lead",
//           subtitle: "Immediately create lead from incoming call",
//           value: cloudCall,
//           onChanged: (v) => setState(() => cloudCall = v),
//         ),

//         _sectionTitle("Phone Call:"),
//         _switchTile(
//           title: "Auto Convert Phone call to lead",
//           subtitle: "Immediately create a lead from incoming call",
//           value: phoneCall,
//           onChanged: (v) => setState(() => phoneCall = v),
//         ),

//         _sectionTitle("Unassigned Lead:"),
//         _switchTile(
//           title: "Auto assign lead to selected staff",
//           subtitle: "Unassigned lead automatic assign to selected staff",
//           value: autoAssign,
//           onChanged: (v) => setState(() => autoAssign = v),
//         ),
//       ],
//     );
//   }

//   /// 🔷 SECTION TITLE
//   Widget _sectionTitle(String text) {
//     return Padding(
//       padding: EdgeInsets.only(top: 1.h, bottom: 0.5.h),
//       child: Text(text, style: AppTextStyle.link(color: AppColors.black)),
//     );
//   }

//   /// 🔷 REUSABLE SWITCH TILE
//   Widget _switchTile({
//     required String title,
//     required String subtitle,
//     required bool value,
//     required Function(bool) onChanged,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 1.2.h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// TEXT
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title, style: AppTextStyle.medium()),
//                 SizedBox(height: 0.5.h),
//                 Text(
//                   subtitle,
//                   style: AppTextStyle.medium(color: AppColors.grey),
//                 ),
//               ],
//             ),
//           ),

//           /// SWITCH
//           Transform.scale(
//             scale: 0.8,
//             child: Switch(
//               value: value,
//               activeColor: AppColors.primary,
//               onChanged: onChanged,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/feature/settings/general_settings/model/general_settings_model.dart';
import 'package:sizer/sizer.dart';
import '../cubit/general_settings_cubit.dart';
import '../cubit/general_settings_state.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GeneralSettingsCubit, GeneralSettingsState>(
      listener: (context, state) {
        if (state is GeneralSettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {

        // ✅ if/else instead of switch expression — works on all Dart versions
        GeneralSettingsModel? settings;
        if (state is GeneralSettingsLoaded) {
          settings = state.settings;
        } else if (state is GeneralSettingsUpdating) {
          settings = state.settings;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: state is GeneralSettingsLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _header(),
                          Positioned(
                            top: 10.h,
                            left: 4.w,
                            right: 4.w,
                            child: _cardContainer(context, settings),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _header() {
    return Container(
      height: 18.h,
      width: double.infinity,
      decoration: BoxDecoration(gradient: AppColors.gradientBlue),
    );
  }

  Widget _cardContainer(BuildContext context, GeneralSettingsModel? settings) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabs(),
            SizedBox(height: 1.h),
            selectedTab == 0
                ? _pushNotifications(context, settings)
                : _otherSettings(context, settings),
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    return Column(
      children: [
        Row(
          children: [
            _tabItem("Push Notifications", 0),
            SizedBox(width: 6.w),
            _tabItem("Other Settings", 1),
          ],
        ),
        Divider(height: 1, thickness: 1, color: AppColors.divider),
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
            width: 15.w,
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _pushNotifications(
      BuildContext context, GeneralSettingsModel? settings) {
    return Column(
      children: [
        _switchTile(
          context: context,
          field: 'newLead',
          title: "New lead assigned",
          subtitle:
              "Send a push notification to the staff when a new lead is assigned.",
          value: settings?.newLead ?? true,
        ),
        _switchTile(
          context: context,
          field: 'facebookLead',
          title: "Facebook Leads",
          subtitle:
              "Send a push notification to the assigned staff member whenever a new lead is generated from Facebook.",
          value: settings?.facebookLead ?? true,
        ),
        _switchTile(
          context: context,
          field: 'transferLead',
          title: "Transfer Leads",
          subtitle:
              "Send a push notification to the staff member to whom the lead is transferred.",
          value: settings?.transferLead ?? true,
        ),
      ],
    );
  }

  Widget _otherSettings(BuildContext context, GeneralSettingsModel? settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Official WhatsApp:"),
        _switchTile(
          context: context,
          field: 'whatsapp',
          title: "Auto Convert Official WhatsApp chat to lead",
          subtitle: "Immediately create lead from Official WhatsApp chat",
          value: settings?.whatsapp ?? false,
        ),
        _sectionTitle("Cloud Call:"),
        _switchTile(
          context: context,
          field: 'cloudCall',
          title: "Auto Convert Cloud call to lead",
          subtitle: "Immediately create lead from incoming call",
          value: settings?.cloudCall ?? true,
        ),
        _sectionTitle("Phone Call:"),
        _switchTile(
          context: context,
          field: 'phoneCall',
          title: "Auto Convert Phone call to lead",
          subtitle: "Immediately create a lead from incoming call",
          value: settings?.phoneCall ?? false,
        ),
        _sectionTitle("Unassigned Lead:"),
        _switchTile(
          context: context,
          field: 'autoAssign',
          title: "Auto assign lead to selected staff",
          subtitle: "Unassigned lead automatic assign to selected staff",
          value: settings?.autoAssign ?? false,
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 1.h, bottom: 0.5.h),
      child: Text(text, style: AppTextStyle.link(color: AppColors.black)),
    );
  }

  Widget _switchTile({
    required BuildContext context,
    required String field,
    required String title,
    required String subtitle,
    required bool value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.medium()),
                SizedBox(height: 0.5.h),
                Text(subtitle,
                    style: AppTextStyle.medium(color: AppColors.grey)),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              activeColor: AppColors.primary,
              onChanged: (v) =>
                  context.read<GeneralSettingsCubit>().toggleField(field, v),
            ),
          ),
        ],
      ),
    );
  }
}