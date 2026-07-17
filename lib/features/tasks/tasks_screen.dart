import 'package:flutter/material.dart';
import 'package:focus_flow/core/widgets/empty_state.dart';
import 'package:focus_flow/core/widgets/task_card.dart';
import 'package:focus_flow/features/tasks/add_task_screen.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  Box<TaskModel> get box => Hive.box<TaskModel>('tasks');

  final TextEditingController searchController = TextEditingController();

  String search = "";

  Future<void> _openAddTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),

      appBar: AppBar(title: const Text("My Tasks"), centerTitle: true),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTask,
        child: const Icon(Icons.add),
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
                padding: const EdgeInsets.all(16),

                child: TextField(
                  controller: searchController,

                  onChanged: (value) {
                    setState(() {
                      search = value;
                    });
                  },

                  decoration: InputDecoration(
                    hintText: "Search tasks...",

                    prefixIcon: const Icon(Icons.search),

                    filled: true,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              if (tasks.isEmpty)
                const Expanded(
                  child: EmptyState(
                    icon: Icons.task_alt_rounded,
                    title: "No Tasks Yet 🎯",
                    subtitle:
                        "Press the + button below\nand start your productivity journey.",
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    itemCount: filteredTasks.length,

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
                          margin: const EdgeInsets.only(bottom: 12),

                          decoration: BoxDecoration(
                            color: Colors.red,

                            borderRadius: BorderRadius.circular(15),
                          ),

                          alignment: Alignment.centerRight,

                          padding: const EdgeInsets.only(right: 20),

                          child: const Icon(Icons.delete, color: Colors.white),
                        ),

                        onDismissed: (_) async {
                          await box.delete(task.key);

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${task.title} deleted")),
                          );
                        },

                        child: TaskCard(
                          task: task,
                          onEdit: () async {
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
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
