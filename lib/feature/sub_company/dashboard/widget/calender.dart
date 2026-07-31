import 'package:Odit_CRM/core/theme/app_colors.dart';
import 'package:Odit_CRM/core/theme/app_theme.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/widget/calender.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// enum CalendarMode { single, range, both }

// class CalendarResult {
//   final DateTime from;
//   final DateTime to;
//   final bool isRange;

//   const CalendarResult({
//     required this.from,
//     required this.to,
//     required this.isRange,
//   });
// }

Future<CalendarResult?> showCustomCalendarDialog(
  BuildContext context, {
  CalendarResult?
  initialResult, // ← was `initialDate`; now carries single OR range
  CalendarMode mode = CalendarMode.both,
}) async {
  return showDialog<CalendarResult>(
    context: context,
    builder: (_) => _CalendarDialog(initialResult: initialResult, mode: mode),
  );
}

class _CalendarDialog extends StatefulWidget {
  final CalendarResult? initialResult;
  final CalendarMode mode;

  const _CalendarDialog({this.initialResult, this.mode = CalendarMode.both});

  @override
  State<_CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<_CalendarDialog> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _first;
  DateTime? _second;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialResult;
    if (initial != null) {
      // Reopening: restore previous selection (single date or range) exactly.
      _first = initial.from;
      _second = initial.isRange ? initial.to : null;
      _currentMonth = DateTime(initial.from.year, initial.from.month);
    } else {
      // Fresh open: nothing selected, nothing highlighted.
      _first = null;
      _second = null;
      _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    }
  }

  // ── helpers ────────────────────────────────────────────────────────────────
  // (unchanged: _daysInMonth, _same, _rangeFrom, _rangeTo, _isStart, _isEnd,
  //  _inRange, _isSelected — all already null-safe on _first/_second)

  List<DateTime> _daysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final offset = firstDay.weekday % 7;
    final before = List.generate(
      offset,
      (i) => firstDay.subtract(Duration(days: offset - i)),
    );
    final inMonth = List.generate(
      DateTime(month.year, month.month + 1, 0).day,
      (i) => DateTime(month.year, month.month, i + 1),
    );
    final all = [...before, ...inMonth];
    while (all.length % 7 != 0) {
      all.add(all.last.add(const Duration(days: 1)));
    }
    return all;
  }

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime get _rangeFrom =>
      (_second != null && _second!.isBefore(_first!)) ? _second! : _first!;
  DateTime get _rangeTo =>
      (_second != null && _second!.isBefore(_first!)) ? _first! : _second!;

  bool _isStart(DateTime d) => _first != null && _same(d, _rangeFrom);
  bool _isEnd(DateTime d) =>
      _second != null && _same(d, _rangeTo) && !_same(_rangeFrom, _rangeTo);
  bool _inRange(DateTime d) {
    if (_second == null) return false;
    return d.isAfter(_rangeFrom) && d.isBefore(_rangeTo);
  }

  bool _isSelected(DateTime d) =>
      (_first != null && _same(d, _first!)) ||
      (_second != null && _same(d, _second!));

  // ── tap logic — unchanged, mode `both` already gives single+range in one dialog

  void _onTap(DateTime day) {
    setState(() {
      switch (widget.mode) {
        case CalendarMode.single:
          _first = day;
          _second = null;
          break;

        case CalendarMode.range:
          if (_first == null || _second != null) {
            _first = day;
            _second = null;
          } else {
            if (_same(day, _first!)) return;
            _second = day;
          }
          break;

        case CalendarMode.both:
          if (_first == null) {
            _first = day;
          } else if (_second == null) {
            if (_same(day, _first!)) {
              _first = null;
            } else {
              _second = day;
            }
          } else {
            _first = day;
            _second = null;
          }
          break;
      }
    });
  }

  String get _label {
    switch (widget.mode) {
      case CalendarMode.single:
        if (_first == null) return 'Select a date';
        return DateFormat('dd MMM yyyy').format(_first!);

      case CalendarMode.range:
        if (_first == null) return 'Select start date';
        if (_second == null) return 'Select end date';
        return '${DateFormat('dd MMM').format(_rangeFrom)} → '
            '${DateFormat('dd MMM yyyy').format(_rangeTo)}';

      case CalendarMode.both:
        if (_first == null) return 'Select a date';
        if (_second == null) return DateFormat('dd MMM yyyy').format(_first!);
        return '${DateFormat('dd MMM').format(_rangeFrom)} → '
            '${DateFormat('dd MMM yyyy').format(_rangeTo)}';
    }
  }

  bool get _canConfirm {
    if (widget.mode == CalendarMode.range)
      return _first != null && _second != null;
    return _first != null;
  }

  void _confirm() {
    if (!_canConfirm) return;
    final isRange = _second != null && !_same(_first!, _second!);
    Navigator.pop(
      context,
      CalendarResult(
        from: _rangeFrom,
        to: isRange ? _rangeTo : _first!,
        isRange: isRange,
      ),
    );
  }

  void _prev() => setState(() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
  });

  void _next() => setState(() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
  });

  // ── build methods below are 100% unchanged from your original file ─────────
  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(_currentMonth);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTopBar(),
            _buildSelectionLabel(),
            _buildWeekdayRow(),
            _buildGrid(days),
            const SizedBox(height: 8),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: const BoxDecoration(
        color: AppThemeColors.appPrimaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _prev,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat.MMMM().format(_currentMonth),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _currentMonth.year.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _next,
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionLabel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFFF0F4FF),
      child: Text(
        _label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          // color: Color(0xFF1E3A5F),
          color: AppThemeColors.appPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildWeekdayRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
            .map(
              (d) => SizedBox(
                width: 36,
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildGrid(List<DateTime> days) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: days.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 4,
          crossAxisSpacing: 0,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, i) => _buildDay(days[i]),
      ),
    );
  }

  Widget _buildDay(DateTime day) {
    final inMonth = day.month == _currentMonth.month;
    final isStart = _isStart(day);
    final isEnd = _isEnd(day);
    final inRange = _inRange(day);
    final isHighlighted = _isSelected(day);

    BorderRadius? rangeBg;
    if (isStart && _second != null) {
      rangeBg = const BorderRadius.horizontal(left: Radius.circular(20));
    } else if (isEnd) {
      rangeBg = const BorderRadius.horizontal(right: Radius.circular(20));
    }

    return GestureDetector(
      onTap: inMonth ? () => _onTap(day) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: inRange
              ? const Color(0xFF1E3A5F).withOpacity(0.08)
              : Colors.transparent,
          borderRadius: rangeBg ?? BorderRadius.zero,
        ),
        child: Container(
          // margin: const EdgeInsets.symmetric(vertical: 5),
          // width: 50,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            color: isHighlighted
                ? AppThemeColors.appPrimaryColor
                : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Text(
            day.day.toString(),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w400,
              color: isHighlighted
                  ? Colors.white
                  : inMonth
                  ? Colors.black87
                  : Colors.grey.withOpacity(0.35),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF1E3A5F)),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeColors.appPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _canConfirm ? _confirm : null,
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }
}
