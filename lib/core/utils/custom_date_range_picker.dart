import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

enum _PickStep { from, to }

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
  _PickStep _step = _PickStep.from;
  DateTime? _fromDate;
  DateTime? _toDate;

  final DateRangePickerController _pickerController =
      DateRangePickerController();

  @override
  void initState() {
    super.initState();
    _fromDate = widget.initialFromDate;
    _toDate = widget.initialToDate;
  }

  @override
  void dispose() {
    _pickerController.dispose();
    super.dispose();
  }

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')} / '
        '${d.month.toString().padLeft(2, '0')} / '
        '${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
            // ── Step indicator ──────────────────────────────────────
            _StepIndicator(step: _step),
            const SizedBox(height: 10),

            // ── From / To chips ─────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _DateChip(
                    label: 'From',
                    date: _fmt(_fromDate),
                    isActive: _step == _PickStep.from,
                    isSet: _fromDate != null,
                    onTap: () => setState(() => _step = _PickStep.from),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: _DateChip(
                    label: 'To',
                    date: _fmt(_toDate),
                    isActive: _step == _PickStep.to,
                    isSet: _toDate != null,
                    onTap: _fromDate == null
                        ? null // can't jump to "To" before picking "From"
                        : () => setState(() => _step = _PickStep.to),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Calendar ────────────────────────────────────────────
            SfDateRangePicker(
              controller: _pickerController,
              selectionMode: DateRangePickerSelectionMode.single,
              backgroundColor: Colors.white,
              headerStyle: DateRangePickerHeaderStyle(
                backgroundColor: Colors.indigo.shade900,
                textStyle: AppTextStyle.medium(
                  color: AppColors.white,
                  weight: FontWeight.w500,
                ),
              ),
              // Grey-out past dates when picking "To"
              minDate: _step == _PickStep.to ? _fromDate : null,
              initialSelectedDate:
                  _step == _PickStep.from ? _fromDate : _toDate,
              onSelectionChanged:
                  (DateRangePickerSelectionChangedArgs args) {
                if (args.value is! DateTime) return;
                final picked = args.value as DateTime;
                setState(() {
                  if (_step == _PickStep.from) {
                    _fromDate = picked;
                    // Reset toDate if it's now before the new fromDate
                    if (_toDate != null &&
                        _toDate!.isBefore(_fromDate!)) {
                      _toDate = null;
                    }
                    // Auto-advance to "To" step
                    _step = _PickStep.to;
                  } else {
                    _toDate = picked;
                  }
                });
              },
            ),

            // ── Action buttons ──────────────────────────────────────
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
                    if (_fromDate != null && _toDate != null) {
                      widget.onRangeSelected(_fromDate!, _toDate!);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _fromDate == null
                                ? 'Please select a From date.'
                                : 'Please select a To date.',
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

// ── Step indicator ─────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final _PickStep step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(active: step == _PickStep.from, label: '1'),
        Container(width: 32, height: 2, color: Colors.indigo.shade200),
        _dot(active: step == _PickStep.to, label: '2'),
      ],
    );
  }

  Widget _dot({required bool active, required String label}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.indigo.shade700 : Colors.indigo.shade100,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.indigo.shade400,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ── Date chip ──────────────────────────────────────────────────────────────

class _DateChip extends StatelessWidget {
  final String label;
  final String date;
  final bool isActive;
  final bool isSet;
  final VoidCallback? onTap;

  const _DateChip({
    required this.label,
    required this.date,
    required this.isActive,
    required this.isSet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.indigo.shade50
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? Colors.indigo.shade700
                : isSet
                    ? Colors.indigo.shade200
                    : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: isActive ? Colors.indigo.shade700 : Colors.grey,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive
                        ? Colors.indigo.shade700
                        : Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSet ? Colors.black87 : Colors.grey.shade400,
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