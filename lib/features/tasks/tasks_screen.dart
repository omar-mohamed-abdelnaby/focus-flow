import 'package:flutter/material.dart';
import 'package:focus_flow/features/tasks/add_task_screen.dart';
import 'package:focus_flow/features/widgets/empty_state.dart';
import 'package:focus_flow/features/widgets/task_card.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

// تأكد من استيراد الملف الذي يحتوي على الـ extensions الخاصة بـ context (مثل context.scheme)
// import 'package:focus_flow/core/theme/theme_extension.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  Box<TaskModel> get box => Hive.box<TaskModel>('tasks');
  final TextEditingController searchController = TextEditingController();
  String search = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
    // تحديث الواجهة بعد العودة في حال تم إضافة مهمة
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // بناءً على الـ extensions، نفترض أن:
    // context.scheme = Theme.of(context).colorScheme
    // context.theme = Theme.of(context)

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "My Tasks",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.scheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.scheme.onSurface),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTask,
        // استخدمنا لون primary للزر الأساسي ليتوافق مع كلا الوضعين
        backgroundColor: context.scheme.primary,
        foregroundColor: context.scheme.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text("New Task", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<TaskModel> box, _) {
          final tasks = box.values.toList();
          final filteredTasks = tasks.where((task) {
            return task.title.toLowerCase().contains(search.toLowerCase());
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: TextField(
                  controller: searchController,
                  style: TextStyle(color: context.scheme.onSurface),
                  // افتراض أن لديك extension يجلب اللون المميز (أو استخدام primary)
                  cursorColor: context.scheme.primary,
                  onChanged: (value) => setState(() => search = value),
                  decoration: InputDecoration(
                    hintText: "Search tasks...",
                    hintStyle: TextStyle(color: context.scheme.onSurface.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search_rounded, color: context.scheme.onSurface.withOpacity(0.5)),
                    filled: true,
                    fillColor: context.scheme.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      // إذا لم يكن لديك context.borderColor، يمكنك استخدام onSurface بشفافية
                      borderSide: BorderSide(color: context.scheme.onSurface.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: context.scheme.primary.withOpacity(0.5), width: 1.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              if (tasks.isEmpty)
                Expanded(
                  child: Center(
                    child: EmptyState(
                      icon: Icons.task_alt_rounded,
                      title: "No Tasks Yet 🎯",
                      subtitle: "Press the button below\nand start your productivity journey.",
                    ),
                  ),
                )
              else if (filteredTasks.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      "No tasks match your search.",
                      style: TextStyle(color: context.scheme.onSurface.withOpacity(0.6), fontSize: 16),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredTasks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];

                      return Dismissible(
                        key: ValueKey(task.key),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: context.scheme.surface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Text(
                                  "Delete Task",
                                  style: TextStyle(color: context.scheme.onSurface, fontWeight: FontWeight.bold),
                                ),
                                content: Text(
                                  'Are you sure you want to delete "${task.title}"?',
                                  style: TextStyle(color: context.scheme.onSurface.withOpacity(0.7)),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text("Cancel", style: TextStyle(color: context.scheme.onSurface.withOpacity(0.6))),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: context.scheme.error.withOpacity(0.2),
                                      foregroundColor: context.scheme.error,
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
                          decoration: BoxDecoration(
                            color: context.scheme.error, // استخدام لون الخطأ من الثيم
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: Icon(Icons.delete_outline_rounded, color: context.scheme.onError, size: 28),
                        ),
                        onDismissed: (_) async {
                          await box.delete(task.key);
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${task.title} deleted", style: TextStyle(color: context.scheme.onInverseSurface)),
                              backgroundColor: context.scheme.inverseSurface,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        },
                        child: TaskCard(
                          task: task,
                          onEdit: () async {
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
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}