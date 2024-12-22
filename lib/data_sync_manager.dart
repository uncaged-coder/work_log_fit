// data_sync_manager.dart
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:work_log_fit/hive_manager.dart';
import 'package:work_log_fit/models/work_log_entry.dart';
import 'package:work_log_fit/models/program.dart';
import 'package:work_log_fit/models/exercise.dart';
import 'package:work_log_fit/models/hive_entity.dart';
//import 'old_mappings.dart'; // for mwlcsv imports only
import 'package:work_log_fit/exercises_manager.dart';

class DataSyncManager {
  final HiveManager hiveManager = HiveManager();

  /// Import data from the selected directory:
  /// - Parse all *.wlfcsv files (new format)
  /// - Parse all *.mwlcsv files (old format, read-only)
  /// Update the database with the entries found.
  Future<void> importData(String directoryPath) async {
    //await hiveManager.initialize();
    final dir = Directory(directoryPath);

    if (!await dir.exists()) {
      print("Directory does not exist: $directoryPath");
      return;
    }

    final files = dir.listSync().whereType<File>();
    for (final file in files) {
      final name = file.path.split(Platform.pathSeparator).last;

      if (name.endsWith('.wlfcsv')) {
        await _importWlfCsv(file);
      } else if (name.endsWith('.mwlcsv')) {
        //await _importMwlcsv(file);
      }
    }
  }

  /// Export any new data to the wlfcsv files.
  /// The assumption: we track entries that have not yet been written to CSV.
  /// One approach: store a lastSync timestamp in a settings box, and export all entries newer than that time.
  /// Another approach: keep a hash of entries. For simplicity, let's assume a lastSync timestamp approach.
  Future<void> exportData(String directoryPath) async {
    //await hiveManager.initialize();
    var box = hiveManager.worklogBox;

    // TODO: Retrieve lastSync timestamp from a settings box.
    // For demonstration, we assume lastSync = DateTime(1970, 1, 1);
    DateTime lastSync = DateTime(1970, 1, 1);

    var allEntries = box.values.cast<WorkLogEntry>().where((e) => e.date.isAfter(lastSync)).toList();

    if (allEntries.isEmpty) {
      print("No new entries to export.");
      return;
    }

    // Group entries by year (since we have one file per year)
    Map<int, List<WorkLogEntry>> entriesByYear = {};
    for (var entry in allEntries) {
      int year = entry.date.year;
      entriesByYear.putIfAbsent(year, () => []);
      entriesByYear[year]!.add(entry);
    }

    for (var year in entriesByYear.keys) {
      String fileName = 'wlf_data_$year.wlfcsv';
      File file = File('$directoryPath/$fileName');

      // If file doesn't exist, create with header
      bool fileExists = await file.exists();
      IOSink sink = file.openWrite(mode: FileMode.append);

      if (!fileExists) {
        // Write header: date,exerciseId,programId,weight,repetitions
        sink.writeln('date,exerciseId,programId,weight,repetitions');
      }

      for (var entry in entriesByYear[year]!) {
        String dateStr = entry.date.toIso8601String(); // e.g., "2024-12-14T15:30:45.123"
        sink.writeln('$dateStr,${entry.exerciseId},${entry.programId},${entry.weight},${entry.repetitions}');
      }

      await sink.flush();
      await sink.close();
    }

    // TODO: Update lastSync timestamp in a settings box.
  }

  Future<void> _importWlfCsv(File file) async {
    print("Importing WLF CSV: ${file.path}");
    final input = file.openRead();
    final fields = await input.transform(utf8.decoder).transform(CsvToListConverter()).toList();

    // Expecting header: date,exerciseId,programId,weight,repetitions
    // date format: yyyy-MM-dd or something consistent
    var header = fields.first;
    int dateIndex = header.indexOf('date');
    int exerciseIndex = header.indexOf('exerciseId');
    int programIndex = header.indexOf('programId');
    int weightIndex = header.indexOf('weight');
    int repsIndex = header.indexOf('repetitions');

    var worklogBox = hiveManager.worklogBox;
    var programsBox = hiveManager.programsBox;

    int hop = 0;

    for (int i = 1; i < fields.length; i++) {
      var row = fields[i];

      DateTime date = DateTime.parse(row[dateIndex]);
      int exerciseId = int.parse(row[exerciseIndex].toString());
      int programId = int.parse(row[programIndex].toString());
      int weight = int.parse(row[weightIndex].toString());
      int repetitions = int.parse(row[repsIndex].toString());

      date = date.add(Duration(milliseconds: hop++));

      // Check if entry already exists
      // One approach is to check entries with same date, programId, exerciseId, weight, and repetitions.
      // If your data can have duplicates, consider another approach like a hash or a unique ID.
      bool exists = worklogBox.values.cast<WorkLogEntry>().any((e) =>
        e.date == date &&
        e.exerciseId == exerciseId &&
        e.programId == programId &&
        e.weight == weight &&
        e.repetitions == repetitions
      );


      if (!exists) {
        WorkLogEntry entry = WorkLogEntry(
          date: date,
          exerciseId: exerciseId,
          programId: programId,
          weight: weight,
          repetitions: repetitions,
        );
        await worklogBox.add(entry);

        // Update the program with the exercise ID if not already present
        var program = programsBox.get(programId) as Program?;
        if (program != null && !program.exerciseIds.contains(exerciseId)) {
          program.exerciseIds.add(exerciseId);
          programsBox.put(programId, program);
        }
      }
    }
  }

  /*
  Future<void> _importMwlcsv(File file) async {
    print("Importing MWL CSV (old format): ${file.path}");
    final input = file.openRead();
    final fields = await input.transform(utf8.decoder).transform(CsvToListConverter()).toList();

    // Assume old format similar to debug/csv.dart: date in dd-MM-yyyy, name, repetitions, weight
    // Header: Date(DD-MM-YYYY), ExerciseName, Reps, Weight
    var header = fields.first;
    // We trust a known order here, or find indices by name if needed.
    // date: row[0], name: row[1], reps: row[2], weight: row[3]

    var worklogBox = hiveManager.worklogBox;
    var programsBox = hiveManager.programsBox;
    var exerciseManager = ExerciseManager();

    for (int i = 1; i < fields.length; i++) {
      var row = fields[i];
      DateTime date = DateFormat('dd-MM-yyyy').parse(row[0]);
      String csvExerciseName = row[1].toString();
      int repetitions = double.parse(row[2].toString()).round();
      String weightStr = row[3].toString();
      if (weightStr == "BW") weightStr = "0";
      int weight = double.parse(weightStr).round();

      // Convert old name to the known exercise name
      String? exerciseManagerName = csvToExerciseManagerMap[csvExerciseName];
      if (exerciseManagerName == null) {
        print("Warning: Exercise '$csvExerciseName' not found in map, skipping.");
        continue;
      }

      int? exerciseId = exerciseManager.getExerciseIdByName(exerciseManagerName);
      if (exerciseId == null) {
        print("Warning: Exercise ID for '$exerciseManagerName' not found, skipping.");
        continue;
      }

      // In old format, we must decide how to determine programId. For now, put everything into a default program (0)
      // or you can add logic if needed. Here we use a default program = 0.
      int programId = 0;

      bool exists = worklogBox.values.cast<WorkLogEntry>().any((e) =>
        e.date == date &&
        e.exerciseId == exerciseId &&
        e.programId == programId &&
        e.weight == weight &&
        e.repetitions == repetitions
      );

      if (!exists) {
        WorkLogEntry entry = WorkLogEntry(
          weight: weight,
          repetitions: repetitions,
          date: date,
          programId: programId,
          exerciseId: exerciseId
        );
        await worklogBox.add(entry);

        // Update program with exercise ID
        var program = programsBox.get(programId) as Program?;
        if (program != null && !program.exerciseIds.contains(exerciseId)) {
          program.exerciseIds.add(exerciseId);
          programsBox.put(programId, program);
        }
      }
    }
  }
  */
}
