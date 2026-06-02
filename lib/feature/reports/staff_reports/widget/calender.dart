
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// enum CalendarPickMode { single, range }

// Future<({DateTime? single, DateTime? from, DateTime? to})?> showCalendarDialog(
//   BuildContext context, {
//   CalendarPickMode mode = CalendarPickMode.single,
// }) async {
//   return showDialog(
//     context: context,
//     builder: (context) => _CalendarDialog(mode: mode),
//   );
// }

// class _CalendarDialog extends StatefulWidget {
//   final CalendarPickMode mode;
//   const _CalendarDialog({required this.mode});

//   @override
//   State<_CalendarDialog> createState() => _CalendarDialogState();
// }

// class _CalendarDialogState extends State<_CalendarDialog> {
//   DateTime currentMonth = DateTime.now();
//   DateTime? selectedDate;
//   DateTime? rangeStart;
//   DateTime? rangeEnd;

//   List<DateTime> _daysInMonth(DateTime month) {
//     final firstDay = DateTime(month.year, month.month, 1);
//     final firstWeekday = firstDay.weekday % 7;

//     final daysBefore = List.generate(
//       firstWeekday,
//       (index) => firstDay.subtract(Duration(days: firstWeekday - index)),
//     );

//     final daysInMonth = List.generate(
//       DateTime(month.year, month.month + 1, 0).day,
//       (index) => DateTime(month.year, month.month, index + 1),
//     );

//     final total = [...daysBefore, ...daysInMonth];
//     while (total.length % 7 != 0) {
//       total.add(total.last.add(const Duration(days: 1)));
//     }
//     return total;
//   }

//   void _nextMonth() => setState(() {
//     currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
//   });

//   void _prevMonth() => setState(() {
//     currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
//   });

//   bool _isInRange(DateTime day) {
//     if (rangeStart == null || rangeEnd == null) return false;
//     return day.isAfter(rangeStart!) && day.isBefore(rangeEnd!);
//   }

//   bool _isSameDay(DateTime a, DateTime b) =>
//       a.year == b.year && a.month == b.month && a.day == b.day;

//   bool _isRangeStart(DateTime day) =>
//       rangeStart != null && _isSameDay(day, rangeStart!);

//   bool _isRangeEnd(DateTime day) =>
//       rangeEnd != null && _isSameDay(day, rangeEnd!);

//   void _onDayTapped(DateTime day) {
//     if (widget.mode == CalendarPickMode.single) {
//       setState(() => selectedDate = day);
//       return;
//     }

//     // Range mode
//     setState(() {
//       if (rangeStart == null || (rangeStart != null && rangeEnd != null)) {
//         // Start fresh
//         rangeStart = day;
//         rangeEnd = null;
//       } else {
//         // rangeStart is set, rangeEnd is not
//         if (day.isBefore(rangeStart!)) {
//           rangeEnd = rangeStart;
//           rangeStart = day;
//         } else {
//           rangeEnd = day;
//         }
//       }
//     });
//   }

//   bool get _canConfirm {
//     if (widget.mode == CalendarPickMode.single) return selectedDate != null;
//     return rangeStart != null && rangeEnd != null;
//   }

//   String get _selectionLabel {
//     if (widget.mode == CalendarPickMode.single) {
//       return selectedDate != null
//           ? DateFormat('dd MMM yyyy').format(selectedDate!)
//           : 'Select a date';
//     }
//     if (rangeStart == null) return 'Select start date';
//     if (rangeEnd == null) return '${DateFormat('dd MMM').format(rangeStart!)} → ?';
//     return '${DateFormat('dd MMM').format(rangeStart!)} → ${DateFormat('dd MMM yyyy').format(rangeEnd!)}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final days = _daysInMonth(currentMonth);

//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: SizedBox(
//         width: 320,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ── Header ──────────────────────────────────────
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               height: 52,
//               decoration: const BoxDecoration(
//                 color: Color(0xFF1E3A5F),
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//               ),
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: _prevMonth,
//                     icon: const Icon(Icons.chevron_left, color: Colors.white),
//                   ),
//                   Expanded(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           DateFormat.MMMM().format(currentMonth),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           currentMonth.year.toString(),
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: _nextMonth,
//                     icon: const Icon(Icons.chevron_right, color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),

//             // ── Mode label ───────────────────────────────────
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               color: const Color(0xFFF0F4FF),
//               child: Text(
//                 _selectionLabel,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Color(0xFF1E3A5F),
//                   fontWeight: FontWeight.w500,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),

//             // ── Weekday headers ──────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
//                     .map(
//                       (e) => SizedBox(
//                         width: 36,
//                         child: Center(
//                           child: Text(
//                             e,
//                             style: const TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ),
//                       ),
//                     )
//                     .toList(),
//               ),
//             ),

//             // ── Days grid ────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: days.length,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 7,
//                   mainAxisSpacing: 4,
//                   crossAxisSpacing: 0,
//                   childAspectRatio: 1,
//                 ),
//                 itemBuilder: (context, index) {
//                   final day = days[index];
//                   final isCurrentMonth = day.month == currentMonth.month;
//                   final isStart = _isRangeStart(day);
//                   final isEnd = _isRangeEnd(day);
//                   final inRange = _isInRange(day);
//                   final isSingle = widget.mode == CalendarPickMode.single &&
//                       selectedDate != null &&
//                       _isSameDay(day, selectedDate!);
//                   final isHighlighted = isStart || isEnd || isSingle;

//                   return GestureDetector(
//                     onTap: isCurrentMonth ? () => _onDayTapped(day) : null,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         // Range fill between start and end
//                         color: inRange
//                             ? const Color(0xFF1E3A5F).withOpacity(0.08)
//                             : Colors.transparent,
//                         // Round left cap on start, right cap on end
//                         borderRadius: isStart
//                             ? const BorderRadius.horizontal(
//                                 left: Radius.circular(20))
//                             : isEnd
//                             ? const BorderRadius.horizontal(
//                                 right: Radius.circular(20))
//                             : BorderRadius.zero,
//                       ),
//                       child: Container(
//                         margin: const EdgeInsets.all(2),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: isHighlighted
//                               ? const Color(0xFF1E3A5F)
//                               : Colors.transparent,
//                         ),
//                         alignment: Alignment.center,
//                         child: Text(
//                           day.day.toString(),
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: isHighlighted
//                                 ? FontWeight.w700
//                                 : FontWeight.w400,
//                             color: isHighlighted
//                                 ? Colors.white
//                                 : isCurrentMonth
//                                 ? Colors.black87
//                                 : Colors.grey.withOpacity(0.35),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 8),

//             // ── Action buttons ───────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text(
//                       'Cancel',
//                       style: TextStyle(color: Color(0xFF1E3A5F)),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF1E3A5F),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onPressed: _canConfirm
//                         ? () => Navigator.pop(
//                               context,
//                               (
//                                 single: selectedDate,
//                                 from: rangeStart,
//                                 to: rangeEnd,
//                               ),
//                             )
//                         : null,
//                     child: const Text('Select'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Result returned from [showCalendarDialog].
/// If only one date was selected, [from] == [to] == that date and [isRange] is false.
/// If two dates were selected, [isRange] is true.
class CalendarResult {
  final DateTime from;
  final DateTime to;
  final bool isRange;

  const CalendarResult({
    required this.from,
    required this.to,
    required this.isRange,
  });
}

/// Opens the smart calendar dialog directly — no mode-selection step.
/// The user taps once for a single date, taps a second date for a range.
// Future<CalendarResult?> showCalendarDialog(BuildContext context) async {
//   return showDialog<CalendarResult>(
//     context: context,
//     builder: (_) => const _CalendarDialog(),
//   );
// }
Future<CalendarResult?> showCalendarDialog(
  BuildContext context, {
  DateTime? initialDate,
}) async {
  return showDialog<CalendarResult>(
    context: context,
    builder: (_) => _CalendarDialog(
      initialDate: initialDate,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal dialog
// ─────────────────────────────────────────────────────────────────────────────

class _CalendarDialog extends StatefulWidget {
  final DateTime? initialDate;

  const _CalendarDialog({
    this.initialDate,
  });

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

  if (widget.initialDate != null) {
    _first = widget.initialDate;

    _currentMonth = DateTime(
      widget.initialDate!.year,
      widget.initialDate!.month,
    );
  } else {
    _first = DateTime.now(); // Highlight today

    _currentMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month,
    );
  }
}

  // ── helpers ────────────────────────────────────────────────────────────────

  List<DateTime> _daysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final offset = firstDay.weekday % 7; // Sun = 0

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

  // ── tap logic ──────────────────────────────────────────────────────────────

  void _onTap(DateTime day) {
    setState(() {
      if (_first == null) {
        // Nothing selected yet
        _first = day;
      } else if (_second == null) {
        if (_same(day, _first!)) {
          // Tap same day → deselect
          _first = null;
        } else {
          // Second tap → range
          _second = day;
        }
      } else {
        // Already have a range → reset and start fresh
        _first = day;
        _second = null;
      }
    });
  }

  // ── label ──────────────────────────────────────────────────────────────────

  String get _label {
    if (_first == null) return 'Select a date';
    if (_second == null) return DateFormat('dd MMM yyyy').format(_first!);
    return '${DateFormat('dd MMM').format(_rangeFrom)} → '
        '${DateFormat('dd MMM yyyy').format(_rangeTo)}';
  }

  bool get _canConfirm => _first != null;

  // ── confirm ────────────────────────────────────────────────────────────────

  void _confirm() {
    if (_first == null) return;
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

  // ── navigation ─────────────────────────────────────────────────────────────

  void _prev() => setState(() {
        _currentMonth =
            DateTime(_currentMonth.year, _currentMonth.month - 1);
      });

  void _next() => setState(() {
        _currentMonth =
            DateTime(_currentMonth.year, _currentMonth.month + 1);
      });

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(_currentMonth);

    return Dialog(
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFFF0F4FF),
      child: Text(
        _label,
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
    final isStart = _isStart(day);
    final isEnd = _isEnd(day);
    final inRange = _inRange(day);
    final isHighlighted = _isSelected(day);

    // Range highlight background (pill between start & end)
    BorderRadius? rangeBg;
    if (isStart && _second != null) {
      rangeBg = const BorderRadius.horizontal(left: Radius.circular(20));
    } else if (isEnd) {
      rangeBg = const BorderRadius.horizontal(right: Radius.circular(20));
    }

    return GestureDetector(
      onTap: inMonth ? () => _onTap(day) : null,
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
            color: isHighlighted
                ? const Color(0xFF1E3A5F)
                : Colors.transparent,
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
                  : inMonth
                      ? Colors.black87
                      : Colors.grey.withOpacity(0.35),
            ),
          ),
        ),
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF1E3A5F)),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
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