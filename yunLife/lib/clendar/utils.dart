// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'utils.dart';

/// Function to fetch events from the API and update the event map
Future<void> fetchEventsFromApi() async {
  final response = await http.get(Uri.parse('http://yunlifeserver.glitch.me/calendar'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    kEvents.clear();

    for (var event in data['greetings']) {
      // Parse the date from the "活動日期" field
      DateTime eventDate = DateTime.parse(
        '${DateTime.now().year}-${event['活動日期'].split('/')[0]}-${event['活動日期'].split('/')[1]}'
      );

      // Check if the date already exists in kEvents, if not, create a new list
      if (kEvents[eventDate] == null) {
        kEvents[eventDate] = [];
      }

      // Add the event to the list of events for that date
      kEvents[eventDate]?.add(Event(event['活動']));
    }
  } else {
    // Handle the error case when the API request fails
    print('Failed to load events from server');
  }
}

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

/// Returns a list of [DateTime] objects from [first] to [last], inclusive
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

/// Constants to define the range of dates for the calendar
final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
