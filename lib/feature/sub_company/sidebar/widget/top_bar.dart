import 'dart:html' as html;
import 'dart:async';
import 'dart:developer';
import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/core/utils/menu_hover_bottun.dart';
import 'package:Odit_CRM/feature/sub_company/dashboard/widget/add_leads_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/feature/auth/cubit/auth/auth_cubit.dart';
import 'package:Odit_CRM/feature/auth/screen/login.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:Odit_CRM/feature/sub_company/notification/cubit/notification_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/notification/cubit/notification_state.dart';
import 'package:go_router/go_router.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/core/router/browser_aware_link.dart';
import 'package:Odit_CRM/feature/sub_company/settings/general_settings/cubit/general_settings_cubit.dart';
import 'package:Odit_CRM/feature/sub_company/settings/general_settings/cubit/general_settings_state.dart';
import 'package:Odit_CRM/feature/sub_company/settings/general_settings/model/general_settings_model.dart';
import 'package:sizer/sizer.dart';

class TopBar extends StatefulWidget {
  final bool isSidebarOpen;
  final VoidCallback onMenuTap;

  const TopBar({
    super.key,
    required this.isSidebarOpen,
    required this.onMenuTap,
  });

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  static String _lastSearchQuery = '';
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isFullscreen = false;
  bool _isDropdownVisible = false;
  bool _isHoveringOverlay = false;
  bool _isSearchClicked = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: _lastSearchQuery);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && !_isHoveringOverlay) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted && !_searchFocusNode.hasFocus && !_isHoveringOverlay) {
            _hideDropdown();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleFullscreen() {
    if (_isFullscreen) {
      html.document.exitFullscreen();
    } else {
      html.document.documentElement?.requestFullscreen();
    }
    setState(() => _isFullscreen = !_isFullscreen);
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void _onSearchChanged(String query, AddLeadCubit cubit) {
    _lastSearchQuery = query;
    cubit.searchLeads(query);
    if (query.trim().isNotEmpty) {
      _showDropdown(cubit);
    } else {
      _hideDropdown();
    }
  }

  // ── Overlay management ────────────────────────────────────────────────────

  void _showDropdown(AddLeadCubit cubit) {
    if (_isDropdownVisible) return;
    _isDropdownVisible = true;
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        width: 22.w,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, 6.h),
          showWhenUnlinked: false,
          child: MouseRegion(
            onEnter: (_) => _isHoveringOverlay = true,
            onExit: (_) => _isHoveringOverlay = false,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              child: BlocProvider.value(
                value: cubit,
                child: BlocBuilder<AddLeadCubit, AddLeadState>(
                  buildWhen: (prev, next) =>
                      prev.searchResults != next.searchResults ||
                      prev.isSearching != next.isSearching,
                  builder: (ctx, state) {
                    if (!state.isSearching) return const SizedBox.shrink();

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 1.2.w,
                              vertical: 0.6.h,
                            ),
                            color: const Color(0xfff3f3f9),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 14.sp,
                                  color: AppColors.grey,
                                ),
                                SizedBox(width: 0.5.w),
                                Text(
                                  'LEADS',
                                  style: AppTextStyle.small(
                                    size: 9.5.sp,
                                    color: AppColors.grey,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Loading
                          if (state.isSearching &&
                              state.searchResults.isEmpty &&
                              state.listStatus == LeadListStatus.loading)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.w,
                                vertical: 2.h,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Searching...',
                                    style: AppTextStyle.small(
                                      size: 11.sp,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          // No results
                          else if (state.searchResults.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.w,
                                vertical: 2.h,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    color: AppColors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'No leads found',
                                    style: AppTextStyle.small(
                                      size: 11.sp,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          // Results list
                          else
                            ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 45.h),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: state.searchResults.length.clamp(
                                  0,
                                  8,
                                ),
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  indent: 1.w,
                                  endIndent: 1.w,
                                  color: Colors.grey.shade100,
                                ),
                                itemBuilder: (_, i) {
                                  final lead = state.searchResults[i];
                                  final path = RoutePaths.followUpPath(
                                    lead.id!,
                                    "NEW",
                                  );
                                  return BrowserAwareLink(
                                    destination: path,
                                    usePush: true,
                                    hoverColor: Colors.grey.shade50,
                                    onNewTabOpened: () {
                                      _hideDropdown();
                                    },
                                    onTap: () {
                                      log('Lead tapped: ${lead.clientName}');
                                      _hideDropdown();
                                      context.push(path);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 1.w,
                                        vertical: 0.8.h,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 2.2.h,
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            child: Icon(
                                              Icons.person,
                                              size: 11.sp,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                          SizedBox(width: 0.8.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lead.clientName,
                                                  style: AppTextStyle.small(
                                                    size: 11.sp,
                                                    color: AppColors.black,
                                                    weight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 0.2.h),
                                                Text(
                                                  lead.contactNumber,
                                                  style: AppTextStyle.small(
                                                    size: 10.sp,
                                                    color: AppColors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _isDropdownVisible = false;
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onSearchClicked() {
    setState(() {
      _isSearchClicked = !_isSearchClicked;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Container(
        height: 10.h,
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        decoration: BoxDecoration(
          color: Colors.white,
          // border: Border(
          //   bottom: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
          // ),
        ),
        child: Builder(
          builder: (context) {
            final location = GoRouterState.of(context).uri.path;
            final page =
                GoRouterState.of(context).uri.queryParameters['fromCard'] ??
                GoRouterState.of(context).uri.queryParameters['from_card'];
            final isDashboard =
                location == RoutePaths.dashboard || location == '/';
            final isLeadListScreen =
                location == RoutePaths.newLeads || location == '/leads';
            final isViewStaff = location == RoutePaths.viewStaff;

            final breadcrumbs = _getBreadcrumbs(location, page ?? '');

            return Row(
              children: [
                // LEFT SIDE: Back and Forward buttons, and Breadcrumbs
                // GestureDetector(
                //   onTap: () {
                //     if (context.canPop()) {
                //       context.pop();
                //     } else if (location.contains('/follow_up/')) {
                //       context.go(
                //         Uri(
                //           path: RoutePaths.newLeads,
                //           queryParameters: {'fromCard': page ?? "NEW"},
                //         ).toString(),
                //       );
                //     }
                //   },
                //   child: Container(
                //     width: 32,
                //     height: 32,
                //     decoration: BoxDecoration(
                //       color: const Color(0xFFF1F5F9),
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: Icon(
                //       Icons.chevron_left,
                //       size: 14.sp,
                //       color: AppColors.grey,
                //     ),
                //   ),
                // ),
                // const SizedBox(width: 6),
                // Container(
                //   width: 32,
                //   height: 32,
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFF1F5F9),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Icon(
                //     Icons.chevron_right,
                //     size: 14.sp,
                //     color: const Color(0xFF94A3B8).withOpacity(0.5),
                //   ),
                // ),
                const SizedBox(width: 12),

                // Breadcrumbs: Parent Category / Current Category
                Text(
                  breadcrumbs.parent,
                  style: AppTextStyle.medium(
                    size: 11.5,
                    color: breadcrumbs.current.isEmpty
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFA9A9A9),
                    weight: breadcrumbs.current.isEmpty
                        ? FontWeight.w600
                        : FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
                if (breadcrumbs.current.isNotEmpty) ...[
                  Text(
                    '  >>  ',
                    style: AppTextStyle.medium(
                      size: 11.5,
                      color: const Color(0xFFA9A9A9),
                      weight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    breadcrumbs.current,
                    style: AppTextStyle.medium(
                      size: 11.5,
                      color: const Color(0xFF0F172A),
                      weight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],

                const Spacer(),

                // RIGHT SIDE: Search Box, Hamburger (Menu), Bell, Settings, Fullscreen
                if (!isViewStaff) _buildSearchBox(),
                if (_isSearchClicked && isViewStaff) _buildSearchBox(),
                if (isViewStaff && !_isSearchClicked)
                  InkWell(
                    onTap: _onSearchClicked,
                    child: Container(
                      height: 32,
                      padding: EdgeInsets.symmetric(horizontal: 0.8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.search,
                        size: 13.sp,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),

                SizedBox(width: 0.8.w),
                if (isDashboard || isLeadListScreen) AddLeadsButton(),
                if (isDashboard || isLeadListScreen) SizedBox(width: 0.6.w),

                // _TopBarIconButton(
                //   icon: Icons.notes,
                //   tooltip: 'Menu',
                //   onTap: widget.onMenuTap,
                // ),
                const MenuHoverButton(),
                SizedBox(width: 0.6.w),

                // Notification Bell with Badge
                BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    final unread = state is NotificationLoaded
                        ? state.unreadCount
                        : 0;
                    return _TopBarIconButton(
                      icon: Icons.notifications_none_outlined,
                      tooltip: 'Notifications',
                      onTap: () {
                        context.push(RoutePaths.notifications);
                      },
                      badge: unread > 0
                          ? Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                unread > 99 ? '99+' : '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : null,
                    );
                  },
                ),
                SizedBox(width: 0.6.w),

                // Settings Cog
                _TopBarIconButton(
                  icon: Icons.settings_outlined,
                  tooltip: 'Settings',
                  onTap: () => _showSettingsDialog(context),
                ),
                SizedBox(width: 0.6.w),

                // Fullscreen Toggle
                _TopBarIconButton(
                  icon: _isFullscreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  tooltip: 'Toggle Fullscreen',
                  onTap: _toggleFullscreen,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Search box widget ─────────────────────────────────────────────────────

  Widget _buildSearchBox() {
    final cubit = context.read<AddLeadCubit>();
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 5.2.h,
        width: 25.w,
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFCBD5E1)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 13.sp, color: const Color(0xFF94A3B8)),
            SizedBox(width: 0.5.w),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (query) => _onSearchChanged(query, cubit),
                style: AppTextStyle.small(size: 11.5, color: AppColors.black),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: AppTextStyle.small(
                    size: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (_, value, __) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    _lastSearchQuery = '';
                    _searchController.clear();
                    cubit.searchLeads('');
                    _hideDropdown();
                  },
                  child: Icon(
                    Icons.cancel,
                    size: 12.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider(
          create: (_) {
            final cubit = GeneralSettingsCubit()..loadForCurrentUser();
            cubit.onSettingsChanged = (updated) {
              try {
                context.read<NotificationCubit>().refreshSettings(updated);
              } catch (_) {}
            };
            return cubit;
          },
          child: const PushNotificationSettingsDialog(),
        );
      },
    );
  }
}

class PushNotificationSettingsDialog extends StatefulWidget {
  const PushNotificationSettingsDialog({super.key});

  @override
  State<PushNotificationSettingsDialog> createState() =>
      _PushNotificationSettingsDialogState();
}

class _PushNotificationSettingsDialogState
    extends State<PushNotificationSettingsDialog> {
  bool? _newLead;
  bool? _transferLead;
  GeneralSettingsModel? _originalSettings;
  bool _isInitialized = false;
  int selectedTab = 0;

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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GeneralSettingsCubit, GeneralSettingsState>(
      listener: (context, state) {
        if (state is GeneralSettingsError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        GeneralSettingsModel? settings;
        if (state is GeneralSettingsLoaded) {
          settings = state.settings;
        } else if (state is GeneralSettingsUpdating) {
          settings = state.settings;
        }

        if (settings != null && !_isInitialized) {
          _originalSettings = settings;
          _newLead = settings.newLead;
          _transferLead = settings.transferLead;
          _isInitialized = true;
        }

        final isLoading = state is GeneralSettingsLoading || !_isInitialized;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Container(
            width: 600,
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Push Notifications)
                Stack(
                  children: [
                    Divider(height: 1, thickness: 1, color: Colors.transparent),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(height: 1, color: AppColors.divider),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Push Notifications',
                            style: AppTextStyle.medium(
                              size: 16,
                              color: const Color(0xFF0F172A),
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          height: 3,
                          width: 150, // width of text approximate
                          color: const Color(0xFF0D3E6E),
                        ),
                      ],
                    ),
                  ],
                ),
                // _tabs(),
                const SizedBox(height: 24),

                if (isLoading)
                  const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  // New Lead Assigned row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Lead Assigned',
                              style: AppTextStyle.medium(
                                size: 14,
                                color: const Color(0xFF0F3A66),
                                weight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Send a push notification to the staff when a new lead is assigned.',
                              style: AppTextStyle.medium(
                                size: 12,
                                color: AppThemeColors.hintColor,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 45,
                        height: 28,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Switch(
                            value: _newLead ?? false,
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFF0D3E6E),
                            // inactiveThumbColor: Colors.white,
                            // inactiveTrackColor: const Color(0xFFE2E8F0),
                            onChanged: (val) {
                              setState(() {
                                _newLead = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Transfer Leads row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transfer Leads',
                              style: AppTextStyle.medium(
                                size: 14,
                                color: const Color(0xFF0F3A66),
                                weight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Send a push notification to the staff member to whom the lead is transferred.',
                              style: AppTextStyle.medium(
                                size: 12,
                                color: AppThemeColors.hintColor,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 45,
                        height: 28,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Switch(
                            value: _transferLead ?? false,
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFF0D3E6E),
                            // inactiveThumbColor: Colors.white,
                            // inactiveTrackColor: const Color(0xFFE2E8F0),
                            onChanged: (val) {
                              setState(() {
                                _transferLead = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Footer buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyle.medium(
                            size: 11.5.sp,
                            color: const Color(0xFF475569),
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: state is GeneralSettingsUpdating
                            ? null
                            : () async {
                                final updated = _originalSettings!.copyWith(
                                  newLead: _newLead,
                                  transferLead: _transferLead,
                                );
                                await context
                                    .read<GeneralSettingsCubit>()
                                    .saveSettings(updated);
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                        icon: state is GeneralSettingsUpdating
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.save_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                        label: Text(
                          'Save Changes',
                          style: AppTextStyle.medium(
                            size: 11.5.sp,
                            color: Colors.white,
                            weight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemeColors.basicGreen,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

String getPageName(String fromCard) {
  switch (fromCard.toUpperCase()) {
    case 'NEW':
      return 'New Leads';
    case 'FOLLOWUP':
      return 'Follow-up Leads';
    case 'CLOSED':
      return 'Closed Leads';
    case 'TOTAL':
      return 'Total Called';
    case 'MISSED':
      return 'Missed Leads';
    case 'TRANSFERRED':
      return 'Transferred Leads';
    default:
      return 'Leads';
  }
}

class _BreadcrumbsData {
  final String parent;
  final String current;

  _BreadcrumbsData(this.parent, this.current);
}

_BreadcrumbsData _getBreadcrumbs(String path, String fromCard) {
  if (path == RoutePaths.dashboard || path == '/') {
    return _BreadcrumbsData('Dashboard', '');
  }
  if (path == RoutePaths.addLead) {
    return _BreadcrumbsData('Lead Management', 'Add Lead');
  }
  if (path == RoutePaths.leadsReport) {
    return _BreadcrumbsData('Lead Management', 'Leads Report');
  }
  if (path == RoutePaths.deletedLeads) {
    return _BreadcrumbsData('Lead Management', 'Deleted Leads');
  }
  if (path == RoutePaths.importLeads) {
    return _BreadcrumbsData('Lead Management', 'Import Leads');
  }
  if (path == RoutePaths.transferLeads) {
    return _BreadcrumbsData('Lead Management', 'Transfer Leads');
  }
  if (path == RoutePaths.leadCategory) {
    return _BreadcrumbsData('Lead Management', 'Lead Category');
  }
  if (path == RoutePaths.leadSource) {
    return _BreadcrumbsData('Lead Management', 'Lead Source');
  }
  if (path == RoutePaths.customFields) {
    return _BreadcrumbsData('Lead Management', 'Custom Fields');
  }
  if (path == RoutePaths.leadStages) {
    return _BreadcrumbsData('Lead Management', 'Lead Stages');
  }
  if (path == RoutePaths.leadDistribution) {
    return _BreadcrumbsData('Lead Management', 'Lead Distribution');
  }
  if (path == RoutePaths.unassignedLeads) {
    return _BreadcrumbsData('Lead Management', 'Unassigned Leads');
  }
  if (path == RoutePaths.newLeads || path == '/leads') {
    return _BreadcrumbsData('Dashboard', getPageName(fromCard));
  }

  if (path == RoutePaths.addStaff) {
    return _BreadcrumbsData('Staff Management', 'Add Staff');
  }
  if (path == RoutePaths.viewStaff) {
    return _BreadcrumbsData('Staff Management', 'View Staff');
  }
  if (path == RoutePaths.designation) {
    return _BreadcrumbsData('Staff Management', 'Designations');
  }
  if (path == RoutePaths.deletedStaff) {
    return _BreadcrumbsData('Staff Management', 'Deleted Staff');
  }

  if (path == RoutePaths.staffReports) {
    return _BreadcrumbsData('Reports', 'Staff Reports');
  }
  if (path == RoutePaths.transferReport) {
    return _BreadcrumbsData('Reports', 'Transfer Reports');
  }
  if (path == RoutePaths.scheduledReport) {
    return _BreadcrumbsData('Reports', 'Scheduled Reports');
  }
  if (path == RoutePaths.rejectedReport) {
    return _BreadcrumbsData('Reports', 'Rejected Reports');
  }
  if (path == RoutePaths.outgoingCallHistory) {
    return _BreadcrumbsData('Reports', 'Outgoing Call History');
  }

  if (path == RoutePaths.personalProfile) {
    return _BreadcrumbsData('Profile', 'Personal Profile');
  }
  if (path == RoutePaths.notifications) {
    return _BreadcrumbsData('Notifications', 'View Notifications');
  }

  // Parameterized routes check
  if (path.contains('/leads/edit/')) {
    return _BreadcrumbsData('Lead Management', 'Edit Lead');
  }
  if (path.contains('/staff/edit/')) {
    return _BreadcrumbsData('Staff Management', 'Edit Staff');
  }
  if (path.contains('/follow_up/')) {
    return _BreadcrumbsData('Dashboard  >>  Lead List', 'Follow Up Details');
  }
  if (path.contains('/staff/') && path.contains('/change_password')) {
    return _BreadcrumbsData('Staff Management', 'Change Password');
  }
  if (path.contains('/staff/')) {
    return _BreadcrumbsData('Staff Management', 'Staff Profile');
  }
// Designation Permissions screen (used for BOTH add and edit)
if (path.contains('/designations/') && path.contains('/permissions')) {
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  // segments => ['designations', ':designationId', 'permissions']
  final designationId = segments.length >= 2 ? segments[1] : '';
  final isAdd = designationId.toLowerCase() == 'new';

  return _BreadcrumbsData(
    'Staff Management >> Designation',
    isAdd ? 'Add Designation' : 'Edit Designation',
  );
}

  // Default fallback: parse path segments
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.length >= 2) {
    final parent = segments[0].replaceAll('_', ' ').replaceAll('-', ' ');
    final current = segments[1].replaceAll('_', ' ').replaceAll('-', ' ');
    return _BreadcrumbsData(
      parent.substring(0, 1).toUpperCase() + parent.substring(1),
      current.substring(0, 1).toUpperCase() + current.substring(1),
    );
  } else if (segments.length == 1) {
    final current = segments[0].replaceAll('_', ' ').replaceAll('-', ' ');
    return _BreadcrumbsData(
      'Pages',
      current.substring(0, 1).toUpperCase() + current.substring(1),
    );
  }

  return _BreadcrumbsData('Pages', 'Odit CRM');
}

class _TopBarIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Widget? badge;

  const _TopBarIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.badge,
  });

  @override
  State<_TopBarIconButton> createState() => _TopBarIconButtonState();
}

class _TopBarIconButtonState extends State<_TopBarIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.icon,
                  size: 13.sp,
                  color: const Color(0xFF475569),
                ),
              ),
              if (widget.badge != null)
                Positioned(top: -2, right: -2, child: widget.badge!),
            ],
          ),
        ),
      ),
    );
  }
}
