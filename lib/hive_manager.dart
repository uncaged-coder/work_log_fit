import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:work_log_fit/models/program.dart';
import 'package:work_log_fit/models/exercise.dart';
import 'package:work_log_fit/models/work_log_entry.dart';

class HiveManager {
  static final HiveManager _instance = HiveManager._privateConstructor();
  Box? _exercisesBox;
  Box? _programsBox;
  Box? _worklogBox;

  HiveManager._privateConstructor();

  factory HiveManager() {
    return _instance;
  }

  // Function to open all necessary boxes
  Future<void> _openAllBoxes() async {
    _exercisesBox = await Hive.openBox('exercises');
    _programsBox = await Hive.openBox('programs');
    _worklogBox = await Hive.openBox('worklog');
  }

  void _printHivePath() {
    if (Hive.isBoxOpen('programs')) {
      print('Hive programs box path: ${Hive.box('programs').path}');
    }
  }

  Future<void> initialize() async {
    // Set the path for Hive based on the platform
    if (kIsWeb) {
      Hive.init('');
    } else if (Platform.isLinux) {
      // For Linux, set the path according to XDG Base Directory Specification
      String homeDirectory = Platform.environment['HOME'] ?? '/home/username';
      String hiveDirectory = '$homeDirectory/.local/share/work_log_fit/hive';
      Hive.init(hiveDirectory);
    } else {
      // For other platforms, use the path provided by path_provider
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
    }

    Hive.registerAdapter(ProgramAdapter());
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(WorkLogEntryAdapter());

    await _openAllBoxes();
    _printHivePath();
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
