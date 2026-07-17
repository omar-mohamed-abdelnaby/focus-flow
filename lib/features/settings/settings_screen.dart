import 'package:flutter/material.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:focus_flow/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focus_flow/core/services/notification_service.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box<UserModel>('user');

    final user = userBox.getAt(0);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          const Text(
            "Profile",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              onTap: () async {
                final nameController = TextEditingController(text: user?.name);

                final emailController = TextEditingController(
                  text: user?.email,
                );

                String selectedGoal = user?.goal ?? "Study";

                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setStateDialog) {
                        return AlertDialog(
                          title: const Text("Edit Profile"),

                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    labelText: "Name",
                                  ),
                                ),

                                const SizedBox(height: 15),

                                TextField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    labelText: "Email",
                                  ),
                                ),

                                const SizedBox(height: 20),

                                DropdownButton<String>(
                                  value: selectedGoal,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                      value: "Study",
                                      child: Text("Study"),
                                    ),

                                    DropdownMenuItem(
                                      value: "Work",
                                      child: Text("Work"),
                                    ),

                                    DropdownMenuItem(
                                      value: "Personal",
                                      child: Text("Personal"),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      selectedGoal = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text("Cancel"),
                            ),

                            FilledButton(
                              onPressed: () async {
                                user?.name = nameController.text.trim();

                                user?.email = emailController.text.trim();

                                user?.goal = selectedGoal;

                                await user?.save();

                                if (!mounted) return;

                                Navigator.pop(context, true);
                              },
                              child: const Text("Save"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );

                if (result == true) {
                  setState(() {});
                }
              },

              leading: const CircleAvatar(child: Icon(Icons.person)),

              title: Text(user?.name ?? ""),

              subtitle: Text(
                user?.email ?? "No Email",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Goal",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          Card(
            child: ListTile(
              leading: const Icon(Icons.flag),
              title: Text(user?.goal ?? ""),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Data",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          Card(
            child: ListTile(
              onTap: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Text("Delete All Tasks"),
                      content: const Text(
                        "Are you sure you want to delete all tasks?\n\nThis action cannot be undone.",
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
                );

                if (result != true) return;

                final taskBox = Hive.box<TaskModel>('tasks');

                await taskBox.clear();

                await NotificationService.cancelAll();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All tasks deleted")),
                );
              },

              leading: const Icon(Icons.delete_forever, color: Colors.red),

              title: const Text("Delete All Tasks"),

              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            ),
          ),

          Card(
            child: ListTile(
              onTap: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Text("Reset Statistics"),
                      content: const Text(
                        "Are you sure you want to reset all statistics?\n\nThis action cannot be undone.",
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
                          child: const Text("Reset"),
                        ),
                      ],
                    );
                  },
                );

                if (result != true) return;

                final focusBox = Hive.box('focus');

                await focusBox.clear();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Statistics reset")),
                );
              },

              leading: const Icon(Icons.restart_alt, color: Colors.orange),

              title: const Text("Reset Statistics"),

              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Test Notification"),
              subtitle: const Text("Send a test notification"),
              onTap: () async {
                await NotificationService.testNotification();
              },
            ),
          ),

          const SizedBox(height: 30),

          const Center(
            child: Text("FocusFlow v1.0", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
