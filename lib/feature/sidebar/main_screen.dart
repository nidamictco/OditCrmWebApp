import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/leads/data/add_lead_repo.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';
import 'package:oxdo/feature/lead_managment/import_leads/cubit/import_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/import_leads/data/import_lead_repo.dart';
import 'package:oxdo/feature/reports/staff_reports/screen/staff_profile_screen.dart';
import 'package:oxdo/feature/reports/staff_reports/screen/time_line.dart';
import 'package:oxdo/feature/rightside_menu/call_settings.dart/cubit/call_settings_cubit.dart';
import 'package:oxdo/feature/rightside_menu/call_settings.dart/data/call_settings_repo.dart';
import 'package:oxdo/feature/rightside_menu/call_settings.dart/screen/call_settings.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/feature/dashboard/dashboard.dart';
import 'package:oxdo/feature/dashboard/lead_list_screen.dart';
import 'package:oxdo/feature/file_manager/view/screen/view.dart';
import 'package:oxdo/feature/lead_managment/call_history/out_going_callHistory.dart';
import 'package:oxdo/feature/lead_managment/leads/screen/delete_leads/screens/delete_leads.dart';
import 'package:oxdo/feature/lead_managment/import_leads/screen/import_leads.dart';
import 'package:oxdo/feature/lead_managment/leads/screen/unassingned_leads/screen/unassingned_lead.dart';
import 'package:oxdo/feature/reports/rejected_leads_report/screen/rejected_leads.dart';
import 'package:oxdo/feature/reports/scheduled_leads/screen/scheduled_leads.dart';
import 'package:oxdo/feature/reports/staff_reports/screen/staff_reports.dart';
import 'package:oxdo/feature/reports/transfer_leads/screen/transfer_leads_report.dart';
import 'package:oxdo/feature/rightside_menu/custom_field_settings/cubit/custom_field_cubit.dart';
import 'package:oxdo/feature/rightside_menu/custom_field_settings/data/custom_field_repo.dart';
import 'package:oxdo/feature/rightside_menu/custom_field_settings/screen/aditional_field.dart';
import 'package:oxdo/feature/rightside_menu/lead_category/cubit/lead_category_cubit.dart';
import 'package:oxdo/feature/rightside_menu/lead_category/data/lead_category_repository.dart';
import 'package:oxdo/feature/rightside_menu/lead_category/screen/lead_category.dart';
import 'package:oxdo/feature/rightside_menu/lead_source/cubit/lead_source_cubit.dart';
import 'package:oxdo/feature/rightside_menu/lead_source/data/lead_source_repo.dart';
import 'package:oxdo/feature/rightside_menu/lead_source/lead_source_screen.dart';
import 'package:oxdo/feature/rightside_menu/lead_stage/cubit/lead_stage_cubit.dart';
import 'package:oxdo/feature/rightside_menu/lead_stage/screen/lead_stage.dart';
import 'package:oxdo/feature/rightside_menu/unassigned_settings/lead_distribution_settings.dart';
import 'package:oxdo/feature/settings/fb_settings/screen/facebook_settings.dart';
import 'package:oxdo/feature/settings/general_settings/screen/general_settings.dart';
import 'package:oxdo/feature/sidebar/widget/bottom_bar.dart';
import 'package:oxdo/feature/sidebar/widget/mini_sidebar.dart';
import 'package:oxdo/feature/sidebar/widget/top_bar.dart';
import 'package:oxdo/feature/lead_managment/leads/screen/add_lead/screen/add_lead.dart';
import 'package:oxdo/feature/lead_managment/leads/screen/lead_report/lead_report.dart';
import 'package:oxdo/feature/lead_managment/call_history/call_history.dart';
import 'package:oxdo/feature/lead_managment/phone_call_log/phone_call_log.dart';
import 'package:oxdo/feature/lead_managment/leads/screen/transfer_leads/transfer_leads.dart';
import 'package:oxdo/feature/sidebar/sidebar_item.dart';
import 'package:oxdo/feature/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:oxdo/feature/staff_managment/staff/model/staff_model.dart';
import 'package:oxdo/feature/staff_managment/staff/screen/add_staff/screen/add_staff.dart';
import 'package:oxdo/feature/staff_managment/staff/screen/deleted_staff/screen/delete_staff.dart';
import 'package:oxdo/feature/staff_managment/designation/cubit/designation_cubit.dart';
import 'package:oxdo/feature/staff_managment/designation/model/designation_model.dart';
import 'package:oxdo/feature/staff_managment/designation/screen/add_designation_screen.dart';
import 'package:oxdo/feature/staff_managment/designation/screen/designation_screen.dart';
import 'package:oxdo/feature/staff_managment/staff/screen/view_staff/screen/view_staff.dart';

import '../dashboard/follow_up_details_screen.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex;
  final DesignationModel? designation;
  final StaffModel? staff;
  final AddLeadModel? lead;
  final String? fromCard;
  const MainScreen({
    super.key,
    this.selectedIndex = 0,
    this.designation,
    this.staff,
    this.lead,
    this.fromCard
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int selectedIndex; // ✅ local state
  bool isSidebarOpen = true;

  // DesignationModel? designation;

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
        return BlocProvider(
          create: (_) => AddLeadCubit(
            leadRepository: AddLeadRepository(),
            categoryRepository: LeadCategoryRepository(),
            sourceRepository: LeadSourceRepository(),
          ),
          child: AddLeadPage(lead: widget.lead),
        );
      case 2:
        return BlocProvider(
          create: (context) => AddLeadCubit(),
          child: LeadsReport(),
        );
      case 3:
        return CallHistoryPage();
      case 4:
        return BlocProvider(
          create: (_) => AddLeadCubit(
            leadRepository: AddLeadRepository(),
            categoryRepository: LeadCategoryRepository(),
            sourceRepository: LeadSourceRepository(),
          )..fetchDeletedLeads(),
          child: DeleteLeads(),
        );
      case 5:
        return BlocProvider(
          create: (_) =>
              AddLeadCubit(
                  leadRepository: AddLeadRepository(),
                  categoryRepository: LeadCategoryRepository(),
                  sourceRepository: LeadSourceRepository(),
                )
                ..fetchLeads()
                ..fetchStaff(),
          child: TransferLeads(),
        );
      case 6:
        return PhoneCallLog();
      case 7:
        return BlocProvider(
          create: (_) => LeadCategoryCubit()..watchCategories(),
          child: LeadCategory(),
        );
      case 8:
        return BlocProvider(
          create: (context) => AdditionalFieldsCubit(
            repository: AdditionalFieldsRepositoryImpl(),
          ),
          child: AdditionalFieldsSection(),
        );
      case 9:
        return BlocProvider(
          create: (_) => LeadSourceCubit()..watchSources(),
          child: LeadSourceScreen(),
        );
      case 10:
        return BlocProvider(
          create: (_) => LeadStageCubit(),
          child: LeadStagesScreen(),
        );
      case 11:
        return LeadDistributionSettingsScreen();
      case 12:
        return BlocProvider(
          create: (context) => AddLeadCubit()..fetchLeads(),
          child: NewLeadsPage(fromCard: widget.fromCard??"",),
        );

      case 13:
        return BlocProvider(
          create: (context) => AddLeadCubit()..fetchLeads(),
          child: UnassingnedLead(),
        );
      case 14:
        return BlocProvider(
          create: (_) => ImportLeadsCubit(repository: ImportLeadsRepository()),
          child: ImportLeads(),
        );
      case 15:
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => StaffCubit()),
            BlocProvider(create: (_) => DesignationCubit()..fetchAll()),
          ],
          child: AddStaff(staff: widget.staff),
        );
      case 16:
        return BlocProvider(create: (_) => StaffCubit(), child: ViewStaff());
      // case 17:
      //   return DesignationScreen();
      case 17:
        return BlocProvider(
          create: (_) => DesignationCubit(),
          child: const DesignationScreen(),
        );
      case 18:
        return BlocProvider(
          create: (_) => StaffCubit()..fetchDeletedStaff(),
          child: DeletedStaffScreen(),
        );
      case 19:
        return ViewPage();
      case 20:
        return GeneralSettings();
      case 21:
        return FacebookSettings();
      case 22:
        return BlocProvider(
          create: (context) => StaffCubit()..fetchAll(),
          child: StaffReports(),
        );
      case 23:
        return TransferLeadsReport();
      case 24:
        return ScheduledLeads();
      case 25:
        return BlocProvider(
          create: (context) => AddLeadCubit(),
          child: RejectedLeads(),
        );
      case 26:
        return OutGoingCallhistory();
      // case 27:
      //   return DesignationPermissionsScreen();
      case 27:
        return BlocProvider(
          create: (_) => DesignationCubit(),
          child: DesignationPermissionsScreen(designation: widget.designation),
        );
      case 28:
        return BlocProvider(
          create: (context) =>
              CallSettingsCubit(repository: CallSettingsRepository())..init(),
          child: CloudCallSettingsScreen(),
        );
      case 29:
        return StaffProfileScreen();
      case 30:
        return TimeLine();
      case 31:
        return FollowUpDetailsScreen();
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
