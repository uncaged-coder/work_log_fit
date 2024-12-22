import 'package:hive/hive.dart';
import 'package:work_log_fit/hive_manager.dart';
import 'hive_type_ids.dart';
import 'hive_entity.dart';
part 'program.g.dart';

@HiveType(typeId: HiveTypeIds.program)
class Program extends HiveEntity {
  @HiveField(0)
  final String name;

  @HiveField(1)
  List<int> exerciseIds;

  Program({
    required this.name,
    List<int> exerciseIds = const [],
  })  : exerciseIds = (exerciseIds.isEmpty) ? [] : List<int>.from(exerciseIds),
        super(baseName: 'programs');

  @override
  bool useImage() {
    return true;
  }

  @override
  String getImageIcon() {
    return 'assets/program_icon.png';
  }

  void removeExercise(int exerciseId) async {
    exerciseIds.remove(exerciseId);
    var box = HiveManager().programsBox;
    box.put(key, this);
  }

  @override
  void remove() async {
    var box = HiveManager().worklogBox;
    box.values
        .where((workLog) => workLog.programId == key)
        .toList()
        .forEach((workLog) {
      box.delete(workLog.key);
    });

    super.remove();
  }
}
