import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:work_log_fit/models/program.dart';
import 'package:work_log_fit/models/exercise.dart';
import 'list_screen_base.dart';
import 'exercise_log_screen.dart';
import 'exercises_list_screen.dart';

// Change StatelessWidget to StatefulWidget
class ProgramShowScreen extends BaseListScreen<Exercise> {
  final Program program; // parent

  ProgramShowScreen({required this.program})
      : super(
            title: 'Work Log Fit - Program',
            boxName: 'program',
            emptyList: 'No exercices available - please add a new exercise.');

  @override
  _ProgramShowScreenState createState() => _ProgramShowScreenState(program);
}

class _ProgramShowScreenState extends BaseListScreenState<Exercise> {
  final Program program; // parent

  _ProgramShowScreenState(this.program);

  @override
  Exercise? createItem(String name) {
    return new Exercise(name: name, programId: program.key);
  }

  @override
  String getItemString(Exercise ex) {
    return ex.name;
  }

  @override
  Future<List<Exercise>> loadItems(Box<dynamic> box) async {
    // Obtain the exercises asynchronously
    var exercises = await box.values
        .cast<Exercise>()
        .where((exercise) => exercise.programId == program.key)
        .toList()
        .reversed
        .toList();

    // Return the exercises in case you need them
    return exercises;
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
      final Exercise clonedExercise = Exercise(
        name: selectedExercise.name,
        programId: program.key, // Assuming 'program' is your Program instance
      );
      addItem(clonedExercise);
    }
  }

  @override
  void itemSelected(BuildContext context, Exercise item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseLogScreen(exercise: item),
      ),
    );
  }
}
