import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime today = DateTime.now();

  void _onDaySelected(DateTime day,DateTime focusedDay){
    setState(() {
      today=day;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calendar"),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20,),
        TableCalendar(
          rowHeight: 70,
          locale: "en_US",
          focusedDay: today,
          firstDay: DateTime.utc(2010,1,1),
          lastDay: DateTime.utc(2039,1,1),
          selectedDayPredicate: (day)=>isSameDay(day,today),
          onDaySelected: _onDaySelected,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,titleCentered: true
          ),
        )
        ],

      ),
    );
  }
}
