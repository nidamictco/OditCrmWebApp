import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:login_2_it_solution/feature/sidebar/widget/hover/hover_icon.dart';
import 'package:login_2_it_solution/feature/sidebar/widget/hover/profile_hover.dart';
import 'package:sizer/sizer.dart';


class TopBar extends StatelessWidget {
  final bool isSidebarOpen;
  final VoidCallback onMenuTap;

  const TopBar({
    super.key,
    required this.isSidebarOpen,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 11.h,
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT SIDE
          Row(
            children: [
              IconButton(
                onPressed: onMenuTap,
                icon: Icon(
                  isSidebarOpen
                      ? Icons
                            .menu_open_outlined // 👈 better UX
                      : Icons.menu_outlined,
                  size: 16.sp,
                ),
              ),

              SizedBox(width: 1.w),

              Container(
                height: 6.h,
                width: 18.w,
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                decoration: BoxDecoration(
                  color: Color(0xfff3f3f9),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 13.sp, color: AppColors.grey),
                    SizedBox(width: 1.w),
                    Text(
                      "Search...",
                      style: AppTextStyle.small(
                        size: 11.5.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// RIGHT SIDE
          Row(
            children: [
              HoverIcon(icon: Icons.grid_view),
              SizedBox(width: 0.5.w),
              HoverIcon(icon: Icons.fullscreen),
              SizedBox(width: 0.5.w),
              HoverIcon(icon: Icons.notifications_none_outlined),
              SizedBox(width: 0.3.w),
              _profileAvatar(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileAvatar(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) async {
        final position = RelativeRect.fromLTRB(
          details.globalPosition.dx,
          details.globalPosition.dy + 10,
          details.globalPosition.dx,
          0,
        );

        await showMenu<String>(
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
      },
      child: Container(
        // height: 10.h,
        width: 12.w,
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
                Text("Fathima Nida", style: AppTextStyle.small(size: 11.sp, color: AppColors.black, weight: FontWeight.w500)),
                Text("Admin", style: AppTextStyle.small(size: 11.sp, color: AppColors.black, weight: FontWeight.w500)),
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
