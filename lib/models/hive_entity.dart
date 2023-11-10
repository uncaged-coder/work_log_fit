import 'package:hive/hive.dart';

class HiveEntity extends HiveObject {
  HiveEntity();

  bool useImage() {
    return false;
  }

  bool useGroup() {
    return false;
  }

  String getImageIcon() {
    return '';
  }
}
