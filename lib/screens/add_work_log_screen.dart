import 'package:flutter/material.dart';
import 'package:work_log_fit/models/work_log_entry.dart';

class AddWorkLogScreen extends StatefulWidget {
  final exerciseId;

  AddWorkLogScreen(this.exerciseId);

  @override
  _AddWorkLogScreenState createState() => _AddWorkLogScreenState(exerciseId);
}

class _AddWorkLogScreenState extends State<AddWorkLogScreen> {
  final exerciseId;
  String weight = '0';
  String repetitions = '0';

  _AddWorkLogScreenState(this.exerciseId);

  void addNumber(String number, String type) {
    setState(() {
      if (type == 'weight') {
        if (weight == '0' && number != '0') {
          weight = number;
        } else if (weight != '0') {
          weight += number;
        }
      } else if (type == 'reps') {
        if (repetitions == '0' && number != '0') {
          repetitions = number;
        } else if (repetitions != '0') {
          repetitions += number;
        }
      }
    });
  }

  void deleteNumber(String type) {
    setState(() {
      if (type == 'weight' && weight.length > 1) {
        weight = weight.substring(0, weight.length - 1);
      } else if (type == 'weight') {
        weight = '0';
      } else if (type == 'reps' && repetitions.length > 1) {
        repetitions = repetitions.substring(0, repetitions.length - 1);
      } else if (type == 'reps') {
        repetitions = '0';
      }
    });
  }

  Widget numberButton(String number, String type) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          onPressed: () => addNumber(number, type),
          child: Text(number, style: TextStyle(fontSize: 24)),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(
                double.infinity, double.infinity), // Make the button expand
          ),
        ),
      ),
    );
  }

  Widget deleteButton(String type) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          onPressed: () => deleteNumber(type),
          child: Icon(Icons.backspace, size: 24),
          style: ElevatedButton.styleFrom(
            primary: Colors.red, // Background color
            minimumSize: Size(
                double.infinity, double.infinity), // Make the button expand
          ),
        ),
      ),
    );
  }

  Widget keypad(String type) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            // Make sure the Row takes up equal space
            child: Row(
              children: [
                numberButton('1', type),
                numberButton('2', type),
                numberButton('3', type),
              ],
            ),
          ),
          Expanded(
            // Repeat for each Row
            child: Row(
              children: [
                numberButton('4', type),
                numberButton('5', type),
                numberButton('6', type),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                numberButton('7', type),
                numberButton('8', type),
                numberButton('9', type),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                numberButton('0', type),
                deleteButton(type),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Work Log'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('Weight: $weight kg', style: TextStyle(fontSize: 24)),
                  keypad('weight'),
                  SizedBox(height: 20),
                  Text('Repetitions: $repetitions times',
                      style: TextStyle(fontSize: 24)),
                  keypad('reps'),
                ],
              ),
            ),
          ),

          //Expanded(child: Container()), // This just fills the remaining space
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  // Save functionality
                  onPressed: () {
                    final workLog = WorkLogEntry(
                      weight: int.tryParse(weight) ?? 0,
                      repetitions: int.tryParse(repetitions) ?? 0,
                      date: DateTime.now(),
                      exerciseId: exerciseId,
                    );
                    Navigator.pop(context, workLog);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 30.0),
                    child: Text('Save', style: TextStyle(fontSize: 24)),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // Save button color
                  ),
                ),
                ElevatedButton(
                  // Cancel functionality
                  onPressed: () {
                    // Simply pop the screen without saving anything
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 30.0),
                    child: Text('Cancel', style: TextStyle(fontSize: 24)),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Cancel button color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
