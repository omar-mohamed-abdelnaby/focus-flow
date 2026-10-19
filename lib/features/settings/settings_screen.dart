import 'package:flutter/material.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:focus_flow/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focus_flow/core/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:focus_flow/core/theme/theme_provider.dart';
import 'package:local_auth/local_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> _authenticate() async {
    try {
      final bool isSupported = await _auth.isDeviceSupported();

      if (!isSupported) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Device authentication is not supported'),
            ),
          );
        }
        return false;
      }

      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      return authenticated;
    } catch (e) {
      debugPrint('Authentication Error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication Error: $e'),
          ),
        );
      }

      return false;
    }
  }

  @override
  void initState() {
    super.initState();

    final settingsBox = Hive.box('settings');

    pomodoroMinutes =
        settingsBox.get('pomodoroMinutes', defaultValue: 25);

    shortBreakMinutes =
        settingsBox.get('shortBreakMinutes', defaultValue: 5);

    autoStartBreaks =
        settingsBox.get('autoStartBreaks', defaultValue: false);
  }

  Color _bg(BuildContext context) =>
      Theme
          .of(context)
          .scaffoldBackgroundColor;

  Color _card(BuildContext context) =>
      Theme
          .of(context)
          .colorScheme
          .surface;

  Color _text(BuildContext context) =>
      Theme
          .of(context)
          .colorScheme
          .onSurface;

  Color _accent(BuildContext context) =>
      Theme
          .of(context)
          .colorScheme
          .primary;

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "Light";
      case ThemeMode.dark:
        return "Dark";
      default:
        return "System";
    }
  }

  void _showThemeDialog(ThemeNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  title: const Text("System"),
                  value: ThemeMode.system,
                  groupValue: notifier.themeMode,
                  onChanged: (value) {
                    notifier.setTheme(value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text("Light"),
                  value: ThemeMode.light,
                  groupValue: notifier.themeMode,
                  onChanged: (value) {
                    notifier.setTheme(value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text("Dark"),
                  value: ThemeMode.dark,
                  groupValue: notifier.themeMode,
                  onChanged: (value) {
                    notifier.setTheme(value!);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool soundEnabled = true;
  int pomodoroMinutes = 25;
  int shortBreakMinutes = 5;
  bool autoStartBreaks = false;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    final userBox = Hive.box<UserModel>('user');
    final user = userBox.isNotEmpty ? userBox.getAt(0) : null;

    return Scaffold(
      backgroundColor: _bg(context),
      appBar: AppBar(
        backgroundColor: _bg(context),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _text(context)),
        title: Text(
          "Settings",
          style: TextStyle(
            color: _text(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildProfileCard(user),
          const SizedBox(height: 30),

          _buildSectionTitle("Appearance"),

          _buildSettingsGroup([
            _buildListTile(
              icon: Icons.palette_outlined,
              iconColor: Colors.indigoAccent,
              title: "Appearance",
              subtitle: _getThemeName(themeNotifier.themeMode),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              ),
              onTap: () => _showThemeDialog(themeNotifier),
            ),
          ]),

          const SizedBox(height: 24), _buildSectionTitle("Focus Preferences"),

          _buildSettingsGroup([
            _buildListTile(
              icon: Icons.timer_rounded,
              iconColor: Colors.tealAccent,
              title: "Pomodoro Length",
              subtitle: "$pomodoroMinutes minutes",
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () =>
                  _showTimePicker(
                    title: "Pomodoro Length",
                    currentValue: pomodoroMinutes,
                    minValue: 1,
                    maxValue: 180,
                    onSave: (value) async {
                      await Hive.box('settings').put(
                        'pomodoroMinutes',
                        value,
                      );

                      setState(() {
                        pomodoroMinutes = value;
                      });
                    },
                  ),
            ),

            _buildDivider(),

            _buildListTile(
              icon: Icons.coffee_rounded,
              iconColor: Colors.orangeAccent,
              title: "Short Break",
              subtitle: "$shortBreakMinutes minutes",
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () =>
                  _showTimePicker(
                    title: "Short Break",
                    currentValue: shortBreakMinutes,
                    minValue: 1,
                    maxValue: 60,
                    onSave: (value) async {
                      await Hive.box('settings').put(
                        'shortBreakMinutes',
                        value,
                      );

                      setState(() {
                        shortBreakMinutes = value;
                      });
                    },
                  ),
            ),

            _buildDivider(),

            _buildSwitchTile(
              icon: Icons.autorenew_rounded,
              iconColor: Colors.blueAccent,
              title: "Auto-start Breaks",
              value: autoStartBreaks,
              onChanged: (value) async {
                await Hive.box('settings').put(
                  'autoStartBreaks',
                  value,
                );

                setState(() {
                  autoStartBreaks = value;
                });
              },
            ),
          ]),

          const SizedBox(height: 24),

          _buildSectionTitle("Notifications & Sounds"),

          _buildSettingsGroup([
            _buildSwitchTile(
              icon: Icons.volume_up_rounded,
              iconColor: Colors.purpleAccent,
              title: "Sound Effects",
              value: soundEnabled,
              onChanged: (value) {
                setState(() {
                  soundEnabled = value;
                });
              },
            ),

            _buildDivider(),

            _buildListTile(
              icon: Icons.notifications_active_rounded,
              iconColor: Colors.pinkAccent,
              title: "Test Notification",
              subtitle: "Send a sample alert",
              onTap: () async {
                await NotificationService.testNotification();
              },
            ),
          ]),

          const SizedBox(height: 24),

          _buildSectionTitle("Data Management"),

          _buildSettingsGroup([
            _buildListTile(
              icon: Icons.restart_alt_rounded,
              iconColor: Colors.amber,
              title: "Reset Statistics",
              subtitle: "Clear all focus sessions data",
              onTap: () async {
                final authenticated = await _authenticate();

                if (authenticated) {
                  await _handleResetStatistics();
                }
              },
            ),

            _buildDivider(),

            _buildListTile(
              icon: Icons.delete_forever_rounded,
              iconColor: Colors.redAccent,
              title: "Delete All Tasks",
              subtitle: "This action cannot be undone",
              titleColor: Colors.redAccent,
              onTap: () async {
                final authenticated = await _authenticate();

                if (authenticated) {
                  await _handleDeleteAllTasks();
                }
              },
            ),
          ]),

          const SizedBox(height: 40),

          const Center(
            child: Text(
              "FocusFlow v1.0.0\n© 2026 Omar Mohamed Abdelnaby. All Rights Reserved.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

//==========================================================
// Widgets
//==========================================================
  Widget _buildProfileCard(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accent(context).withOpacity(0.15),
            ),
            child: Icon(
              Icons.person_rounded,
              color: _accent(context),
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? "Set your name",
                  style: TextStyle(
                    color: _text(context),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),


                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _accent(context).withOpacity(.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Goal: ${user?.goal ?? "Study"}",
                    style: TextStyle(
                      color: _accent(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // التعديل يفتح من القلم فقط
          IconButton(
            onPressed: () => _editProfileDialog(user),
            icon: Icon(
              Icons.edit_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        bottom: 8,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade500,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme
              .of(context)
              .dividerColor
              .withOpacity(.15),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 4,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? _text(context),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
        subtitle,
        style: TextStyle(
          color: Theme
              .of(context)
              .textTheme
              .bodySmall
              ?.color,
        ),
      ),
      trailing: trailing,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: _accent(context),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 4,
      ),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _text(context),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 64,
      color: Theme
          .of(context)
          .dividerColor
          .withOpacity(.15),
    );
  }

  void _showTimePicker({
    required String title,
    required int currentValue,
    required int minValue,
    required int maxValue,
    required ValueChanged<int> onSave,
  }) {
    int selectedValue = currentValue;
    final controller =
    TextEditingController(text: currentValue.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(
                bottom: MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: selectedValue > minValue
                              ? () {
                            setModalState(() {
                              selectedValue--;
                              controller.text =
                                  selectedValue.toString();
                            });
                          }
                              : null,
                          icon: const Icon(Icons.remove),
                        ),

                        const SizedBox(width: 16),

                        SizedBox(
                          width: 125,
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              suffixText: "min",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              final number = int.tryParse(value);

                              if (number != null &&
                                  number >= minValue &&
                                  number <= maxValue) {
                                setModalState(() {
                                  selectedValue = number;
                                });
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        IconButton.filled(
                          onPressed: selectedValue < maxValue
                              ? () {
                            setModalState(() {
                              selectedValue++;
                              controller.text =
                                  selectedValue.toString();
                            });
                          }
                              : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final typedValue =
                          int.tryParse(controller.text);

                          if (typedValue == null ||
                              typedValue < minValue ||
                              typedValue > maxValue) {
                            return;
                          }

                          onSave(typedValue);
                          Navigator.pop(sheetContext);
                        },
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

//==========================================================
// Logic
//==========================================================
  Future<void> _editProfileDialog(UserModel? user) async {
    final nameController = TextEditingController(text: user?.name);

    String selectedGoal = user?.goal ?? "Study";

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: _card(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: Text(
                "Edit Profile",
                style: TextStyle(
                  color: _text(context),
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    _buildDialogTextField(
                      controller: nameController,
                      label: "Name",
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 16),


                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: selectedGoal,

                      dropdownColor: _card(context),

                      style: TextStyle(
                        color: _text(context),
                      ),

                      decoration: InputDecoration(
                        labelText: "Main Goal",
                        prefixIcon: const Icon(Icons.flag),

                        filled: true,
                        fillColor: _bg(context),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),

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
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent(context),
                  ),

                  onPressed: () async {
                    if (user != null) {
                      user.name = nameController.text.trim();
                      user.goal = selectedGoal;

                      await user.save();
                    }

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
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,

      style: TextStyle(
        color: _text(context),
      ),

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon),

        filled: true,
        fillColor: _bg(context),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _handleDeleteAllTasks() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) =>
          AlertDialog(
            backgroundColor: _card(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Delete All Tasks",
              style: TextStyle(
                color: _text(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "Are you sure you want to delete all tasks?\nThis action cannot be undone.",
              style: TextStyle(
                color: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium
                    ?.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
    );

    if (result == true) {
      final taskBox = Hive.box<TaskModel>('tasks');

      await taskBox.clear();
      await NotificationService.cancelAll();

      if (!mounted) return;

      _showDarkSnackbar("All tasks deleted");
    }
  }

  Future<void> _handleResetStatistics() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) =>
          AlertDialog(
            backgroundColor: _card(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Reset Statistics",
              style: TextStyle(
                color: _text(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "Are you sure you want to reset all statistics?\nThis action cannot be undone.",
              style: TextStyle(
                color: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium
                    ?.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Reset"),
              ),
            ],
          ),
    );

    if (result == true) {
      final focusBox = Hive.box('focus');

      await focusBox.clear();

      if (!mounted) return;

      _showDarkSnackbar("Statistics reset successfully");
    }
  }

  void _showDarkSnackbar(String message) {
    final scheme = Theme
        .of(context)
        .colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: scheme.inverseSurface,
        content: Text(
          message,
          style: TextStyle(
            color: scheme.onInverseSurface,
          ),
        ),
      ),
    );
  }
}