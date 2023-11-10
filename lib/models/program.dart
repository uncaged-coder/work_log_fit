import 'package:hive/hive.dart';
import 'hive_type_ids.dart';
import 'hive_entity.dart';
part 'program.g.dart';

@HiveType(typeId: HiveTypeIds.program)
class Program extends HiveEntity {
  @HiveField(0)
  final String name;

  Program({required this.name}) : super();

  @override
  bool useImage() {
    return true;
  }

  @override
  String getImageIcon() {
    return 'assets/program_icon.png';
  }
}
