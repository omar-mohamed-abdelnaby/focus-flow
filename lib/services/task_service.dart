import '../models/task_model.dart';

class TaskService {
  static List<TaskModel> tasks = [
    TaskModel(
      title: "Flutter Project",
      description: "Complete Home Screen",
      priority: "High",
      dueDate: DateTime.now(),
    ),

    TaskModel(
      title: "Summer Training",
      description: "Finish Flutter App",
      priority: "Medium",
      dueDate: DateTime.now(),
    ),

    TaskModel(
      title: "Database Assignment",
      description: "Solve SQL Questions",
      priority: "Low",
      dueDate: DateTime.now(),
      isCompleted: true,
    ),
  ];
}
