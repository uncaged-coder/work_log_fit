import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:work_log_fit/models/exercise.dart';
import 'list_screen_base.dart';

class ExerciseListScreen extends BaseListScreen<Exercise> {
  ExerciseListScreen()
      : super(
          title: 'Work Log Fit - Exercices',
          boxName: 'exercices',
          emptyList: 'No exercices available. Please add a new exercice.',
          extraButtonName: 'Settings',
          extraButtonIcon: 'Settings',
        );

  @override
  _ExerciseListScreenState createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends BaseListScreenState<Exercise> {
  // This box will store custom exercises added by the user
  late Box<dynamic> customExercisesBox;

  // Predefined categories and exercises
  final Map<String, List<Exercise>> categories = {
    'Abs': [
      Exercise(name: 'Crunch', programId: 0),
      Exercise(name: 'Leg Raise', programId: 0),
    ],
    'Biceps': [
      Exercise(name: 'Larry Scott Dumbbell Curl', programId: 0),
    ],
    'Triceps': [
      Exercise(name: 'Dips', programId: 0),
    ],
    'Legs': [
      Exercise(name: 'Leg Press', programId: 0),
    ],
    'Chest': [
      Exercise(name: 'Butterfly', programId: 0),
      Exercise(name: 'Machine Bench Press', programId: 0),
    ],
    'Shoulder': [
      Exercise(name: 'Machine Shoulder Military Press', programId: 0),
    ],
    'Back': [
      Exercise(name: 'Lat Pulldown', programId: 0),
    ],
    'Other': [],
  };

  // The list of exercises selected by the user to add to the program
  List<String> selectedExercises = [];

  @override
  String getItemString(Exercise ex) {
    return ex.name;
  }

  @override
  List<Widget> buildItemList(BuildContext context) {
    List<Widget> categorySections = [];
    categories.forEach((category, exercises) {
      // Add a section header for the category
      categorySections.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            category,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      );
      // Add a list tile for each exercise in the category
      categorySections.addAll(exercises.map((exercise) {
        return ListTile(
          leading: Container(
            color: Theme.of(context).canvasColor,
            child: Image.asset(
              'assets/program_icon.png',
              width: 50.0,
              height: 50.0,
            ),
          ),
          title: Text(exercise.name),
          onTap: () {
            if (!showDelete) {
              itemSelected(context, exercise);
            }
          },
          trailing: showDelete
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Perform deletion from the customExercisesBox and update the UI accordingly
                    // You may need a method to get the index or key of the exercise in the customExercisesBox
                  },
                )
              : null,
        );
      }).toList());
    });
    return categorySections;
  }

  @override
  void itemSelected(BuildContext context, Exercise item) {
    Navigator.pop(context, item);
  }
}
