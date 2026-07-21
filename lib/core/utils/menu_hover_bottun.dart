import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_colors.dart';

class MenuHoverButton extends StatefulWidget {
  const MenuHoverButton({super.key});

  @override
  State<MenuHoverButton> createState() => _MenuHoverButtonState();
}

class _MenuHoverButtonState extends State<MenuHoverButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),

      child: Builder(
        builder: (context) {
          return PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            offset: const Offset(0, 40),
            constraints: BoxConstraints(maxWidth: 225),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              switch (value) {
                case "Leads Category":
                  context.go(RoutePaths.leadCategory);
                  break;

                case "Custom Field Settings":
                  context.go(RoutePaths.customFields);
                  break;

                case "Lead Source":
                  context.go(RoutePaths.leadSource);
                  break;

                case "Lead Stage":
                  context.go(RoutePaths.leadStages);
                  break;

                // case "Call Settings":
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (_) => MainScreen(selectedIndex: 28,)),
                //   );
                //   break;

                // case "Unfinished Lead Distribution Settings":
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (_) => MainScreen(selectedIndex: 11,)),
                //   );
                //   break;
              }
            },
            borderRadius: BorderRadius.circular(12),
            menuPadding: EdgeInsets.zero,
            color: AppColors.white,
            itemBuilder: (context) => [
              PopupMenuItem(
                height: 35,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                value: "Leads Category",
                child: Row(
                  spacing: 8,
                  children: [
                    Image.asset("assets/icon/category.png", scale: 3.1),
                    Text(
                      "Leads Category",
                      style: AppTextStyle.medium(
                        size: 11.5.sp,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                height: 35,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                value: "Custom Field Settings",
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.settings_outlined, size: 19.8),
                    Text(
                      "Custom Field Settings",
                      style: AppTextStyle.medium(
                        size: 11.5.sp,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                height: 35,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                value: "Lead Source",
                child: Row(
                  spacing: 8,
                  children: [
                    Image.asset("assets/icon/source.png", scale: 3.1),
                    Text(
                      "Lead Source",
                      style: AppTextStyle.medium(
                        size: 11.5.sp,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                height: 35,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                value: "Lead Stage",
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.leaderboard_outlined, size: 19.8),
                    Text(
                      "Lead Stage",
                      style: AppTextStyle.medium(
                        size: 11.5.sp,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // PopupMenuItem(value: 'Call Settings', child: Text('Call Settings')),
              // PopupMenuItem(
              //   value: "Unfinished Lead Distribution Settings",
              //   child: Text("Unfinished Lead Distribution Settings"),
              // ),
            ],

            child: AnimatedContainer(
              // duration: const Duration(milliseconds: 200),
              // height: 6.h,
              // width: 6.h,
              // decoration: BoxDecoration(
              //   color: isHovering
              //       ? Colors.blue.shade100
              //       : const Color(0xffE5E7EB),
              //   borderRadius: BorderRadius.circular(4),
              // ),
              duration: const Duration(milliseconds: 150),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isHovering
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.notes,
                size: 13.sp,
                color: isHovering ? Colors.blue : Colors.black54,
              ),
            ),
          );
        },
      ),
    );
  }
}
