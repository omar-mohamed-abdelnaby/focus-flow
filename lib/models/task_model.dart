import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  String priority;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  bool isCompleted;

  // جديد
  @HiveField(5)
  bool reminderEnabled;

  // جديد
  @HiveField(6)
  int reminderMinutes;

  TaskModel({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,

    this.reminderEnabled = true,

    this.reminderMinutes = 10,
  });
}