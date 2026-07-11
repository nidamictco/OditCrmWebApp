import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:Odit_CRM/feature/sub_company/lead_managment/leads/data/add_lead_repo.dart';
import 'package:go_router/go_router.dart';
import 'package:Odit_CRM/core/router/route_paths.dart';
import 'package:Odit_CRM/core/router/browser_aware_link.dart';
import 'package:sizer/sizer.dart';

class AddLeadsButton extends StatefulWidget {
  const AddLeadsButton({super.key});

  @override
  State<AddLeadsButton> createState() => _AddLeadsButtonState();
}

class _AddLeadsButtonState extends State<AddLeadsButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: BrowserAwareLink(
        destination: RoutePaths.addLead,
        usePush: true,
        enableInkWell: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isHovering
                ? const Color(0xff059669) // darker emerald green on hover
                : const Color(0xff10b981), // emerald green
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (isHovering)
                BoxShadow(
                  color: const Color(0xff10b981).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                "Add Leads",
                style: AppTextStyle.medium(
                  color: Colors.white,
                  size: 13,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
