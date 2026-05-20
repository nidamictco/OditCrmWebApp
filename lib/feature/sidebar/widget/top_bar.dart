// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:oxdo/core/theme/app_colors.dart';
// import 'package:oxdo/core/theme/app_text_style.dart';
// import 'package:oxdo/feature/auth/cubit/auth_cubit.dart';
// import 'package:oxdo/feature/sidebar/main_screen.dart';
// import 'package:oxdo/feature/sidebar/widget/hover/hover_icon.dart';
// import 'package:sizer/sizer.dart';

// class TopBar extends StatelessWidget {
//   final bool isSidebarOpen;
//   final VoidCallback onMenuTap;

//   const TopBar({
//     super.key,
//     required this.isSidebarOpen,
//     required this.onMenuTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthCubit, AuthState>(
//       listener: (context, state) {
//         if (state is AuthLoggedOut) {
//           Navigator.of(
//             context,
//           ).pushNamedAndRemoveUntil('/login', (route) => false);
//         }
//       },
//       child: Container(
//         height: 11.h,
//         padding: EdgeInsets.symmetric(horizontal: 1.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border(
//             bottom: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
//           ),
//         ),
//         child: Row(
//           children: [
//             /// LEFT SIDE
//             Row(
//               children: [
//                 IconButton(
//                   onPressed: onMenuTap,
//                   icon: Icon(
//                     isSidebarOpen
//                         ? Icons.menu_open_outlined
//                         : Icons.menu_outlined,
//                     size: 16.sp,
//                   ),
//                 ),
//                 SizedBox(width: 1.w),
//                 Container(
//                   height: 6.h,
//                   width: 18.w,
//                   padding: EdgeInsets.symmetric(horizontal: 1.w),
//                   decoration: BoxDecoration(
//                     color: Color(0xfff3f3f9),
//                     borderRadius: BorderRadius.circular(3),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.search, size: 13.sp, color: AppColors.grey),
//                       SizedBox(width: 1.w),
//                       Text(
//                         "Search...",
//                         style: AppTextStyle.small(
//                           size: 11.5.sp,
//                           color: AppColors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             Spacer(),

//             /// RIGHT SIDE
//             Row(
//               children: [
//                 HoverIcon(icon: Icons.grid_view),
//                 SizedBox(width: 0.5.w),
//                 HoverIcon(icon: Icons.fullscreen),
//                 SizedBox(width: 0.5.w),
//                 HoverIcon(icon: Icons.notifications_none_outlined),
//                 SizedBox(width: 0.3.w),
//                 BlocBuilder<AuthCubit, AuthState>(
//                   builder: (context, state) {
//                     final user = state is Authenticated ? state.user : null;
//                     return _profileAvatar(
//                       context,
//                       user?.name ?? '',
//                       user?.staffType ?? '',
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _profileAvatar(BuildContext context, String name, String role) {
//     return GestureDetector(
//       onTapDown: (details) async {
//         final position = RelativeRect.fromLTRB(
//           details.globalPosition.dx,
//           details.globalPosition.dy + 10,
//           details.globalPosition.dx,
//           0,
//         );

//         final selected = await showMenu<String>(
//           color: AppColors.white,
//           context: context,
//           position: position,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           items: [
//             _buildMenuItem(Icons.person_outline, "Profile"),
//             _buildMenuItem(Icons.lock_outline, "Change Password"),
//             _buildMenuItem(Icons.settings_outlined, "Settings"),
//             const PopupMenuDivider(),
//             _buildMenuItem(Icons.logout, "Logout", isLogout: true),
//           ],
//         );

//         if (selected == "Logout" && context.mounted) {
//           context.read<AuthCubit>().logout();
//         }
//         if (selected == "Settings" && context.mounted) {
//           Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//             return MainScreen(selectedIndex: 20);
//           }));
//         }
//         if (selected == "Profile" && context.mounted) {
//           Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//             return MainScreen(selectedIndex: 29);
//           }));
//         }
//         if (selected == "Change Password" && context.mounted) {
//           Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//             return MainScreen(selectedIndex: 32);
//           }));
//         }
//       },
//       child: Container(
//         // width: 12.w,
//         padding: EdgeInsets.all(0.5.w),
//         color: AppColors.greenCard,
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 3.h,
//               child: Icon(Icons.person, size: 12.sp),
//             ),
//             SizedBox(width: 0.6.w),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   name,
//                   style: AppTextStyle.small(
//                     size: 11.sp,
//                     color: AppColors.black,
//                     weight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   role,
//                   style: AppTextStyle.small(
//                     size: 11.sp,
//                     color: AppColors.black,
//                     weight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   PopupMenuItem<String> _buildMenuItem(
//     IconData icon,
//     String text, {
//     bool isLogout = false,
//   }) {
//     return PopupMenuItem<String>(
//       value: text,
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: isLogout ? Colors.red : Colors.grey[700]),
//           const SizedBox(width: 10),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 13,
//               color: isLogout ? Colors.red : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/feature/auth/cubit/auth_cubit.dart';
import 'package:oxdo/feature/auth/screen/login.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:oxdo/feature/sidebar/widget/hover/hover_icon.dart';
import 'package:oxdo/feature/staff_managment/designation/cubit/cubit/permission_cubit.dart';
import 'package:oxdo/feature/staff_managment/staff/model/staff_model.dart';
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
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _debounce;

  AddLeadCubit? _searchCubit;

  @override
  void initState() {
    super.initState();
    // ← assign cubit here, not inside _showOverlay()
    // _searchCubit = context.read<AddLeadCubit>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      context.read<AddLeadCubit>().searchLeads(query);
      if (query.trim().isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _showOverlay() {
    _removeOverlay();
    // final cubit = context.read<AddLeadCubit>();

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        width: 22.w,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, 7.h),
          showWhenUnlinked: false,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            child: BlocProvider.value(
              value: context.read<AddLeadCubit>(),
              child: BlocBuilder<AddLeadCubit, AddLeadState>(
                builder: (ctx, state) {
                  if (!state.isSearching) return const SizedBox.shrink();

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ── Search box replica at top of dropdown ──
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 1.w,
                            vertical: 0.8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                size: 14.sp,
                                color: AppColors.grey,
                              ),
                              SizedBox(width: 0.5.w),
                              Expanded(
                                child: Text(
                                  _searchController.text,
                                  style: AppTextStyle.small(
                                    size: 11.5.sp,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  _removeOverlay();
                                  // cubit.searchLeads('');
                                },
                                child: Icon(
                                  Icons.cancel,
                                  size: 14.sp,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// ── Results body ──
                        if (state.searchResults.isEmpty)
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
                        else
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 45.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// "LEADS" section header
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 1.2.w,
                                    vertical: 0.6.h,
                                  ),
                                  color: Colors.grey.shade50,
                                  child: Text(
                                    'LEADS',
                                    style: AppTextStyle.small(
                                      size: 9.5.sp,
                                      color: AppColors.grey,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                /// Lead list
                                Flexible(
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
                                          log('wwwwww');
                                          _removeOverlay();
                                          _searchController.clear();
                                          // cubit.searchLeads('');
                                          Navigator.of(context).push(
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
                                              /// Person avatar (grey circle with icon)
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

                                              /// Name + phone
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
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    _searchCubit = context.read<AddLeadCubit>();
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()), // ← FIXED
            (route) => false,
          );
        }
      },
      child: TapRegion(
        // onTapOutside: (_) {
        //   _removeOverlay();
        //   _searchController.clear();
        //   context.read<AddLeadCubit>().searchLeads('');
        // },
        onTapOutside: (_) {
          _removeOverlay();
          _searchController.clear();
          try {
            context.read<AddLeadCubit>().searchLeads('');
          } catch (_) {}
        },
        child: Container(
          height: 11.h,
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              /// LEFT SIDE
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

                  /// SEARCH BOX
                  CompositedTransformTarget(
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
                          Icon(
                            Icons.search,
                            size: 13.sp,
                            color: AppColors.grey,
                          ),
                          SizedBox(width: 0.5.w),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
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

                          /// Clear button
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _searchController,
                            builder: (_, value, __) {
                              if (value.text.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  _removeOverlay();
                                  context.read<AddLeadCubit>().searchLeads('');
                                },
                                child: Icon(
                                  Icons.cancel,
                                  size: 12.sp,
                                  color: AppColors.grey,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              /// RIGHT SIDE
              Row(
                children: [
                  HoverIcon(icon: Icons.grid_view),
                  SizedBox(width: 0.5.w),
                  HoverIcon(icon: Icons.fullscreen),
                  SizedBox(width: 0.5.w),
                  HoverIcon(icon: Icons.notifications_none_outlined),
                  SizedBox(width: 0.3.w),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      // final user = state is Authenticated ? state.user : null;
                      if (state is! Authenticated)
                        return const SizedBox.shrink(); // ← safe guard
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
      ),
    );
  }

  Widget _profileAvatar(
    BuildContext context,
    String name,
    String role,
    StaffModel user,
  ) {
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
            MaterialPageRoute(
              builder: (context) {
                return MainScreen(selectedIndex: 20);
              },
            ),
          );
        }
        if (selected == "Profile" && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return MainScreen(selectedIndex: 29, staff: user);
              },
            ),
          );
        }
        if (selected == "Change Password" && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return MainScreen(selectedIndex: 32, staff: user);
              },
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(0.5.w),
        color: AppColors.greenCard,
        child: Row(
          children: [
            CircleAvatar(
              radius: 3.h,
              child: Icon(Icons.person, size: 12.sp),
            ),
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
}
