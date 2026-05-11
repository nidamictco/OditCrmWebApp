// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:oxdo/core/theme/app_colors.dart';
// import 'package:oxdo/core/theme/app_text_style.dart';
// import 'package:oxdo/core/utils/custom_calender.dart';
// import 'package:sizer/sizer.dart';

// class InputDate extends StatefulWidget {
//   final String label;
//   final TextEditingController controller;
//   final double? top;
//   final double? left;
//   const InputDate({
//     super.key,
//     required this.label,

//     required this.controller,
//     this.top,
//     this.left,
//   });

//   @override
//   State<InputDate> createState() => _InputDateState();
// }

// class _InputDateState extends State<InputDate> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.label,
//           style: AppTextStyle.small(
//             size: 11.sp,
//             color: AppColors.black,
//             weight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(height: 0.3.h),
//         GestureDetector(
//           onTap: () {
//             showDialog(
//               context: context,
//               barrierColor: Colors.transparent,
//               builder: (context) {
//                 return Stack(
//                   children: [
//                     Positioned(
//                       // top: widget.top ?? 43.h,
//                       // left: widget.left ?? 28.w,
//                       child: CustomCalendar(
//                         // widget.controller.text = DateFormat(
//                         //   'dd MMM yyyy',
//                         // ).format(date);
//                         // Navigator.pop(context); // optional (close popup)
//                         onDateSelected: (date) {
//                           setState(() {
//                             widget.controller.text = DateFormat(
//                               'dd MMM yyyy',
//                             ).format(date);
//                           });

//                           Navigator.pop(context);
//                         },
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//           child: Container(
//             height: 4.5.h,
//             decoration: _box(),
//             alignment: Alignment.centerLeft,
//             padding: EdgeInsets.symmetric(horizontal: 1.w),
//             child: Text(
//               widget.controller.text.isEmpty
//                   ? "Select Date"
//                   : widget.controller.text,
//               style: AppTextStyle.small(
//                 size: 11.sp,
//                 color: AppColors.black,
//                 weight: FontWeight.w400,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   BoxDecoration _box() {
//     return BoxDecoration(
//       border: Border.all(color: AppColors.divider),
//       borderRadius: BorderRadius.circular(3),
//       color: AppColors.greyCard,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/utils/custom_date_range_picker.dart';
import 'package:sizer/sizer.dart';

class InputDate extends StatefulWidget {
  final String label;
  final TextEditingController fromController;
  final TextEditingController toController;
  final bool isFrom;

  const InputDate({
    super.key,
    required this.label,
    required this.fromController,
    required this.toController,
    this.isFrom = false,
  });

  @override
  State<InputDate> createState() => _InputDateState();
}

class _InputDateState extends State<InputDate> {
  @override
  void initState() {
    super.initState();
    // Listen to both controllers so widget rebuilds when either changes
    widget.fromController.addListener(_rebuild);
    widget.toController.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.fromController.removeListener(_rebuild);
    widget.toController.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  String get _displayText {
    final text = widget.isFrom
        ? widget.fromController.text
        : widget.toController.text;
    return text.isEmpty ? 'Select Date' : text;
  }

  void _openPicker() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (_) => CustomDateRangePicker(
        initialFromDate: _parse(widget.fromController.text),
        initialToDate: _parse(widget.toController.text),
        onRangeSelected: (from, to) {
          // No setState needed here — listeners handle it
          widget.fromController.text = DateFormat('dd MMM yyyy').format(from);
          widget.toController.text = DateFormat('dd MMM yyyy').format(to);
        },
      ),
    );
  }

  DateTime? _parse(String text) {
    try {
      return text.isEmpty ? null : DateFormat('dd MMM yyyy').parse(text);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyle.small(
            size: 11.sp,
            color: AppColors.black,
            weight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.3.h),
        GestureDetector(
          onTap: _openPicker,
          child: Container(
            height: 5.2.h,
            decoration: _box(),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Text(
              _displayText,
              style: AppTextStyle.small(
                size: 11.sp,
                color: AppColors.black,
                weight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      border: Border.all(color: AppColors.divider),
      borderRadius: BorderRadius.circular(3),
      color: AppColors.greyCard,
    );
  }
}
