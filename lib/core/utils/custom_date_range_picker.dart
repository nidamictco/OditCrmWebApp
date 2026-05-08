import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CustomDateRangePicker extends StatefulWidget {
  final DateTime? initialFromDate;
  final DateTime? initialToDate;
  final void Function(DateTime fromDate, DateTime toDate) onRangeSelected;

  const CustomDateRangePicker({
    super.key,
    this.initialFromDate,
    this.initialToDate,
    required this.onRangeSelected,
  });

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  PickerDateRange? _tempRange;

  @override
  void initState() {
    super.initState();
    if (widget.initialFromDate != null && widget.initialToDate != null) {
      _tempRange = PickerDateRange(
        widget.initialFromDate,
        widget.initialToDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        // height: 500,
        width: 500,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              child: SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.range,
                backgroundColor: Colors.white,
                headerStyle: DateRangePickerHeaderStyle(
                  backgroundColor: Colors.indigo.shade900,
                  textStyle: AppTextStyle.medium(
                    color: AppColors.white,
                    weight: FontWeight.w500,
                  ),
                ),
                initialSelectedRange: _tempRange,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  if (args.value is PickerDateRange) {
                    _tempRange = args.value;
                  }
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppTextStyle.medium(
                      color: AppColors.black.withOpacity(0.7),
                      weight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    if (_tempRange?.startDate != null &&
                        _tempRange?.endDate != null) {
                      widget.onRangeSelected(
                        _tempRange!.startDate!,
                        _tempRange!.endDate!,
                      );
                      Navigator.pop(context);
                    } else {
                      // Show snackbar warning
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please select both From and To dates.',
                            style: AppTextStyle.medium(
                              color: AppColors.white,
                              weight: FontWeight.w400,
                            ),
                          ),
                          backgroundColor: Colors.indigo.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Apply',
                    style: AppTextStyle.medium(
                      color: AppColors.white,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
