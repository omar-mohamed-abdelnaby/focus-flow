import 'package:flutter/material.dart';
import 'package:focus_flow/features/focus/focus_screen.dart';
import 'package:focus_flow/features/statistics/statistics_screen.dart';
import 'package:focus_flow/features/tasks/add_task_screen.dart';
import 'package:focus_flow/features/widgets/action_card.dart';
import 'package:focus_flow/features/widgets/home_task_tile.dart';
import 'package:focus_flow/features/widgets/progress_card.dart';
import 'package:focus_flow/features/widgets/section_title.dart';
import 'package:focus_flow/features/widgets/streak_card.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:focus_flow/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const HomeScreen({
    super.key,
    this.onProfileTap,
  });

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
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final box = Hive.box<TaskModel>('tasks');
    final focusBox = Hive.box('focus');
    final userBox = Hive.box<UserModel>('user');

    // Safe handling if user is not yet created
    final user = userBox.isNotEmpty ? userBox.getAt(0) : null;

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
      // لون خلفية داكن وأنيق جداً (Dark Gray/Black)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // حركة سلسة عند النزول
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(color: text.bodyMedium?.color, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.name ?? "User",
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),

          InkWell(
            onTap: widget.onProfileTap,
            borderRadius: BorderRadius.circular(50),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.indigoAccent.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: Colors.indigoAccent,
                size: 30,
              ),
            ),
          ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Let's make today productive!",
                style: TextStyle(
                  color: scheme.onSurface.withOpacity(.65),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),

              // --- Progress & Streak ---
              ProgressCard(
                progress: progress,
                completedTasks: completedTasks,
                totalTasks: tasks.length,
              ),
              const SizedBox(height: 16),
              StreakCard(sessions: sessions),
              const SizedBox(height: 36),

              // --- Quick Actions ---
              const SectionTitle(title: "Quick Actions"),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ActionCard(
                      icon: Icons.add_rounded,
                      title: "Add Task",
                      onTap: _openAddTask,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ActionCard(
                      icon: Icons.timer_rounded, // أيقونات مدورة أفضل في الـ Modern UI
                      title: "Focus",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FocusScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ActionCard(
                      icon: Icons.insert_chart_rounded,
                      title: "Stats",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- Tasks List ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle(title: "Today's Tasks"),
                  if (tasks.isNotEmpty)
                    Text(
                      "$completedTasks/${tasks.length} done",
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<TaskModel> box, _) {
                  final tasksList = box.values.toList();

                  if (tasksList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 60,
                              color: scheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "All caught up!",
                              style: TextStyle(
                                color: scheme.onSurface.withOpacity(.7),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasksList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12), // مسافة بين المهام
                    itemBuilder: (context, index) {
                      final task = tasksList[index];

                      return Dismissible(
                        key: ValueKey(task.key),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: scheme.surface, // ديالوج داكن
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Text(
                                  "Delete Task",
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to delete "${task.title}"?',
                                  style: TextStyle(color: Colors.grey.shade400),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text("Cancel", style: TextStyle(color: Colors.grey.shade500)),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.redAccent.withOpacity(0.2), // زر حذف هادئ
                                      foregroundColor: Colors.redAccent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          ) ?? false;
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16), // نفس دوران كارت المهمة
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: scheme.onInverseSurface,
                            size: 30,
                          ),
                        ),
                        onDismissed: (_) async {
                          await box.delete(task.key);
                          if (!mounted) return;

                          // SnackBar متوافق مع الـ Dark Mode
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${task.title} deleted", style: const TextStyle(color: Colors.white)),
                              backgroundColor: scheme.inverseSurface,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        },
                        child: HomeTaskTile(
                          task: task,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}