import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:work_log_fit/models/work_log_entry.dart';
import 'package:work_log_fit/models/program.dart';
import 'package:work_log_fit/exercises_manager.dart';
import 'package:work_log_fit/hive_manager.dart';

// Define the map for CSV exercise names to ExerciseManager names
const Map<String, String> csvToExerciseManagerMap = {
  // 'Exercise Name from CSV': 'Exercise Name in ExerciseManager'
  // legs
  'Leg extension': 'Leg extensions',
  'Leg curl': 'Seated leg curl',
  'Leg press': 'Leg press',
  //abdo
  'Abdo crush machine': 'Crunches',
  'Rotary torso' : 'Rotary torso',
  'Abdo gros ventre ':'Abdo crunch machine',
  'Debout levé jambes': 'Stand leg raise',
  'Seated crunch with cable': 'Abdo crunch machine',
  // biceps
  'curl': 'Preacher curl with machine',
  'Barbell curl': 'Standing biceps curl with cable',
  'Larry Scott dumbbell curl': 'Preacher curl with machine',
  // triceps
  'Dips': 'Triceps dips using body weight',
  'Triceps dips using machine': 'Triceps dips machine',
  'Triceps Machine 2': 'Triceps extensions machine',
  'Triceps extensions machine': 'Triceps extensions machine',
  'Triceps Pushdown': 'Triceps pushdown with rope and cable',
  'Extension poulie corde': 'Triceps pushdown with rope and cable',
  'Extension poulie': 'Triceps pushdown with cable',
  'Triceps pushdown pronated grip': 'Triceps pushdown with cable',
  // back
  'Hammer Seated cable row': 'Seated cable rows',
  'Lat pulldown': 'Wide grip lat pull down',
  'Back extension': 'Hyperextensions',
  // shoulder
  'Epaure poule': 'Lateral dumbbell raises',
  'Side lateral raise' : 'Lateral dumbbell raises',
  'Machine Shoulder (Military) Press': 'Seated Shoulder press machine',
  // chest
  'Butterfly': 'Butterfly machine',
  'Butterfly 2': 'butterfly2 machine',
  'Machine Bench Press': 'Machine bench press',
  'Bench press with barbell': 'Smith machine bench press',
};

// Define the map for ExerciseManager names to program IDs
const Map<String, int> exerciseToProgramIdMap = {
  // legs
  'Leg extension': 1,
  'Leg curl': 1,
  'Leg press': 1,
  //abdo
  'Abdo crush machine': 1,
  'Abdo gros ventre ': 1,
  'Seated crunch with cable': 1,
  'Rotary torso': 1,
  'Debout levé jambes': 1,
  // biceps
  'curl': 0,
  'Barbell curl': 0,
  'Larry Scott dumbbell curl': 0,
  // triceps
  'Dips': 0,
  'Triceps dips using machine': 0,
  'Triceps Machine 2': 0,
  'Triceps extensions machine': 0,
  'Triceps Pushdown': 0,
  'Extension poulie corde': 0,
  'Extension poulie': 0,
  'Triceps pushdown pronated grip': 0,
  // back
  'Hammer Seated cable row': 0,
  'Lat pulldown': 0,
  'Back extension': 0,
  // shoulder
  'Epaure poule': 0,
  'Side lateral raise' : 0,
  'Machine Shoulder (Military) Press': 0,
  // chest
  'Butterfly': 0,
  'Butterfly 2': 0,
  'Machine Bench Press': 0,
  'Bench press with barbell': 0,
};

void createDefaultProgram() async {

    // Store the entry in Hive database
    var box = HiveManager().programsBox;

    // Create a WorkLogEntry
    Program mgfHigh = Program(
        name: 'MGF High');
    Program mgfLow = Program(
        name: 'MGF Low');

    await box.add(mgfHigh);
    await box.add(mgfLow);
}

/// Populates the database from a CSV file.
/// @param csvFilePath Path to the CSV file.
/// @return void
void populateDatabaseFromCsv(String csvFilePath) async {
  var hiveManager = HiveManager();
  await hiveManager.initialize();

  // Open the CSV file
  final input = File(csvFilePath).openRead();

  // Parse the CSV file
  final fields = await input
      .transform(utf8.decoder)
      .transform(CsvToListConverter())
      .toList();

  createDefaultProgram();

  // Skip the header row
  for (var i = 1; i < fields.length; i++) {
    var row = fields[i];

    // Parse date, CSV exercise name, reps, and weight
    DateTime date = DateFormat('dd-MM-yyyy').parse(row[0]);
    String csvExerciseName = row[1];
    int repetitions = double.parse(row[2].toString()).round();
    String weightStr = row[3].toString();
    print("date=$date, name=$csvExerciseName, weight=$weightStr, rep=$repetitions");
    if (weightStr == "BW") {
      weightStr = "0";
    }
    int weight = double.parse(weightStr).round();

    // Find the ExerciseManager name from the CSV name
    String? exerciseManagerName = csvToExerciseManagerMap[csvExerciseName];
    if (exerciseManagerName == null) {
      print("Error: Exercise '$csvExerciseName' not found in map.");
      continue;
    }

    final exerciseManager = ExerciseManager();
    int? exerciseId = exerciseManager.getExerciseIdByName(exerciseManagerName);
    if (exerciseId == null) {
      print("Error: Exercise ID for '$exerciseManagerName' not found.");
      continue;
    }

    // Find the program ID from the exercise name
    int? programId = exerciseToProgramIdMap[csvExerciseName];
    if (programId == null) {
      print("Error: Program ID for '$exerciseManagerName' not found.");
      continue;
    }

    // Create a WorkLogEntry
    WorkLogEntry entry = WorkLogEntry(
        weight: weight,
        repetitions: repetitions,
        date: date,
        programId: programId,
        exerciseId: exerciseId);

    // Store the entry in Hive database
    var box = HiveManager().worklogBox;
    await box.add(entry);

    // Update the program with the exercise ID if not already present
    var programsBox = HiveManager().programsBox;
    var program = programsBox.get(programId) as Program?;
    if (program != null && !program.exerciseIds.contains(exerciseId)) {
      program.exerciseIds.add(exerciseId);
      programsBox.put(programId, program);
    }
    else {
      print("Not added ! $program $programId");
    }
  }
}

void main() async {
  populateDatabaseFromCsv('private/backup.csv');
}
