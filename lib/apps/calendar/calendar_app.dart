import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  State<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  DateTime _selectedDay = DateTime.now();

  // TODO: Buraya etkinlik oluşturma gelebilir.

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          TableCalendar<void>(
            rowHeight: 70,
            locale: "en_US",
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(now.year + 10, 12, 31),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (day, _) => setState(() => _selectedDay = day),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        ],
      ),
    );
  }
}
