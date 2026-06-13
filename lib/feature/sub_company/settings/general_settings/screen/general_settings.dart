import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_style.dart';
import '../model/general_settings_model.dart';
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
      // listener: (context, state) {
      //   if (state is GeneralSettingsError) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text(state.message)),
      //     );
      //   }
      // },
      listenWhen: (prev, next) => next is GeneralSettingsError,
      listener: (context, state) {
        if (state is GeneralSettingsError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        GeneralSettingsModel? settings;
        if (state is GeneralSettingsLoaded)
          settings = state.settings;
        else if (state is GeneralSettingsUpdating)
          settings = state.settings;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: state is GeneralSettingsLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        height: 24.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientBlue,
                        ),
                      ),
                      // Card (no Stack, no Positioned — just normal flow)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Transform.translate(
                          offset: Offset(1, -9.h), // pulls card up over header
                          child: _cardContainer(context, settings),
                        ),
                      ),
                      SizedBox(height: 4.h),
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
        padding: EdgeInsets.only(left: 3.w, right: 3.w, bottom: 3.w, top: 2.w),
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
            // selectedTab == 0
            //     ? _pushNotifications(context, settings)
            //     : _otherSettings(context, settings),
          _pushNotifications(context, settings),
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
            // _tabItem("Other Settings", 1),
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

  // Widget _pushNotifications(
  //   BuildContext context,
  //   GeneralSettingsModel? settings,
  // ) {
  //   return Column(
  //     children: [
  //       _switchTile(
  //         context: context,
  //         field: 'newLead',
  //         title: "New lead assigned",
  //         subtitle:
  //             "Send a push notification to the staff when a new lead is assigned.",
  //         value: settings?.newLead ?? false,
  //       ),
  //       _switchTile(
  //         context: context,
  //         field: 'facebookLead',
  //         title: "Facebook Leads",
  //         subtitle:
  //             "Send a push notification to the assigned staff member whenever a new lead is generated from Facebook.",
  //         value: settings?.facebookLead ?? false,
  //       ),
  //       _switchTile(
  //         context: context,
  //         field: 'transferLead',
  //         title: "Transfer Leads",
  //         subtitle:
  //             "Send a push notification to the staff member to whom the lead is transferred.",
  //         value: settings?.transferLead ?? false,
  //       ),
  //     ],
  //   );
  // }

  // Widget _otherSettings(BuildContext context, GeneralSettingsModel? settings) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _sectionTitle("Official WhatsApp:"),
  //       _switchTile(
  //         context: context,
  //         field: 'whatsapp',
  //         title: "Auto Convert Official WhatsApp chat to lead",
  //         subtitle: "Immediately create lead from Official WhatsApp chat",
  //         value: settings?.whatsapp ?? false,
  //       ),
  //       _sectionTitle("Cloud Call:"),
  //       _switchTile(
  //         context: context,
  //         field: 'cloudCall',
  //         title: "Auto Convert Cloud call to lead",
  //         subtitle: "Immediately create lead from incoming call",
  //         value: settings?.cloudCall ?? true,
  //       ),
  //       _sectionTitle("Phone Call:"),
  //       _switchTile(
  //         context: context,
  //         field: 'phoneCall',
  //         title: "Auto Convert Phone call to lead",
  //         subtitle: "Immediately create a lead from incoming call",
  //         value: settings?.phoneCall ?? false,
  //       ),
  //       _sectionTitle("Unassigned Lead:"),
  //       _switchTile(
  //         context: context,
  //         field: 'autoAssign',
  //         title: "Auto assign lead to selected staff",
  //         subtitle: "Unassigned lead automatic assign to selected staff",
  //         value: settings?.autoAssign ?? false,
  //       ),
  //     ],
  //   );
  // }

  Widget _pushNotifications(
    BuildContext context,
    GeneralSettingsModel? settings,
  ) {
    return Column(
      children: [
        _SwitchTile(
          key: const ValueKey('newLead'),
          field: 'newLead',
          title: "New lead assigned",
          subtitle:
              "Send a push notification to the staff when a new lead is assigned.",
          initialValue: settings?.newLead ?? false,
        ),
        // _SwitchTile(
        //   key: const ValueKey('facebookLead'),
        //   field: 'facebookLead',
        //   title: "Facebook Leads",
        //   subtitle:
        //       "Send a push notification to the assigned staff member whenever a new lead is generated from Facebook.",
        //   initialValue: settings?.facebookLead ?? false,
        // ),
        _SwitchTile(
          key: const ValueKey('transferLead'),
          field: 'transferLead',
          title: "Transfer Leads",
          subtitle:
              "Send a push notification to the staff member to whom the lead is transferred.",
          initialValue: settings?.transferLead ?? false,
        ),
      ],
    );
  }

  Widget _otherSettings(BuildContext context, GeneralSettingsModel? settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Official WhatsApp:"),
        _SwitchTile(
          key: const ValueKey('whatsapp'),
          field: 'whatsapp',
          title: "Auto Convert Official WhatsApp chat to lead",
          subtitle: "Immediately create lead from Official WhatsApp chat",
          initialValue: settings?.whatsapp ?? false,
        ),
        _sectionTitle("Cloud Call:"),
        _SwitchTile(
          key: const ValueKey('cloudCall'),
          field: 'cloudCall',
          title: "Auto Convert Cloud call to lead",
          subtitle: "Immediately create lead from incoming call",
          initialValue: settings?.cloudCall ?? true,
        ),
        _sectionTitle("Phone Call:"),
        _SwitchTile(
          key: const ValueKey('phoneCall'),
          field: 'phoneCall',
          title: "Auto Convert Phone call to lead",
          subtitle: "Immediately create a lead from incoming call",
          initialValue: settings?.phoneCall ?? false,
        ),
        _sectionTitle("Unassigned Lead:"),
        _SwitchTile(
          key: const ValueKey('autoAssign'),
          field: 'autoAssign',
          title: "Auto assign lead to selected staff",
          subtitle: "Unassigned lead automatic assign to selected staff",
          initialValue: settings?.autoAssign ?? false,
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
                Text(
                  subtitle,
                  style: AppTextStyle.medium(color: AppColors.grey),
                ),
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

// Add this class at the bottom of general_settings.dart
class _SwitchTile extends StatefulWidget {
  final String field;
  final String title;
  final String subtitle;
  final bool initialValue;

  const _SwitchTile({
    super.key,
    required this.field,
    required this.title,
    required this.subtitle,
    required this.initialValue,
  });

  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  late bool _value;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didUpdateWidget(_SwitchTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSaving && oldWidget.initialValue != widget.initialValue) {
      setState(() => _value = widget.initialValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: AppTextStyle.medium()),
                SizedBox(height: 0.5.h),
                Text(
                  widget.subtitle,
                  style: AppTextStyle.medium(color: AppColors.grey),
                ),
              ],
            ),
          ),
          // Transform.scale(
          //   scale: 0.8,
          //   child: Switch(
          //     value: _value,
          //     activeColor: AppColors.primary,
          //     onChanged: (v) async {
          //       log(
          //         'Switch tapped: ${widget.field} = $v',
          //       ); // ← does this print?
          //       try {
          //         final cubit = context.read<GeneralSettingsCubit>();
          //         log('Cubit found: $cubit'); // ← does this print?
          //         setState(() {
          //           _value = v;
          //           _isSaving = true;
          //         });
          //         await cubit.toggleField(widget.field, v);
          //       } catch (e) {
          //         log('ERROR reading cubit: $e'); // ← probably prints this
          //       }
          //       if (mounted) setState(() => _isSaving = false);
          //     },
          //   ),
          // ),
          SizedBox(
            width: 45,
            height: 28,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Switch(
                value: _value,
                activeColor: AppColors.primary,
                onChanged: (v) async {
                  log('Switch tapped: ${widget.field} = $v');
                  setState(() {
                    _value = v;
                    _isSaving = true;
                  });
                  await context.read<GeneralSettingsCubit>().toggleField(
                    widget.field,
                    v,
                  );
                  if (mounted) setState(() => _isSaving = false);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
