import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_log_fit/models/work_log_entry.dart';

class ExerciseStatsChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Map<DateTime, List<WorkLogEntry>> groupedLogs;

  ExerciseStatsChart(this.spots, this.groupedLogs);

  SideTitles getBottomTitles() {
    final dateFormat = DateFormat('yy/MM/dd');
    final middleXIndex = spots.length ~/ 2;
    final firstX = spots.first.x;
    final lastX = spots.last.x;

    return SideTitles(
      showTitles: true,
      reservedSize: 30,
      getTitlesWidget: (double value, TitleMeta meta) {
        // FIXME: ugly: because of our ugly work arround (implemented because of inverted data.
        // See more info below, search for ugly) we did lost date in case of not summed stats.
        // Since we only need first and last one, we are getting them directly from grouppedLogs
        // map structure.
        DateTime date =
            (value == firstX) ? groupedLogs.keys.first : groupedLogs.keys.last;
        Widget title;
        if (value == firstX || value == lastX) {
          String formattedDate = dateFormat.format(date);
          title = Text(formattedDate, textAlign: TextAlign.left);
        } else {
          title = const SizedBox.shrink(); // No title
        }

        return SideTitleWidget(
          axisSide: meta.axisSide,
          fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
          child: title,
        );
      },
    );
  }

  // Function to generate left titles (y-axis)
  SideTitles getLeftTitles() {
    double firstY = spots.map((e) => e.y).reduce(min);
    double lastY = spots.map((e) => e.y).reduce(max);
    double middleY = (firstY + lastY) / 2;

    return SideTitles(
      showTitles: true,
      reservedSize: 40,
      getTitlesWidget: (double value, TitleMeta meta) {
        Widget title;
        if (value == firstY || value == middleY || value == lastY) {
          title = Text(value.toInt().toString());
        } else {
          title = const SizedBox.shrink(); // No title
        }

        return SideTitleWidget(
          axisSide: meta.axisSide,
          fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
          angle: -0.5,
          child: title,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: getBottomTitles()),
          leftTitles: AxisTitles(sideTitles: getLeftTitles()),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [mainData()],
      ),
    );
  }

  LineChartBarData mainData() {
    return LineChartBarData(
      spots: spots,
      isCurved: false,
      barWidth: 2,
      isStrokeCapRound: false,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
    );
  }
}

class StatsDialog extends StatefulWidget {
  final Map<DateTime, List<WorkLogEntry>> groupedLogs;

  StatsDialog(this.groupedLogs);

  @override
  _StatsDialogState createState() => _StatsDialogState();
}

class _StatsDialogState extends State<StatsDialog> {
  late GraphType selectedGraphType;
  List<GraphType> graphTypes = [
    GraphType("Sum - All", (logs) => processWeightData(logs, true)),
    GraphType("Sum - 1 Month",
        (logs) => processWeightData(filterLogsForPastMonth(logs), true)),
    GraphType("Weight - All", (logs) => processWeightData(logs, false)),
    GraphType("Weight - 1 Month",
        (logs) => processWeightData(filterLogsForPastMonth(logs), false)),
  ];

  @override
  void initState() {
    super.initState();
    selectedGraphType = graphTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = selectedGraphType.filterFunction(widget.groupedLogs);

    return AlertDialog(
      title: Text('Exercise Statistics'),
      content: Container(
        height: 400,
        width: double.maxFinite,
        child: Column(
          children: [
            DropdownButton<GraphType>(
              value: selectedGraphType,
              onChanged: (GraphType? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedGraphType = newValue;
                  });
                }
              },
              items:
                  graphTypes.map<DropdownMenuItem<GraphType>>((GraphType type) {
                return DropdownMenuItem<GraphType>(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
            ),
            Expanded(
              child: ExerciseStatsChart(spots, widget.groupedLogs),
            ),
          ],
        ),
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
  }
}

// Utility function to filter logs for the past month
Map<DateTime, List<WorkLogEntry>> filterLogsForPastMonth(
    Map<DateTime, List<WorkLogEntry>> logs) {
  DateTime oneMonthAgo = DateTime.now().subtract(Duration(days: 30));
  return Map.fromEntries(
      logs.entries.where((entry) => entry.key.isAfter(oneMonthAgo)));
}

// Utility function to process weight data for logs
List<FlSpot> processWeightData(
    Map<DateTime, List<WorkLogEntry>> logs, bool sumWeights) {
  List<FlSpot> spots = [];

  // FIXME: this is very ugly ;)
  // because all data are inverted, and to avoid playing with temporary list which
  // would be CPU wast, and because I'm too lazy to rewrite the code, I had to use
  // this ugly work arround.
  // so by decreasing x for each point, we will get our chart as we want.
  double x = 1000000;

  logs.forEach((date, entries) {
    if (sumWeights) {
      // If summing weights, use the date for the x-coordinate
      double totalWeight =
          entries.fold(0.0, (sum, entry) => sum + entry.weight.toDouble());
      spots.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), totalWeight));
    } else {
      // If not summing, increment x for each log entry
      for (var entry in entries) {
        x--;
        spots.add(FlSpot(x, entry.weight.toDouble()));
      }
    }
  });
  return spots;
}

class GraphType {
  final String name;
  final Function(Map<DateTime, List<WorkLogEntry>>) filterFunction;

  GraphType(this.name, this.filterFunction);
}
