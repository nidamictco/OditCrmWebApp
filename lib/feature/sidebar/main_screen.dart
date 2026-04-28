import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:login_2_it_solution/feature/rightside_menu/call_settings.dart/screen/call_settings.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/feature/dashboard/dashboard.dart';
import 'package:login_2_it_solution/feature/dashboard/lead_details.dart';
import 'package:login_2_it_solution/feature/file_manager/view/screen/view.dart';
import 'package:login_2_it_solution/feature/lead_managment/call_history/out_going_callHistory.dart';
import 'package:login_2_it_solution/feature/lead_managment/delete_leads/screens/delete_leads.dart';
import 'package:login_2_it_solution/feature/lead_managment/import_leads/screen/import_leads.dart';
import 'package:login_2_it_solution/feature/lead_managment/unassingned_leads/screen/unassingned_lead.dart';
import 'package:login_2_it_solution/feature/reports/rejected_leads_report/screen/rejected_leads.dart';
import 'package:login_2_it_solution/feature/reports/scheduled_leads/screen/scheduled_leads.dart';
import 'package:login_2_it_solution/feature/reports/staff_reports/screen/staff_reports.dart';
import 'package:login_2_it_solution/feature/reports/transfer_leads/screen/transfer_leads_report.dart';
import 'package:login_2_it_solution/feature/rightside_menu/custom_field_settings/aditional_field.dart';
import 'package:login_2_it_solution/feature/rightside_menu/lead_category/lead_category.dart';
import 'package:login_2_it_solution/feature/rightside_menu/lead_source/lead_source_screen.dart';
import 'package:login_2_it_solution/feature/rightside_menu/lead_stage/lead_stage.dart';
import 'package:login_2_it_solution/feature/rightside_menu/unassigned_settings/lead_distribution_settings.dart';
import 'package:login_2_it_solution/feature/settings/fb_settings/screen/facebook_settings.dart';
import 'package:login_2_it_solution/feature/settings/general_settings/screen/general_settings.dart';
import 'package:login_2_it_solution/feature/sidebar/widget/bottom_bar.dart';
import 'package:login_2_it_solution/feature/sidebar/widget/mini_sidebar.dart';
import 'package:login_2_it_solution/feature/sidebar/widget/top_bar.dart';
import 'package:login_2_it_solution/feature/lead_managment/add_lead/add_lead.dart';
import 'package:login_2_it_solution/feature/lead_managment/lead_report/lead_report.dart';
import 'package:login_2_it_solution/feature/lead_managment/call_history/call_history.dart';
import 'package:login_2_it_solution/feature/lead_managment/phone_call_log/phone_call_log.dart';
import 'package:login_2_it_solution/feature/lead_managment/transfer_leads/transfer_leads.dart';
import 'package:login_2_it_solution/feature/sidebar/sidebar_item.dart';
import 'package:login_2_it_solution/feature/staff_managment/add_staff/screen/add_staff.dart';
import 'package:login_2_it_solution/feature/staff_managment/delete_staff/screen/delete_staff.dart';
import 'package:login_2_it_solution/feature/staff_managment/designation/screen/add_designation_screen.dart';
import 'package:login_2_it_solution/feature/staff_managment/designation/screen/designation_screen.dart';
import 'package:login_2_it_solution/feature/staff_managment/view_staff/screen/view_staff.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex;
  const MainScreen({super.key, this.selectedIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int selectedIndex; // ✅ local state
  bool isSidebarOpen = true;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex; // initial value
  }

  void toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
    });
  }

  Widget getPage() {
    switch (selectedIndex) {
      // ✅ use local variable
      case 0:
        return DashboardScreen();
      case 1:
        return AddLeadPage();
      case 2:
        return LeadsReport();
      case 3:
        return CallHistoryPage();
      case 4:
        return DeleteLeads();
      case 5:
        return TransferLeads();
      case 6:
        return PhoneCallLog();
      case 7:
        return LeadCategory();
      case 8:
        return AdditionalFieldsSection();
      case 9:
        return LeadSourceScreen();
      case 10:
        return LeadStagesScreen();
      case 11:
        return LeadDistributionSettingsScreen();
      case 12:
        return NewLeadsPage();
      case 13:
        return UnassingnedLead();
      case 14:
        return ImportLeads();
      case 15:
        return AddStaff();
      case 16:
        return ViewStaff();
      case 17:
        return DesignationScreen();
      case 18:
        return DeleteStaff();
      case 19:
        return ViewPage();
      case 20:
        return GeneralSettings();
      case 21:
        return FacebookSettings();
      case 22:
        return StaffReports();
      case 23:
        return TransferLeadsReport();
      case 24:
        return ScheduledLeads();
      case 25:
        return RejectedLeads();
      case 26:
        return OutGoingCallhistory();
      case 27:
        return DesignationPermissionsScreen();
      case 28:
        return CloudCallSettingsScreen();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          /// SIDEBAR
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSidebarOpen ? 250 : 70,
            child: isSidebarOpen
                ? SidebarItem(
                    selectedIndex: selectedIndex,
                    onItemSelected: (index) {
                      setState(() {
                        selectedIndex = index; // ✅ FIXED
                      });
                    },
                  )
                : MiniSidebar(
                    selectedIndex: selectedIndex,
                    onItemSelected: (index) {
                      setState(() {
                        selectedIndex = index; // ✅ FIXED
                      });
                    },
                  ),
          ),

          /// MAIN CONTENT
          Expanded(
            child: Column(
              children: [
                TopBar(isSidebarOpen: isSidebarOpen, onMenuTap: toggleSidebar),

                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: getPage(),
                  ),
                ),

                BottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
