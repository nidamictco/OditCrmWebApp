// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../theme/app_colors.dart';
// import '../theme/app_text_style.dart';
// import 'custom_calender.dart';
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
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'custom_single_date_picker.dart';
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final initialDate = _parse(
      widget.isFrom ? widget.fromController.text : widget.toController.text,
    );
    final minDate = widget.isFrom ? null : _parse(widget.fromController.text);
    final parsedTo = _parse(widget.toController.text);
    final maxDate = widget.isFrom
        ? (parsedTo != null && parsedTo.isBefore(today) ? parsedTo : today)
        : today;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (_) => CustomSingleDatePicker(
        title: widget.label,
        initialDate: initialDate,
        minDate: minDate,
        maxDate: maxDate,
        onDateSelected: (date) {
          final formatted = DateFormat('dd-MM-yyyy').format(date);
          if (widget.isFrom) {
            widget.fromController.text = formatted;
          } else {
            widget.toController.text = formatted;
          }
        },
      ),
    );
  }

  DateTime? _parse(String text) {
    try {
      return text.isEmpty ? null : DateFormat('dd-MM-yyyy').parse(text);
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
          style: AppTextStyle.medium(
            size: 11.5,
            color: AppColors.black,
            weight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 3),
        GestureDetector(
          onTap: _openPicker,
          child: Container(
            height: 35,
            decoration: _box(),
            alignment: Alignment.centerLeft,
            // padding: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.5.w),
                  child: Icon(
                    Icons.calendar_month_outlined,
                    size: 16,
                    color: const Color(0xff4a5d9e),
                  ),
                ),
                SizedBox(width: 0.3.w),
                Expanded(
                  child: Text(
                    _displayText,
                    style: AppTextStyle.small(
                      size: 11.5,
                      color: AppColors.grey,
                      weight: FontWeight.w400,
                    ),
                  ),
                ),
                if (widget.isFrom
                    ? widget.fromController.text.isNotEmpty
                    : widget.toController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      if (widget.isFrom) {
                        widget.fromController.clear();
                      } else {
                        widget.toController.clear();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 4.0,
                      ),
                      child: Icon(Icons.clear, size: 16, color: AppColors.grey),
                    ),
                  ),
                // Padding(
                //   padding: EdgeInsets.only(right: 0.5.w),
                //   child: Icon(
                //     Icons.keyboard_arrow_down,
                //     color: AppColors.grey,
                //     size: 18,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      border: Border.all(color: AppColors.divider),
      borderRadius: BorderRadius.circular(8),
      // color: AppColors.greyCard,
    );
  }
}
