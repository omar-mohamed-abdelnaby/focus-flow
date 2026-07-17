import 'package:hive/hive.dart';

class HiveService {
  static final Box box = Hive.box('tasks');

  static List getTasks() {
    return box.values.toList();
  }

  static Future<void> addTask(Map<String, dynamic> task) async {
    await box.add(task);
  }

  static Future<void> deleteTask(int index) async {
    await box.deleteAt(index);
  }

  static Future<void> updateTask(int index, Map<String, dynamic> task) async {
    await box.putAt(index, task);
  }
}
