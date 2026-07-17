import 'package:flutter/material.dart';
import 'package:focus_flow/core/widgets/action_card.dart';
import 'package:focus_flow/core/widgets/home_task_tile.dart';
import 'package:focus_flow/core/widgets/progress_card.dart';
import 'package:focus_flow/core/widgets/section_title.dart';
import 'package:focus_flow/core/widgets/streak_card.dart';
import 'package:focus_flow/features/focus/focus_screen.dart';
import 'package:focus_flow/features/statistics/statistics_screen.dart';
import 'package:focus_flow/features/tasks/add_task_screen.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:focus_flow/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focus_flow/core/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Box<TaskModel> get box => Hive.box<TaskModel>('tasks');

  List<TaskModel> get tasks => box.values.toList();

  int get completedTasks => tasks.where((task) => task.isCompleted).length;

  double get progress {
    if (tasks.isEmpty) return 0;
    return completedTasks / tasks.length;
  }

  Future<void> _openAddTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TaskModel>('tasks');

    final focusBox = Hive.box('focus');
    final userBox = Hive.box<UserModel>('user');

    final user = userBox.getAt(0);

    final sessions = focusBox.get('sessions', defaultValue: 0);
    final hour = DateTime.now().hour;

    String greeting;

    if (hour < 12) {
      greeting = "Good Morning 👋";
    } else if (hour < 18) {
      greeting = "Good Afternoon ☀️";
    } else {
      greeting = "Good Evening 🌙";
    }
    return Scaffold(
      backgroundColor: const Color(0xFF111827),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                greeting,
                style: const TextStyle(color: Colors.grey, fontSize: 18),
              ),

              const SizedBox(height: 8),

              Text(
                user?.name ?? "User",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Let's make today productive!",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 25),

              ProgressCard(
                progress: progress,
                completedTasks: completedTasks,
                totalTasks: tasks.length,
              ),

              const SizedBox(height: 20),

              StreakCard(sessions: sessions),

              const SizedBox(height: 30),

              const SectionTitle(title: "Quick Actions"),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ActionCard(
                      icon: Icons.add,
                      title: "Add Task",
                      onTap: _openAddTask,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: ActionCard(
                      icon: Icons.timer,
                      title: "Focus",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FocusScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: ActionCard(
                      icon: Icons.bar_chart,
                      title: "Stats",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StatisticsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const SectionTitle(title: "Today's Tasks"),

              const SizedBox(height: 15),

              ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<TaskModel> box, _) {
                  final tasks = box.values.toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return Dismissible(
                        key: ValueKey(task.key),

                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Delete Task"),
                                content: Text(
                                  'Are you sure you want to delete "${task.title}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text("Cancel"),
                                  ),

                                  FilledButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          ) ??
                              false;
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),

                        onDismissed: (_) async {
                          await box.delete(task.key);

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${task.title} deleted")),
                          );
                        },

                        child: HomeTaskTile(
                          task: task,

                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddTaskScreen(task: task),
                              ),
                            );

                            setState(() {});
                          },

                          onChanged: (value) async {
                            task.isCompleted = value!;

                            await task.save();

                            setState(() {});
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
