import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/feature/sidebar/main_screen.dart';
import 'package:sizer/sizer.dart';

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

      /// 👇 IMPORTANT: Builder gives fresh context
      child: Builder(
        builder: (context) {
          return PopupMenuButton<String>(
            offset: const Offset(0, 45),

            onSelected: (value) {
              switch (value) {
                case "Leads Category":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MainScreen(selectedIndex: 7),
                    ),
                  );
                  break;

                case "Custom Field Settings":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MainScreen(selectedIndex: 8),
                    ),
                  );
                  break;

                case "Lead Source": 
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MainScreen(selectedIndex: 9,)),
                  );
                  break;

                case "Lead Stage":
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MainScreen(selectedIndex: 10,)),
                  );
                  break;

                case "Call Settings":
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MainScreen(selectedIndex: 28,)),
                  );
                  break;

                case "Unfinished Lead Distribution Settings":
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MainScreen(selectedIndex: 11,)),
                  );
                  break;
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
              PopupMenuItem(value: 'Call Settings', child: Text('Call Settings')),
              PopupMenuItem(
                value: "Unfinished Lead Distribution Settings",
                child: Text("Unfinished Lead Distribution Settings"),
              ),
            ],

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 6.h,
              width: 6.h,
              decoration: BoxDecoration(
                color: isHovering
                    ? Colors.blue.shade100
                    : const Color(0xffE5E7EB),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.menu,
                size: 18,
                color: isHovering ? Colors.blue : Colors.black54,
              ),
            ),
          );
        },
      ),
    );
  }
}
