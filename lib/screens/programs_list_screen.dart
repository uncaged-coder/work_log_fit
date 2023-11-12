import 'package:flutter/material.dart';
import 'package:work_log_fit/models/program.dart';
import 'program_show_screen.dart';
import 'list_screen_base.dart';

class ProgramsListScreen extends BaseListScreen<Program> {
  ProgramsListScreen()
      : super(
          title: 'Work Log Fit - Programs',
          boxName: null,
          boxItemsName: 'programs',
          emptyList: "No programs available. Please add a new program.",
        );

  @override
  _ProgramsListScreenState createState() => _ProgramsListScreenState();
}

class _ProgramsListScreenState extends BaseListScreenState<Program> {
  @override
  Program? createItem(String name) {
    return new Program(name: name);
  }

  @override
  String getItemString(Program p) {
    return p.name;
  }

  @override
  void itemSelected(BuildContext context, Program item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgramShowScreen(program: item),
      ),
    );
  }
}
