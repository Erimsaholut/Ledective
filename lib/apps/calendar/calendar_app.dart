import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/game_clock.dart';
import '../../theme/app_theme.dart';
import '../../theme/turkish_dates.dart';

class CalendarEvent {
  const CalendarEvent({
    required this.date,
    required this.title,
    this.userAdded = false,
  });

  final DateTime date;
  final String title;

  /// Events the player created; only these can be deleted.
  final bool userAdded;
}

/// Story events, placed relative to the day the game was first opened.
List<CalendarEvent> storyEvents(GameClock clock, {int? year}) {
  DateTime day(int offset) => clock.daysBeforeFirstOpen(-offset);
  final y = year ?? DateTime.now().year;
  return [
    CalendarEvent(date: day(-7), title: "İzin başlangıcı ✈️"),
    CalendarEvent(date: day(-3), title: "Berat Yılmaz olayı"),
    CalendarEvent(date: day(3), title: "Türkiye'ye dönüş uçuşu"),
    for (final year in [y - 1, y, y + 1])
      CalendarEvent(date: DateTime(year, 4, 10), title: "Polis Haftası"),
  ];
}

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  State<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  static const _prefsKey = 'calendarEvents';

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<CalendarEvent> _userEvents = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored == null || !mounted) return;
    setState(() {
      _userEvents = [
        for (final item in json.decode(stored) as List)
          CalendarEvent(
            date: DateTime.parse(
              (item as Map<String, dynamic>)['date'] as String,
            ),
            title: item['title'] as String,
            userAdded: true,
          ),
      ];
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      json.encode([
        for (final e in _userEvents)
          {'date': e.date.toIso8601String(), 'title': e.title},
      ]),
    );
  }

  List<CalendarEvent> _eventsOn(DateTime day) => [
    ...storyEvents(GameClock.current, year: day.year),
    ..._userEvents,
  ].where((e) => isSameDay(e.date, day)).toList();

  Future<void> _addEvent() async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => const _AddEventDialog(),
    );
    if (title == null) return;
    final day = _selectedDay;
    setState(() {
      _userEvents = [
        ..._userEvents,
        CalendarEvent(
          date: DateTime(day.year, day.month, day.day),
          title: title,
          userAdded: true,
        ),
      ];
    });
    await _save();
  }

  Future<void> _delete(CalendarEvent event) async {
    setState(() => _userEvents = [..._userEvents]..remove(event));
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final events = _eventsOn(_selectedDay);
    const red = AppColors.red;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text(
          "${turkishMonths[_focusedDay.month - 1]} ${_focusedDay.year}",
          style: const TextStyle(
            color: red,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _selectedDay = now;
              _focusedDay = now;
            }),
            child: const Text("Today", style: TextStyle(color: red)),
          ),
          IconButton(
            onPressed: _addEvent,
            tooltip: "Add Event",
            icon: const Icon(Icons.add_rounded, color: red),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<CalendarEvent>(
            rowHeight: 52,
            locale: "en_US",
            startingDayOfWeek: StartingDayOfWeek.monday,
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(now.year + 10, 12, 31),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            eventLoader: _eventsOn,
            onDaySelected: (day, focused) => setState(() {
              _selectedDay = day;
              _focusedDay = focused;
            }),
            onPageChanged: (focused) => setState(() => _focusedDay = focused),
            headerVisible: false,
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) => Center(
                child: Text(
                  turkishWeekdayAbbreviations[day.weekday - 1],
                  style: const TextStyle(
                    color: AppColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: AppColors.secondaryLabel,
                fontSize: 12,
              ),
              weekendStyle: TextStyle(
                color: AppColors.secondaryLabel,
                fontSize: 12,
              ),
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              todayTextStyle: TextStyle(
                color: red,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
              todayDecoration: BoxDecoration(shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(
                color: red,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
              defaultTextStyle: TextStyle(fontSize: 17),
              weekendTextStyle: TextStyle(
                fontSize: 17,
                color: AppColors.secondaryLabel,
              ),
              markerDecoration: BoxDecoration(
                color: AppColors.secondaryLabel,
                shape: BoxShape.circle,
              ),
              markerSize: 5,
            ),
          ),
          const Divider(),
          Expanded(
            child: ColoredBox(
              color: AppColors.background,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    longTurkishDate(_selectedDay),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (events.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        "No events",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.secondaryLabel),
                      ),
                    ),
                  for (final event in events)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                color: event.userAdded ? AppColors.blue : red,
                              ),
                              Expanded(
                                child: ListTile(
                                  title: Text(event.title),
                                  subtitle: const Text("tüm gün"),
                                  trailing: event.userAdded
                                      ? IconButton(
                                          tooltip: "Delete",
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                          ),
                                          onPressed: () => _delete(event),
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddEventDialog extends StatefulWidget {
  const _AddEventDialog();

  @override
  State<_AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<_AddEventDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) Navigator.pop(context, title);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Event"),
      content: TextField(
        controller: _controller,
        autofocus: true,
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(labelText: "Title"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(onPressed: _submit, child: const Text("Add")),
      ],
    );
  }
}
