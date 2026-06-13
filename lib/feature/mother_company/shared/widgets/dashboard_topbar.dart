import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardTopBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardTopBar({super.key});

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
          Expanded(
            child: Container(
              height: 38,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: AppThemeColors.scaffoldBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppThemeColors.borderLight),
              ),
              child: const TextField(
                style: TextStyle(fontSize: 13, color: AppThemeColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Global search',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppThemeColors.textMuted,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: AppThemeColors.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Actions
          _IconBtn(icon: Icons.settings_outlined, onTap: () {}),
          const SizedBox(width: 4),
          _IconBtn(icon: Icons.notifications_none_rounded, onTap: () {}, badge: true),
          const SizedBox(width: 16),
          // User
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'Ismail CT',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppThemeColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Super Admin',
                    style: TextStyle(
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
                child: const Text(
                  'IC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
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
