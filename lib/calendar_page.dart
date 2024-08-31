import 'package:flutter/material.dart';
import 'package:project_a/event.dart';
import 'package:project_a/event_category.dart';
import 'package:project_a/event_history_page.dart';
import 'package:project_a/event_provider.dart';
import 'package:provider/provider.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate;

  get categoryStr => null;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildWeekdayButton(context, 'Monday'),
                _buildWeekdayButton(context, 'Tuesday'),
                _buildWeekdayButton(context, 'Wednesday'),
                _buildWeekdayButton(context, 'Thursday'),
                _buildWeekdayButton(context, 'Friday'),
                _buildWeekdayButton(context, 'Saturday'),
                _buildWeekdayButton(context, 'Sunday'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventHistoryPage(),
                ),
              );
            },
            child: Text('View Event History'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayButton(BuildContext context, String weekday) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          _selectedDate = _getDateTimeForWeekday(weekday);
          _showEventHistoryOrAddEvent(context, weekday);
        },
        child: Text(
          weekday,
          style: TextStyle(fontSize: 20),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }

  // hier würde ich schauen ob du den "weekday" nicht einfach als enum oder int verwendest
  // das macht es auch leichter mit Übersetzungen zu arbeiten
  DateTime _getDateTimeForWeekday(String weekday) {
    DateTime now = DateTime.now();
    int weekdayIndex = DateTime.monday;
    switch (weekday.toLowerCase()) {
      case 'monday':
        weekdayIndex = DateTime.monday;
        break;
      case 'tuesday':
        weekdayIndex = DateTime.tuesday;
        break;
      case 'wednesday':
        weekdayIndex = DateTime.wednesday;
        break;
      case 'thursday':
        weekdayIndex = DateTime.thursday;
        break;
      case 'friday':
        weekdayIndex = DateTime.friday;
        break;
      case 'saturday':
        weekdayIndex = DateTime.saturday;
        break;
      case 'sunday':
        weekdayIndex = DateTime.sunday;
        break;
    }

    int daysUntilWeekday = weekdayIndex - now.weekday;
    if (daysUntilWeekday < 0) {
      daysUntilWeekday += 7;
    }

    return now.add(Duration(days: daysUntilWeekday));
  }

  void _showEventHistoryOrAddEvent(BuildContext context, String weekday) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    List<Event>? eventsForSelectedDate = eventProvider.events[_selectedDate];

    if (eventsForSelectedDate != null && eventsForSelectedDate.isNotEmpty) {
      _showEventHistory(context, eventsForSelectedDate);
    } else {
      _showEventDialog(context, weekday);
    }
  }

  void _showEventHistory(BuildContext context, List<Event> events) {
    // Hier kannst du die Ereignishistorie anzeigen
  }

  void _showEventDialog(BuildContext context, String weekday) async {
    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (startTime == null) return;

    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (endTime == null) return;

    String? categoryStr = await _showCategoryDialog(context);

    if (categoryStr == null) return;

    Event event = Event(
      startTime: startTime,
      endTime: endTime,
      category: categoryStr,
      name: '',
    );

    Provider.of<EventProvider>(context, listen: false).addEvent(
      _selectedDate,
      event,
    );

    Navigator.of(context).pop();
  }

  Future<String?> _showCategoryDialog(BuildContext context) async {
    String? categoryStr;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        // Den Dialog könntest du ggf auch in ein Widget auslagern
        return AlertDialog(
          title: Text('Select Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: EventCategory.values.map((category) {
              return RadioListTile<String>(
                title: Text(category.toString().split('.').last),
                value: category.toString(),
                groupValue: categoryStr,
                onChanged: (String? value) {
                  categoryStr = value;
                  Navigator.of(context).pop(value);
                },
              );
            }).toList(),
          ),
        );
      },
    );
    return categoryStr;
  }
}
