import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:work_log_fit/models/program.dart';
import 'package:work_log_fit/models/exercise.dart';
import 'package:work_log_fit/exercises_manager.dart';
import 'list_screen_base.dart';
import 'exercise_log_screen.dart';
import 'exercises_list_screen.dart';

// Change StatelessWidget to StatefulWidget
class ProgramShowScreen extends BaseListScreen<Exercise> {
  final Program program; // parent

  ProgramShowScreen({super.key, required this.program})
      : super(
          title: program.name,
          boxName: 'programs',
          boxItemsName: 'exercises',
          emptyList: 'No exercises available - please add a new exercise.',
          enableFirstButton: false,
        );

  @override
  _ProgramShowScreenState createState() => _ProgramShowScreenState(program);
}

class _ProgramShowScreenState extends BaseListScreenState<Exercise> {
  final Program program; // parent

  _ProgramShowScreenState(this.program);

  @override
  String getItemString(Exercise ex) {
    return ex.name;
  }

  @override
  Future<List<Exercise>> loadItems(Box<dynamic> box) async {
    var exercises = box.values
        .cast<Exercise>()
        .where((exercise) => program.exerciseIds.contains(exercise.key))
        .toList();

    // Instantiate ExerciseManager to access hardcoded exercises
    var exerciseManager = ExerciseManager();

    // Add hardcoded exercises whose pkey matches with program.exerciseIds
    for (var id in program.exerciseIds) {
      var hardcodedExercise = exerciseManager.getExerciseByKey(id);
      if (hardcodedExercise != null &&
          !exercises.any((e) => e.pkey == hardcodedExercise.pkey)) {
        exercises.add(hardcodedExercise);
      }
    }

    return exercises;
  }

  @override
  void deleteItem(Exercise ex) {
    // removing logs related to this exercise.
    // here we dont want to call remove() since it would remove
    // the exercise from custom exercises database (if custom)
    ex.removeLogs(program.key);
    program.removeExercise(ex.getId());
    setState(() {
      baseItemsList.remove(ex);
    });
  }

  @override
  void showAddItemDialog(BuildContext context) async {
    final Exercise? selectedExercise = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseListScreen(),
      ),
    );

    // Check if an item was selected before trying to add it
    if (selectedExercise != null) {
      addItem(selectedExercise);
      _addExercisesToProgram(selectedExercise);
      _updateProgramInDatabase();
    }
  }

  void _addExercisesToProgram(Exercise ex) {
    int? key = ex.pkey ?? ex.key;

    if (key != null) {
      program.exerciseIds.add(key);
    } else {
      print('Error: Exercise key is null');
    }
  }

  void _updateProgramInDatabase() {
    baseBox!.put(program.key, program);
  }

  @override
  void itemSelected(BuildContext context, Exercise item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExerciseLogScreen(exercise: item, programId: program.key),
      ),
    );
  }
}
