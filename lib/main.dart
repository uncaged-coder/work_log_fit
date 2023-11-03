import 'dart:io' show Platform, Directory;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:work_log_fit/models/program.dart';
import 'package:work_log_fit/models/exercise.dart';
import 'package:work_log_fit/models/work_log_entry.dart';
import 'screens/programs_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  await Hive.openBox('programs');
  printHivePath();

  runApp(WorkLogFitApp());
}

void printHivePath() {
  if (Hive.isBoxOpen('programs')) {
    print('Hive programs box path: ${Hive.box('programs').path}');
  }
}

class WorkLogFitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkLogFit',
      theme: ThemeData.dark().copyWith(
        primaryColor: Color.fromRGBO(60, 0, 128, 1),
      ),
      home: ProgramsListScreen(),
    );
  }
}
