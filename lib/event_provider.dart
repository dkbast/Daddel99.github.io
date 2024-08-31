import 'package:flutter/material.dart';
import 'package:project_a/event.dart';
import 'package:project_a/event_category.dart';

class EventProvider with ChangeNotifier {
  Map<DateTime, List<Event>> _events = {};
  final Map<EventCategory, double> _timeSpent = {
    EventCategory.Sport: 0.0,
    EventCategory.Chores: 0.0,
    EventCategory.Science: 0.0,
    EventCategory.Social: 0.0,
    EventCategory.Creativity: 0.0,
    EventCategory.Language: 0.0,
  };

  Map<DateTime, List<Event>> get events => _events;
  Map<EventCategory, double> get timeSpent => _timeSpent;

  void addEvent(DateTime date, Event event) {
    DateTime normalizedDate = DateTime(date.year, date.month, date.day);

    if (_events[normalizedDate] == null) {
      _events[normalizedDate] = [];
    }

    _events[normalizedDate]!.add(event);

    _printAllEvents();

    notifyListeners();
  }

  void updateTimeSpent(EventCategory category, double time) {
    _timeSpent[category] = time;
    notifyListeners();
  }

  void addTimeSpent(EventCategory category, double hours) {
    if (_timeSpent[category] == null) {
      _timeSpent[category] = 0;
    }
    _timeSpent[category] = (_timeSpent[category] ?? 0) + hours;
    notifyListeners();
  }

  // Methode zum Ausgeben aller Events
  void _printAllEvents() {
    print('----- Alle Events -----');
    _events.forEach((date, events) {
      print('Datum: $date');
      for (var event in events) {
        print(event); // Aufruf der toString-Methode des Events
      }
    });
    print('-----------------------');
  }
}
