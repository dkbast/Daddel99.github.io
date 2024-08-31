import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project_a/event_category.dart';
import 'package:project_a/event_provider.dart';
import 'package:provider/provider.dart';

// bin ich nicht mehr zu gekommen
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
      _resetStopwatch(); // Reset the stopwatch after saving
      Navigator.pop(context); // Close the popup
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
