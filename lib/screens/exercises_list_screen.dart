import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:work_log_fit/models/exercise.dart';
import 'package:work_log_fit/settings.dart';
import 'package:work_log_fit/exercises_manager.dart';
import 'list_screen_base.dart';

class ExerciseListScreen extends BaseListScreen<Exercise> {
  bool customMode;

  ExerciseListScreen({this.customMode = false})
      : super(
          title: 'Work Log Fit - Exercices',
          boxItemsName: 'exercises',
          emptyList: 'No exercises available. Please add a new exercise.',
          button1Name: 'Custom exercise',
          button1Icon: 'fitness_center',
          enableDeleteButton: customMode,
          enableAddButton: customMode,
        );

  @override
  _ExerciseListScreenState createState() =>
      _ExerciseListScreenState(customMode);
}

class _ExerciseListScreenState extends BaseListScreenState<Exercise> {
  // This box will store custom exercises added by the user
  late Box<dynamic> customExercisesBox;
  final bool customMode;
  final exerciseManager = ExerciseManager();

  // The list of exercises selected by the user to add to the program
  List<String> selectedExercises = [];

  _ExerciseListScreenState(this.customMode);

  @override
  String getItemString(Exercise ex) {
    return ex.name;
  }

  // This method builds the item list for both predefined and custom modes
  List<Widget> _buildItemList(
      BuildContext context, Map<String, List<Exercise>> exerciseGroups) {
    List<Widget> categorySections = [];
    exerciseGroups.forEach((category, exercises) {
      // Add a section header for the category
      categorySections.add(
        Container(
          color: themeColor,
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
                  onPressed: () {}, // Implement delete functionality
                )
              : null,
        );
      }).toList());
    });
    return categorySections;
  }

  // This method groups exercises by muscle group
  Map<String, List<Exercise>> _groupExercisesByMuscleGroup(
      List<Exercise> exercises) {
    Map<String, List<Exercise>> groupedExercises = {};
    for (var exercise in exercises) {
      if (!groupedExercises.containsKey(exercise.muscleGroup)) {
        groupedExercises[exercise.muscleGroup] = [];
      }
      groupedExercises[exercise.muscleGroup]!.add(exercise);
    }
    return groupedExercises;
  }

  @override
  List<Widget> buildItemList(BuildContext context) {
    return customMode
        ? _buildItemListCustom(context)
        : _buildItemListPredefined(context);
  }

  List<Widget> _buildItemListCustom(BuildContext context) {
    // Group exercises by muscle group
    Map<String, List<Exercise>> groupedExercises =
        _groupExercisesByMuscleGroup(baseItemsList);

    // Build item list from grouped exercises
    return _buildItemList(context, groupedExercises);
  }

// This method returns predefined exercises grouped by muscle group
  List<Widget> _buildItemListPredefined(BuildContext context) {
    return _buildItemList(context, exerciseManager.categories);
  }

  @override
  void itemSelected(BuildContext context, Exercise item) {
    Navigator.pop(context, item);
  }

  @override
  void showAddItemDialog(BuildContext context) {
    TextEditingController _exerciseNameController = TextEditingController();

    // List of muscle group names
    List<String> muscleGroupNames = [
      MuscleGroups.abs,
      MuscleGroups.biceps,
      MuscleGroups.triceps,
      MuscleGroups.legs,
      MuscleGroups.chest,
      MuscleGroups.shoulder,
      MuscleGroups.back,
      MuscleGroups.other,
    ];

    String? _selectedMuscleGroup = muscleGroupNames.first;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('Muscle Group:'),
                  ),
                  Expanded(
                    flex: 3,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedMuscleGroup,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMuscleGroup = newValue;
                        });
                      },
                      items: muscleGroupNames
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _exerciseNameController,
                decoration: InputDecoration(hintText: "Exercise Name"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('ADD'),
              onPressed: () {
                if (_exerciseNameController.text.isNotEmpty &&
                    _selectedMuscleGroup != null) {
                  // Find the current max ID in the box, starting from customExerciseStartId
                  int newId = baseItemsBox.keys.fold<int>(customExerciseStartId,
                          (max, current) => current > max ? current : max) +
                      1;

                  Exercise newItem = Exercise(
                    name: _exerciseNameController.text,
                    muscleGroup: _selectedMuscleGroup!,
                  );
                  addItem(newItem);
                  saveItem(newItem, key: newId);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    ).then((_) {
      // This block is executed after the dialog is closed.
      timerManager.updateTickCb(onTick: () => setState(() {}));
    });
  }

  @override
  void showCustomItemDialog(BuildContext context) async {
    // cannot add exercises to hard coded list
    if (customMode) {
      // return to previsou windows without selection
      Navigator.pop(context);
      return;
    }

    final Exercise? selectedExercise = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseListScreen(customMode: true),
      ),
    );

    // Check if an item was selected before trying to add it
    if (selectedExercise != null) {
      Navigator.pop(context, selectedExercise);
    }
  }
}
