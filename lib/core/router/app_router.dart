// lib/core/router/app_router.dart

import 'package:Odit_CRM/feature/sub_company/lead_managment/follow_up/screens/follow_up_details_new.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_stage/cubit/lead_tag_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/rightside_menu/lead_stage/screen/lead_tag.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../feature/sub_company/notification/data/notification_repo.dart';
import '../../feature/sub_company/settings/general_settings/data/general_settings_repo.dart';
import 'route_paths.dart';
import 'router_refresh_notifier.dart';
import 'crm_shell.dart';

// Standalone Auth Screens
import '../../feature/auth/cubit/auth/auth_cubit.dart';
import '../../feature/auth/screen/login.dart';
import '../../feature/auth/screen/forget_psswrd.dart';

// Mother Company Screens
import '../../feature/mother_company/MotherCompanyMainScreen.dart';
import '../../feature/mother_company/shared/enum/mother_company_enum.dart';

// CRM Sub-Company Screens
import '../../feature/sub_company/dashboard/dashboard.dart';
import '../../feature/sub_company/lead_managment/leads/screen/add_lead/screen/add_lead.dart';
import '../../feature/sub_company/lead_managment/leads/screen/lead_report/lead_report.dart';
import '../../feature/sub_company/lead_managment/call_history/call_history.dart';
import '../../feature/sub_company/lead_managment/leads/screen/delete_leads/screens/delete_leads.dart';
import '../../feature/sub_company/lead_managment/leads/screen/transfer_leads/transfer_leads.dart';
import '../../feature/sub_company/lead_managment/phone_call_log/phone_call_log.dart';
import '../../feature/sub_company/rightside_menu/lead_category/screen/lead_category.dart';
import '../../feature/sub_company/rightside_menu/lead_category/screen/sub_category.dart';
import '../../feature/sub_company/rightside_menu/lead_category/cubit/sub_category_cubit.dart';
import '../../feature/sub_company/rightside_menu/custom_field_settings/screen/aditional_field.dart';
import '../../feature/sub_company/rightside_menu/lead_source/lead_source_screen.dart';
import '../../feature/sub_company/rightside_menu/lead_stage/screen/lead_stage.dart';
import '../../feature/sub_company/rightside_menu/unassigned_settings/lead_distribution_settings.dart';
import '../../feature/sub_company/dashboard/lead_list_screen.dart';
import '../../feature/sub_company/lead_managment/leads/screen/unassingned_leads/screen/unassingned_lead.dart';
import '../../feature/sub_company/lead_managment/import_leads/screen/import_leads.dart';
import '../../feature/sub_company/staff_managment/staff/screen/add_staff/screen/add_staff.dart';
import '../../feature/sub_company/staff_managment/staff/screen/view_staff/screen/view_staff.dart';
import '../../feature/sub_company/staff_managment/designation/screen/designation_screen.dart';
import '../../feature/sub_company/staff_managment/staff/screen/deleted_staff/screen/delete_staff.dart';
import '../../feature/sub_company/file_manager/view/screen/view.dart';
import '../../feature/sub_company/settings/general_settings/screen/general_settings.dart';
import '../../feature/sub_company/settings/fb_settings/screen/facebook_settings.dart';
import '../../feature/sub_company/reports/staff_reports/screen/staff_reports.dart';
import '../../feature/sub_company/reports/transfer_leads/screen/transfer_leads_report.dart';
import '../../feature/sub_company/reports/scheduled_leads/screen/scheduled_leads.dart';
import '../../feature/sub_company/reports/rejected_leads_report/screen/rejected_leads.dart';
import '../../feature/sub_company/lead_managment/call_history/out_going_callHistory.dart';
import '../../feature/sub_company/staff_managment/designation/screen/add_designation_screen.dart';
import '../../feature/sub_company/rightside_menu/call_settings.dart/screen/call_settings.dart';
import '../../feature/sub_company/reports/staff_reports/screen/staff_profile_screen.dart';
import '../../feature/sub_company/reports/staff_reports/screen/time_line.dart';
import '../../feature/sub_company/lead_managment/follow_up/screens/follow_up_details_screen.dart';
import '../../feature/sub_company/staff_managment/staff/screen/view_staff/screen/psswrd.dart';
import '../../feature/sub_company/sidebar/widget/profile.dart';
import '../../feature/sub_company/notification/screen/notification.dart';

// Cubits and Repositories
import '../../feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import '../../feature/sub_company/lead_managment/leads/data/add_lead_repo.dart';
import '../../feature/sub_company/lead_managment/leads/model/add_lead_model.dart';
import '../../feature/sub_company/rightside_menu/lead_category/cubit/lead_category_cubit.dart';
import '../../feature/sub_company/rightside_menu/lead_category/data/lead_category_repository.dart';
import '../../feature/sub_company/rightside_menu/lead_source/cubit/lead_source_cubit.dart';
import '../../feature/sub_company/rightside_menu/lead_source/data/lead_source_repo.dart';
import '../../feature/sub_company/rightside_menu/lead_stage/cubit/lead_stage_cubit.dart';
import '../../feature/sub_company/rightside_menu/custom_field_settings/cubit/custom_field_cubit.dart';
import '../../feature/sub_company/rightside_menu/custom_field_settings/data/custom_field_repo.dart';
import '../../feature/sub_company/lead_managment/import_leads/cubit/import_lead_cubit.dart';
import '../../feature/sub_company/lead_managment/import_leads/data/import_lead_repo.dart';
import '../../feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import '../../feature/sub_company/staff_managment/staff/data/add_staff_repo.dart';
import '../../feature/sub_company/staff_managment/staff/model/staff_model.dart';
import '../../feature/sub_company/staff_managment/designation/cubit/designation_cubit.dart';
import '../../feature/sub_company/staff_managment/designation/data/designation_repository.dart';
import '../../feature/sub_company/staff_managment/designation/model/designation_model.dart';
import '../../feature/sub_company/settings/general_settings/cubit/general_settings_cubit.dart';
import '../../feature/sub_company/rightside_menu/call_settings.dart/cubit/call_settings_cubit.dart';
import '../../feature/sub_company/rightside_menu/call_settings.dart/data/call_settings_repo.dart';
import '../../feature/sub_company/reports/staff_reports/cubit/staff_activity_cubit.dart';
import '../../feature/sub_company/lead_managment/follow_up/data/activity_repo.dart';
import '../../feature/sub_company/staff_managment/designation/screen/permission_guard.dart';
import '../../feature/sub_company/staff_managment/designation/cubit/permition_cubit/permission_cubit.dart';
import '../../feature/sub_company/notification/cubit/notification_cubit.dart';
import '../shared_preference/session_service.dart';

class AppRouter {
  static GoRouter createRouter(
    AuthCubit authCubit, {
    List<NavigatorObserver>? observers,
  }) {
    final refreshNotifier = RouterRefreshNotifier(authCubit);

    return GoRouter(
      initialLocation: RoutePaths.dashboard,
      refreshListenable: refreshNotifier,
      observers: observers,
      redirect: (context, state) {
        final authState = authCubit.state;
        final isLoggingIn = state.uri.path == RoutePaths.login;
        final isForgotPassword = state.uri.path == RoutePaths.forgotPassword;

        // Transient states: never redirect. AuthLoading and AuthError carry
        // no navigation intent — the router has nothing meaningful to act on.
        // Importantly, AuthError must be a no-op here: if we let it fall
        // through to the !isAuthenticated branch below (AuthError is not
        // Authenticated), GoRouter would redirect back to /login even when
        // already there, creating a second LoginScreen instance on top of the
        // existing one before its BlocConsumer is disposed — which is exactly
        // what causes the double-SnackBar on every login cycle after the first.
        if (authState is AuthInitial ||
            authState is AuthLoading ||
            authState is AuthError) {
          return null;
        }

        final isAuthenticated = authState is Authenticated;

        if (!isAuthenticated) {
          // Already on the login page — no redirect needed. Without this guard,
          // a double evaluation of the redirect callback during the GoRouter
          // page-transition animation (logout → /login) can push a *second*
          // /login route entry, leaving two LoginScreen instances alive with
          // two active BlocConsumer subscriptions on the same AuthCubit.
          if (isForgotPassword || isLoggingIn) return null;
          return RoutePaths.login;
        }

        // Authenticated user trying to access login or forgot password
        if (isLoggingIn || isForgotPassword) {
          if (authState.user.companyType == 'mother_company') {
            return RoutePaths.motherCompanyDashboard;
          } else {
            return RoutePaths.dashboard;
          }
        }

        // Catch root path and redirect
        if (state.uri.path == '/') {
          if (authState.user.companyType == 'mother_company') {
            return RoutePaths.motherCompanyDashboard;
          } else {
            return RoutePaths.dashboard;
          }
        }

        return null;
      },
      errorBuilder: (context, state) => RoutingErrorScreen(
        errorMessage: state.error?.toString() ?? 'Page not found',
      ),
      routes: [
        // Standalone Auth Routes
        GoRoute(
          path: RoutePaths.login,
          // builder: (context, state) => const LoginScreen(),
          pageBuilder: (context, state) => const MaterialPage(
            key: ValueKey(
              'login-page',
            ), // stable across every redirect resolution
            child: LoginScreen(),
          ),
        ),
        GoRoute(
          path: RoutePaths.forgotPassword,
          // builder: (context, state) => const ForgotPasswordScreen(),
          pageBuilder: (context, state) => const MaterialPage(
            key: ValueKey('forgot-password-page'),
            child: ForgotPasswordScreen(),
          ),
        ),

        // Mother Company Routes (Non-CRM Shell)
        GoRoute(
          path: RoutePaths.motherCompanyDashboard,
          builder: (context, state) => const MotherCompanyMainScreen(
            initialPage: MotherCompanyPage.dashboard,
          ),
        ),
        GoRoute(
          path: RoutePaths.motherCompanyCompanyManage,
          builder: (context, state) => const MotherCompanyMainScreen(
            initialPage: MotherCompanyPage.companyManage,
          ),
        ),
        GoRoute(
          path: RoutePaths.motherCompanyAddCompany,
          builder: (context, state) => const MotherCompanyMainScreen(
            initialPage: MotherCompanyPage.addCompany,
          ),
        ),

        // Sub Company CRM Routes wrapped in CrmShell
        ShellRoute(
          builder: (context, state, child) => CrmShell(child: child),
          routes: [
            GoRoute(
              path: RoutePaths.dashboard,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewDashboard,
                  child: BlocProvider(
                    create: (_) => AddLeadCubit(),
                    child: DashboardScreen(),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.addLead,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
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
                    child: const AddLeadPage(lead: null),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.editLead,
              builder: (context, state) {
                final leadId = state.pathParameters['leadId'] ?? '';
                return EditLeadWrapper(leadId: leadId);
              },
            ),
            GoRoute(
              path: RoutePaths.leadsReport,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
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
              },
            ),
            GoRoute(
              path: RoutePaths.callHistory,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewCallHistory,
                  child: CallHistoryPage(),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.deletedLeads,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
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
              },
            ),
            GoRoute(
              path: RoutePaths.transferLeads,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission:
                      perm.canTransferLeads || perm.canViewTransferLeads,
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
              },
            ),
            GoRoute(
              path: RoutePaths.phoneCallLog,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewPhoneCallLog,
                  child: PhoneCallLog(),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.leadCategory,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewLeadCategory,
                  child: BlocProvider(
                    create: (_) => LeadCategoryCubit()..watchCategories(),
                    child: LeadCategory(),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.subCategory,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                final categoryName =
                    state.uri.queryParameters['categoryName'] ?? '';
                final categoryId =
                    state.uri.queryParameters['categoryId'] ?? '';
                return PermissionGuard(
                  hasPermission: perm.canViewLeadCategory,
                  child: BlocProvider(
                    create: (_) =>
                        SubCategoryCubit(categoryId: categoryId)
                          ..watchSubCategories(),
                    child: LeaSubCategoryScreen(
                      categoryName: categoryName,
                      categoryId: categoryId,
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.leadTag,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                final leadStageName =
                    state.uri.queryParameters['leadStageName'] ?? '';
                final leadStageId =
                    state.uri.queryParameters['leadStageId'] ?? '';
                final leadTagMandatory =
                    state.uri.queryParameters['tagMandatory'] == 'true';
                return PermissionGuard(
                  hasPermission: perm.canViewLeadStages,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) =>
                            LeadTagCubit(leadStageId: leadStageId)
                              ..watchLeadTags(),
                      ),
                      BlocProvider(create: (_) => LeadStageCubit()),
                    ],
                    child: LeaTagScreen(
                      leadStageName: leadStageName,
                      leadStageId: leadStageId,
                      tagMandatory: leadTagMandatory,
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.customFields,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewCustomFields,
                  child: BlocProvider(
                    create: (_) => AdditionalFieldsCubit(
                      repository: AdditionalFieldsRepositoryImpl(),
                    ),
                    child: AdditionalFieldsSection(),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.leadSource,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewLeadSource,
                  child: BlocProvider(
                    create: (_) => LeadSourceCubit()..watchSources(),
                    child: LeadSourceScreen(),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.leadStages,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewLeadStages,
                  child: BlocProvider(
                    create: (_) => LeadStageCubit(),
                    child: LeadStagesScreen(),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.leadDistribution,
              builder: (context, state) => LeadDistributionSettingsScreen(),
            ),
            GoRoute(
              path: RoutePaths.newLeads,
              builder: (context, state) {
                final fromCard = state.uri.queryParameters['fromCard'];
                final selectedDateStr =
                    state.uri.queryParameters['selectedDate'];
                final staffId = state.uri.queryParameters['staffId'];

                DateTime? selectedDate;
                if (selectedDateStr != null) {
                  selectedDate = DateTime.tryParse(selectedDateStr);
                }

                return NewLeadsWrapper(
                  fromCard: fromCard,
                  selectedDate: selectedDate,
                  staffId: staffId,
                );
              },
            ),
            GoRoute(
              path: RoutePaths.unassignedLeads,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewUnassignedLeads,
                  child: BlocProvider(
                    create: (_) => AddLeadCubit()..fetchLeads(),
                    child: UnassingnedLead(),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.importLeads,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canImportLeads,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => ImportLeadsCubit(
                          repository: ImportLeadsRepository(),
                        ),
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
              },
            ),
            GoRoute(
              path: RoutePaths.addStaff,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canAddStaff,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (_) => StaffCubit()),
                      BlocProvider(
                        create: (_) => DesignationCubit()..fetchAll(),
                      ),
                    ],
                    child: const AddStaff(
                      key: ValueKey('add_staff'),
                      staff: null,
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.editStaff,
              builder: (context, state) {
                final staffId = state.pathParameters['staffId'] ?? '';
                return EditStaffWrapper(staffId: staffId);
              },
            ),
            GoRoute(
              path: RoutePaths.viewStaff,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewStaff,
                  child: BlocProvider(
                    create: (_) => StaffCubit()..fetchAll(),
                    child: ViewStaff(),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.designation,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewDesignation,
                  child: BlocProvider(
                    create: (_) => DesignationCubit()..fetchAll(),
                    child: const DesignationScreen(),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.deletedStaff,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewDeletedStaff,
                  child: BlocProvider(
                    create: (_) => StaffCubit()..fetchDeletedStaff(),
                    child: DeletedStaffScreen(),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.fileManager,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewFileManager,
                  child: ViewPage(),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.generalSettings,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewGeneralSettings,
                  child: BlocProvider(
                    create: (blocContext) {
                      final cubit = GeneralSettingsCubit()
                        ..loadForCurrentUser();
                      cubit.onSettingsChanged = (updated) {
                        try {
                          blocContext.read<NotificationCubit>().refreshSettings(
                            updated,
                          );
                        } catch (_) {}
                      };
                      return cubit;
                    },
                    child: const GeneralSettings(),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.facebookSettings,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewFacebookSettings,
                  child: FacebookSettings(),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.staffReports,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewStaffReport,
                  child: BlocProvider(
                    create: (_) => StaffCubit()..fetchAll(),
                    child: StaffReports(),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.transferReport,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
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
              },
            ),
            GoRoute(
              path: RoutePaths.scheduledReport,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewScheduledReport,
                  child: ScheduledLeads(),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.rejectedReport,
              builder: (context, state) {
                final perm = context.watch<PermissionCubit>();
                return PermissionGuard(
                  hasPermission: perm.canViewRejectedReport,
                  child: BlocProvider(
                    create: (_) => AddLeadCubit(),
                    child: RejectedLeads(),
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.outgoingCallHistory,
              builder: (context, state) => OutGoingCallhistory(),
            ),
            GoRoute(
              path: RoutePaths.designationPermissions,
              builder: (context, state) {
                final designationId =
                    state.pathParameters['designationId'] ?? '';
                return DesignationPermissionsWrapper(
                  designationId: designationId,
                );
              },
            ),
            GoRoute(
              path: RoutePaths.cloudCallSettings,
              builder: (context, state) => BlocProvider(
                create: (_) =>
                    CallSettingsCubit(repository: CallSettingsRepository())
                      ..init(),
                child: CloudCallSettingsScreen(),
              ),
            ),
            GoRoute(
              path: RoutePaths.staffProfile,
              builder: (context, state) {
                final staffId = state.pathParameters['staffId'] ?? '';
                return StaffProfileWrapper(staffId: staffId);
              },
            ),
            GoRoute(
              path: RoutePaths.timeline,
              builder: (context, state) => TimeLine(),
            ),
            GoRoute(
              path: RoutePaths.followUp,
              builder: (context, state) {
                final leadId = state.pathParameters['leadId'] ?? '';
                final fromCard = state.uri.queryParameters['fromCard'];
                return FollowUpWrapper(leadId: leadId, fromCard: fromCard);
              },
            ),
            GoRoute(
              path: RoutePaths.changePassword,
              builder: (context, state) {
                final staffId = state.pathParameters['staffId'] ?? '';
                return ChangePasswordWrapper(staffId: staffId);
              },
            ),
            GoRoute(
              path: RoutePaths.personalProfile,
              builder: (context, state) => BlocProvider(
                create: (_) => StaffCubit(),
                child: PersonalProfile(),
              ),
            ),
            // GoRoute(
            //   path: RoutePaths.notifications,
            //   builder: (context, state) {
            //     return BlocProvider.value(
            //       value: context.read<NotificationCubit>(),
            //       child: NotificationScreen(),
            //     );
            //   },
            // ),
            GoRoute(
              path: RoutePaths.notifications,
              builder: (context, state) => const NotificationScreen(),
              // builder: (context, state) => BlocProvider(
              //   create: (_) => NotificationCubit(
              //     NotificationRepo(),
              //     GeneralSettingsRepository(
              //       staffId: state.pathParameters['staffId'] ?? '',
              //     ),
              //   ),
              //   child: NotificationScreen(),
              // ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── STAGE B/C: COMPATIBILITY ROUTE WRAPPERS FOR NESTED ROUTING ──────────────

class FollowUpWrapper extends StatefulWidget {
  final String leadId;
  final String? fromCard;

  const FollowUpWrapper({super.key, required this.leadId, this.fromCard});

  @override
  State<FollowUpWrapper> createState() => _FollowUpWrapperState();
}

class _FollowUpWrapperState extends State<FollowUpWrapper> {
  AddLeadModel? _lead;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLead();
  }

  Future<void> _loadLead() async {
    try {
      final lead = await AddLeadRepository().getLeadById(widget.leadId);
      if (mounted) {
        setState(() {
          _lead = lead;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _lead == null) {
      return Scaffold(
        body: Center(
          child: Text('Failed to load lead: ${_error ?? "Lead not found"}'),
        ),
      );
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AddLeadCubit()
            ..initialize()
            ..fetchStaff(),
        ),
        BlocProvider(create: (_) => LeadCategoryCubit()),
      ],
      // child: FollowUpDetailsScreen(
      //   currentLead: _lead!,
      //   fromCard: widget.fromCard,
      // ),
      child: FollowUpDetailsNewScreen(
        currentLead: _lead!,
        fromCard: widget.fromCard,
      ),
    );
  }
}

class EditLeadWrapper extends StatefulWidget {
  final String leadId;
  const EditLeadWrapper({super.key, required this.leadId});

  @override
  State<EditLeadWrapper> createState() => _EditLeadWrapperState();
}

class _EditLeadWrapperState extends State<EditLeadWrapper> {
  AddLeadModel? _lead;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLead();
  }

  Future<void> _loadLead() async {
    try {
      final lead = await AddLeadRepository().getLeadById(widget.leadId);
      if (mounted) {
        setState(() {
          _lead = lead;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _lead == null) {
      return Scaffold(
        body: Center(
          child: Text('Failed to load lead: ${_error ?? "Lead not found"}'),
        ),
      );
    }
    final perm = context.watch<PermissionCubit>();
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
        child: AddLeadPage(lead: _lead),
      ),
    );
  }
}

class StaffProfileWrapper extends StatefulWidget {
  final String staffId;
  const StaffProfileWrapper({super.key, required this.staffId});

  @override
  State<StaffProfileWrapper> createState() => _StaffProfileWrapperState();
}

class _StaffProfileWrapperState extends State<StaffProfileWrapper> {
  StaffModel? _staff;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    try {
      final staff = await StaffRepository().getStaff(widget.staffId);
      if (mounted) {
        setState(() {
          _staff = staff;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _staff == null) {
      return Scaffold(
        body: Center(
          child: Text('Failed to load staff: ${_error ?? "Staff not found"}'),
        ),
      );
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => StaffCubit()),
        BlocProvider(create: (_) => AddLeadCubit()),
        BlocProvider(create: (_) => StaffActivityCubit(ActivityRepository())),
      ],
      child: StaffProfileScreen(staff: _staff!),
    );
  }
}

class EditStaffWrapper extends StatefulWidget {
  final String staffId;
  const EditStaffWrapper({super.key, required this.staffId});

  @override
  State<EditStaffWrapper> createState() => _EditStaffWrapperState();
}

class _EditStaffWrapperState extends State<EditStaffWrapper> {
  StaffModel? _staff;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    try {
      final staff = await StaffRepository().getStaff(widget.staffId);
      if (mounted) {
        setState(() {
          _staff = staff;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _staff == null) {
      return Scaffold(
        body: Center(
          child: Text('Failed to load staff: ${_error ?? "Staff not found"}'),
        ),
      );
    }
    final perm = context.watch<PermissionCubit>();
    return PermissionGuard(
      hasPermission: perm.canAddStaff,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => StaffCubit()),
          BlocProvider(create: (_) => DesignationCubit()..fetchAll()),
        ],
        child: AddStaff(
          key: ValueKey(_staff?.id ?? 'edit_staff'),
          staff: _staff,
        ),
      ),
    );
  }
}

class ChangePasswordWrapper extends StatefulWidget {
  final String staffId;
  const ChangePasswordWrapper({super.key, required this.staffId});

  @override
  State<ChangePasswordWrapper> createState() => _ChangePasswordWrapperState();
}

class _ChangePasswordWrapperState extends State<ChangePasswordWrapper> {
  StaffModel? _staff;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    try {
      final staff = await StaffRepository().getStaff(widget.staffId);
      if (mounted) {
        setState(() {
          _staff = staff;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _staff == null) {
      return Scaffold(
        body: Center(
          child: Text('Failed to load staff: ${_error ?? "Staff not found"}'),
        ),
      );
    }
    return BlocProvider(
      create: (_) => StaffCubit(),
      child: ChangePasswordScreen(staff: _staff!),
    );
  }
}

class DesignationPermissionsWrapper extends StatefulWidget {
  final String designationId;
  const DesignationPermissionsWrapper({super.key, required this.designationId});

  @override
  State<DesignationPermissionsWrapper> createState() =>
      _DesignationPermissionsWrapperState();
}

class _DesignationPermissionsWrapperState
    extends State<DesignationPermissionsWrapper> {
  DesignationModel? _designation;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDesignation();
  }

  Future<void> _loadDesignation() async {
    if (widget.designationId == 'new') {
      if (mounted) {
        setState(() {
          _designation = null;
          _loading = false;
        });
      }
      return;
    }
    try {
      final designation = await DesignationRepository().getDesignation(
        widget.designationId,
      );
      if (mounted) {
        setState(() {
          _designation = designation;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (widget.designationId != 'new' &&
        (_error != null || _designation == null)) {
      return Scaffold(
        body: Center(
          child: Text(
            'Failed to load designation: ${_error ?? "Designation not found"}',
          ),
        ),
      );
    }
    return BlocProvider(
      create: (_) => DesignationCubit(),
      child: DesignationPermissionsScreen(designation: _designation),
    );
  }
}

class NewLeadsWrapper extends StatefulWidget {
  final String? fromCard;
  final DateTime? selectedDate;
  final String? staffId;

  const NewLeadsWrapper({
    super.key,
    this.fromCard,
    this.selectedDate,
    this.staffId,
  });

  @override
  State<NewLeadsWrapper> createState() => _NewLeadsWrapperState();
}

class _NewLeadsWrapperState extends State<NewLeadsWrapper> {
  StaffModel? _staff;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final authState = context.read<AuthCubit>().state;
    StaffModel? defaultStaff;
    if (authState is Authenticated) {
      defaultStaff = authState.user;
    }

    if (widget.staffId != null && widget.staffId!.isNotEmpty) {
      if (defaultStaff != null && defaultStaff.id == widget.staffId) {
        setState(() {
          _staff = defaultStaff;
        });
        return;
      }
      setState(() {
        _loading = true;
      });
      try {
        final staff = await StaffRepository().getStaff(widget.staffId!);
        if (mounted) {
          setState(() {
            _staff = staff;
            _loading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _staff = defaultStaff;
            _loading = false;
          });
        }
      }
    } else {
      setState(() {
        _staff = defaultStaff;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return BlocProvider(
      create: (_) => AddLeadCubit()
        ..initialize()
        ..fetchStaff(),
      child: NewLeadsPage(
        fromCard: widget.fromCard ?? "",
        staff: _staff,
        selectedDate: widget.selectedDate,
      ),
    );
  }
}

// ─── ERROR SCREEN ────────────────────────────────────────────────────────────

class RoutingErrorScreen extends StatelessWidget {
  final String errorMessage;
  const RoutingErrorScreen({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'Routing Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(RoutePaths.dashboard),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002660),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
