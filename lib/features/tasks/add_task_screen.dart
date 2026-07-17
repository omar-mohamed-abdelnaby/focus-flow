import 'package:flutter/material.dart';
import 'package:focus_flow/core/services/notification_service.dart';

import 'package:focus_flow/models/task_model.dart';
import 'package:hive/hive.dart';

class AddTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String priority = "Medium";

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay.now();

  bool reminderEnabled = true;

  int reminderMinutes = 10;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      titleController.text = widget.task!.title;
      descriptionController.text = widget.task!.description;

      priority = widget.task!.priority;

      selectedDate = widget.task!.dueDate;

      selectedTime = TimeOfDay(
        hour: widget.task!.dueDate.hour,
        minute: widget.task!.dueDate.minute,
      );

      reminderEnabled = widget.task!.reminderEnabled;

      reminderMinutes = widget.task!.reminderMinutes;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.task == null ? "Add Task" : "Edit Task"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      widget.task == null ? "Create New Task" : "Edit Task",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text("Stay organized and never miss your deadlines."),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Task Title",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: titleController,

                textInputAction: TextInputAction.next,

                decoration: InputDecoration(
                  hintText: "Enter task title",

                  prefixIcon: const Icon(Icons.title),

                  filled: true,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: descriptionController,

                maxLines: 4,

                decoration: InputDecoration(
                  hintText: "Describe your task...",

                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 70),
                    child: Icon(Icons.notes),
                  ),

                  filled: true,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),
              const Text(
                "Priority",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: priority,

                decoration: InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                items: const [
                  DropdownMenuItem(value: "High", child: Text("🔴 High")),
                  DropdownMenuItem(value: "Medium", child: Text("🟡 Medium")),
                  DropdownMenuItem(value: "Low", child: Text("🟢 Low")),
                ],

                onChanged: (value) {
                  setState(() {
                    priority = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              const Text(
                "Schedule",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.calendar_month),

                        title: const Text("Date"),

                        subtitle: Text(
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        ),

                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2035),
                          );

                          if (picked != null) {
                            setState(() {
                              selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                selectedTime.hour,
                                selectedTime.minute,
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.access_time),

                        title: const Text("Time"),

                        subtitle: Text(selectedTime.format(context)),

                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );

                          if (picked != null) {
                            setState(() {
                              selectedTime = picked;

                              selectedDate = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                picked.hour,
                                picked.minute,
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Text(
                "Reminder",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Card(
                elevation: 2,
                child: SwitchListTile(
                  secondary: const Icon(Icons.notifications_active),
                  title: const Text("Enable Reminder"),
                  subtitle: const Text(
                    "Receive a notification before the task is due",
                  ),
                  value: reminderEnabled,
                  onChanged: (value) {
                    setState(() {
                      reminderEnabled = value;
                    });
                  },
                ),
              ),

              if (reminderEnabled) ...[
                const SizedBox(height: 15),

                DropdownButtonFormField<int>(
                  value: reminderMinutes,

                  decoration: InputDecoration(
                    labelText: "Notify me",
                    prefixIcon: const Icon(Icons.alarm),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  items: const [
                    DropdownMenuItem(value: 0, child: Text("At time")),

                    DropdownMenuItem(value: 5, child: Text("5 minutes before")),

                    DropdownMenuItem(
                      value: 10,
                      child: Text("10 minutes before"),
                    ),

                    DropdownMenuItem(
                      value: 30,
                      child: Text("30 minutes before"),
                    ),

                    DropdownMenuItem(value: 60, child: Text("1 hour before")),
                  ],

                  onChanged: (value) {
                    setState(() {
                      reminderMinutes = value!;
                    });
                  },
                ),
              ],

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter task title"),
                        ),
                      );
                      return;
                    }

                    try {
                      if (widget.task == null) {
                        final task = TaskModel(
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          priority: priority,
                          dueDate: selectedDate,
                          reminderEnabled: reminderEnabled,
                          reminderMinutes: reminderMinutes,
                        );

                        final box = Hive.box<TaskModel>('tasks');

                        await box.add(task);

                        if (task.reminderEnabled) {
                          final reminderDate = task.dueDate.subtract(
                            Duration(minutes: task.reminderMinutes),
                          );

                          await NotificationService.scheduleNotification(
                            id: task.key as int,
                            title: task.title,
                            body: "Task is due soon.",
                            date: reminderDate,
                          );
                        }
                      } else {
                        widget.task!.title = titleController.text.trim();
                        widget.task!.description = descriptionController.text.trim();
                        widget.task!.priority = priority;
                        widget.task!.dueDate = selectedDate;
                        widget.task!.reminderEnabled = reminderEnabled;
                        widget.task!.reminderMinutes = reminderMinutes;

                        await widget.task!.save();

                        if (widget.task!.reminderEnabled) {
                          final reminderDate = widget.task!.dueDate.subtract(
                            Duration(minutes: widget.task!.reminderMinutes),
                          );

                          await NotificationService.scheduleNotification(
                            id: widget.task!.key as int,
                            title: widget.task!.title,
                            body: "Task is due soon.",
                            date: reminderDate,
                          );
                        } else {
                          await NotificationService.cancel(
                            widget.task!.key as int,
                          );
                        }
                      }

                      if (!mounted) return;

                      Navigator.pop(context);
                    } catch (e) {
                      debugPrint(e.toString());

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Save Task",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
