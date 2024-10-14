import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:yunLife/clendar/clendarEvent.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class clendarPage extends StatefulWidget {
  const clendarPage({super.key});

  @override
  State<clendarPage> createState() => _clendarPageState();
}

class _clendarPageState extends State<clendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<clendarEvent>> events = {};
  final TextEditingController _eventController = TextEditingController();
  late final ValueNotifier<List<clendarEvent>> _selectedEvents;

  @override
  void dispose() {
    _eventController.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://yunlifeserver.glitch.me/clendar'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded =
          json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> dataList = decoded['greetings'] as List<dynamic>;
      getData(dataList);
    } else {
      print('Failed to load data: ${response.body}');
    }
  }

  void getData(List<dynamic> dataList) {
    setState(() {
      final DateFormat formatter = DateFormat('M/d'); // 根据实际日期格式调整
      final int currentYear = DateTime.now().year; // 获取当前年份
      for (var event in dataList) {
        try {
          DateTime parsedDate = formatter.parse(event["活動日期"]);
          DateTime eventDate =
              DateTime(currentYear, parsedDate.month, parsedDate.day); // 设置年份
          String eventName = event["活動"];
          print('Parsed event: $eventName on $eventDate'); // 调试信息
          if (events.containsKey(eventDate)) {
            events[eventDate]!.add(clendarEvent(eventName, eventDate));
          } else {
            events[eventDate] = [clendarEvent(eventName, eventDate)];
          }
          print('Event added: $eventName on $eventDate'); // 调试信息
        } catch (e) {
          print('Error parsing date: ${event["活動日期"]}'); // 错误信息
        }
      }
      // 添加一个特定日期的事件
      if (events.containsKey(_focusedDay)) {
        events[_focusedDay]!.add(clendarEvent("輸入成功", _focusedDay));
      } else {
        events[_focusedDay] = [clendarEvent("輸入成功", _focusedDay)];
      }
      print('Event added: 輸入成功 on $_focusedDay'); // 调试信息

      _selectedEvents.value = _getEventsForDay(_selectedDay!);
      print('Events: $events'); // 调试信息
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
    }
  }

  void _editEvent(int index) {
    //編輯事件
    _eventController.text = events[_selectedDay]![index].name;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: Text("編輯事件"),
          content: Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: _eventController,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  events[_selectedDay]!.removeAt(index);
                });
                Navigator.of(context).pop();
                _selectedEvents.value = _getEventsForDay(_selectedDay!);
              },
              child: Text("刪除"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_eventController.text.isNotEmpty) {
                  setState(() {
                    events[_selectedDay]![index] =
                        clendarEvent(_eventController.text, _selectedDay!);
                  });
                  Navigator.of(context).pop();
                  _selectedEvents.value = _getEventsForDay(_selectedDay!);
                }
              },
              child: Text("保存"),
            ),
          ],
        );
      },
    );
  }

  List<clendarEvent> _getEventsForDay(DateTime day) {
    //取得事件
    return events[day] ?? [];
  }

  void _addEvent() {
    if (_eventController.text.isNotEmpty && _selectedDay != null) {
      setState(() {
        if (events[_selectedDay!] != null) {
          events[_selectedDay!]!
              .add(clendarEvent(_eventController.text, _selectedDay!));
        } else {
          events[_selectedDay!] = [
            clendarEvent(_eventController.text, _selectedDay!)
          ];
        }
        _selectedEvents.value = _getEventsForDay(_selectedDay!); // 更新选中日期的事件列表
        print('Event added: ${_eventController.text} on $_selectedDay'); // 调试信息
        print('Events: $events'); // 调试信息
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: addEventBtn(context),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2030, 1, 1),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay, // 确保使用正确的事件加载器
            calendarStyle: CalendarStyle(outsideDaysVisible: false),
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          Divider(
            height: 8,
          ),
          Expanded(
            child: ValueListenableBuilder<List<clendarEvent>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        trailing: Text(value[index].date.toString()),
                        title: Text(value[index].name),
                        onTap: () => _editEvent(index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  FloatingActionButton addEventBtn(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              scrollable: true,
              title: Text("新增任務"),
              content: Padding(
                padding: EdgeInsets.all(8),
                child: TextField(
                  controller: _eventController,
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (_eventController.text.isNotEmpty) {
                      setState(() {
                        if (events[_selectedDay] != null) {
                          events[_selectedDay]!.add(clendarEvent(
                              _eventController.text, _selectedDay!));
                        } else {
                          events[_selectedDay!] = [
                            clendarEvent(_eventController.text, _selectedDay!)
                          ];
                        }
                      });
                      Navigator.of(context).pop();
                      _selectedEvents.value = _getEventsForDay(_selectedDay!);
                    }
                  },
                  child: Text("確認"),
                ),
              ],
            );
          },
        );
      },
      child: Icon(Icons.add),
    );
  }
}
