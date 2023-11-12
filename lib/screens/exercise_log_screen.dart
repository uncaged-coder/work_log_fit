import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:work_log_fit/models/work_log_entry.dart';
import 'package:work_log_fit/models/exercise.dart';
import 'package:work_log_fit/settings.dart';
import 'list_screen_base.dart';
import 'add_work_log_screen.dart';

class ExerciseLogScreen extends BaseListScreen<WorkLogEntry> {
  final Exercise exercise;
  final int programId;

  ExerciseLogScreen({required this.exercise, required this.programId})
      : super(
          title: '${exercise.name} log',
          titleIcon: exercise.getImageIcon(),
          boxItemsName: 'workLog',
          emptyList: 'No logs available - please add a new log.',
          button1Name: 'Stats',
          button1Icon: 'Monitoring',
          showTimer: true,
        );

  @override
  _ExerciseLogScreenState createState() =>
      _ExerciseLogScreenState(exercise, programId);
}

class _ExerciseLogScreenState extends BaseListScreenState<WorkLogEntry> {
  final Exercise exercise; // parent
  final int programId;
  bool showDelete = false;
  WorkLogEntry? _lastLog;

  _ExerciseLogScreenState(this.exercise, this.programId);

  @override
  String getItemString(WorkLogEntry w) {
    return "${w.repetitions} x ${w.weight} kg";
  }

  @override
  Future<List<WorkLogEntry>> loadItems(Box<dynamic> box) async {
    // Obtain the log asynchronously
    var logs = await box.values
        .cast<WorkLogEntry>()
        .where((log) =>
            log.exerciseId == exercise.getId() && log.programId == programId)
        .toList()
        .reversed
        .toList();

    // Update the last log
    if (logs.isNotEmpty) {
      _lastLog = logs.first;
    }

    // Return the exercises in case you need them
    return logs;
  }

  WorkLogEntry _getLastLog() {
    return _lastLog ??
        WorkLogEntry(
          weight: 0,
          repetitions: 0,
          date: DateTime.now(),
          exerciseId: exercise.getId(),
          programId: programId,
        );
  }

  Future<void> handleLogEntry(
      BuildContext context, WorkLogEntry log, bool update) async {
    final WorkLogEntry? modifiedLog = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWorkLogScreen(
            exerciseId: exercise.getId(),
            programId: programId,
            existingEntry: log,
            update: update),
      ),
    );

    if (modifiedLog != null) {
      setState(() {
        if (update && (modifiedLog.key != null)) {
          updateItem(modifiedLog);
        } else {
          addItem(modifiedLog);
          saveItem(modifiedLog);
          _lastLog = modifiedLog;
        }
      });
    }
  }

  @override
  void showAddItemDialog(BuildContext context) async {
    WorkLogEntry lastLog = _getLastLog();
    await handleLogEntry(context, lastLog, false);
  }

  @override
  void itemSelected(BuildContext context, WorkLogEntry item) async {
    await handleLogEntry(context, item, true);
  }

  Map<DateTime, List<WorkLogEntry>> _groupLogsByDate() {
    final Map<DateTime, List<WorkLogEntry>> groupedLogs = {};
    for (var log in baseItemsList) {
      final date = DateTime(
          log.date.year, log.date.month, log.date.day); // Strip time from date
      groupedLogs.putIfAbsent(date, () => []).add(log);
    }
    return groupedLogs;
  }

  List<DateTime> _sortDates(Map<DateTime, List<WorkLogEntry>> groupedLogs) {
    final sortedDates = groupedLogs.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Ensure dates are in descending order
    return sortedDates;
  }

  @override
  List<Widget> buildItemList(BuildContext context) {
    // Check if there are any work logs to display
    if (baseItemsList.isEmpty) {
      // Return an empty list containing just a placeholder widget
      return [Center(child: Text('No logs available'))];
    }

    // Group logs by date
    Map<DateTime, List<WorkLogEntry>> groupedLogs = _groupLogsByDate();

    // Convert the map into a sorted list of dates
    List<DateTime> sortedDates = _sortDates(groupedLogs);

    // Flatten the grouped logs into a single list of widgets
    List<Widget> listItems = [];
    for (DateTime date in sortedDates) {
      // Add date header with styling
      listItems.add(
        Container(
          color: themeColor,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            DateFormat('yyyy/MM/dd').format(date),
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
        ),
      );
      // Add log entries for this date
      List<Widget> logEntries = groupedLogs[date]!
          .map((log) => ListTile(
                title: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText1,
                    children: <TextSpan>[
                      TextSpan(
                          text: '${log.repetitions} ',
                          style: TextStyle(color: themeColor2)),
                      const TextSpan(text: 'x '),
                      TextSpan(
                          text: '${log.weight} ',
                          style: TextStyle(color: themeColor2)),
                      const TextSpan(text: 'kg'),
                    ],
                  ),
                ),
                trailing: showDelete
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteItem(log),
                      )
                    : null,
                onTap: () {
                  if (!showDelete) {
                    itemSelected(context, log);
                  }
                },
              ))
          .toList();
      listItems.addAll(logEntries);
    }

    return listItems;
  }
}
