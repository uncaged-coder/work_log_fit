import 'package:work_log_fit/models/exercise.dart';

class MuscleGroups {
  static const String abs = 'abs';
  static const String biceps = 'biceps';
  static const String triceps = 'triceps';
  static const String legs = 'legs';
  static const String chest = 'chest';
  static const String shoulder = 'shoulder';
  static const String back = 'back';
  static const String other = 'other';
}

class ExerciseManager {
// Singleton instance
  static final ExerciseManager _instance = ExerciseManager._internal();

  // Factory constructor
  factory ExerciseManager() {
    return _instance;
  }

  // Internal constructor
  ExerciseManager._internal() {
    // Initialize your data here
  }

  // Predefined categories and exercises
  final Map<String, List<Exercise>> categories = {
    'Abs': [
      Exercise(pkey: 0, name: 'Crunches', muscleGroup: MuscleGroups.abs),
      Exercise(
          pkey: 1,
          name: 'Flat bench leg raises',
          muscleGroup: MuscleGroups.abs),
    ],
    'Biceps': [
      Exercise(
          pkey: 2,
          name: 'Preacher curl with machine',
          muscleGroup: MuscleGroups.biceps),
      Exercise(
          pkey: 3,
          name: 'Standing biceps curl with cable',
          muscleGroup: MuscleGroups.biceps),
    ],
    'Triceps': [
      Exercise(
          pkey: 4,
          name: 'Triceps dips using body weight',
          muscleGroup: MuscleGroups.triceps),
      Exercise(
          pkey: 5, name: 'Triceps Dips', muscleGroup: MuscleGroups.triceps),
      Exercise(
          pkey: 6,
          name: 'Triceps pushdown with rope and cable',
          muscleGroup: MuscleGroups.triceps),
      Exercise(
          pkey: 7,
          name: 'Triceps pushdown with cable',
          muscleGroup: MuscleGroups.triceps),
      Exercise(
          pkey: 8,
          name: 'Triceps extensions using machine',
          muscleGroup: MuscleGroups.triceps),
      Exercise(
          pkey: 9,
          name: 'Straight Arm Push down',
          muscleGroup: MuscleGroups.triceps),
    ],
    'Legs': [
      Exercise(pkey: 10, name: 'Leg press', muscleGroup: MuscleGroups.legs),
      Exercise(pkey: 11, name: 'Barbell squat', muscleGroup: MuscleGroups.legs),
      Exercise(
          pkey: 12, name: 'Leg extensions', muscleGroup: MuscleGroups.legs),
      Exercise(
          pkey: 13,
          name: 'Lying leg curl machine',
          muscleGroup: MuscleGroups.legs),
      Exercise(
          pkey: 14, name: 'Seated leg curl', muscleGroup: MuscleGroups.legs),
      Exercise(
          pkey: 15,
          name: 'Smith machine squats',
          muscleGroup: MuscleGroups.legs),
      Exercise(
          pkey: 16, name: 'Thigh abductor', muscleGroup: MuscleGroups.legs),
    ],
    'Chest': [
      Exercise(
          pkey: 17, name: 'Butterfly machine', muscleGroup: MuscleGroups.chest),
      Exercise(
          pkey: 18,
          name: 'Machine bench press',
          muscleGroup: MuscleGroups.chest),
      Exercise(
          pkey: 19,
          name: 'Incline chest press',
          muscleGroup: MuscleGroups.chest),
      Exercise(pkey: 20, name: 'Bench press', muscleGroup: MuscleGroups.chest),
      Exercise(
          pkey: 21,
          name: 'Smith machine bench press',
          muscleGroup: MuscleGroups.chest),
      Exercise(pkey: 22, name: 'Push ups', muscleGroup: MuscleGroups.chest),
    ],
    'Shoulder': [
      Exercise(
          pkey: 23,
          name: 'Seated Shoulder press machine',
          muscleGroup: MuscleGroups.shoulder),
    ],
    'Back': [
      Exercise(
          pkey: 24,
          name: 'Wide grip lat pull down',
          muscleGroup: MuscleGroups.back),
      Exercise(
          pkey: 25, name: 'Seated cable rows', muscleGroup: MuscleGroups.back),
      Exercise(pkey: 26, name: 'Pull ups', muscleGroup: MuscleGroups.back),
      Exercise(
          pkey: 27, name: 'Hyperextensions', muscleGroup: MuscleGroups.back),
    ],
    'Other': [],
  };

  Exercise? getExerciseByKey(int key) {
    // Iterate through each category
    for (var categoryExercises in categories.values) {
      // Search for the exercise with the matching key
      for (var exercise in categoryExercises) {
        if (exercise.pkey == key) {
          return exercise;
        }
      }
    }

    // Return null if the exercise is not found
    return null;
  }
}
