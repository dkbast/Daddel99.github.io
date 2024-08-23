import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';// Für das Datumsformat
import 'iterable_extensions.dart';




void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: MaterialAppWidget(),
    ),
  );
}





class MaterialAppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

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


class WorkoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController timeController = TextEditingController();
    EventCategory? selectedCategory;

    return AlertDialog(
      title: Text('Zeit für Workout hinzufügen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: timeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Zeit in Minuten'),
          ),
          DropdownButton<EventCategory>(
            hint: Text('Kategorie wählen'),
            value: selectedCategory,
            onChanged: (EventCategory? newValue) {
              selectedCategory = newValue!;
            },
            items: EventCategory.values.map((EventCategory category) {
              return DropdownMenuItem<EventCategory>(
                value: category,
                child: Text(category.name), // Verwende .name für die String-Repräsentation
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () {
            if (timeController.text.isNotEmpty && selectedCategory != null) {
              int minutes = int.parse(timeController.text);
              double hours = minutes / 60.0;

              // Aktualisiere die Zeit im EventProvider
              Provider.of<EventProvider>(context, listen: false)
                  .addTimeSpent(selectedCategory!, hours);

              Navigator.of(context).pop();
            }
          },
          child: Text('Hinzufügen'),
        ),
      ],
    );
  }
}


class StopwatchWidget extends StatefulWidget {
  @override
  _StopwatchWidgetState createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget> {
  Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String _elapsedTime = "00:00:00";
  EventCategory? _selectedCategory;

  void _startStopwatch() {
    _stopwatch.start();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = _formatElapsedTime(_stopwatch.elapsed);
      });
    });
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _timer.cancel();
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    setState(() {
      _elapsedTime = "00:00:00";
    });
  }

  String _formatElapsedTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _saveTimeSpent() {
    

    
    if (_selectedCategory != null) {
      final elapsedTimeInHours = _stopwatch.elapsed.inMinutes / 60.0;
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider.addTimeSpent(_selectedCategory!, elapsedTimeInHours);
      _resetStopwatch();  // Reset the stopwatch after saving
      Navigator.pop(context);  // Close the popup
    } else {
      // Show an error message or warning if no category is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bitte wähle eine Kategorie aus.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Stopwatch"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _elapsedTime,
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          DropdownButton<EventCategory>(
            hint: Text("Event auswählen"),
            value: _selectedCategory,
            onChanged: (newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
            items: EventCategory.values.map((category) {
              return DropdownMenuItem<EventCategory>(
                value: category,
                child: Text(category.toString().split('.').last),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _startStopwatch,
          child: Text("Start"),
        ),
        TextButton(
          onPressed: _stopStopwatch,
          child: Text("Stop"),
        ),
        TextButton(
          onPressed: _saveTimeSpent,
          child: Text("Speichern"),
        ),
        TextButton(
          onPressed: _resetStopwatch,
          child: Text("Reset"),
        ),
      ],
    );
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> notifications = [];
  Set<String> notifiedEvents = {};
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _checkForNotifications();
    _startNotificationCheck();
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              _showNotificationPopup(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PageOne()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Profile',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PageTwo()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Skillen',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Dungeon',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

   // Methode zum Starten des Timers für regelmäßige Benachrichtigungsprüfungen
   void _startNotificationCheck() {
    _notificationTimer = Timer.periodic(Duration(seconds: 30), (Timer timer) {
      _checkForNotifications();
    });
  }

  void _checkForNotifications() {
  DateTime now = DateTime.now();
  TimeOfDay nowTime = TimeOfDay(hour: now.hour, minute: now.minute);
  DateTime nowDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    nowTime.hour,
    nowTime.minute,
  );

  Map<DateTime, List<Event>> events = Provider.of<EventProvider>(context, listen: false).events;

  for (var entry in events.entries) {
    DateTime date = entry.key;
    List<Event> eventList = entry.value;

    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      for (Event event in eventList) {
        DateTime endTime = DateTime(
          now.year,
          now.month,
          now.day,
          event.endTime.hour,
          event.endTime.minute,
        );

        if (nowDateTime.isAfter(endTime.subtract(Duration(minutes: 1))) &&
            nowDateTime.isBefore(endTime.add(Duration(minutes: 1)))) {
               String categoryStr = event.category.toString().split('.').last;
           String eventIdentifier = '$categoryStr-${event.startTime.format(context)}-${event.endTime.format(context)}';
          if (!notifiedEvents.contains(eventIdentifier)) {
            String notificationMessage = 'Event ending soon: $categoryStr';
            _addNotification(notificationMessage);
            notifiedEvents.add(notificationMessage);
          }
        }
      }
    }
  }
 }


  void _addNotification(String notification) {
    print("Notification defined: $notification"); // Debug-Statemen
    setState(() {
      notifications.add(notification);
      
    });
  }

   EventCategory? getEventCategoryFromString(String categoryStr) {
    // Trimming any leading or trailing whitespace
    String trimmedCategoryStr = categoryStr.trim().toLowerCase();
    print('Trimmed and lowercased categoryStr: $trimmedCategoryStr');
    
    // Converting the string to the appropriate EventCategory
    switch (trimmedCategoryStr) {
      case 'sport':
        return EventCategory.Sport;
      case 'chores':
        return EventCategory.Chores;
      case 'science':
        return EventCategory.Science;
      case 'social':
        return EventCategory.Social;
      case 'creativity':
        return EventCategory.Creativity;
      case 'language':
        return EventCategory.Language;
      default:
        print('Category not found(gecfs): $trimmedCategoryStr');
        return null;
    }
  }

  String extractCategoryStringFromNotification(CustomNotification notification) {
  String categoryStr = notification as String;
  print('Raw category from notification: $categoryStr');
  return categoryStr;
 }



 void processNotification(CustomNotification notification) {
  // Extrahiere die Kategorie als String
  String categoryStr = extractCategoryStringFromNotification(notification);
  print('Extracted category string: $categoryStr');
  
  // Finde die zugehörige Kategorie
  EventCategory? category = getEventCategoryFromString(categoryStr);
  print('Matched Enum category: $category');

  if (category != null) {
    // Weiterverarbeitung der Benachrichtigung
    print('Processing notification for category: $category');
  } else {
    print('No matching category found for: $categoryStr');
  }
}






  void _removeNotification(String notification) {
  setState(() {
    notifications.remove(notification);
  });
  }
  void _showNotificationPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Notifications'),
        content: notifications.isEmpty
            ? Text('No notifications.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: notifications.map((notification) {
                  return ListTile(
                    title: Text(notification),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            _acceptNotification(notification);
                            
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            _removeNotification(notification);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
 }

  void _acceptNotification(String notification) {
  DateTime startTime = DateTime.now(); // Startzeit erfassen
  print('Start processing notification at: $startTime');

  // Regular expression to extract the category string from the notification
  RegExp regex = RegExp(r'Event ending soon: (\w+)');
  print(regex);
  Match? match = regex.firstMatch(notification);
  print(match);
  

  if (match != null) {
    // Extracting the category string
    String categoryStr = match.group(1)!;
    print('Notification matched category: $categoryStr'); // Debugging output

    // Trimming leading and trailing whitespace from the category string
    categoryStr = categoryStr.trim();
    print('Category string extracted: $categoryStr'); // Debugging output

    // Using the conversion function to get the corresponding EventCategory enum
    EventCategory? category = getEventCategoryFromString(categoryStr);
    print('Matched Enum category: $category'); // Debugging output

    if (category == null) {
      print('Category not found: $category'); // Debugging output
      return;
    }

    // Getting the EventProvider instance
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    DateTime today = DateTime.now();
    DateTime todayKey = DateTime(today.year, today.month, today.day);

    if (eventProvider.events.containsKey(todayKey)) {
    List<Event>? todayEvents = eventProvider.events[todayKey];
    print('Events für heute: $todayEvents');
    } else {
    print('Keine Events für heute gefunden. Schlüssel: $todayKey');
    }

    List<Event>? todayEvents = eventProvider.events[todayKey];
    print(todayEvents);

    if (todayEvents != null && todayEvents.isNotEmpty) {
      print('Today events: $todayEvents'); // Debugging output
      // Finding the matching event based on the category
      Event? matchingEvent = todayEvents.firstWhereOrNull(
        (event) => event.category.toString().split(".").last == categoryStr,
      );

      print('Matching event: $matchingEvent'); // Debugging output
      print("Categorystr: $categoryStr");
      

      if (matchingEvent == null) {
        print('Event not found for category: $categoryStr'); // Debugging output
        return;
      }

      // Adding the time spent for the event's category
      double duration = matchingEvent.getDurationInHours();
      print('Calculated duration for category "$categoryStr": $duration hours'); // Debugging output
      eventProvider.addTimeSpent(category, duration);
      print('Time spent added: $duration hours for category: $category'); // Debugging output
    } else {
      print('No events found for today'); // Debugging output
    }
  } else {
    print('No match found for notification: $notification'); // Debugging output
  }

  DateTime endTime = DateTime.now(); // Endzeit erfassen
  Duration elapsedTime = endTime.difference(startTime);
  print('Finished processing notification at: $endTime');
  print('Time taken for processing: ${elapsedTime.inMilliseconds} milliseconds');

  // Removing the processed notification
  _removeNotification(notification);
}















}



class PageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Text('This is Page One'),
      ),
    );
  }
}

class PageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Skillen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<EventProvider>(
                builder: (context, eventProvider, _) {
                  return SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(text: 'Categories'),
                    ),
                    series: <ChartSeries>[
                      ColumnSeries<EventCategory, String>(
                        dataSource: EventCategory.values,
                        xValueMapper: (EventCategory category, _) =>
                            category.toString().split('.').last,
                        yValueMapper: (EventCategory category, _) =>
                            eventProvider.timeSpent[category] ?? 0,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          labelAlignment: ChartDataLabelAlignment.auto,
                          textStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ),
          Spacer(flex: 1),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarPage()),
              );
            },
            icon: Icon(Icons.calendar_today, size: 40),
            label: Text(
              'Calendar',
              style: TextStyle(fontSize: 20),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 90, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          SizedBox(height: 40.0),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StopwatchWidget();
                },
              );
            },
            icon: Icon(Icons.timer, size: 40),
            label: Text(
              'Stopwatch',
              style: TextStyle(fontSize: 20),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 90, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          SizedBox(height: 40.0),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder:(BuildContext context) {
                  return WorkoutDialog();
                }
              );
            },
            icon: Icon(Icons.sports_gymnastics, size: 40),
            label: Text(
              'Manual',
              style: TextStyle(fontSize: 20),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 90, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




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

  Widget _buildCategoryDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Select Category'),
      content: SingleChildScrollView(
        child: ListBody(
          children: EventCategory.values.map((category) {
            return RadioListTile<EventCategory>(
              title: Text(category.toString().split('.').last),
              value: category,
              groupValue: null,
              onChanged: (EventCategory? value) {
                Navigator.of(context).pop(value);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showEventHistory(BuildContext context, List<Event> events) {
    // Hier kannst du die Ereignishistorie anzeigen
  }


class EventHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    Map<String, List<Event>> sortedEvents = _sortEventsByWeekday(eventProvider.events);

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
            children: eventsForWeekday.map((event) => _buildEventTile(event, weekday)).toList(),
          );
        },
      ),
    );
  }

  Map<String, List<Event>> _sortEventsByWeekday(Map<DateTime, List<Event>> events) {
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

enum EventCategory {
  Sport,
  Science,
  Creativity,
  Social,
  Language,
  Chores,
}

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

class CustomNotification {
  final String title;
  final String body;
  final String category;

  CustomNotification({required this.title, required this.body, required this.category});
}




class NotificationView extends StatelessWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification Screen"),
      ),
      body: listView(),
    );
  }

  Widget listView() {
    return ListView.separated(
      itemBuilder: (context, index) {
        return listViewItem(index);
      },
      separatorBuilder: (context, index) {
        return Divider(height: 0);
      },
      itemCount: 15,
    );
  }

  Widget listViewItem(int index) {
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          message(index),
          timeAndDate(index),
        ],
      ),
    );
  }

  Widget message(int index) {
    double textSize = 14;
    return Container(
      child: RichText(
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: "Message",
          style: TextStyle(
            fontSize: textSize,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: " Message Description",
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget timeAndDate(int index) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "19-07-2024",
            style: TextStyle(fontSize: 10),
          ),
          Text(
            "12:00 AM",
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
