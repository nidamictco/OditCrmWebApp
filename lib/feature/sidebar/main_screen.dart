import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/shared_preference/session_service.dart';
import 'package:oxdo/feature/auth/cubit/auth/auth_cubit.dart';
import 'package:oxdo/feature/lead_managment/follow_up/data/activity_repo.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/leads/data/add_lead_repo.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';
import 'package:oxdo/feature/lead_managment/import_leads/cubit/import_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/import_leads/data/import_lead_repo.dart';
import 'package:oxdo/feature/notification/cubit/notification_cubit.dart';
import 'package:oxdo/feature/notification/data/notification_repo.dart';
import 'package:oxdo/feature/reports/staff_reports/cubit/staff_activity_cubit.dart';
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
import 'package:oxdo/feature/settings/general_settings/cubit/general_settings_cubit.dart';
import 'package:oxdo/feature/settings/general_settings/data/general_settings_repo.dart';
import 'package:oxdo/feature/settings/general_settings/screen/general_settings.dart';
import 'package:oxdo/feature/notification/screen/notification.dart';
import 'package:oxdo/feature/sidebar/widget/bottom_bar.dart';
import 'package:oxdo/feature/sidebar/widget/mini_sidebar.dart';
import 'package:oxdo/feature/sidebar/widget/profile.dart';
import 'package:oxdo/feature/sidebar/widget/top_bar.dart';
import 'package:oxdo/feature/lead_managment/leads/screen/add_lead/screen/add_lead.dart';
import 'package:oxdo/feature/lead_managment/leads/screen/lead_report/lead_report.dart';
import 'package:oxdo/feature/lead_managment/call_history/call_history.dart';
import 'package:oxdo/feature/lead_managment/phone_call_log/phone_call_log.dart';
import 'package:oxdo/feature/lead_managment/leads/screen/transfer_leads/transfer_leads.dart';
import 'package:oxdo/feature/sidebar/sidebar_item.dart';
import 'package:oxdo/feature/staff_managment/designation/cubit/cubit/permission_cubit.dart';
import 'package:oxdo/feature/staff_managment/designation/screen/permission_guard.dart';
import 'package:oxdo/feature/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:oxdo/feature/staff_managment/staff/model/staff_model.dart';
import 'package:oxdo/feature/staff_managment/staff/screen/add_staff/screen/add_staff.dart';
import 'package:oxdo/feature/staff_managment/staff/screen/deleted_staff/screen/delete_staff.dart';
import 'package:oxdo/feature/staff_managment/designation/cubit/designation_cubit.dart';
import 'package:oxdo/feature/staff_managment/designation/model/designation_model.dart';
import 'package:oxdo/feature/staff_managment/designation/screen/add_designation_screen.dart';
import 'package:oxdo/feature/staff_managment/designation/screen/designation_screen.dart';
import 'package:oxdo/feature/staff_managment/staff/screen/view_staff/screen/psswrd.dart';
import 'package:oxdo/feature/staff_managment/staff/screen/view_staff/screen/view_staff.dart';

import '../lead_managment/follow_up/screens/follow_up_details_screen.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex;
  final DesignationModel? designation;
  final StaffModel? staff;
  final AddLeadModel? lead;
  final String? fromCard;
  final DateTime? selectedDate;
  const MainScreen({
    super.key,
    this.selectedIndex = 0,
    this.designation,
    this.staff,
    this.lead,
    this.fromCard,
    this.selectedDate,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int selectedIndex;
  bool isSidebarOpen = true;
  AddLeadModel? _editLead;
   StaffModel? _currentStaff;

  // late final NotificationCubit _notificationCubit;

  // // DesignationModel? designation;

  // @override
  // void initState() {
  //   super.initState();
  //   selectedIndex = widget.selectedIndex;
  //   _editLead = widget.lead;

  //    WidgetsBinding.instance.addPostFrameCallback((_) async {
  //   final user = await SessionService().getSavedUser();
  //   if (!mounted) return;
  //   final staffId = user?.id ?? '';
  //   // Re-create with the real staffId now that we have it
  //   _notificationCubit.close();
  //   _notificationCubit = NotificationCubit(
  //     NotificationRepo(),
  //     GeneralSettingsRepository(staffId: staffId),
  //   );
  //   _notificationCubit.load(staffId);
  // });
  // }

  // @override
  // void dispose() {
  //   _notificationCubit.close();
  //   super.dispose();
  // }

  late NotificationCubit _notificationCubit;
  bool _notificationCubitReady = false;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
    _editLead = widget.lead;
    _currentStaff = widget.staff;
    _notificationCubit = NotificationCubit(
      NotificationRepo(),
      GeneralSettingsRepository(staffId: ''),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = await SessionService().getSavedUser();
      if (!mounted) return;
      final staffId = user?.id ?? '';

      _notificationCubit = NotificationCubit(
        NotificationRepo(),
        GeneralSettingsRepository(staffId: staffId),
      );
      _notificationCubit.load(staffId);

      setState(() => _notificationCubitReady = true);
    });
  }

  @override
  void dispose() {
    if (_notificationCubitReady) _notificationCubit.close();
    super.dispose();
  }

  void toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
    });
  }

  
  void _onItemSelected(int index) {
    setState(() {
      if (selectedIndex == 20 && index != 20) {
        _generalSettingsPage = null; // ← clear when navigating away
      }
      selectedIndex = index;
      _editLead = null;
      _currentStaff = null;
    });
  }

  Widget? _generalSettingsPage;

  Widget getPage() {
    final perm = context.read<PermissionCubit>(); // ← read once

    switch (selectedIndex) {
      case 0:
        return PermissionGuard(
          hasPermission: perm.canViewDashboard,
          child: BlocProvider(
            create: (context) =>
                AddLeadCubit(),//..fetchDashboardCounts(DateTime.now()),
            child: DashboardScreen(),
          ),
        );
      case 1:
        return PermissionGuard(
          hasPermission: perm.canAddLead,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => AddLeadCubit(
                  leadRepository: AddLeadRepository(),
                  categoryRepository: LeadCategoryRepository(),
                  sourceRepository: LeadSourceRepository(),
                ),
              ),
              BlocProvider(create: (_) => LeadCategoryCubit()),
              BlocProvider(create: (_) => LeadSourceCubit()),
              BlocProvider(create: (_) => LeadStageCubit()),
            ],
            child: AddLeadPage(lead: _editLead),
          ),
        );
      case 2:
        return PermissionGuard(
          hasPermission: perm.canViewLeadsReport,
          child: BlocProvider(
            create: (_) => AddLeadCubit()
              ..fetchLeads()
              ..initialize()
              ..fetchStaff(),
            child: LeadsReport(),
          ),
        );
      case 3:
        return PermissionGuard(
          hasPermission: perm.canViewCallHistory,
          child: CallHistoryPage(),
        );
      case 4:
        return PermissionGuard(
          hasPermission: perm.canViewDeletedLeads,
          child: BlocProvider(
            create: (_) => AddLeadCubit(
              leadRepository: AddLeadRepository(),
              categoryRepository: LeadCategoryRepository(),
              sourceRepository: LeadSourceRepository(),
            )..fetchDeletedLeads(),
            child: DeleteLeads(),
          ),
        );
      case 5:
        return PermissionGuard(
          hasPermission: perm.canTransferLeads || perm.canViewTransferLeads,
          child: BlocProvider(
            create: (_) =>
                AddLeadCubit(
                    leadRepository: AddLeadRepository(),
                    categoryRepository: LeadCategoryRepository(),
                    sourceRepository: LeadSourceRepository(),
                  )
                  ..fetchLeads()
                  ..fetchStaff(),
            child: TransferLeads(),
          ),
        );
      case 6:
        return PermissionGuard(
          hasPermission: perm.canViewPhoneCallLog,
          child: PhoneCallLog(),
        );
      case 7:
        return PermissionGuard(
          hasPermission: perm.canViewLeadCategory,
          child: BlocProvider(
            create: (_) => LeadCategoryCubit()..watchCategories(),
            child: LeadCategory(),
          ),
        );
      case 8:
        return PermissionGuard(
          hasPermission: perm.canViewCustomFields,
          child: BlocProvider(
            create: (_) => AdditionalFieldsCubit(
              repository: AdditionalFieldsRepositoryImpl(),
            ),
            child: AdditionalFieldsSection(),
          ),
        );
      case 9:
        return PermissionGuard(
          hasPermission: perm.canViewLeadSource,
          child: BlocProvider(
            create: (_) => LeadSourceCubit()..watchSources(),
            child: LeadSourceScreen(),
          ),
        );
      case 10:
        return PermissionGuard(
          hasPermission: perm.canViewLeadStages,
          child: BlocProvider(
            create: (_) => LeadStageCubit(),
            child: LeadStagesScreen(),
          ),
        );
      case 11:
        return LeadDistributionSettingsScreen();
      case 12:
        return BlocProvider(
          create: (_) => AddLeadCubit()
            ..initialize()
            ..fetchStaff(),
          // ..fetchDashboardLeads(
          //   staffId: widget.staff!.id!,
          //   role: widget.staff?.staffType ?? 'Admin',
          //   fromCard: widget.fromCard ?? "",
          //   selectedDate: context.read<AddLeadCubit>().state.selectedDashboardDate ?? DateTime.now(),
          // ),
          child: NewLeadsPage(
            fromCard: widget.fromCard ?? "",
            staff: widget.staff,
            selectedDate: widget.selectedDate,
          ),
        );
      case 13:
        return PermissionGuard(
          hasPermission: perm.canViewUnassignedLeads,
          child: BlocProvider(
            create: (_) => AddLeadCubit()..fetchLeads(),
            child: UnassingnedLead(),
          ),
        );
      case 14:
        return PermissionGuard(
          hasPermission: perm.canImportLeads,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) =>
                    ImportLeadsCubit(repository: ImportLeadsRepository()),
              ),
              BlocProvider(
                create: (_) => AddLeadCubit(
                  leadRepository: AddLeadRepository(),
                  categoryRepository: LeadCategoryRepository(),
                  sourceRepository: LeadSourceRepository(),
                ),
              ),
              BlocProvider(create: (_) => LeadCategoryCubit()),
              BlocProvider(create: (_) => LeadSourceCubit()),
              BlocProvider(create: (_) => LeadStageCubit()),
            ],
            child: ImportLeads(),
          ),
        );
      case 15:
        return PermissionGuard(
          hasPermission: perm.canAddStaff,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => StaffCubit()),
              BlocProvider(create: (_) => DesignationCubit()..fetchAll()),
            ],
            // child: AddStaff(staff: widget.staff,),
             child: AddStaff(
        key: ValueKey(_currentStaff?.id ?? 'add_staff'), 
        staff: _currentStaff, 
      ),
          ),
        );
      case 16:
        return PermissionGuard(
          hasPermission: perm.canViewStaff,
          child: BlocProvider(
            create: (_) => StaffCubit()..fetchAll(),
            child: ViewStaff(),
          ),
        );
      case 17:
        return PermissionGuard(
          hasPermission: perm.canViewDesignation,
          child: BlocProvider(
            create: (_) => DesignationCubit()..fetchAll(),
            child: const DesignationScreen(),
          ),
        );
      case 18:
        return PermissionGuard(
          hasPermission: perm.canViewDeletedStaff,
          child: BlocProvider(
            create: (_) => StaffCubit()..fetchDeletedStaff(),
            child: DeletedStaffScreen(),
          ),
        );
      case 19:
        return PermissionGuard(
          hasPermission: perm.canViewFileManager,
          child: ViewPage(),
        );
      // case 20:
      //   _generalSettingsPage ??= PermissionGuard(
      //     hasPermission: perm.canViewGeneralSettings,
      //     child: BlocProvider(
      //       create: (_) => GeneralSettingsCubit()..loadForCurrentUser(),
      //       child: const GeneralSettings(),
      //     ),
      //   );
      //   return _generalSettingsPage!;
      case 20:
        _generalSettingsPage ??= PermissionGuard(
          hasPermission: perm.canViewGeneralSettings,
          child: BlocProvider(
            create: (_) {
              final cubit = GeneralSettingsCubit()..loadForCurrentUser();
              // ← wire the callback so toggle updates NotificationCubit immediately
              cubit.onSettingsChanged = (updated) {
                if (_notificationCubitReady) {
                  _notificationCubit.refreshSettings(updated);
                }
              };
              return cubit;
            },
            child: const GeneralSettings(),
          ),
        );
        return _generalSettingsPage!;
      case 21:
        return PermissionGuard(
          hasPermission: perm.canViewFacebookSettings,
          child: FacebookSettings(),
        );
      case 22:
        return PermissionGuard(
          hasPermission: perm.canViewStaffReport,
          child: BlocProvider(
            create: (_) => StaffCubit()..fetchAll(),
            child: StaffReports(),
          ),
        );
      // case 23:
      //   return PermissionGuard(
      //     hasPermission: perm.canViewTransferReport,
      //     child: BlocProvider(
      //       create: (_) => AddLeadCubit()..fetchLeads(),
      //       child: TransferLeadsReport(),
      //     ),
      //   );
      case 23:
  return PermissionGuard(
    hasPermission: perm.canViewTransferReport,
    child: FutureBuilder(
      future: SessionService().getSavedUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = snapshot.data;
        return BlocProvider(
          create: (_) => AddLeadCubit(),
          child: TransferLeadsReport(
            currentUserId:   user?.id ?? '',
            currentUserRole: user?.staffType ?? '',
            currentUserName: user?.name ?? '',
          ),
        );
      },
    ),
  );
      case 24:
        return PermissionGuard(
          hasPermission: perm.canViewScheduledReport,
          child: ScheduledLeads(),
        );
      case 25:
        return PermissionGuard(
          hasPermission: perm.canViewRejectedReport,
          child: BlocProvider(
            create: (_) => AddLeadCubit(),
            child: RejectedLeads(),
          ),
        );
      case 26:
        return OutGoingCallhistory();
      case 27:
        return BlocProvider(
          create: (_) => DesignationCubit(),
          child: DesignationPermissionsScreen(designation: widget.designation),
        );
      case 28:
        return BlocProvider(
          create: (_) =>
              CallSettingsCubit(repository: CallSettingsRepository())..init(),
          child: CloudCallSettingsScreen(),
        );
      case 29:
        if (widget.staff == null) return const SizedBox();
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => StaffCubit()),
            BlocProvider(create: (context) => AddLeadCubit()),
            BlocProvider(create: (context) => StaffActivityCubit(ActivityRepository())),
          ],
          child: StaffProfileScreen(staff: widget.staff!),
        );
      case 30:
        return TimeLine();
      case 31:
        return BlocProvider(
          create: (_) => AddLeadCubit()
            // ..fetchDashboardLeads(staffId: '', role: '', fromCard: '', selectedDate: )
            ..initialize()
            ..fetchStaff(),
          child: FollowUpDetailsScreen(currentLead: widget.lead!),
        );
      case 32:
        if (widget.staff == null) return const SizedBox();
        return BlocProvider(
          create: (_) => StaffCubit(),
          child: ChangePasswordScreen(staff: widget.staff!),
        );
      case 33:
        return BlocProvider(
          create: (context) => StaffCubit(),
          child: PersonalProfile(),
        );
      case 34:
        return BlocProvider.value(
          value: _notificationCubit,
          child: NotificationScreen(),
        );
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
          SizedBox(
            width: isSidebarOpen ? 250 : 70,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: isSidebarOpen
                  ? SidebarItem(
                      selectedIndex: selectedIndex,
                      onItemSelected: _onItemSelected,
                    )
                  : MiniSidebar(
                      selectedIndex: selectedIndex,
                      onItemSelected: _onItemSelected,
                    ),
            ),
          ),

          /// MAIN CONTENT
          Expanded(
            child: Column(
              children: [
                MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => AddLeadCubit()..fetchLeads()),

                    BlocProvider.value(value: _notificationCubit),
                  ],
                  child: TopBar(
                    isSidebarOpen: isSidebarOpen,
                    onMenuTap: toggleSidebar,
                  ),
                ),

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
