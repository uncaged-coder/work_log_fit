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

class MuscleGroups {
  static const String abs = 'abs';
  static const String biceps = 'biceps';
  static const String triceps = 'triceps';
  static const String legs = 'legs';
  static const String chest = 'chest';
  static const String shoulder = 'shoulder';
  static const String back = 'back';
  static const String other = 'other';
}

class _ExerciseListScreenState extends BaseListScreenState<Exercise> {
  // This box will store custom exercises added by the user
  late Box<dynamic> customExercisesBox;

  // Predefined categories and exercises
  final Map<String, List<Exercise>> categories = {
    'Abs': [
      Exercise(name: 'Crunches', muscleGroup: MuscleGroups.abs),
      Exercise(name: 'Flat bench leg raises', muscleGroup: MuscleGroups.abs),
    ],
    'Biceps': [
      Exercise(
          name: 'Preacher curl with machine', muscleGroup: MuscleGroups.biceps),
      Exercise(
          name: 'Standing biceps curl with cable',
          muscleGroup: MuscleGroups.biceps),
    ],
    'Triceps': [
      Exercise(
          name: 'Triceps dips using body weight',
          muscleGroup: MuscleGroups.triceps),
      Exercise(name: 'Triceps Dips', muscleGroup: MuscleGroups.triceps),
      Exercise(
          name: 'Triceps pushdown with rope and cable',
          muscleGroup: MuscleGroups.triceps),
      Exercise(
          name: 'Triceps pushdown with cable',
          muscleGroup: MuscleGroups.triceps),
      Exercise(
          name: 'Triceps extensions using machine',
          muscleGroup: MuscleGroups.triceps),
      Exercise(
          name: 'Straight Arm Push down', muscleGroup: MuscleGroups.triceps),
    ],
    'Legs': [
      Exercise(name: 'Leg press', muscleGroup: MuscleGroups.legs),
      Exercise(name: 'Barbell squat', muscleGroup: MuscleGroups.legs),
      Exercise(name: 'Leg extensions', muscleGroup: MuscleGroups.legs),
      Exercise(name: 'Lying leg curl machine', muscleGroup: MuscleGroups.legs),
      Exercise(name: 'Seated leg curl', muscleGroup: MuscleGroups.legs),
      Exercise(name: 'Smith machine squats', muscleGroup: MuscleGroups.legs),
      Exercise(name: 'Thigh abductor', muscleGroup: MuscleGroups.legs),
    ],
    'Chest': [
      Exercise(name: 'Butterfly machine', muscleGroup: MuscleGroups.chest),
      Exercise(name: 'Machine bench press', muscleGroup: MuscleGroups.chest),
      Exercise(name: 'Incline chest press', muscleGroup: MuscleGroups.chest),
      Exercise(name: 'Bench press', muscleGroup: MuscleGroups.chest),
      Exercise(
          name: 'Smith machine bench press', muscleGroup: MuscleGroups.chest),
      Exercise(name: 'Push ups', muscleGroup: MuscleGroups.chest),
    ],
    'Shoulder': [
      Exercise(
          name: 'Seated Shoulder press machine',
          muscleGroup: MuscleGroups.shoulder),
    ],
    'Back': [
      Exercise(name: 'Wide grip lat pull down', muscleGroup: MuscleGroups.back),
      Exercise(name: 'Seated cable rows', muscleGroup: MuscleGroups.back),
      Exercise(name: 'Pull ups', muscleGroup: MuscleGroups.back),
      Exercise(name: 'Hyperextensions', muscleGroup: MuscleGroups.back),
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
          leading: ClipOval(
            child: Container(
              color: Colors.transparent,
              width: 50.0,
              height: 50.0,
              child: Image.asset(
                exercise.getImageIcon(),
                fit: BoxFit.cover,
              ),
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
                  onPressed: () {},
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
