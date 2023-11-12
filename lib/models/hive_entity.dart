import 'package:hive/hive.dart';
import 'package:work_log_fit/hive_manager.dart';

class HiveEntity extends HiveObject {
  String baseName;

  HiveEntity({required this.baseName});

  bool useImage() {
    return false;
  }

  bool useGroup() {
    return false;
  }

  String getImageIcon() {
    return '';
  }

  void remove() async {
    var box = HiveManager().getDataBox(baseName);
    box.delete(this.key);
  }
}
