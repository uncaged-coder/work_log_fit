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
          title: '${exercise.name}',
          titleIcon: exercise.getImageIcon(),
          boxItemsName: 'workLog',
          emptyList: 'No logs available - please add a new log.',
          button1Name: 'Stats',
          button1Icon: 'Monitoring',
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

  void _toggleTimer() {
    if (timerManager.isTimerRunning) {
      timerManager.stopTimer();
    } else {
      timerManager.startTimer(onTick: () => setState(() {}));
    }

    // Force the widget to rebuild and update the UI
    setState(() {});
  }

  @override
  List<Widget> buildItemList(BuildContext context) {
    if (baseItemsList.isEmpty) {
      return [Center(child: Text('No logs available'))];
    }

    Map<DateTime, List<WorkLogEntry>> groupedLogs = _groupLogsByDate();
    List<DateTime> sortedDates = _sortDates(groupedLogs);

    List<Widget> listItems = [];
    bool isFirstDate = true;

    for (DateTime date in sortedDates) {
      Widget dateHeader = isFirstDate
          ? _buildDateHeaderWithTimer(context, date)
          : _buildDateHeaderWithoutTimer(context, date);
      isFirstDate = false;

      listItems.add(dateHeader);
      listItems.addAll(_buildLogEntries(groupedLogs[date]!));
    }

    return listItems;
  }

  Widget _buildDateHeaderWithTimer(BuildContext context, DateTime date) {
    return Container(
      color: themeColor,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('yyyy/MM/dd').format(date),
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          _buildTimerRow(),
        ],
      ),
    );
  }

  Widget _buildDateHeaderWithoutTimer(BuildContext context, DateTime date) {
    return Container(
      color: themeColor,
      padding: const EdgeInsets.all(8.0),
      child: Text(
        DateFormat('yyyy/MM/dd').format(date),
        style: Theme.of(context).textTheme.headline6?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
      ),
    );
  }

  Widget _buildTimerRow() {
    return Row(
      children: [
        Text(
          formatTime(timerManager.remainingSeconds),
          style: TextStyle(
            fontFamily: 'DigitalDisplay',
            color: Colors.red,
          ),
        ),
        IconButton(
          icon:
              Icon(timerManager.isTimerRunning ? Icons.stop : Icons.play_arrow),
          onPressed: _toggleTimer,
        ),
      ],
    );
  }

  List<Widget> _buildLogEntries(List<WorkLogEntry> logEntries) {
    return logEntries
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
  }
}
