import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class CustomCalendar extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final DateTime? initialSelectedDate;
  const CustomCalendar({super.key, this.onDateSelected,this.initialSelectedDate});

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime currentMonth = DateTime.now();
  DateTime? selectedDate;

   @override
  void initState() {
    super.initState();
    selectedDate = widget.initialSelectedDate;
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDay.weekday % 7;

    final daysBefore = List.generate(
      firstWeekday,
      (index) => firstDay.subtract(Duration(days: firstWeekday - index)),
    );

    final daysInMonth = List.generate(
      DateTime(month.year, month.month + 1, 0).day,
      (index) => DateTime(month.year, month.month, index + 1),
    );

    final total = [...daysBefore, ...daysInMonth];

    while (total.length % 7 != 0) {
      total.add(total.last.add(const Duration(days: 1)));
    }

    return total;
  }

  // //  DateTime? selectedDate;

  // @override
  // void initState() {
  //   super.initState();
  //   selectedDate = DateTime.now();
  // }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  void _prevMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(currentMonth);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// 🔺 TOP ARROW
        Positioned(
          top: -6,
          left: 3.w,
          child: Transform.rotate(
            angle: 0.785,
            child: Container(
              width: 12,
              height: 12,
              color: const Color(0xff4A5A8A),
            ),
          ),
        ),

        /// 🔹 MAIN CARD
        Container(
          width: 26.w,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              /// 🔹 HEADER
              Container(
                padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                height: 6.h,
                decoration: const BoxDecoration(
                  color: Color(0xff4A5A8A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _prevMonth,
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat.MMMM().format(currentMonth),
                            style: AppTextStyle.medium(
                              color: Colors.white,
                              weight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            currentMonth.year.toString(),
                            style: AppTextStyle.medium(
                              color: Colors.white,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              /// 🔹 WEEK DAYS
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                      .map(
                        (e) => SizedBox(
                          width: 3.w,
                          child: Center(
                            child: Text(
                              e,
                              style: AppTextStyle.small(
                                weight: FontWeight.w600,
                                size: 10.sp,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              /// 🔹 DAYS GRID
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: days.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final today = DateTime.now();

                    final isCurrentMonth = day.month == currentMonth.month;

                    final isSelected =
                        selectedDate != null &&
                        day.day == selectedDate!.day &&
                        day.month == selectedDate!.month &&
                        day.year == selectedDate!.year;

                    // ✅ Today check
                    final isToday =
                        day.day == today.day &&
                        day.month == today.month &&
                        day.year == today.year;

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedDate = day);
                        widget.onDateSelected?.call(day);
                      },
                      child: Container(
                        // ✅ Priority: selected → today → normal
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primary
                              : isToday
                              ? AppColors.primary.withOpacity(0.12)
                              : Colors.transparent,
                          border: !isSelected && isToday
                              ? Border.all(color: AppColors.primary, width: 1.5)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          day.day.toString(),
                          style: AppTextStyle.small(
                            size: 10.sp,
                            weight: FontWeight.w500,
                            // ✅ Priority: selected → today → current month → outside month
                            color: isSelected
                                ? Colors.white
                                : isToday
                                ? AppColors.primary
                                : isCurrentMonth
                                ? AppColors.black
                                : AppColors.lightGrey.withOpacity(0.6),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 1.h),
            ],
          ),
        ),
      ],
    );
  }
}
