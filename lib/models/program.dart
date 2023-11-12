import 'package:hive/hive.dart';
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
        super();

  @override
  bool useImage() {
    return true;
  }

  @override
  String getImageIcon() {
    return 'assets/program_icon.png';
  }
}
