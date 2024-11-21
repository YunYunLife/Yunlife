import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';

import 'package:yunLife/setting.dart';

/// Example event class
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

/// Event map using a LinkedHashMap to store events by date
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
);

/// Helper function to generate a hash code for a DateTime object
int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Function to fetch events from multiple APIs and update the event map
Future<void> fetchEventsFromMultipleApis() async {
  // Fetch data from both APIs
  final userCalendarResponse = await http.get(Uri.parse('$SERVER_IP/user_calendar'));
  final calendarResponse = await http.get(Uri.parse('$SERVER_IP/calendar'));

  kEvents.clear(); // Clear existing events

  // Handle user_calendar response
  if (userCalendarResponse.statusCode == 200) {
    final userData = jsonDecode(userCalendarResponse.body);
    for (var event in userData['greetings']) {
      if (event['學號'] == "B11023042") {
        DateTime eventDate = DateTime.parse(event['日期']);
        if (kEvents[eventDate] == null) {
          kEvents[eventDate] = [];
        }
        kEvents[eventDate]?.add(Event(event['事件']));
      }
    }
  } else {
    print('Failed to load user calendar events');
  }

  // Handle calendar response
  if (calendarResponse.statusCode == 200) {
    final calendarData = jsonDecode(calendarResponse.body);
    for (var event in calendarData['greetings']) {
      DateTime eventDate = DateTime.parse(
        '${DateTime.now().year}-${event['活動日期'].split('/')[0]}-${event['活動日期'].split('/')[1]}'
      );
      if (kEvents[eventDate] == null) {
        kEvents[eventDate] = [];
      }
      kEvents[eventDate]?.add(Event(event['活動']));
    }
  } else {
    print('Failed to load general calendar events');
  }

  // Debugging: Print the combined events
  print('Combined Events: $kEvents');
}

/// Constants to define the range of dates for the calendar
final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year - 3, kToday.month, kToday.day);
final kLastDay = DateTime(kToday.year + 3, kToday.month, kToday.day);

/// Returns a list of [DateTime] objects from [first] to [last], inclusive
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}
