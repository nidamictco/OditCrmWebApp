
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// /// Result returned from [showCalendarDialog].
// /// If only one date was selected, [from] == [to] == that date and [isRange] is false.
// /// If two dates were selected, [isRange] is true.
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

// /// Opens the smart calendar dialog directly — no mode-selection step.
// /// The user taps once for a single date, taps a second date for a range.
// // Future<CalendarResult?> showCalendarDialog(BuildContext context) async {
// //   return showDialog<CalendarResult>(
// //     context: context,
// //     builder: (_) => const _CalendarDialog(),
// //   );
// // }
// Future<CalendarResult?> showCalendarDialog(
//   BuildContext context, {
//   DateTime? initialDate,
// }) async {
//   return showDialog<CalendarResult>(
//     context: context,
//     builder: (_) => _CalendarDialog(
//       initialDate: initialDate,
//     ),
//   );
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Internal dialog
// // ─────────────────────────────────────────────────────────────────────────────

// class _CalendarDialog extends StatefulWidget {
//   final DateTime? initialDate;

//   const _CalendarDialog({
//     this.initialDate,
//   });

//   @override
//   State<_CalendarDialog> createState() => _CalendarDialogState();
// }

// class _CalendarDialogState extends State<_CalendarDialog> {
//   DateTime _currentMonth = DateTime.now();
//   DateTime? _first;  
//   DateTime? _second; 

//   @override
// void initState() {
//   super.initState();

//   if (widget.initialDate != null) {
//     _first = widget.initialDate;

//     _currentMonth = DateTime(
//       widget.initialDate!.year,
//       widget.initialDate!.month,
//     );
//   } else {
//     _first = DateTime.now(); // Highlight today

//     _currentMonth = DateTime(
//       DateTime.now().year,
//       DateTime.now().month,
//     );
//   }
// }

//   // ── helpers ────────────────────────────────────────────────────────────────

//   List<DateTime> _daysInMonth(DateTime month) {
//     final firstDay = DateTime(month.year, month.month, 1);
//     final offset = firstDay.weekday % 7; // Sun = 0

//     final before = List.generate(
//       offset,
//       (i) => firstDay.subtract(Duration(days: offset - i)),
//     );
//     final inMonth = List.generate(
//       DateTime(month.year, month.month + 1, 0).day,
//       (i) => DateTime(month.year, month.month, i + 1),
//     );
//     final all = [...before, ...inMonth];
//     while (all.length % 7 != 0) {
//       all.add(all.last.add(const Duration(days: 1)));
//     }
//     return all;
//   }

//   bool _same(DateTime a, DateTime b) =>
//       a.year == b.year && a.month == b.month && a.day == b.day;

//   DateTime get _rangeFrom =>
//       (_second != null && _second!.isBefore(_first!)) ? _second! : _first!;
//   DateTime get _rangeTo =>
//       (_second != null && _second!.isBefore(_first!)) ? _first! : _second!;

//   bool _isStart(DateTime d) => _first != null && _same(d, _rangeFrom);
//   bool _isEnd(DateTime d) =>
//       _second != null && _same(d, _rangeTo) && !_same(_rangeFrom, _rangeTo);
//   bool _inRange(DateTime d) {
//     if (_second == null) return false;
//     return d.isAfter(_rangeFrom) && d.isBefore(_rangeTo);
//   }

//   bool _isSelected(DateTime d) =>
//       (_first != null && _same(d, _first!)) ||
//       (_second != null && _same(d, _second!));

//   // ── tap logic ──────────────────────────────────────────────────────────────

//   void _onTap(DateTime day) {
//     setState(() {
//       if (_first == null) {
//         // Nothing selected yet
//         _first = day;
//       } else if (_second == null) {
//         if (_same(day, _first!)) {
//           // Tap same day → deselect
//           _first = null;
//         } else {
//           // Second tap → range
//           _second = day;
//         }
//       } else {
//         // Already have a range → reset and start fresh
//         _first = day;
//         _second = null;
//       }
//     });
//   }

//   // ── label ──────────────────────────────────────────────────────────────────

//   String get _label {
//     if (_first == null) return 'Select a date';
//     if (_second == null) return DateFormat('dd MMM yyyy').format(_first!);
//     return '${DateFormat('dd MMM').format(_rangeFrom)} → '
//         '${DateFormat('dd MMM yyyy').format(_rangeTo)}';
//   }

//   bool get _canConfirm => _first != null;

//   // ── confirm ────────────────────────────────────────────────────────────────

//   void _confirm() {
//     if (_first == null) return;
//     final isRange = _second != null && !_same(_first!, _second!);
//     Navigator.pop(
//       context,
//       CalendarResult(
//         from: _rangeFrom,
//         to: isRange ? _rangeTo : _first!,
//         isRange: isRange,
//       ),
//     );
//   }

//   // ── navigation ─────────────────────────────────────────────────────────────

//   void _prev() => setState(() {
//         _currentMonth =
//             DateTime(_currentMonth.year, _currentMonth.month - 1);
//       });

//   void _next() => setState(() {
//         _currentMonth =
//             DateTime(_currentMonth.year, _currentMonth.month + 1);
//       });

//   // ── build ──────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final days = _daysInMonth(_currentMonth);

//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       child: SizedBox(
//         width: 320,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildTopBar(),
//             _buildSelectionLabel(),
//             _buildWeekdayRow(),
//             _buildGrid(days),
//             const SizedBox(height: 8),
//             _buildActions(),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── top bar ────────────────────────────────────────────────────────────────

//   Widget _buildTopBar() {
//     return Container(
//       height: 52,
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       decoration: const BoxDecoration(
//         color: Color(0xFF1E3A5F),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: _prev,
//             icon: const Icon(Icons.chevron_left, color: Colors.white),
//           ),
//           Expanded(
//             child: Center(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     DateFormat.MMMM().format(_currentMonth),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   Text(
//                     _currentMonth.year.toString(),
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontWeight: FontWeight.w500,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           IconButton(
//             onPressed: _next,
//             icon: const Icon(Icons.chevron_right, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── selection label ────────────────────────────────────────────────────────

//   Widget _buildSelectionLabel() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       color: const Color(0xFFF0F4FF),
//       child: Text(
//         _label,
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//           fontSize: 12,
//           color: Color(0xFF1E3A5F),
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   // ── weekday header ─────────────────────────────────────────────────────────

//   Widget _buildWeekdayRow() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
//             .map(
//               (d) => SizedBox(
//                 width: 36,
//                 child: Center(
//                   child: Text(
//                     d,
//                     style: const TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black54,
//                     ),
//                   ),
//                 ),
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }

//   // ── days grid ──────────────────────────────────────────────────────────────

//   Widget _buildGrid(List<DateTime> days) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: days.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 7,
//           mainAxisSpacing: 4,
//           crossAxisSpacing: 0,
//           childAspectRatio: 1,
//         ),
//         itemBuilder: (_, i) => _buildDay(days[i]),
//       ),
//     );
//   }

//   Widget _buildDay(DateTime day) {
//     final inMonth = day.month == _currentMonth.month;
//     final isStart = _isStart(day);
//     final isEnd = _isEnd(day);
//     final inRange = _inRange(day);
//     final isHighlighted = _isSelected(day);

//     // Range highlight background (pill between start & end)
//     BorderRadius? rangeBg;
//     if (isStart && _second != null) {
//       rangeBg = const BorderRadius.horizontal(left: Radius.circular(20));
//     } else if (isEnd) {
//       rangeBg = const BorderRadius.horizontal(right: Radius.circular(20));
//     }

//     return GestureDetector(
//       onTap: inMonth ? () => _onTap(day) : null,
//       child: Container(
//         decoration: BoxDecoration(
//           color: inRange
//               ? const Color(0xFF1E3A5F).withOpacity(0.08)
//               : Colors.transparent,
//           borderRadius: rangeBg ?? BorderRadius.zero,
//         ),
//         child: Container(
//           margin: const EdgeInsets.all(2),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: isHighlighted
//                 ? const Color(0xFF1E3A5F)
//                 : Colors.transparent,
//           ),
//           alignment: Alignment.center,
//           child: Text(
//             day.day.toString(),
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight:
//                   isHighlighted ? FontWeight.w700 : FontWeight.w400,
//               color: isHighlighted
//                   ? Colors.white
//                   : inMonth
//                       ? Colors.black87
//                       : Colors.grey.withOpacity(0.35),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── action buttons ─────────────────────────────────────────────────────────

//   Widget _buildActions() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(color: Color(0xFF1E3A5F)),
//             ),
//           ),
//           const SizedBox(width: 8),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF1E3A5F),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: _canConfirm ? _confirm : null,
//             child: const Text('Select'),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum CalendarMode { single, range, both }

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

Future<CalendarResult?> showCalendarDialog(
  BuildContext context, {
  DateTime? initialDate,
  CalendarMode mode = CalendarMode.both, // ← new param, default = both
}) async {
  return showDialog<CalendarResult>(
    context: context,
    builder: (_) => _CalendarDialog(
      initialDate: initialDate,
      mode: mode,
    ),
  );
}

class _CalendarDialog extends StatefulWidget {
  final DateTime? initialDate;
  final CalendarMode mode;

  const _CalendarDialog({
    this.initialDate,
    this.mode = CalendarMode.both,
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
      _first = DateTime.now();
      _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    }
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

  // ── tap logic — respects mode ──────────────────────────────────────────────

  void _onTap(DateTime day) {
    setState(() {
      switch (widget.mode) {
        case CalendarMode.single:
          // Always just pick one date
          _first = day;
          _second = null;
          break;

        case CalendarMode.range:
          // Must pick two dates — first tap sets start, second sets end
          if (_first == null || _second != null) {
            // Start fresh
            _first = day;
            _second = null;
          } else {
            if (_same(day, _first!)) return; // ignore tapping same day
            _second = day;
          }
          break;

        case CalendarMode.both:
          // Original behavior: single tap = single date, second tap = range
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

  // ── can confirm — range mode needs both dates ──────────────────────────────

  bool get _canConfirm {
    if (widget.mode == CalendarMode.range) return _first != null && _second != null;
    return _first != null;
  }

  // ── confirm ────────────────────────────────────────────────────────────────

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

  // ── build — unchanged layout ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(_currentMonth);
    return Dialog(backgroundColor: Colors.white,
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
            color: isHighlighted ? const Color(0xFF1E3A5F) : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Text(
            day.day.toString(),
            style: TextStyle(
              fontSize: 12,
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