import 'package:hive/hive.dart';
import 'hive_type_ids.dart';
import 'hive_entity.dart';
part 'work_log_entry.g.dart';

@HiveType(typeId: HiveTypeIds.workLogEntry)
class WorkLogEntry extends HiveEntity {
  @HiveField(0)
  int weight;

  @HiveField(1)
  int repetitions;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final int exerciseId;

  WorkLogEntry(
      {required this.weight,
      required this.repetitions,
      required this.date,
      required this.exerciseId});

  // Cloning constructor
  WorkLogEntry.clone(WorkLogEntry original)
      : weight = original.weight,
        repetitions = original.repetitions,
        date = original.date,
        exerciseId = original.exerciseId;
}
