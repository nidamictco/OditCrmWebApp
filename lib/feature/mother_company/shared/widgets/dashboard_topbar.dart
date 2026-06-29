import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/cubit/auth/auth_cubit.dart';

class DashboardTopBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardTopBar({
    super.key,
    required this.screen,
    this.onSearchChanged,
    this.searchHint = 'Global search',
    this.searchController,
  });

  final ValueChanged<String>? onSearchChanged;
  final String screen;
  final String searchHint;
  final TextEditingController? searchController;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppThemeColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Search
          if (screen != "addCompany")
            Expanded(
              child: Container(
                height: 38,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: AppThemeColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppThemeColors.borderLight),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppThemeColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: searchHint,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppThemeColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: AppThemeColors.textMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
          if (screen == "addCompany")
            Row(
              children: [
                Text(
                  'Company Manage',
                  style: AppTextStyle.body(
                    fontSize: 13,
                    color: AppThemeColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppThemeColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Add New Company',
                  style: AppTextStyle.body(
                    fontSize: 13,
                    color: AppThemeColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppThemeColors.textSecondary,
                ),
              ],
            ),
          const Spacer(),
          // Actions
          // _IconBtn(icon: Icons.settings_outlined, onTap: () {}),
          // const SizedBox(width: 4),
          _IconBtn(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
            badge: true,
          ),
          const SizedBox(width: 16),
          // User
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              String name = 'Ismail CT';
              String role = 'Super Admin';
              String initials = 'IC';
              String? imageUrl;

              if (state is Authenticated) {
                name = state.user.name;
                role = state.user.designation ?? 'Super Admin';
                imageUrl = state.user.imageUrl;

                final nameParts = name.trim().split(RegExp(r'\s+'));
                if (nameParts.length >= 2) {
                  initials = (nameParts[0][0] + nameParts[1][0]).toUpperCase();
                } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
                  initials = nameParts[0][0].toUpperCase();
                } else {
                  initials = 'IC';
                }
              }

              return Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppThemeColors.textPrimary,
                        ),
                      ),
                      Text(
                        role,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppThemeColors.primary,
                    backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : null,
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? null
                        : Text(
                            initials,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap, this.badge = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(icon, color: AppThemeColors.textSecondary, size: 22),
          onPressed: onTap,
          splashRadius: 20,
        ),
        if (badge)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
