import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class CalendarGrid extends StatelessWidget {
  CalendarGrid({super.key});

  final List<Map<String, dynamic>> data = List.generate(35, (index) {
    return {
      "day": index + 1,
      "event": index % 5 == 0 ? "FollowUp: ${index + 1}" : null
    };
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: data.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final item = data[index];
        return CalendarCell(
          day: item["day"],
          event: item["event"],
          isSelected: item["day"] == 25,
        );
      },
    );
  }
}



class CalendarCell extends StatelessWidget {
  final int day;
  final String? event;
  final bool isSelected;

  const CalendarCell({
    super.key,
    required this.day,
    this.event,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(0.2.w),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blueGrey.withOpacity(0.2)
            : Colors.transparent,
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(1.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$day",
              style: AppTextStyle.small(),
            ),
            const Spacer(),

            if (event != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    event!,
                    style: AppTextStyle.small(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}