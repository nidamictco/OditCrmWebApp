import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:sizer/sizer.dart';

class ToolTipWidget extends StatefulWidget {
  final String message;
  const ToolTipWidget({super.key, required this.message});

  @override
  State<ToolTipWidget> createState() => _ToolTipWidgetState();
}

class _ToolTipWidgetState extends State<ToolTipWidget> {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      // preferBelow: false,
      message: widget.message,
      textAlign: TextAlign.center,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: TextStyle(color: Colors.white, fontSize: 12),
      waitDuration: Duration(milliseconds: 200),
      child: Container(
        height: 1.5.h,
        width: 1.5.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.green, width: 1),
        ),
        child: Icon(
          Icons.question_mark_rounded,
          size: 9.sp,
          color: AppColors.green,
        ),
      ),
    );
  }
}
