import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:yunLife/clendar/utils.dart';
import 'package:yunLife/setting.dart';

class clendarPage extends StatefulWidget {
  @override
  clendarPageState createState() => clendarPageState();
}

class clendarPageState extends State<clendarPage> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    fetchEventsFromMultipleApis().then((_) {
      setState(() {
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    });
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  Future<void> _addEvent(String eventTitle) async {
    if (_selectedDay != null) {
      final response = await http.post(
        Uri.parse('http://yunlifeserver.glitch.me/userdata_upload'), 
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          '學號': 'B11023042', 
          '日期': '${_selectedDay!.year}-${_selectedDay!.month}-${_selectedDay!.day}', 
          '事件': eventTitle,
        }),
      );

      if (response.statusCode == 201) {
        // 成功添加事件
        setState(() {
          kEvents[_selectedDay!]!.add(Event(eventTitle));
          _selectedEvents.value = _getEventsForDay(_selectedDay!);
        });
      } else {
        // 处理添加事件失败
        print('Failed to add event: ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            onDaySelected: _onDaySelected,
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        title: Text('${value[index]}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final String? eventTitle = await _showAddEventDialog(context);
          if (eventTitle != null) {
            _addEvent(eventTitle);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _showAddEventDialog(BuildContext context) async {
    String? eventTitle;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController titleController = TextEditingController();
        return AlertDialog(
          title: const Text('新增事件'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: '事件名稱'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                eventTitle = titleController.text;
                Navigator.of(context).pop();
              },
              child: const Text('新增'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
    return eventTitle;
  }
}
