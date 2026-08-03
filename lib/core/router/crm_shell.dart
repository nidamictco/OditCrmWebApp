// lib/core/router/crm_shell.dart

import 'dart:developer';

import 'package:Odit_CRM/feature/sub_company/staff_managment/staff/cubit/add_staff_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import 'route_paths.dart';

// Sidebar components
import '../../feature/sub_company/sidebar/sidebar_item.dart';
import '../../feature/sub_company/sidebar/widget/mini_sidebar.dart';
import '../../feature/sub_company/sidebar/widget/top_bar.dart';

// Cubits and resources
import '../../feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import '../../feature/sub_company/notification/cubit/notification_cubit.dart';
import '../../feature/sub_company/notification/data/notification_repo.dart';
import '../shared_preference/session_service.dart';
import '../../feature/sub_company/settings/general_settings/data/general_settings_repo.dart';

class CrmShell extends StatefulWidget {
  final Widget child;
  const CrmShell({super.key, required this.child});

  @override
  State<CrmShell> createState() => _CrmShellState();
}

class _CrmShellState extends State<CrmShell> {
  bool isSidebarOpen = true;
  bool showExitAlert = false;

  late NotificationCubit _notificationCubit;
  bool _notificationCubitReady = false;

   late final StaffCubit _staffCubit;

  @override
  void initState() {
    super.initState();
     _staffCubit = StaffCubit();
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
      _staffCubit.close();  
    if (_notificationCubitReady) {
      _notificationCubit.close();
    }
    super.dispose();
  }

  void toggleSidebar() => setState(() => isSidebarOpen = !isSidebarOpen);

  int _getSelectedIndex(String path) {
    if (path == RoutePaths.dashboard) return 0;
    if (path == RoutePaths.addLead) return 1;
    if (path.startsWith('/leads/edit/')) return 1;
    if (path == RoutePaths.leadsReport) return 2;
    if (path == RoutePaths.callHistory) return 3;
    if (path == RoutePaths.deletedLeads) return 4;
    if (path == RoutePaths.transferLeads) return 5;
    if (path == RoutePaths.phoneCallLog) return 6;
    if (path == RoutePaths.leadCategory) return 7;
    if (path == RoutePaths.customFields) return 8;
    if (path == RoutePaths.leadSource) return 9;
    if (path == RoutePaths.leadStages) return 10;
    if (path == RoutePaths.leadDistribution) return 11;
    if (path == RoutePaths.newLeads) return 12;
    if (path == RoutePaths.unassignedLeads) return 13;
    if (path == RoutePaths.importLeads) return 14;
    if (path == RoutePaths.addStaff) return 15;
    if (path.startsWith('/staff/edit/')) return 15;
    if (path == RoutePaths.viewStaff) return 16;
    if (path == RoutePaths.designation) return 17;
    if (path == RoutePaths.deletedStaff) return 18;
    if (path == RoutePaths.fileManager) return 19;
    if (path == RoutePaths.generalSettings) return 20;
    if (path == RoutePaths.facebookSettings) return 21;
    if (path == RoutePaths.staffReports) return 22;
    if (path == RoutePaths.transferReport) return 23;
    if (path == RoutePaths.scheduledReport) return 24;
    if (path == RoutePaths.rejectedReport) return 25;
    if (path == RoutePaths.outgoingCallHistory) return 26;
    if (path.startsWith('/designations/') && path.endsWith('/permissions'))
      return 27;
    if (path == RoutePaths.cloudCallSettings) return 28;
    if (path.startsWith('/staff/') && path.endsWith('/change_password'))
      return 32;
    if (path.startsWith('/staff/')) return 29;
    if (path == RoutePaths.timeline) return 30;
    if (path.startsWith('/follow_up/')) return 31;
    if (path == RoutePaths.personalProfile) return 33;
    if (path == RoutePaths.notifications) return 34;

    return 0;
  }

  void _onItemSelected(BuildContext context, int index) {
    final path = RoutePaths.sidebarPaths[index];
    if (path != null) {
      context.go(path);
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
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _getSelectedIndex(location);
    final bool isDashboard = selectedIndex == 0;

    // Block native OS back pop on Dashboard to show the exit dialog (non-web)
    final bool blockNativePop = kIsWeb ? false : isDashboard;

    final screenWidth = MediaQuery.of(context).size.width;
    log("screen width is ............. $screenWidth");
    final screenHeight = MediaQuery.of(context).size.height;
    final double minLayoutWidth = 1000;
    final double contentWidth = screenWidth < minLayoutWidth
        ? minLayoutWidth
        : screenWidth;

    final mainContent = Stack(
      children: [
        Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: contentWidth,
              height: screenHeight,
              child: Row(
                children: [
                  // ── SIDEBAR ────────────────────────────────────────────────
                  SizedBox(
                    width: isSidebarOpen ? 225 : 70,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: isSidebarOpen
                          ? SidebarItem(
                              selectedIndex: selectedIndex,
                              onItemSelected: (idx) =>
                                  _onItemSelected(context, idx),
                              onBackArrowTap: toggleSidebar,
                            )
                          : MiniSidebar(
                              selectedIndex: selectedIndex,
                              onItemSelected: (idx) =>
                                  _onItemSelected(context, idx),
                              onBackArrowTap: toggleSidebar,
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
                        // Expanded(
                        //   child: Container(
                        //     color: AppColors.background,
                        //     child: BlocProvider.value(
                        //       value: _notificationCubit,
                        //       child: widget.child,
                        //     ),
                        //   ),
                        // ),
                        Expanded(
  child: Container(
    color: AppColors.background,
    child: MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _notificationCubit),
        BlocProvider.value(value: _staffCubit),   // ← add here instead
      ],
      child: widget.child,
    ),
  ),
),
                        // const BottomBar(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildExitDialogOverlay(),
      ],
    );

    if (kIsWeb) {
      return mainContent;
    }

    return PopScope(
      canPop: !blockNativePop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isDashboard) {
          setState(() => showExitAlert = !showExitAlert);
        }
      },
      child: mainContent,
    );
  }
}
