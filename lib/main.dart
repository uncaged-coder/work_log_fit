import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/programs_list_screen.dart';
import 'hive_manager.dart';
import 'timer.dart';
import 'settings.dart';

void main() async {
  final GlobalTimerManager globalTimerManager = GlobalTimerManager();

  WidgetsFlutterBinding.ensureInitialized();

  var hiveManager = HiveManager();
  await hiveManager.initialize();

  runApp(
    Provider<GlobalTimerManager>.value(
      value: globalTimerManager,
      child: WorkLogFitApp(),
    ),
  );
}

class WorkLogFitApp extends StatelessWidget {
  const WorkLogFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkLogFit',
      theme: ThemeData.dark().copyWith(
        primaryColor: themeColor,
      ),
      home: ProgramsListScreen(),
    );
  }

  void dispose() {
    HiveManager().closeAllBoxes();
  }
}
