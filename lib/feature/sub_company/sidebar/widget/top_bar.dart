import 'dart:html' as html;

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/feature/auth/cubit/auth/auth_cubit.dart';
import 'package:oxdo/feature/auth/screen/login.dart';
import 'package:oxdo/feature/sub_company/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/sub_company/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/sub_company/notification/cubit/notification_cubit.dart';
import 'package:oxdo/feature/sub_company/notification/cubit/notification_state.dart';
import 'package:oxdo/feature/sub_company/sidebar/main_screen.dart';
import 'package:oxdo/feature/sub_company/sidebar/widget/hover/hover_icon.dart';
import 'package:oxdo/feature/sub_company/staff_managment/designation/cubit/cubit/permission_cubit.dart';
import 'package:oxdo/feature/sub_company/staff_managment/staff/model/staff_model.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isFullscreen = false;
  bool _isDropdownVisible = false;
  bool _isHoveringOverlay = false;

  @override
  void initState() {
    super.initState();
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

    final navigator = Navigator.of(context);

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
                                  return InkWell(
                                    onTap: () {
                                      log('Lead tapped: ${lead.clientName}');
                                      _searchController.clear();
                                      cubit.searchLeads('');
                                      _hideDropdown();
                                      navigator.push(
                                        MaterialPageRoute(
                                          builder: (_) => MainScreen(
                                            selectedIndex: 31,
                                            lead: lead,
                                          ),
                                        ),
                                      );
                                    },
                                    hoverColor: Colors.grey.shade50,
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
        height: 11.h,
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: [
            // LEFT SIDE
            Row(
              children: [
                IconButton(
                  onPressed: widget.onMenuTap,
                  icon: Icon(
                    widget.isSidebarOpen
                        ? Icons.menu_open_outlined
                        : Icons.menu_outlined,
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 1.w),
                _buildSearchBox(),
              ],
            ),

            const Spacer(),

            // RIGHT SIDE
            Row(
              children: [
                _buildQuickLinksButton(),
                SizedBox(width: 0.5.w),
                GestureDetector(
                  onTap: _toggleFullscreen,
                  child: Tooltip(
                    message: 'Toggle Fullscreen',
                    child: HoverIcon(
                      icon: _isFullscreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen,
                    ),
                  ),
                ),
                SizedBox(width: 0.5.w),

                // GestureDetector(
                //   onTap: () {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //           builder: (_) => MainScreen(selectedIndex: 34)),
                //     );
                //   },
                //   child: HoverIcon(icon: Icons.notifications_none_outlined)),
                // in your RIGHT SIDE Row, replace the notification GestureDetector:
                BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    final unread = state is NotificationLoaded
                        ? state.unreadCount
                        : 0;
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MainScreen(selectedIndex: 34),
                          ),
                        );
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Tooltip(
                            message: 'Notifications',
                            child: HoverIcon(icon: Icons.notifications_none_outlined),
                          ),
                          if (unread > 0)
                            Positioned(
                              top: 3,
                              right: 5.5,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  unread > 99 ? '99+' : '$unread',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(width: 0.3.w),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is! Authenticated) return const SizedBox.shrink();
                    final user = state.user;
                    return _profileAvatar(
                      context,
                      user.name,
                      user.staffType ?? '',
                      user,
                    );
                  },
                ),
              ],
            ),
          ],
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
        height: 6.h,
        width: 18.w,
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        decoration: BoxDecoration(
          color: const Color(0xfff3f3f9),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 13.sp, color: AppColors.grey),
            SizedBox(width: 0.5.w),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (query) => _onSearchChanged(query, cubit),
                style: AppTextStyle.small(
                  size: 11.5.sp,
                  color: AppColors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: AppTextStyle.small(
                    size: 11.5.sp,
                    color: AppColors.grey,
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
                    _searchController.clear();
                    cubit.searchLeads('');
                    _hideDropdown();
                  },
                  child: Icon(Icons.cancel, size: 12.sp, color: AppColors.grey),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Profile avatar ────────────────────────────────────────────────────────

  Widget _profileAvatar(
    BuildContext context,
    String name,
    String role,
    StaffModel user,
  ) {
    final hasImage = user.imageUrl != null && user.imageUrl!.trim().isNotEmpty;

    return GestureDetector(
      onTapDown: (details) async {
        final position = RelativeRect.fromLTRB(
          details.globalPosition.dx,
          details.globalPosition.dy + 10,
          details.globalPosition.dx,
          0,
        );

        final selected = await showMenu<String>(
          color: AppColors.white,
          context: context,
          position: position,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          items: [
            _buildMenuItem(Icons.person_outline, "Profile"),
            _buildMenuItem(Icons.lock_outline, "Change Password"),
            _buildMenuItem(Icons.settings_outlined, "Settings"),
            const PopupMenuDivider(),
            _buildMenuItem(Icons.logout, "Logout", isLogout: true),
          ],
        );

        if (selected == "Logout" && context.mounted) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Row(
                children: [
                  Icon(Icons.logout, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Confirm Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text(
                    'Cancel',
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
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            context.read<AuthCubit>().logout(
              permissionCubit: context.read<PermissionCubit>(),
            );
          }
        }
        if (selected == "Settings" && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MainScreen(selectedIndex: 20)),
          );
        }
        if (selected == "Profile" && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MainScreen(selectedIndex: 33, staff: user),
            ),
          );
        }
        if (selected == "Change Password" && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MainScreen(selectedIndex: 32, staff: user),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(0.5.w),
        color: AppColors.greenCard,
        child: Row(
          children: [
            // ── Profile image (web-safe) ───────────────────────────
            _buildProfileImage(hasImage, user),
            SizedBox(width: 0.6.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: AppTextStyle.small(
                    size: 11.sp,
                    color: AppColors.black,
                    weight: FontWeight.w500,
                  ),
                ),
                Text(
                  role,
                  style: AppTextStyle.small(
                    size: 11.sp,
                    color: AppColors.black,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Web-safe profile image: uses Image.network inside CircleAvatar
  /// so we can attach loadingBuilder and errorBuilder.
  Widget _buildProfileImage(bool hasImage, StaffModel user) {
    if (!hasImage) {
      return CircleAvatar(
        radius: 3.h,
        backgroundColor: Colors.grey.shade200,
        child: Icon(Icons.person, size: 12.sp, color: Colors.grey),
      );
    }

    return CircleAvatar(
      radius: 3.h,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: Image.network(
          user.imageUrl!,
          width: 6.h,
          height: 6.h,
          fit: BoxFit.cover,
          // Shows a subtle shimmer/spinner while loading on web
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey.shade400,
                ),
              ),
            );
          },
          // Falls back to person icon if URL is broken or CORS fails
          errorBuilder: (context, error, stack) {
            return Icon(Icons.person, size: 12.sp, color: Colors.grey);
          },
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    IconData icon,
    String text, {
    bool isLogout = false,
  }) {
    return PopupMenuItem<String>(
      value: text,
      child: Row(
        children: [
          Icon(icon, size: 16, color: isLogout ? Colors.red : Colors.grey[700]),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isLogout ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick links ───────────────────────────────────────────────────────────

  Widget _buildQuickLinksButton() {
    return GestureDetector(
      onTapDown: (details) async {
        final position = RelativeRect.fromLTRB(
          details.globalPosition.dx - 150,
          details.globalPosition.dy + 10,
          details.globalPosition.dx,
          0,
        );

        final selected = await showMenu<String>(
          context: context,
          position: position,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          items: [
            PopupMenuItem<String>(
              enabled: false,
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Links',
                    style: AppTextStyle.small(
                      size: 12.sp,
                      color: AppColors.black,
                      weight: FontWeight.w600,
                    ),
                  ),
                  Divider(color: Colors.grey.shade200, height: 1.5.h),
                ],
              ),
            ),
            _buildQuickLinkItem(
              icon: Icons.person_add_outlined,
              label: 'New Lead',
              value: 'new_lead',
              iconColor: Colors.blue,
              bgColor: Colors.blue.shade50,
            ),
          ],
        );

        if (!context.mounted) return;
        if (selected == 'new_lead') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MainScreen(selectedIndex: 1)),
          );
        }
      },
      child: Tooltip(message: 'Quick Links',child: HoverIcon(icon: Icons.grid_view),),
    );
  }

  PopupMenuItem<String> _buildQuickLinkItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color bgColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
