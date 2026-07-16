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
            offset: const Offset(0, 45),

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

            color: AppColors.white,

            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "Leads Category",
                child: Text("Leads Category"),
              ),
              PopupMenuItem(
                value: "Custom Field Settings",
                child: Text("Custom Field Settings"),
              ),
              PopupMenuItem(value: "Lead Source", child: Text("Lead Source")),
              PopupMenuItem(value: "Lead Stage", child: Text("Lead Stage")),
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
