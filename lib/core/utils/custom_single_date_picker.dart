import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';

class CustomSingleDatePicker extends StatefulWidget {
  final String title;
  final DateTime? initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final void Function(DateTime selectedDate) onDateSelected;

  const CustomSingleDatePicker({
    super.key,
    required this.title,
    this.initialDate,
    this.minDate,
    this.maxDate,
    required this.onDateSelected,
  });

  @override
  State<CustomSingleDatePicker> createState() => _CustomSingleDatePickerState();
}

class _CustomSingleDatePickerState extends State<CustomSingleDatePicker> {
  DateTime? _selectedDate;
  final DateRangePickerController _pickerController =
      DateRangePickerController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _pickerController.selectedDate = _selectedDate;
  }

  @override
  void dispose() {
    _pickerController.dispose();
    super.dispose();
  }

  String _formatHeaderDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return DateFormat('EEEE, d MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── MODERN GRADIENT HEADER ─────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: AppColors.gradientBlue),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title.toUpperCase(),
                    style: AppTextStyle.small(
                      color: AppColors.white.withOpacity(0.7),
                      weight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, -0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                    child: Text(
                      _formatHeaderDate(_selectedDate),
                      key: ValueKey<String>(
                        _selectedDate?.toIso8601String() ?? 'empty',
                      ),
                      style: AppTextStyle.heading(
                        color: AppColors.white,
                        fontSize: 16,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── CALENDAR BODY ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SfDateRangePicker(
                controller: _pickerController,
                selectionMode: DateRangePickerSelectionMode.single,
                backgroundColor: AppColors.white,
                minDate: widget.minDate,
                maxDate: widget.maxDate,
                showNavigationArrow: true,
                headerStyle: DateRangePickerHeaderStyle(
                  backgroundColor: AppColors.white,
                  textAlign: TextAlign.center,
                  textStyle: AppTextStyle.medium(
                    fontSize: 14,
                    color: AppColors.black,
                    weight: FontWeight.w600,
                  ),
                ),
                monthCellStyle: DateRangePickerMonthCellStyle(
                  textStyle: AppTextStyle.medium(
                    fontSize: 14,
                    color: AppColors.black,
                    weight: FontWeight.w500,
                  ),
                  todayTextStyle: AppTextStyle.medium(
                    fontSize: 14,
                    color: AppColors.primary,
                    weight: FontWeight.bold,
                  ),
                  disabledDatesTextStyle: AppTextStyle.medium(
                    fontSize: 14,
                    color: AppColors.lightGrey,
                  ),
                ),
                yearCellStyle: DateRangePickerYearCellStyle(
                  textStyle: AppTextStyle.medium(
                    fontSize: 14,
                    color: AppColors.black,
                    weight: FontWeight.w500,
                  ),
                  todayTextStyle: AppTextStyle.medium(
                    fontSize: 14,
                    color: AppColors.primary,
                    weight: FontWeight.bold,
                  ),
                  disabledDatesTextStyle: AppTextStyle.medium(
                    fontSize: 14,
                    color: AppColors.lightGrey,
                  ),
                ),
                selectionColor: AppColors.primary,
                todayHighlightColor: AppColors.primary,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  if (args.value is DateTime) {
                    setState(() {
                      _selectedDate = args.value as DateTime;
                    });
                  }
                },
              ),
            ),

            const Divider(height: 1, color: AppColors.divider),

            // ── FOOTER ACTIONS ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.medium(
                        color: AppColors.grey,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectedDate == null
                        ? null
                        : () {
                            widget.onDateSelected(_selectedDate!);
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Apply',
                      style: AppTextStyle.medium(
                        color: AppColors.white,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
