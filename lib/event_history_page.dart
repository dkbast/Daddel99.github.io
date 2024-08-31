import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_a/event.dart';
import 'package:project_a/event_provider.dart';
import 'package:provider/provider.dart';

class EventHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    Map<String, List<Event>> sortedEvents =
        _sortEventsByWeekday(eventProvider.events);

    return Scaffold(
      appBar: AppBar(
        title: Text('Event History'),
      ),
      body: ListView.builder(
        itemCount: sortedEvents.length,
        itemBuilder: (context, index) {
          String weekday = sortedEvents.keys.elementAt(index);
          List<Event> eventsForWeekday = sortedEvents[weekday]!;
          return ExpansionTile(
            title: Text(
              weekday,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: eventsForWeekday
                .map((event) => _buildEventTile(event, weekday))
                .toList(),
          );
        },
      ),
    );
  }

  Map<String, List<Event>> _sortEventsByWeekday(
      Map<DateTime, List<Event>> events) {
    Map<String, List<Event>> sortedEvents = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': [],
    };

    events.forEach((date, eventsList) {
      String weekday = DateFormat('EEEE').format(date);
      if (sortedEvents.containsKey(weekday)) {
        sortedEvents[weekday]!.addAll(eventsList);
      }
    });

    return sortedEvents;
  }

  // Hier würde ich ein Widget draus machen schau dir das Video mal an:
  // https://www.youtube.com/watch?v=IOyq-eTRhvo&vl=en
  Widget _buildEventTile(Event event, String weekday) {
    return ListTile(
      title: Text(
        '${event.startTime} - ${event.endTime}',
      ),
      subtitle: Text(event.category),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          // Hier kannst du das Löschen von Ereignissen implementieren
        },
      ),
    );
  }
}
