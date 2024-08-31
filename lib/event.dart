import 'package:flutter/material.dart';

class Event {
  final String name;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String category;

  Event({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.category,
  });

  double getDurationInHours() {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final durationMinutes = endMinutes - startMinutes;
    return durationMinutes / 60.0; // Dauer in Stunden
  }

  @override
  String toString() {
    return 'Event: $name, Category: $category, Start: $startTime, End: $endTime';
  }
}
