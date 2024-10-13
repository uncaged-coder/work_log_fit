import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_log_fit/models/work_log_entry.dart';

class ExerciseStatsChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<DateTime> dates;

  ExerciseStatsChart(this.spots, this.dates, {Key? key}) : super(key: key);  // Added key here

  // This simplified version focuses only on showing the first and last date.
  SideTitles getBottomTitles() {
    final dateFormat = DateFormat('yy/MM/dd');
    if (spots.isEmpty) {
      return SideTitles(showTitles: false);
    }

    return SideTitles(
      showTitles: true,
      reservedSize: 30,
      getTitlesWidget: (double value, TitleMeta meta) {
        String formattedDate;
        if (value == 0) {
          formattedDate = dateFormat.format(dates.last);
        } else if (value == spots.length - 1) {
          formattedDate = dateFormat.format(dates.first);
        } else {
          return const SizedBox.shrink(); // Do not show other dates
        }

        return SideTitleWidget(
          axisSide: meta.axisSide,
          fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
          child: Text(formattedDate, textAlign: TextAlign.left),
        );
      },
    );
  }

  SideTitles getLeftTitles() {
    if (spots.isEmpty) {
      return SideTitles(showTitles: false);
    }
    double minY = spots.map((e) => e.y).reduce(min);
    double maxY = spots.map((e) => e.y).reduce(max);
    double midY = (minY + maxY) / 2;

    return SideTitles(
      showTitles: true,
      reservedSize: 40,
      getTitlesWidget: (double value, TitleMeta meta) {
        if (value == minY || value == midY || value == maxY) {
          return SideTitleWidget(
            axisSide: meta.axisSide,
            fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
            child: Text(value.toInt().toString()),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return Center(
        child: Text(
          'No data available for the selected period.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

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
  final List<WorkLogEntry> logs;

  StatsDialog(this.logs);

  @override
  _StatsDialogState createState() => _StatsDialogState();
}

class _StatsDialogState extends State<StatsDialog> {
  late GraphType selectedGraphType;
  List<GraphType> graphTypes = [
    GraphType("Reccent progress", (logs) => processLastTenData(logs)),
    GraphType("Full history", (logs) => processWeightData(logs)),
  ];

  @override
  void initState() {
    super.initState();
    selectedGraphType = graphTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = selectedGraphType.filterFunction(widget.logs);
    List<DateTime> dates = widget.logs.map((log) => log.date).toList();

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
              items: graphTypes.map<DropdownMenuItem<GraphType>>((GraphType type) {
                return DropdownMenuItem<GraphType>(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
            ),
            Expanded(
              // Pass a unique key to ensure the chart rebuilds properly when switching graph types
              child: ExerciseStatsChart(spots, dates, key: ValueKey(selectedGraphType)),
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

List<FlSpot> processLastTenData(List<WorkLogEntry> logs) {
  // Handle the case where there are fewer than 10 data points
  final lastTenLogs = logs.length > 10 ? logs.sublist(0, 9) : logs;
  return processWeightData(lastTenLogs);
}

List<FlSpot> processWeightData(List<WorkLogEntry> logs) {
  List<FlSpot> spots = [];

  for (int i = 0; i < logs.length; i++) {
    double x = logs.length - 1 - i.toDouble();
    spots.add(FlSpot(x, logs[i].weight.toDouble()));
  }
  return spots;
}

class GraphType {
  final String name;
  final Function(List<WorkLogEntry>) filterFunction;

  GraphType(this.name, this.filterFunction);
}
