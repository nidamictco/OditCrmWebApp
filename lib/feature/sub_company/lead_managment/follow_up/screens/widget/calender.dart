import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Odit_CRM/feature/sub_company/reports/staff_reports/widget/calender.dart';

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

Future<CalendarResult?> showCalendarDialogUsingTimePicker(
  BuildContext context, {
  DateTime? initialDate,
  CalendarMode mode = CalendarMode.both,
  bool showTimePicker = false,
  DateTime? minDate, // ← dates before this are disabled
}) async {
  return showDialog<CalendarResult>(
    context: context,
    builder: (_) => _CalendarDialog(
      initialDate: initialDate,
      mode: mode,
      showTimePicker: showTimePicker,
      minDate: minDate,
    ),
  );
}

class _CalendarDialog extends StatefulWidget {
  final DateTime? initialDate;
  final CalendarMode mode;
  final bool showTimePicker;
  final DateTime? minDate;

  const _CalendarDialog({
    this.initialDate,
    this.mode = CalendarMode.both,
    this.showTimePicker = false,
    this.minDate,
  });

  @override
  State<_CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<_CalendarDialog> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _first;
  DateTime? _second;

  // Time state
  late int _hour;
  late int _minute;
  late bool _isAm;

  @override
  void initState() {
    super.initState();

    final init = widget.initialDate ?? DateTime.now();
    _first = init;
    _currentMonth = DateTime(init.year, init.month);

    // Init time from initialDate or now
    final now = widget.initialDate ?? DateTime.now();
    _isAm = now.hour < 12;
    _hour = now.hour == 0
        ? 12
        : now.hour > 12
            ? now.hour - 12
            : now.hour;
    _minute = now.minute;
  }

  // ── helpers ────────────────────────────────────────────────────────────────

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

  bool _isDisabled(DateTime day) {
    if (widget.minDate == null) return false;
    final min = DateTime(
      widget.minDate!.year,
      widget.minDate!.month,
      widget.minDate!.day,
    );
    final d = DateTime(day.year, day.month, day.day);
    return d.isBefore(min);
  }

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

  // ── tap logic ──────────────────────────────────────────────────────────────

  void _onTap(DateTime day) {
    if (_isDisabled(day)) return;
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

  // ── label ──────────────────────────────────────────────────────────────────

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

  // ── confirm ────────────────────────────────────────────────────────────────

  void _confirm() {
    if (!_canConfirm) return;

    // Merge selected time into the date
    DateTime _withTime(DateTime date) {
      final h24 = _isAm
          ? (_hour == 12 ? 0 : _hour)
          : (_hour == 12 ? 12 : _hour + 12);
      return DateTime(date.year, date.month, date.day, h24, _minute);
    }

    final isRange = _second != null && !_same(_first!, _second!);
    Navigator.pop(
      context,
      CalendarResult(
        from: widget.showTimePicker ? _withTime(_rangeFrom) : _rangeFrom,
        to: isRange
            ? (widget.showTimePicker ? _withTime(_rangeTo) : _rangeTo)
            : (widget.showTimePicker ? _withTime(_first!) : _first!),
        isRange: isRange,
      ),
    );
  }

  void _prev() {
    // Don't go before minDate's month
    final prevMonth =
        DateTime(_currentMonth.year, _currentMonth.month - 1);
    if (widget.minDate != null) {
      final minMonth =
          DateTime(widget.minDate!.year, widget.minDate!.month);
      if (prevMonth.isBefore(minMonth)) return;
    }
    setState(() => _currentMonth = prevMonth);
  }

  void _next() => setState(
        () => _currentMonth =
            DateTime(_currentMonth.year, _currentMonth.month + 1),
      );

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(_currentMonth);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTopBar(),
            _buildSelectionLabel(),
            _buildWeekdayRow(),
            _buildGrid(days),
            if (widget.showTimePicker) ...[
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _buildTimePicker(),
            ],
            const SizedBox(height: 8),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  // ── top bar ────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A5F),
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
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _currentMonth.year.toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
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

  // ── selection label ────────────────────────────────────────────────────────

  Widget _buildSelectionLabel() {
    final timeStr = widget.showTimePicker
        ? '  ${_hour.toString().padLeft(2, '0')}:'
              '${_minute.toString().padLeft(2, '0')} '
              '${_isAm ? 'AM' : 'PM'}'
        : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFFF0F4FF),
      child: Text(
        _label + timeStr,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF1E3A5F),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── weekday header ─────────────────────────────────────────────────────────

  Widget _buildWeekdayRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
            .map((d) => SizedBox(
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
                ))
            .toList(),
      ),
    );
  }

  // ── days grid ──────────────────────────────────────────────────────────────

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
    final disabled = _isDisabled(day);
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
      onTap: (inMonth && !disabled) ? () => _onTap(day) : null,
      child: Container(
        decoration: BoxDecoration(
          color: inRange
              ? const Color(0xFF1E3A5F).withOpacity(0.08)
              : Colors.transparent,
          borderRadius: rangeBg ?? BorderRadius.zero,
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isHighlighted ? const Color(0xFF1E3A5F) : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Text(
            day.day.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  isHighlighted ? FontWeight.w700 : FontWeight.w400,
              color: isHighlighted
                  ? Colors.white
                  : disabled
                      ? Colors.grey.withOpacity(0.3) // ← disabled style
                      : inMonth
                          ? Colors.black87
                          : Colors.grey.withOpacity(0.35),
            ),
          ),
        ),
      ),
    );
  }

  // ── time picker ────────────────────────────────────────────────────────────

  Widget _buildTimePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, size: 18, color: Color(0xFF1E3A5F)),
          const SizedBox(width: 10),

          // Hour
          _TimeSpinner(
            value: _hour,
            min: 1,
            max: 12,
            onChanged: (v) => setState(() => _hour = v),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A5F),
              ),
            ),
          ),

          // Minute
          _TimeSpinner(
            value: _minute,
            min: 0,
            max: 59,
            onChanged: (v) => setState(() => _minute = v),
            padded: true,
          ),

          const SizedBox(width: 12),

          // AM/PM toggle
          GestureDetector(
            onTap: () => setState(() => _isAm = !_isAm),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isAm ? 'AM' : 'PM',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── action buttons ─────────────────────────────────────────────────────────

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF1E3A5F))),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _canConfirm ? _confirm : null,
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }
}

// ── Time spinner widget ────────────────────────────────────────────────────────

class _TimeSpinner extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final bool padded;
  final ValueChanged<int> onChanged;

  const _TimeSpinner({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.padded = false,
  });

  String get _display =>
      padded ? value.toString().padLeft(2, '0') : value.toString();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Up arrow
        GestureDetector(
          onTap: () => onChanged(value >= max ? min : value + 1),
          child: const Icon(Icons.keyboard_arrow_up,
              size: 20, color: Color(0xFF1E3A5F)),
        ),

        // Value box
        Container(
          width: 40,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF1E3A5F).withOpacity(0.3)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _display,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E3A5F),
            ),
          ),
        ),

        // Down arrow
        GestureDetector(
          onTap: () => onChanged(value <= min ? max : value - 1),
          child: const Icon(Icons.keyboard_arrow_down,
              size: 20, color: Color(0xFF1E3A5F)),
        ),
      ],
    );
  }
}