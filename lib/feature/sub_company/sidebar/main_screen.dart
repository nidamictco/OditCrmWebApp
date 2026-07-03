import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/core/shared_preference/session_service.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/follow_up/data/activity_repo.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/data/add_lead_repo.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/cubit/import_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/data/import_lead_repo.dart';
import 'package:Odit_CRM/feature/sub_company/notification/cubit/notification_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/notification/data/notification_repo.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/cubit/staff_activity_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/screen/staff_profile_screen.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/screen/time_line.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/call_settings.dart/cubit/call_settings_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/call_settings.dart/data/call_settings_repo.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/call_settings.dart/screen/call_settings.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/feature/sub_company/dashboard/dashboard.dart';
import 'package:Odit_CRM/feature/sub_company/dashboard/lead_list_screen.dart';
import 'package:Odit_CRM/feature/sub_company/file_manager/view/screen/view.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/call_history/out_going_callHistory.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/delete_leads/screens/delete_leads.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/screen/import_leads.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/unassingned_leads/screen/unassingned_lead.dart';
import 'package:Odit_CRM/feature/sub_company/reports/rejected_leads_report/screen/rejected_leads.dart';
import 'package:Odit_CRM/feature/sub_company/reports/scheduled_leads/screen/scheduled_leads.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/screen/staff_reports.dart';
import 'package:Odit_CRM/feature/sub_company/reports/transfer_leads/screen/transfer_leads_report.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/custom_field_settings/cubit/custom_field_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/custom_field_settings/data/custom_field_repo.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/custom_field_settings/screen/aditional_field.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/cubit/lead_category_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/data/lead_category_repository.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/screen/lead_category.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_source/cubit/lead_source_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_source/data/lead_source_repo.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_source/lead_source_screen.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_stage/cubit/lead_stage_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_stage/screen/lead_stage.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/unassigned_settings/lead_distribution_settings.dart';
import 'package:Odit_CRM/feature/sub_company/settings/fb_settings/screen/facebook_settings.dart';
import 'package:Odit_CRM/feature/sub_company/settings/general_settings/cubit/general_settings_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/settings/general_settings/data/general_settings_repo.dart';
import 'package:Odit_CRM/feature/sub_company/settings/general_settings/screen/general_settings.dart';
import 'package:Odit_CRM/feature/sub_company/notification/screen/notification.dart';
import 'package:Odit_CRM/feature/sub_company/sidebar/widget/bottom_bar.dart';
import 'package:Odit_CRM/feature/sub_company/sidebar/widget/mini_sidebar.dart';
import 'package:Odit_CRM/feature/sub_company/sidebar/widget/profile.dart';
import 'package:Odit_CRM/feature/sub_company/sidebar/widget/top_bar.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/add_lead/screen/add_lead.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/lead_report/lead_report.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/call_history/call_history.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/phone_call_log/phone_call_log.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/transfer_leads/transfer_leads.dart';
import 'package:Odit_CRM/feature/sub_company/sidebar/sidebar_item.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/cubit/permition_cubit/permission_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/screen/permission_guard.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/screen/add_staff/screen/add_staff.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/screen/deleted_staff/screen/delete_staff.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/cubit/designation_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/model/designation_model.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/screen/add_designation_screen.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/screen/designation_screen.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/screen/view_staff/screen/psswrd.dart';
import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/screen/view_staff/screen/view_staff.dart';

import '../../../main.dart';
import '../lead_managment/follow_up/screens/follow_up_details_screen.dart';

// A single app-wide navigator key so we can always reach the root navigator
// from any context — even one that is mid-pop and no longer the top route.

class MainScreen extends StatefulWidget {
  final int selectedIndex;
  final DesignationModel? designation;
  final StaffModel? staff;
  final AddLeadModel? lead;
  final String? fromCard;
  final DateTime? selectedDate;

  /// When true, pressing the system back button navigates all the way back to
  /// the Dashboard (pops to the first/root route) instead of letting the OS
  /// handle the pop normally.
  ///
  /// Set to true for:
  ///   • Every sidebar-menu navigation  (sidebar → any screen)
  ///   • Every in-app flow that should "bottom out" at Dashboard
  ///     e.g. Dashboard card → LeadListing (index 12)
  ///          LeadListing → FOLLOWUP (index 31)
  ///          ViewStaff → StaffProfile (index 29)
  final bool goToDashboardOnBack;

  const MainScreen({
    super.key,
    this.selectedIndex = 0,
    this.designation,
    this.staff,
    this.lead,
    this.fromCard,
    this.selectedDate,
    this.goToDashboardOnBack = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  late int selectedIndex;
  bool isSidebarOpen = true;
  AddLeadModel? _editLead;
  StaffModel? _currentStaff;
  bool showExitAlert = false;

  late NotificationCubit _notificationCubit;
  bool _notificationCubitReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    selectedIndex = widget.selectedIndex;
    log(
      "[MainScreen] init selectedIndex=$selectedIndex goToDashboardOnBack=${widget.goToDashboardOnBack}",
    );
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
    WidgetsBinding.instance.removeObserver(this);
    if (_notificationCubitReady) _notificationCubit.close();
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    // Only handle if this route is currently the topmost active route.
    final bool isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    if (!isCurrent) {
      return false;
    }

    final bool isDashboard = selectedIndex == 0;
    final bool shouldIntercept = isDashboard || widget.goToDashboardOnBack;

    if (shouldIntercept) {
      if (isDashboard) {
        setState(() => showExitAlert = !showExitAlert);
        return true; // handled
      } else if (widget.goToDashboardOnBack) {
        if (showExitAlert) {
          setState(() => showExitAlert = false);
          return true; // handled
        } else {
          _popToDashboard();
          return true; // handled
        }
      }
    }

    return false; // let default pop happen
  }

  void toggleSidebar() => setState(() => isSidebarOpen = !isSidebarOpen);

  String _getRouteNameForIndex(int index) {
    const names = {
      0: '/dashboard',
      1: '/add_lead',
      2: '/leads_report',
      3: '/call_history',
      4: '/deleted_leads',
      5: '/transfer_leads',
      6: '/phone_call_log',
      7: '/lead_category',
      8: '/custom_fields',
      9: '/lead_source',
      10: '/lead_stages',
      11: '/lead_distribution',
      12: '/new_leads',
      13: '/unassigned_leads',
      14: '/import_leads',
      15: '/add_staff',
      16: '/view_staff',
      17: '/designation',
      18: '/deleted_staff',
      19: '/file_manager',
      20: '/general_settings',
      21: '/facebook_settings',
      22: '/staff_reports',
      23: '/transfer_report',
      24: '/scheduled_report',
      25: '/rejected_report',
      26: '/outgoing_call_history',
      27: '/designation_permissions',
      28: '/cloud_call_settings',
      29: '/staff_profile',
      30: '/timeline',
      31: '/follow_up',
      32: '/change_password',
      33: '/personal_profile',
      34: '/notifications',
    };
    return names[index] ?? '/screen_$index';
  }

  void _onItemSelected(int index) {
    if (selectedIndex == index) return;
    if (selectedIndex == 20 && index != 20) _generalSettingsPage = null;

    if (index == 0) {
      _popToDashboard();
    } else {
      // Always clear everything above Dashboard first, then push the sidebar
      // screen so the stack is always: [Dashboard → SidebarScreen].
      _popToDashboard();
      appNavigatorKey.currentState?.push(
        MaterialPageRoute(
          settings: RouteSettings(name: _getRouteNameForIndex(index)),
          builder: (_) =>
              MainScreen(selectedIndex: index, goToDashboardOnBack: true),
        ),
      );
    }
  }

  /// Pops everything down to the root Dashboard route.
  /// Uses the global navigator key so it works even when this widget's own
  /// BuildContext is no longer the topmost route (e.g. mid-pop).
  void _popToDashboard() {
    appNavigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  Widget? _generalSettingsPage;

  Widget getPage() {
    final perm = context.read<PermissionCubit>();

    switch (selectedIndex) {
      case 0:
        return PermissionGuard(
          hasPermission: perm.canViewDashboard,
          child: BlocProvider(
            create: (_) => AddLeadCubit(),
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
      case 20:
        _generalSettingsPage ??= PermissionGuard(
          hasPermission: perm.canViewGeneralSettings,
          child: BlocProvider(
            create: (_) {
              final cubit = GeneralSettingsCubit()..loadForCurrentUser();
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
                  currentUserId: user?.id ?? '',
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
            BlocProvider(create: (_) => StaffCubit()),
            BlocProvider(create: (_) => AddLeadCubit()),
            BlocProvider(
              create: (_) => StaffActivityCubit(ActivityRepository()),
            ),
          ],
          child: StaffProfileScreen(staff: widget.staff!),
        );
      case 30:
        return TimeLine();
      case 31:
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => AddLeadCubit()
                ..initialize()
                ..fetchStaff(),
            ),
            BlocProvider(create: (_) => LeadCategoryCubit()),
          ],
          child: FOLLOWUPDetailsScreen(currentLead: widget.lead!),
        );
      case 32:
        if (widget.staff == null) return const SizedBox();
        return BlocProvider(
          create: (_) => StaffCubit(),
          child: ChangePasswordScreen(staff: widget.staff!),
        );
      case 33:
        return BlocProvider(
          create: (_) => StaffCubit(),
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

  Widget _buildExitDialogOverlay() {
    if (!showExitAlert) return const SizedBox.shrink();
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => showExitAlert = false),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Exit Application',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  'Are you sure you want to exit from the app?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => setState(() => showExitAlert = false),
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => SystemNavigator.pop(),
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDashboard = selectedIndex == 0;

    // Block the native OS pop for:
    //   • Dashboard → we show the exit alert instead.
    //   • Any screen marked goToDashboardOnBack → we pop to root ourselves.
    // All other screens (canPop = true) let the OS handle back normally.
    // Note: On Web, we always set blockNativePop = false (canPop = true) to prevent
    // PopScope/BackButtonDispatcher from breaking browser back button behavior due to focus loss.
    // We handle the back logic reliably in didPopRoute() instead.
    final bool blockNativePop = kIsWeb
        ? false
        : (isDashboard || widget.goToDashboardOnBack);

    log(
      "[MainScreen Build] idx=$selectedIndex goToDashboardOnBack=${widget.goToDashboardOnBack} blockNativePop=$blockNativePop",
    );

    return PopScope(
      canPop: !blockNativePop,
      onPopInvokedWithResult: (didPop, result) {
        log(
          "[PopScope] idx=$selectedIndex didPop=$didPop goToDashboardOnBack=${widget.goToDashboardOnBack} showExitAlert=$showExitAlert",
        );

        // If Flutter already handled the pop (canPop was true), nothing to do.
        if (didPop) return;

        if (isDashboard) {
          // On Dashboard: toggle the exit confirmation dialog.
          setState(() => showExitAlert = !showExitAlert);
          return;
        }

        // On any goToDashboardOnBack screen: navigate to root.
        // We use the global key here — NOT Navigator.of(context) — because
        // by the time onPopInvokedWithResult fires the widget may no longer
        // be the active top route, making its local context's Navigator stale.
        if (showExitAlert) {
          setState(() => showExitAlert = false);
        } else {
          _popToDashboard();
        }
      },
      child: Stack(
        children: [
          Scaffold(
            body: Row(
              children: [
                // ── SIDEBAR ────────────────────────────────────────────────
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

                // ── MAIN CONTENT ───────────────────────────────────────────
                Expanded(
                  child: Column(
                    children: [
                      MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (_) => AddLeadCubit()..fetchLeads(),
                          ),
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
          ),
          _buildExitDialogOverlay(),
        ],
      ),
    );
  }
}

// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:Odit_CRM/core/shared_preference/session_service.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/follow_up/data/activity_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/data/add_lead_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/cubit/import_lead_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/data/import_lead_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/notification/cubit/notification_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/notification/data/notification_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/cubit/staff_activity_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/screen/staff_profile_screen.dart';
// import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/screen/time_line.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/call_settings.dart/cubit/call_settings_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/call_settings.dart/data/call_settings_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/call_settings.dart/screen/call_settings.dart';
// import 'package:Odit_CRM/core/theme/app_colors.dart';
// import 'package:Odit_CRM/feature/sub_company/dashboard/dashboard.dart';
// import 'package:Odit_CRM/feature/sub_company/dashboard/lead_list_screen.dart';
// import 'package:Odit_CRM/feature/sub_company/file_manager/view/screen/view.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/call_history/out_going_callHistory.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/delete_leads/screens/delete_leads.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/screen/import_leads.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/unassingned_leads/screen/unassingned_lead.dart';
// import 'package:Odit_CRM/feature/sub_company/reports/rejected_leads_report/screen/rejected_leads.dart';
// import 'package:Odit_CRM/feature/sub_company/reports/scheduled_leads/screen/scheduled_leads.dart';
// import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/screen/staff_reports.dart';
// import 'package:Odit_CRM/feature/sub_company/reports/transfer_leads/screen/transfer_leads_report.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/custom_field_settings/cubit/custom_field_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/custom_field_settings/data/custom_field_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/custom_field_settings/screen/aditional_field.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/cubit/lead_category_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/data/lead_category_repository.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/screen/lead_category.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_source/cubit/lead_source_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_source/data/lead_source_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_source/lead_source_screen.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_stage/cubit/lead_stage_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_stage/screen/lead_stage.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/unassigned_settings/lead_distribution_settings.dart';
// import 'package:Odit_CRM/feature/sub_company/settings/fb_settings/screen/facebook_settings.dart';
// import 'package:Odit_CRM/feature/sub_company/settings/general_settings/cubit/general_settings_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/settings/general_settings/data/general_settings_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/settings/general_settings/screen/general_settings.dart';
// import 'package:Odit_CRM/feature/sub_company/notification/screen/notification.dart';
// import 'package:Odit_CRM/feature/sub_company/sidebar/widget/bottom_bar.dart';
// import 'package:Odit_CRM/feature/sub_company/sidebar/widget/mini_sidebar.dart';
// import 'package:Odit_CRM/feature/sub_company/sidebar/widget/profile.dart';
// import 'package:Odit_CRM/feature/sub_company/sidebar/widget/top_bar.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/add_lead/screen/add_lead.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/lead_report/lead_report.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/call_history/call_history.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/phone_call_log/phone_call_log.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/transfer_leads/transfer_leads.dart';
// import 'package:Odit_CRM/feature/sub_company/sidebar/sidebar_item.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/cubit/cubit/permission_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/screen/permission_guard.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/screen/add_staff/screen/add_staff.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/screen/deleted_staff/screen/delete_staff.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/cubit/designation_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/model/designation_model.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/screen/add_designation_screen.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/screen/designation_screen.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/screen/view_staff/screen/psswrd.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/screen/view_staff/screen/view_staff.dart';

// import '../lead_managment/follow_up/screens/follow_up_details_screen.dart';

// class MainScreen extends StatefulWidget {
//   final int selectedIndex;
//   final DesignationModel? designation;
//   final StaffModel? staff;
//   final AddLeadModel? lead;
//   final String? fromCard;
//   final DateTime? selectedDate;

//   /// When true, pressing the system back button will navigate to the Dashboard
//   /// (popUntil first route) instead of allowing the OS to pop this route.
//   ///
//   /// Set this to true for:
//   ///   • Every sidebar-menu navigation  (sidebar → any screen)
//   ///   • Every in-app navigation that should "bottom out" at Dashboard
//   ///     e.g. Dashboard card → LeadListing (index 12), or
//   ///          LeadListing → FOLLOWUP (index 31)
//   final bool goToDashboardOnBack;

//   const MainScreen({
//     super.key,
//     this.selectedIndex = 0,
//     this.designation,
//     this.staff,
//     this.lead,
//     this.fromCard,
//     this.selectedDate,
//     this.goToDashboardOnBack = false,
//   });

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   late int selectedIndex;
//   bool isSidebarOpen = true;
//   AddLeadModel? _editLead;
//   StaffModel? _currentStaff;
//   bool showExitAlert = false;

//   late NotificationCubit _notificationCubit;
//   bool _notificationCubitReady = false;

//   @override
//   void initState() {
//     super.initState();
//     selectedIndex = widget.selectedIndex;
//     log("[MainScreen] selectedIndex: $selectedIndex");
//     _editLead = widget.lead;
//     _currentStaff = widget.staff;
//     _notificationCubit = NotificationCubit(
//       NotificationRepo(),
//       GeneralSettingsRepository(staffId: ''),
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final user = await SessionService().getSavedUser();
//       if (!mounted) return;
//       final staffId = user?.id ?? '';

//       _notificationCubit = NotificationCubit(
//         NotificationRepo(),
//         GeneralSettingsRepository(staffId: staffId),
//       );
//       _notificationCubit.load(staffId);

//       setState(() => _notificationCubitReady = true);
//     });
//   }

//   @override
//   void dispose() {
//     if (_notificationCubitReady) _notificationCubit.close();
//     super.dispose();
//   }

//   void toggleSidebar() {
//     setState(() {
//       isSidebarOpen = !isSidebarOpen;
//     });
//   }

//   String _getRouteNameForIndex(int index) {
//     switch (index) {
//       case 0:
//         return '/dashboard';
//       case 1:
//         return '/add_lead';
//       case 2:
//         return '/leads_report';
//       case 3:
//         return '/call_history';
//       case 4:
//         return '/deleted_leads';
//       case 5:
//         return '/transfer_leads';
//       case 6:
//         return '/phone_call_log';
//       case 7:
//         return '/lead_category';
//       case 8:
//         return '/custom_fields';
//       case 9:
//         return '/lead_source';
//       case 10:
//         return '/lead_stages';
//       case 11:
//         return '/lead_distribution';
//       case 12:
//         return '/new_leads';
//       case 13:
//         return '/unassigned_leads';
//       case 14:
//         return '/import_leads';
//       case 15:
//         return '/add_staff';
//       case 16:
//         return '/view_staff';
//       case 17:
//         return '/designation';
//       case 18:
//         return '/deleted_staff';
//       case 19:
//         return '/file_manager';
//       case 20:
//         return '/general_settings';
//       case 21:
//         return '/facebook_settings';
//       case 22:
//         return '/staff_reports';
//       case 23:
//         return '/transfer_report';
//       case 24:
//         return '/scheduled_report';
//       case 25:
//         return '/rejected_report';
//       case 26:
//         return '/outgoing_call_history';
//       case 27:
//         return '/designation_permissions';
//       case 28:
//         return '/cloud_call_settings';
//       case 29:
//         return '/staff_profile';
//       case 30:
//         return '/timeline';
//       case 31:
//         return '/follow_up';
//       case 32:
//         return '/change_password';
//       case 33:
//         return '/personal_profile';
//       case 34:
//         return '/notifications';
//       default:
//         return '/screen_$index';
//     }
//   }

//   void _onItemSelected(int index) {
//     if (selectedIndex == index) return;
//     if (selectedIndex == 20 && index != 20) {
//       _generalSettingsPage = null;
//     }

//     if (index == 0) {
//       // Tapping Dashboard always pops everything back to root.
//       Navigator.of(context).popUntil((route) => route.isFirst);
//     } else {
//       // Pop all routes above the first route (Dashboard) to keep history stack clean,
//       // then push the selected sidebar item.
//       Navigator.of(context).popUntil((route) => route.isFirst);
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           settings: RouteSettings(name: _getRouteNameForIndex(index)),
//           builder: (context) =>
//               MainScreen(selectedIndex: index, goToDashboardOnBack: true),
//         ),
//       );
//     }
//   }

//   /// Pop the entire back stack back to the Dashboard (the first/root route).
//   void _goToDashboard() {
//     Navigator.of(context).popUntil((route) => route.isFirst);
//   }

//   Widget? _generalSettingsPage;

//   Widget getPage() {
//     final perm = context.read<PermissionCubit>();

//     switch (selectedIndex) {
//       case 0:
//         return PermissionGuard(
//           hasPermission: perm.canViewDashboard,
//           child: BlocProvider(
//             create: (context) => AddLeadCubit(),
//             child: DashboardScreen(),
//           ),
//         );
//       case 1:
//         return PermissionGuard(
//           hasPermission: perm.canAddLead,
//           child: MultiBlocProvider(
//             providers: [
//               BlocProvider(
//                 create: (_) => AddLeadCubit(
//                   leadRepository: AddLeadRepository(),
//                   categoryRepository: LeadCategoryRepository(),
//                   sourceRepository: LeadSourceRepository(),
//                 ),
//               ),
//               BlocProvider(create: (_) => LeadCategoryCubit()),
//               BlocProvider(create: (_) => LeadSourceCubit()),
//               BlocProvider(create: (_) => LeadStageCubit()),
//             ],
//             child: AddLeadPage(lead: _editLead),
//           ),
//         );
//       case 2:
//         return PermissionGuard(
//           hasPermission: perm.canViewLeadsReport,
//           child: BlocProvider(
//             create: (_) => AddLeadCubit()
//               ..fetchLeads()
//               ..initialize()
//               ..fetchStaff(),
//             child: LeadsReport(),
//           ),
//         );
//       case 3:
//         return PermissionGuard(
//           hasPermission: perm.canViewCallHistory,
//           child: CallHistoryPage(),
//         );
//       case 4:
//         return PermissionGuard(
//           hasPermission: perm.canViewDeletedLeads,
//           child: BlocProvider(
//             create: (_) => AddLeadCubit(
//               leadRepository: AddLeadRepository(),
//               categoryRepository: LeadCategoryRepository(),
//               sourceRepository: LeadSourceRepository(),
//             )..fetchDeletedLeads(),
//             child: DeleteLeads(),
//           ),
//         );
//       case 5:
//         return PermissionGuard(
//           hasPermission: perm.canTransferLeads || perm.canViewTransferLeads,
//           child: BlocProvider(
//             create: (_) =>
//                 AddLeadCubit(
//                     leadRepository: AddLeadRepository(),
//                     categoryRepository: LeadCategoryRepository(),
//                     sourceRepository: LeadSourceRepository(),
//                   )
//                   ..fetchLeads()
//                   ..fetchStaff(),
//             child: TransferLeads(),
//           ),
//         );
//       case 6:
//         return PermissionGuard(
//           hasPermission: perm.canViewPhoneCallLog,
//           child: PhoneCallLog(),
//         );
//       case 7:
//         return PermissionGuard(
//           hasPermission: perm.canViewLeadCategory,
//           child: BlocProvider(
//             create: (_) => LeadCategoryCubit()..watchCategories(),
//             child: LeadCategory(),
//           ),
//         );
//       case 8:
//         return PermissionGuard(
//           hasPermission: perm.canViewCustomFields,
//           child: BlocProvider(
//             create: (_) => AdditionalFieldsCubit(
//               repository: AdditionalFieldsRepositoryImpl(),
//             ),
//             child: AdditionalFieldsSection(),
//           ),
//         );
//       case 9:
//         return PermissionGuard(
//           hasPermission: perm.canViewLeadSource,
//           child: BlocProvider(
//             create: (_) => LeadSourceCubit()..watchSources(),
//             child: LeadSourceScreen(),
//           ),
//         );
//       case 10:
//         return PermissionGuard(
//           hasPermission: perm.canViewLeadStages,
//           child: BlocProvider(
//             create: (_) => LeadStageCubit(),
//             child: LeadStagesScreen(),
//           ),
//         );
//       case 11:
//         return LeadDistributionSettingsScreen();
//       case 12:
//         return BlocProvider(
//           create: (_) => AddLeadCubit()
//             ..initialize()
//             ..fetchStaff(),
//           child: NewLeadsPage(
//             fromCard: widget.fromCard ?? "",
//             staff: widget.staff,
//             selectedDate: widget.selectedDate,
//           ),
//         );
//       case 13:
//         return PermissionGuard(
//           hasPermission: perm.canViewUnassignedLeads,
//           child: BlocProvider(
//             create: (_) => AddLeadCubit()..fetchLeads(),
//             child: UnassingnedLead(),
//           ),
//         );
//       case 14:
//         return PermissionGuard(
//           hasPermission: perm.canImportLeads,
//           child: MultiBlocProvider(
//             providers: [
//               BlocProvider(
//                 create: (_) =>
//                     ImportLeadsCubit(repository: ImportLeadsRepository()),
//               ),
//               BlocProvider(
//                 create: (_) => AddLeadCubit(
//                   leadRepository: AddLeadRepository(),
//                   categoryRepository: LeadCategoryRepository(),
//                   sourceRepository: LeadSourceRepository(),
//                 ),
//               ),
//               BlocProvider(create: (_) => LeadCategoryCubit()),
//               BlocProvider(create: (_) => LeadSourceCubit()),
//               BlocProvider(create: (_) => LeadStageCubit()),
//             ],
//             child: ImportLeads(),
//           ),
//         );
//       case 15:
//         return PermissionGuard(
//           hasPermission: perm.canAddStaff,
//           child: MultiBlocProvider(
//             providers: [
//               BlocProvider(create: (_) => StaffCubit()),
//               BlocProvider(create: (_) => DesignationCubit()..fetchAll()),
//             ],
//             child: AddStaff(
//               key: ValueKey(_currentStaff?.id ?? 'add_staff'),
//               staff: _currentStaff,
//             ),
//           ),
//         );
//       case 16:
//         return PermissionGuard(
//           hasPermission: perm.canViewStaff,
//           child: BlocProvider(
//             create: (_) => StaffCubit()..fetchAll(),
//             child: ViewStaff(),
//           ),
//         );
//       case 17:
//         return PermissionGuard(
//           hasPermission: perm.canViewDesignation,
//           child: BlocProvider(
//             create: (_) => DesignationCubit()..fetchAll(),
//             child: const DesignationScreen(),
//           ),
//         );
//       case 18:
//         return PermissionGuard(
//           hasPermission: perm.canViewDeletedStaff,
//           child: BlocProvider(
//             create: (_) => StaffCubit()..fetchDeletedStaff(),
//             child: DeletedStaffScreen(),
//           ),
//         );
//       case 19:
//         return PermissionGuard(
//           hasPermission: perm.canViewFileManager,
//           child: ViewPage(),
//         );
//       case 20:
//         _generalSettingsPage ??= PermissionGuard(
//           hasPermission: perm.canViewGeneralSettings,
//           child: BlocProvider(
//             create: (_) {
//               final cubit = GeneralSettingsCubit()..loadForCurrentUser();
//               cubit.onSettingsChanged = (updated) {
//                 if (_notificationCubitReady) {
//                   _notificationCubit.refreshSettings(updated);
//                 }
//               };
//               return cubit;
//             },
//             child: const GeneralSettings(),
//           ),
//         );
//         return _generalSettingsPage!;
//       case 21:
//         return PermissionGuard(
//           hasPermission: perm.canViewFacebookSettings,
//           child: FacebookSettings(),
//         );
//       case 22:
//         return PermissionGuard(
//           hasPermission: perm.canViewStaffReport,
//           child: BlocProvider(
//             create: (_) => StaffCubit()..fetchAll(),
//             child: StaffReports(),
//           ),
//         );
//       case 23:
//         return PermissionGuard(
//           hasPermission: perm.canViewTransferReport,
//           child: FutureBuilder(
//             future: SessionService().getSavedUser(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               final user = snapshot.data;
//               return BlocProvider(
//                 create: (_) => AddLeadCubit(),
//                 child: TransferLeadsReport(
//                   currentUserId: user?.id ?? '',
//                   currentUserRole: user?.staffType ?? '',
//                   currentUserName: user?.name ?? '',
//                 ),
//               );
//             },
//           ),
//         );
//       case 24:
//         return PermissionGuard(
//           hasPermission: perm.canViewScheduledReport,
//           child: ScheduledLeads(),
//         );
//       case 25:
//         return PermissionGuard(
//           hasPermission: perm.canViewRejectedReport,
//           child: BlocProvider(
//             create: (_) => AddLeadCubit(),
//             child: RejectedLeads(),
//           ),
//         );
//       case 26:
//         return OutGoingCallhistory();
//       case 27:
//         return BlocProvider(
//           create: (_) => DesignationCubit(),
//           child: DesignationPermissionsScreen(designation: widget.designation),
//         );
//       case 28:
//         return BlocProvider(
//           create: (_) =>
//               CallSettingsCubit(repository: CallSettingsRepository())..init(),
//           child: CloudCallSettingsScreen(),
//         );
//       case 29:
//         if (widget.staff == null) return const SizedBox();
//         return MultiBlocProvider(
//           providers: [
//             BlocProvider(create: (context) => StaffCubit()),
//             BlocProvider(create: (context) => AddLeadCubit()),
//             BlocProvider(
//               create: (context) => StaffActivityCubit(ActivityRepository()),
//             ),
//           ],
//           child: StaffProfileScreen(staff: widget.staff!),
//         );
//       case 30:
//         return TimeLine();
//       case 31:
//         return MultiBlocProvider(
//           providers: [
//             BlocProvider(
//               create: (_) => AddLeadCubit()
//                 ..initialize()
//                 ..fetchStaff(),
//             ),
//             BlocProvider(create: (context) => LeadCategoryCubit()),
//           ],
//           child: FOLLOWUPDetailsScreen(currentLead: widget.lead!),
//         );
//       case 32:
//         if (widget.staff == null) return const SizedBox();
//         return BlocProvider(
//           create: (_) => StaffCubit(),
//           child: ChangePasswordScreen(staff: widget.staff!),
//         );
//       case 33:
//         return BlocProvider(
//           create: (context) => StaffCubit(),
//           child: PersonalProfile(),
//         );
//       case 34:
//         return BlocProvider.value(
//           value: _notificationCubit,
//           child: NotificationScreen(),
//         );
//       default:
//         return const SizedBox();
//     }
//   }

//   Widget _buildExitDialogOverlay() {
//     if (!showExitAlert) return const SizedBox.shrink();
//     return Positioned.fill(
//       child: GestureDetector(
//         onTap: () => setState(() => showExitAlert = false),
//         child: Container(
//           color: Colors.black.withOpacity(0.5),
//           child: Center(
//             child: GestureDetector(
//               onTap: () {},
//               child: AlertDialog(
//                 backgroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 title: const Row(
//                   children: [
//                     Icon(Icons.exit_to_app, color: Colors.red, size: 24),
//                     SizedBox(width: 8),
//                     Text(
//                       'Exit Application',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 content: const Text(
//                   'Are you sure you want to exit from the app?',
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => setState(() => showExitAlert = false),
//                     child: const Text(
//                       'No',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onPressed: () => SystemNavigator.pop(),
//                     child: const Text(
//                       'Yes',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ── Back-press rules ────────────────────────────────────────────────────
//     //
//     // 1. Dashboard (index 0)
//     //    → block native pop; show exit alert instead.
//     //
//     // 2. Any screen with goToDashboardOnBack == true
//     //    (sidebar screens, LeadListing from dashboard card, FOLLOWUP, etc.)
//     //    → block native pop; manually pop to root (Dashboard).
//     //
//     // 3. Sub-screens that are genuine OS-level pushes on top of another route
//     //    (goToDashboardOnBack == false, index != 0)
//     //    → allow native pop (OS handles it, goes to the previous route).
//     //
//     final bool isDashboard = selectedIndex == 0;
//     final bool blockNativePop = isDashboard || widget.goToDashboardOnBack;
//     log(
//       "[MainScreen Build] selectedIndex: $selectedIndex, blockNativePop: $blockNativePop, canPop: ${!blockNativePop}, navigatorCanPop: ${Navigator.of(context).canPop()}",
//     );

//     return PopScope(
//       canPop: !blockNativePop,
//       onPopInvokedWithResult: (didPop, result) {
//         log("blockNativePop : $blockNativePop");
//         log("isDashboard : $isDashboard");
//         log("selectedIndex : $selectedIndex");
//         log("goToDashboardOnBack : ${widget.goToDashboardOnBack}");
//         log("showExitAlert : $showExitAlert");
//         log("didPop : $didPop");

//         // Native pop already handled by Flutter — nothing to do.
//         if (didPop) return;

//         if (isDashboard) {
//           // Toggle exit-alert on the dashboard.
//           setState(() => showExitAlert = !showExitAlert);
//         } else if (widget.goToDashboardOnBack) {
//           // Dismiss exit alert if it's open; otherwise go to dashboard.
//           if (showExitAlert) {
//             setState(() => showExitAlert = false);
//           } else {
//             _goToDashboard();
//           }
//         }
//       },
//       child: Stack(
//         children: [
//           Scaffold(
//             body: Row(
//               children: [
//                 /// SIDEBAR
//                 SizedBox(
//                   width: isSidebarOpen ? 250 : 70,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     child: isSidebarOpen
//                         ? SidebarItem(
//                             selectedIndex: selectedIndex,
//                             onItemSelected: _onItemSelected,
//                           )
//                         : MiniSidebar(
//                             selectedIndex: selectedIndex,
//                             onItemSelected: _onItemSelected,
//                           ),
//                   ),
//                 ),

//                 /// MAIN CONTENT
//                 Expanded(
//                   child: Column(
//                     children: [
//                       MultiBlocProvider(
//                         providers: [
//                           BlocProvider(
//                             create: (_) => AddLeadCubit()..fetchLeads(),
//                           ),
//                           BlocProvider.value(value: _notificationCubit),
//                         ],
//                         child: TopBar(
//                           isSidebarOpen: isSidebarOpen,
//                           onMenuTap: toggleSidebar,
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           color: AppColors.background,
//                           child: getPage(),
//                         ),
//                       ),
//                       BottomBar(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           _buildExitDialogOverlay(),
//         ],
//       ),
//     );
//   }
// }

///-------------------------------------------------------------------
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:Odit_CRM/core/shared_preference/session_service.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/follow_up/data/activity_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/data/add_lead_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/cubit/import_lead_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/data/import_lead_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/notification/cubit/notification_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/notification/data/notification_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/cubit/staff_activity_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/screen/staff_profile_screen.dart';
// import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/screen/time_line.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/call_settings.dart/cubit/call_settings_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/call_settings.dart/data/call_settings_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/call_settings.dart/screen/call_settings.dart';
// import 'package:Odit_CRM/core/theme/app_colors.dart';
// import 'package:Odit_CRM/feature/sub_company/dashboard/dashboard.dart';
// import 'package:Odit_CRM/feature/sub_company/dashboard/lead_list_screen.dart';
// import 'package:Odit_CRM/feature/sub_company/file_manager/view/screen/view.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/call_history/out_going_callHistory.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/delete_leads/screens/delete_leads.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/import_leads/screen/import_leads.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/unassingned_leads/screen/unassingned_lead.dart';
// import 'package:Odit_CRM/feature/sub_company/reports/rejected_leads_report/screen/rejected_leads.dart';
// import 'package:Odit_CRM/feature/sub_company/reports/scheduled_leads/screen/scheduled_leads.dart';
// import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/screen/staff_reports.dart';
// import 'package:Odit_CRM/feature/sub_company/reports/transfer_leads/screen/transfer_leads_report.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/custom_field_settings/cubit/custom_field_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/custom_field_settings/data/custom_field_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/custom_field_settings/screen/aditional_field.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/cubit/lead_category_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/data/lead_category_repository.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_category/screen/lead_category.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_source/cubit/lead_source_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_source/data/lead_source_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_source/lead_source_screen.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_stage/cubit/lead_stage_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_stage/screen/lead_stage.dart';
// import 'package:Odit_CRM/feature/sub_company/rightside_menu/unassigned_settings/lead_distribution_settings.dart';
// import 'package:Odit_CRM/feature/sub_company/settings/fb_settings/screen/facebook_settings.dart';
// import 'package:Odit_CRM/feature/sub_company/settings/general_settings/cubit/general_settings_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/settings/general_settings/data/general_settings_repo.dart';
// import 'package:Odit_CRM/feature/sub_company/settings/general_settings/screen/general_settings.dart';
// import 'package:Odit_CRM/feature/sub_company/notification/screen/notification.dart';
// import 'package:Odit_CRM/feature/sub_company/sidebar/widget/bottom_bar.dart';
// import 'package:Odit_CRM/feature/sub_company/sidebar/widget/mini_sidebar.dart';
// import 'package:Odit_CRM/feature/sub_company/sidebar/widget/profile.dart';
// import 'package:Odit_CRM/feature/sub_company/sidebar/widget/top_bar.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/add_lead/screen/add_lead.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/lead_report/lead_report.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/call_history/call_history.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/phone_call_log/phone_call_log.dart';
// import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/screen/transfer_leads/transfer_leads.dart';
// import 'package:Odit_CRM/feature/sub_company/sidebar/sidebar_item.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/cubit/cubit/permission_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/screen/permission_guard.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/model/staff_model.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/screen/add_staff/screen/add_staff.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/screen/deleted_staff/screen/delete_staff.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/cubit/designation_cubit.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/model/designation_model.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/screen/add_designation_screen.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/designation/screen/designation_screen.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/screen/view_staff/screen/psswrd.dart';
// import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/screen/view_staff/screen/view_staff.dart';

// import '../lead_managment/follow_up/screens/follow_up_details_screen.dart';

// class MainScreen extends StatefulWidget {
//   final int selectedIndex;
//   final DesignationModel? designation;
//   final StaffModel? staff;
//   final AddLeadModel? lead;
//   final String? fromCard;
//   final DateTime? selectedDate;
//   const MainScreen({
//     super.key,
//     this.selectedIndex = 0,
//     this.designation,
//     this.staff,
//     this.lead,
//     this.fromCard,
//     this.selectedDate,
//   });

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   late int selectedIndex;
//   bool isSidebarOpen = true;
//   AddLeadModel? _editLead;
//   StaffModel? _currentStaff;
//   bool showExitAlert = false;

//   late NotificationCubit _notificationCubit;
//   bool _notificationCubitReady = false;

//   @override
//   void initState() {
//     super.initState();
//     selectedIndex = widget.selectedIndex;
//     _editLead = widget.lead;
//     _currentStaff = widget.staff;
//     _notificationCubit = NotificationCubit(
//       NotificationRepo(),
//       GeneralSettingsRepository(staffId: ''),
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final user = await SessionService().getSavedUser();
//       if (!mounted) return;
//       final staffId = user?.id ?? '';

//       _notificationCubit = NotificationCubit(
//         NotificationRepo(),
//         GeneralSettingsRepository(staffId: staffId),
//       );
//       _notificationCubit.load(staffId);

//       setState(() => _notificationCubitReady = true);
//     });
//   }

//   @override
//   void dispose() {
//     if (_notificationCubitReady) _notificationCubit.close();
//     super.dispose();
//   }

//   void toggleSidebar() {
//     setState(() {
//       isSidebarOpen = !isSidebarOpen;
//     });
//   }

//   void _onItemSelected(int index) {
//     if (selectedIndex == index) return;
//     if (selectedIndex == 20 && index != 20) {
//       _generalSettingsPage = null; // ← clear when navigating away
//     }
//     if (index == 0) {
//       Navigator.of(context).popUntil((route) => route.isFirst);
//     } else {
//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) => MainScreen(selectedIndex: index),
//           ),
//         );
//       } else {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => MainScreen(selectedIndex: index),
//           ),
//         );
//       }
//     }
//   }

//   Widget? _generalSettingsPage;
//   bool _editCompleted = false;

//   Widget getPage() {
//     final perm = context.read<PermissionCubit>(); // ← read once

//     switch (selectedIndex) {
//       case 0:
//         return PermissionGuard(
//           hasPermission: perm.canViewDashboard,
//           child: BlocProvider(
//             create: (context) =>
//                 AddLeadCubit(), //..fetchDashboardCounts(DateTime.now()),
//             child: DashboardScreen(),
//           ),
//         );
//       // case 1:
//       //   return PermissionGuard(
//       //     hasPermission: perm.canAddLead,
//       //     child: MultiBlocProvider(
//       //       providers: [
//       //         BlocProvider(
//       //           create: (_) => AddLeadCubit(
//       //             leadRepository: AddLeadRepository(),
//       //             categoryRepository: LeadCategoryRepository(),
//       //             sourceRepository: LeadSourceRepository(),
//       //           ),
//       //         ),
//       //         BlocProvider(create: (_) => LeadCategoryCubit()),
//       //         BlocProvider(create: (_) => LeadSourceCubit()),
//       //         BlocProvider(create: (_) => LeadStageCubit()),
//       //       ],
//       //       child: AddLeadPage(lead: _editLead),
//       //     ),
//       //   );
//       case 1:
//         return PermissionGuard(
//           hasPermission: perm.canAddLead,
//           child: MultiBlocProvider(
//             providers: [
//               BlocProvider(
//                 create: (_) => AddLeadCubit(
//                   leadRepository: AddLeadRepository(),
//                   categoryRepository: LeadCategoryRepository(),
//                   sourceRepository: LeadSourceRepository(),
//                 ),
//               ),
//               BlocProvider(create: (_) => LeadCategoryCubit()),
//               BlocProvider(create: (_) => LeadSourceCubit()),
//               BlocProvider(create: (_) => LeadStageCubit()),
//             ],
//             // ✅ ADD THIS: listen for edit success and pop MainScreen with true
//             child: AddLeadPage(lead: _editLead),
//           ),
//         );
//       case 2:
//         return PermissionGuard(
//           hasPermission: perm.canViewLeadsReport,
//           child: BlocProvider(
//             create: (_) => AddLeadCubit()
//               ..fetchLeads()
//               ..initialize()
//               ..fetchStaff(),
//             child: LeadsReport(),
//           ),
//         );
//       case 3:
//         return PermissionGuard(
//           hasPermission: perm.canViewCallHistory,
//           child: CallHistoryPage(),
//         );
//       case 4:
//         return PermissionGuard(
//           hasPermission: perm.canViewDeletedLeads,
//           child: BlocProvider(
//             create: (_) => AddLeadCubit(
//               leadRepository: AddLeadRepository(),
//               categoryRepository: LeadCategoryRepository(),
//               sourceRepository: LeadSourceRepository(),
//             )..fetchDeletedLeads(),
//             child: DeleteLeads(),
//           ),
//         );
//       case 5:
//         return PermissionGuard(
//           hasPermission: perm.canTransferLeads || perm.canViewTransferLeads,
//           child: BlocProvider(
//             create: (_) =>
//                 AddLeadCubit(
//                     leadRepository: AddLeadRepository(),
//                     categoryRepository: LeadCategoryRepository(),
//                     sourceRepository: LeadSourceRepository(),
//                   )
//                   ..fetchLeads()
//                   ..fetchStaff(),
//             child: TransferLeads(),
//           ),
//         );
//       case 6:
//         return PermissionGuard(
//           hasPermission: perm.canViewPhoneCallLog,
//           child: PhoneCallLog(),
//         );
//       case 7:
//         return PermissionGuard(
//           hasPermission: perm.canViewLeadCategory,
//           child: BlocProvider(
//             create: (_) => LeadCategoryCubit()..watchCategories(),
//             child: LeadCategory(),
//           ),
//         );
//       case 8:
//         return PermissionGuard(
//           hasPermission: perm.canViewCustomFields,
//           child: BlocProvider(
//             create: (_) => AdditionalFieldsCubit(
//               repository: AdditionalFieldsRepositoryImpl(),
//             ),
//             child: AdditionalFieldsSection(),
//           ),
//         );
//       case 9:
//         return PermissionGuard(
//           hasPermission: perm.canViewLeadSource,
//           child: BlocProvider(
//             create: (_) => LeadSourceCubit()..watchSources(),
//             child: LeadSourceScreen(),
//           ),
//         );
//       case 10:
//         return PermissionGuard(
//           hasPermission: perm.canViewLeadStages,
//           child: BlocProvider(
//             create: (_) => LeadStageCubit(),
//             child: LeadStagesScreen(),
//           ),
//         );
//       case 11:
//         return LeadDistributionSettingsScreen();
//       case 12:
//         return BlocProvider(
//           create: (_) => AddLeadCubit()
//             ..initialize()
//             ..fetchStaff(),
//           // ..fetchDashboardLeads(
//           //   staffId: widget.staff!.id!,
//           //   role: widget.staff?.staffType ?? 'Admin',
//           //   fromCard: widget.fromCard ?? "",
//           //   selectedDate: context.read<AddLeadCubit>().state.selectedDashboardDate ?? DateTime.now(),
//           // ),
//           child: NewLeadsPage(
//             fromCard: widget.fromCard ?? "",
//             staff: widget.staff,
//             selectedDate: widget.selectedDate,
//           ),
//         );
//       case 13:
//         return PermissionGuard(
//           hasPermission: perm.canViewUnassignedLeads,
//           child: BlocProvider(
//             create: (_) => AddLeadCubit()..fetchLeads(),
//             child: UnassingnedLead(),
//           ),
//         );
//       case 14:
//         return PermissionGuard(
//           hasPermission: perm.canImportLeads,
//           child: MultiBlocProvider(
//             providers: [
//               BlocProvider(
//                 create: (_) =>
//                     ImportLeadsCubit(repository: ImportLeadsRepository()),
//               ),
//               BlocProvider(
//                 create: (_) => AddLeadCubit(
//                   leadRepository: AddLeadRepository(),
//                   categoryRepository: LeadCategoryRepository(),
//                   sourceRepository: LeadSourceRepository(),
//                 ),
//               ),
//               BlocProvider(create: (_) => LeadCategoryCubit()),
//               BlocProvider(create: (_) => LeadSourceCubit()),
//               BlocProvider(create: (_) => LeadStageCubit()),
//             ],
//             child: ImportLeads(),
//           ),
//         );
//       case 15:
//         return PermissionGuard(
//           hasPermission: perm.canAddStaff,
//           child: MultiBlocProvider(
//             providers: [
//               BlocProvider(create: (_) => StaffCubit()),
//               BlocProvider(create: (_) => DesignationCubit()..fetchAll()),
//             ],
//             // child: AddStaff(staff: widget.staff,),
//             child: AddStaff(
//               key: ValueKey(_currentStaff?.id ?? 'add_staff'),
//               staff: _currentStaff,
//             ),
//           ),
//         );
//       case 16:
//         return PermissionGuard(
//           hasPermission: perm.canViewStaff,
//           child: BlocProvider(
//             create: (_) => StaffCubit()..fetchAll(),
//             child: ViewStaff(),
//           ),
//         );
//       case 17:
//         return PermissionGuard(
//           hasPermission: perm.canViewDesignation,
//           child: BlocProvider(
//             create: (_) => DesignationCubit()..fetchAll(),
//             child: const DesignationScreen(),
//           ),
//         );
//       case 18:
//         return PermissionGuard(
//           hasPermission: perm.canViewDeletedStaff,
//           child: BlocProvider(
//             create: (_) => StaffCubit()..fetchDeletedStaff(),
//             child: DeletedStaffScreen(),
//           ),
//         );
//       case 19:
//         return PermissionGuard(
//           hasPermission: perm.canViewFileManager,
//           child: ViewPage(),
//         );
//       // case 20:
//       //   _generalSettingsPage ??= PermissionGuard(
//       //     hasPermission: perm.canViewGeneralSettings,
//       //     child: BlocProvider(
//       //       create: (_) => GeneralSettingsCubit()..loadForCurrentUser(),
//       //       child: const GeneralSettings(),
//       //     ),
//       //   );
//       //   return _generalSettingsPage!;
//       case 20:
//         _generalSettingsPage ??= PermissionGuard(
//           hasPermission: perm.canViewGeneralSettings,
//           child: BlocProvider(
//             create: (_) {
//               final cubit = GeneralSettingsCubit()..loadForCurrentUser();
//               // ← wire the callback so toggle updates NotificationCubit immediately
//               cubit.onSettingsChanged = (updated) {
//                 if (_notificationCubitReady) {
//                   _notificationCubit.refreshSettings(updated);
//                 }
//               };
//               return cubit;
//             },
//             child: const GeneralSettings(),
//           ),
//         );
//         return _generalSettingsPage!;
//       case 21:
//         return PermissionGuard(
//           hasPermission: perm.canViewFacebookSettings,
//           child: FacebookSettings(),
//         );
//       case 22:
//         return PermissionGuard(
//           hasPermission: perm.canViewStaffReport,
//           child: BlocProvider(
//             create: (_) => StaffCubit()..fetchAll(),
//             child: StaffReports(),
//           ),
//         );
//       // case 23:
//       //   return PermissionGuard(
//       //     hasPermission: perm.canViewTransferReport,
//       //     child: BlocProvider(
//       //       create: (_) => AddLeadCubit()..fetchLeads(),
//       //       child: TransferLeadsReport(),
//       //     ),
//       //   );
//       case 23:
//         return PermissionGuard(
//           hasPermission: perm.canViewTransferReport,
//           child: FutureBuilder(
//             future: SessionService().getSavedUser(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               final user = snapshot.data;
//               return BlocProvider(
//                 create: (_) => AddLeadCubit(),
//                 child: TransferLeadsReport(
//                   currentUserId: user?.id ?? '',
//                   currentUserRole: user?.staffType ?? '',
//                   currentUserName: user?.name ?? '',
//                 ),
//               );
//             },
//           ),
//         );
//       case 24:
//         return PermissionGuard(
//           hasPermission: perm.canViewScheduledReport,
//           child: ScheduledLeads(),
//         );
//       case 25:
//         return PermissionGuard(
//           hasPermission: perm.canViewRejectedReport,
//           child: BlocProvider(
//             create: (_) => AddLeadCubit(),
//             child: RejectedLeads(),
//           ),
//         );
//       case 26:
//         return OutGoingCallhistory();
//       case 27:
//         return BlocProvider(
//           create: (_) => DesignationCubit(),
//           child: DesignationPermissionsScreen(designation: widget.designation),
//         );
//       case 28:
//         return BlocProvider(
//           create: (_) =>
//               CallSettingsCubit(repository: CallSettingsRepository())..init(),
//           child: CloudCallSettingsScreen(),
//         );
//       case 29:
//         if (widget.staff == null) return const SizedBox();
//         return MultiBlocProvider(
//           providers: [
//             BlocProvider(create: (context) => StaffCubit()),
//             BlocProvider(create: (context) => AddLeadCubit()),
//             BlocProvider(
//               create: (context) => StaffActivityCubit(ActivityRepository()),
//             ),
//           ],
//           child: StaffProfileScreen(staff: widget.staff!),
//         );
//       case 30:
//         return TimeLine();
//       case 31:
//         return MultiBlocProvider(
//           providers: [
//             BlocProvider(
//               create: (_) => AddLeadCubit()
//                 // ..fetchDashboardLeads(staffId: '', role: '', fromCard: '', selectedDate: )
//                 ..initialize()
//                 ..fetchStaff(),
//             ),
//             BlocProvider(create: (context) => LeadCategoryCubit()),
//           ],
//           child: FOLLOWUPDetailsScreen(currentLead: widget.lead!),
//         );
//       case 32:
//         if (widget.staff == null) return const SizedBox();
//         return BlocProvider(
//           create: (_) => StaffCubit(),
//           child: ChangePasswordScreen(staff: widget.staff!),
//         );
//       case 33:
//         return BlocProvider(
//           create: (context) => StaffCubit(),
//           child: PersonalProfile(),
//         );
//       case 34:
//         return BlocProvider.value(
//           value: _notificationCubit,
//           child: NotificationScreen(),
//         );
//       default:
//         return const SizedBox();
//     }
//   }

//   Widget _buildExitDialogOverlay() {
//     if (!showExitAlert) return const SizedBox.shrink();
//     return Positioned.fill(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             showExitAlert = false;
//           });
//         },
//         child: Container(
//           color: Colors.black.withOpacity(0.5),
//           child: Center(
//             child: GestureDetector(
//               onTap: () {}, // Prevent taps inside dialog from closing it
//               child: AlertDialog(
//                 backgroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 title: const Row(
//                   children: [
//                     Icon(Icons.exit_to_app, color: Colors.red, size: 24),
//                     SizedBox(width: 8),
//                     Text(
//                       'Exit Application',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 content: const Text(
//                   'Are you sure you want to exit from the app?',
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => setState(() => showExitAlert = false),
//                     child: const Text(
//                       'No',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onPressed: () {
//                       SystemNavigator.pop();
//                     },
//                     child: const Text(
//                       'Yes',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: !showExitAlert && Navigator.of(context).canPop(),
//       onPopInvokedWithResult: (didPop, result) {
//         log("selectedIndex : $selectedIndex");
//         log("showExitAlert : $showExitAlert");
//         log("didpop : $didPop");
//         log("canPop : ${Navigator.of(context).canPop()}");
//         if (didPop) return;
//         if (showExitAlert) {
//           setState(() {
//             showExitAlert = false;
//             didPop = true;
//           });
//         } else {
//           setState(() {
//             showExitAlert = true;
//             didPop = false;
//           });
//         }
//       },
//       child: Stack(
//         children: [
//           Scaffold(
//             body: Row(
//               children: [
//                 /// SIDEBAR
//                 SizedBox(
//                   width: isSidebarOpen ? 250 : 70,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     child: isSidebarOpen
//                         ? SidebarItem(
//                             selectedIndex: selectedIndex,
//                             onItemSelected: _onItemSelected,
//                           )
//                         : MiniSidebar(
//                             selectedIndex: selectedIndex,
//                             onItemSelected: _onItemSelected,
//                           ),
//                   ),
//                 ),

//                 /// MAIN CONTENT
//                 Expanded(
//                   child: Column(
//                     children: [
//                       MultiBlocProvider(
//                         providers: [
//                           BlocProvider(
//                             create: (_) => AddLeadCubit()..fetchLeads(),
//                           ),

//                           BlocProvider.value(value: _notificationCubit),
//                         ],
//                         child: TopBar(
//                           isSidebarOpen: isSidebarOpen,
//                           onMenuTap: toggleSidebar,
//                         ),
//                       ),

//                       Expanded(
//                         child: Container(
//                           color: AppColors.background,
//                           child: getPage(),
//                         ),
//                       ),

//                       BottomBar(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           _buildExitDialogOverlay(),
//         ],
//       ),
//     );
//   }
// }
