import 'dart:io' show Platform, Directory;
import 'package:hive/hive.dart';
import 'package:work_log_fit/models/exercise.dart';
import 'package:work_log_fit/models/program.dart';
import 'package:work_log_fit/models/work_log_entry.dart';
import 'package:work_log_fit/hive_manager.dart';

class DatabaseDumper {
  final HiveManager hiveManager;

  DatabaseDumper(this.hiveManager);

  Future<void> dumpAllData() async {
    // Dump Programs
    var programsBox = hiveManager.programsBox;
    print("Programs:");
    await _dumpBox(programsBox, 'Program');

    // Dump Exercises
    var exercisesBox = hiveManager.exercisesBox;
    print("Exercises:");
    await _dumpBox(exercisesBox, 'Exercise');

    // Dump WorkLogEntries
    var worklogBox = hiveManager.worklogBox;
    print("Work Logs:");
    await _dumpBox(worklogBox, 'WorkLogEntry');
  }

  Future<void> _dumpBox(Box box, String type) async {
    for (var key in box.keys) {
      var item = box.get(key);
      if (item != null) {
        if (type == 'Program' && item is Program) {
          print(
              "Key: $key, Name: ${item.name}, Exercise IDs: ${item.exerciseIds}");
        } else if (type == 'Exercise' && item is Exercise) {
          print(
              "Key: $key, Name: ${item.name}, Muscle Group: ${item.muscleGroup}");
        } else if (type == 'WorkLogEntry' && item is WorkLogEntry) {
          print(
              "Key: $key, Date: ${item.date}, Repetitions: ${item.repetitions}, Weight: ${item.weight}, Exercise ID: ${item.exerciseId}, Program ID: ${item.programId}");
        }
      }
    }
  }
}

// Usage example
void main() async {
  var hiveManager = HiveManager();
  await hiveManager.initialize();
  var dumper = DatabaseDumper(hiveManager);
  await dumper.dumpAllData();
}
