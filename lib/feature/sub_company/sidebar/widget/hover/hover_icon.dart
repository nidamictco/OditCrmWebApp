import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:sizer/sizer.dart';

class HoverIcon extends StatefulWidget {
  final IconData icon;

  const HoverIcon({super.key, required this.icon});

  @override
  State<HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<HoverIcon> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(0.5.w),
        decoration: BoxDecoration(
          color: isHovered
              ? Colors.blue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(0.5.w),
        ),
        child: Icon(
          widget.icon,
          size: 15.7.sp,
          color: isHovered ? Colors.blue : AppColors.grey,
        ),
      ),
    );
  }
}
