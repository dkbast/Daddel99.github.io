import 'package:flutter/material.dart';
import 'package:project_a/event_category.dart';
import 'package:project_a/event_provider.dart';
import 'package:provider/provider.dart';

// bin ich nicht mehr zu gekommen
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
                child: Text(category
                    .name), // Verwende .name für die String-Repräsentation
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
