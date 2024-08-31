import 'package:flutter/material.dart';
import 'package:project_a/event_category.dart';
import 'package:project_a/event_provider.dart';
import 'package:project_a/home_page.dart';
import 'package:provider/provider.dart';
// Für das Datumsformat

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
