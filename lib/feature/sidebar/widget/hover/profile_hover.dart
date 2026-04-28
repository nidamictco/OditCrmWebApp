import 'package:flutter/material.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class HoverProfileAvatar extends StatefulWidget {
  const HoverProfileAvatar({super.key});

  @override
  State<HoverProfileAvatar> createState() => _HoverProfileAvatarState();
}

class _HoverProfileAvatarState extends State<HoverProfileAvatar> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 3.h,
            child: Icon(Icons.person, size: 12.sp),
          ),

          if (isHovered)
            Positioned(
              top: 7.h,
              right: 0,
              child: OverflowBox(
                // 🔥 THIS FIXES IT
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(1.w),
                  child: Container(
                    width: 20.w,
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text("Fathima Nida"), Text("Admin")],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
