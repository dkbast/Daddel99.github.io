import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project_a/custom_notification.dart';
import 'package:project_a/event.dart';
import 'package:project_a/event_category.dart';
import 'package:project_a/event_provider.dart';
import 'package:project_a/iterable_extensions.dart';
import 'package:project_a/page_one.dart';
import 'package:project_a/page_two.dart';
import 'package:provider/provider.dart';

// die Datei habe ich mir nicht im Detail angesehen
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
                  onPressed: () {},
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

    Map<DateTime, List<Event>> events =
        Provider.of<EventProvider>(context, listen: false).events;

    for (var entry in events.entries) {
      DateTime date = entry.key;
      List<Event> eventList = entry.value;

      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
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
            String eventIdentifier =
                '$categoryStr-${event.startTime.format(context)}-${event.endTime.format(context)}';
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

  String extractCategoryStringFromNotification(
      CustomNotification notification) {
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
          print(
              'Event not found for category: $categoryStr'); // Debugging output
          return;
        }

        // Adding the time spent for the event's category
        double duration = matchingEvent.getDurationInHours();
        print(
            'Calculated duration for category "$categoryStr": $duration hours'); // Debugging output
        eventProvider.addTimeSpent(category, duration);
        print(
            'Time spent added: $duration hours for category: $category'); // Debugging output
      } else {
        print('No events found for today'); // Debugging output
      }
    } else {
      print(
          'No match found for notification: $notification'); // Debugging output
    }

    DateTime endTime = DateTime.now(); // Endzeit erfassen
    Duration elapsedTime = endTime.difference(startTime);
    print('Finished processing notification at: $endTime');
    print(
        'Time taken for processing: ${elapsedTime.inMilliseconds} milliseconds');

    // Removing the processed notification
    _removeNotification(notification);
  }
}
