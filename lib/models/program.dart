import 'package:hive/hive.dart';
import 'hive_type_ids.dart';
part 'program.g.dart';

@HiveType(typeId: HiveTypeIds.program)
class Program extends HiveObject {
  @HiveField(0)
  final String name;

  Program({required this.name});
}
