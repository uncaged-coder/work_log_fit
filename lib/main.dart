import 'package:flutter/material.dart';

void main() => runApp(WorkLogFitApp());

class WorkLogFitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkLogFit',
      theme: ThemeData.dark(), // Apply the dark theme
      home: ProgramsListScreen(),
    );
  }
}

class ProgramsListScreen extends StatelessWidget {
  final List<String> programs = ["Lafay", "Gym - legs", "Gym High body"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Work Log Fit - Programs'),
      ),
      body: ListView.builder(
        itemCount: programs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(programs[index]),
            onTap: () {
              // Navigate to the exercises screen for the selected program
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExercisesListScreen(programName: programs[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add a new program (this can be updated to show a form in the future)
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ExercisesListScreen extends StatelessWidget {
  final String programName;

  // Dummy exercises data for demonstration
  final List<String> exercises = ["Exercise 1", "Exercise 2", "Exercise 3"];

  ExercisesListScreen({required this.programName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercises for $programName'),
      ),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(exercises[index]),
            onTap: () {
              // Navigate to the logs screen for the selected exercise
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseLogScreen(exerciseName: exercises[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ExerciseLogScreen extends StatelessWidget {
  final String exerciseName;

  ExerciseLogScreen({required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs for $exerciseName'),
      ),
      body: Center(
        child: Text('Here you can view and add logs for $exerciseName'),
      ),
    );
  }
}

