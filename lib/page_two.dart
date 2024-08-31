import 'package:flutter/material.dart';
import 'package:project_a/calendar_page.dart';
import 'package:project_a/event_category.dart';
import 'package:project_a/event_provider.dart';
import 'package:project_a/stopwatch_widget.dart';
import 'package:project_a/workout_dialog.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
                  builder: (BuildContext context) {
                    return WorkoutDialog();
                  });
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
