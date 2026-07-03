import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';

enum CalendarType { month, week, day }

class CalendarScreen extends StatefulWidget {
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarType _type = CalendarType.month;
  final EventController _controller = EventController();

  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    /// Sample event (like FOLLOWUP: 44)
    _controller.add(
      CalendarEventData(
        title: "FOLLOWUP: 44",
        date: DateTime.now(),
        color: Colors.green,
      ),
    );
  }

  void _next() {
    setState(() {
      if (_type == CalendarType.month) {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
      } else if (_type == CalendarType.week) {
        _focusedDay = _focusedDay.add(const Duration(days: 7));
      } else {
        _focusedDay = _focusedDay.add(const Duration(days: 1));
      }
    });
  }

  void _previous() {
    setState(() {
      if (_type == CalendarType.month) {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
      } else if (_type == CalendarType.week) {
        _focusedDay = _focusedDay.subtract(const Duration(days: 7));
      } else {
        _focusedDay = _focusedDay.subtract(const Duration(days: 1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: _controller,
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildCalendar()),
          ],
        ),
      ),
    );
  }

  /// 🔷 HEADER (matches your UI)
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          IconButton(
            onPressed: _previous,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(onPressed: _next, icon: const Icon(Icons.chevron_right)),

          ElevatedButton(
            onPressed: () {
              setState(() => _focusedDay = DateTime.now());
            },
            child: const Text("Today"),
          ),

          const Spacer(),

          Text(
            _getTitle(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const Spacer(),

          _viewButton("Month", CalendarType.month),
          _viewButton("Week", CalendarType.week),
          _viewButton("Day", CalendarType.day),
        ],
      ),
    );
  }

  Widget _viewButton(String text, CalendarType type) {
    final isSelected = _type == type;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
          foregroundColor: isSelected ? Colors.white : Colors.black,
        ),
        onPressed: () {
          setState(() => _type = type);
        },
        child: Text(text),
      ),
    );
  }

  String _getTitle() {
    if (_type == CalendarType.month) {
      return "${_focusedDay.month}/${_focusedDay.year}";
    } else if (_type == CalendarType.week) {
      final start = _focusedDay;
      final end = _focusedDay.add(const Duration(days: 6));
      return "${start.day}/${start.month} - ${end.day}/${end.month}";
    } else {
      return "${_focusedDay.day}/${_focusedDay.month}/${_focusedDay.year}";
    }
  }

  /// 🔷 CALENDAR BODY
  Widget _buildCalendar() {
    switch (_type) {
      case CalendarType.month:
        return MonthView(controller: _controller);

      case CalendarType.week:
        return WeekView(
          initialDay: _focusedDay,
          onPageChange: (date, _) => _focusedDay = date,
          eventTileBuilder: _eventTile,
        );

      case CalendarType.day:
        return DayView(
          initialDay: _focusedDay,
          onPageChange: (date, _) => _focusedDay = date,
          eventTileBuilder: _eventTile,
        );
    }
  }

  /// 🔷 EVENT UI (Green FOLLOWUP bar like your screenshot)
  Widget _eventTile(
    DateTime date,
    List<CalendarEventData> events,
    Rect boundary,
    DateTime start,
    DateTime end,
  ) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        events.first.title,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
