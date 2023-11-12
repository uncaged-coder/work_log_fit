import 'package:hive/hive.dart';

class HiveManager {
  static final HiveManager _instance = HiveManager._privateConstructor();

  HiveManager._privateConstructor();

  factory HiveManager() {
    return _instance;
  }

  Box? _exercisesBox;
  Box? _programsBox;
  Box? _worklogBox;

  // Function to open all necessary boxes
  Future<void> openAllBoxes() async {
    _exercisesBox = await Hive.openBox('exercises');
    _programsBox = await Hive.openBox('programs');
    _worklogBox = await Hive.openBox('worklog');
  }

  // Getter for exercises box
  Box get exercisesBox {
    if (_exercisesBox == null) throw Exception('Exercises box not opened');
    return _exercisesBox!;
  }

  // Getter for programs box
  Box get programsBox {
    if (_programsBox == null) throw Exception('Programs box not opened');
    return _programsBox!;
  }

  // Getter for worklog box
  Box get worklogBox {
    if (_worklogBox == null) throw Exception('Worklog box not opened');
    return _worklogBox!;
  }

  Box getDataBox(String boxName) {
    switch (boxName) {
      case 'programs':
        return programsBox;
      case 'workLog':
        return worklogBox;
      case 'exercises':
        return exercisesBox;
      default:
        throw Exception('unknown box $boxName');
    }
  }

  // Close all boxes
  Future<void> closeAllBoxes() async {
    await _exercisesBox?.close();
    await _programsBox?.close();
    await _worklogBox?.close();
    _exercisesBox = null;
    _programsBox = null;
    _worklogBox = null;
  }
}
