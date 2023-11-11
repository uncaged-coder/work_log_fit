import 'package:hive/hive.dart';
import 'hive_type_ids.dart';
import 'hive_entity.dart';
part 'exercise.g.dart';

@HiveType(typeId: HiveTypeIds.exercise)
class Exercise extends HiveEntity {
  @HiveField(0)
  final String name;

  @HiveField(1)
  String image;

  @HiveField(2)
  String muscleGroup;

  @HiveField(3)
  int programId;

  bool customExercise;

  Exercise({
    required this.name,
    this.programId = 0,
    required this.muscleGroup,
    this.image = '',
    this.customExercise = false,
  }) : super();

  @override
  bool useImage() {
    return true;
  }

  @override
  String getImageIcon() {
    if (image.isNotEmpty) {
      return 'assets/user_images/$image';
    }

    String formattedName = name.toLowerCase().replaceAll(' ', '-');
    return 'assets/icons/$muscleGroup/$formattedName-icon.png';
  }

  @override
  bool useGroup() {
    return true;
  }
}
