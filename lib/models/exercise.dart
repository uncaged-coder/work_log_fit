import 'package:hive/hive.dart';
import 'hive_type_ids.dart';
part 'exercise.g.dart';

@HiveType(typeId: HiveTypeIds.exercise)
class Exercise extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int programId;

  Exercise({required this.name, required this.programId});
}
