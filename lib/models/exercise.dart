import 'package:hive/hive.dart';
import 'package:work_log_fit/settings.dart';
import 'package:work_log_fit/hive_manager.dart';
import 'hive_type_ids.dart';
import 'hive_entity.dart';
import 'work_log_entry.dart';
import 'program.dart';
part 'exercise.g.dart';

@HiveType(typeId: HiveTypeIds.exercise)
class Exercise extends HiveEntity {
  @HiveField(0)
  final String name;

  @HiveField(1)
  String image;

  @HiveField(2)
  String muscleGroup;

  int? pkey;

  Exercise({
    required this.name,
    required this.muscleGroup,
    this.image = '',
    this.pkey = null,
  }) : super(baseName: 'exercises');

  @override
  bool useImage() {
    return true;
  }

  bool isCustomExercise() {
    return pkey == null;
  }

  int getId() {
    // exercise can be hardcoded (use pkey) or defined by user
    // (then use key's of hive database)
    return pkey ?? key;
  }

  @override
  String getImageIcon() {
    if (isCustomExercise()) {
      return 'assets/program_icon.png';
    }

    String formattedName = name.toLowerCase().replaceAll(' ', '-');
    return 'assets/icons/$muscleGroup/$formattedName-icon.png';
  }

  @override
  bool useGroup() {
    return true;
  }

  void removeLogs(int programId) async {
    var box = HiveManager().worklogBox;
    box.values
        .where((workLog) =>
            workLog.programId == programId &&
            workLog.exerciseId == this.getId())
        .toList()
        .forEach((workLog) {
      box.delete(workLog.key);
    });
  }

  @override
  void remove() {
    // FIXME: show dialog if there is program that reference this exercise
    // and dont remove it.
    //super.remove();
  }
}
