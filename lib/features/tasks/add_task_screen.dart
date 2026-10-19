import 'package:flutter/material.dart';
import 'package:focus_flow/core/services/notification_service.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:hive/hive.dart';

// Extension عشان نمنع تكرار كود الـ Theme ونخلي الكود أنظف وأسهل في القراءة
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get scheme => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;
  Color get borderColor =>
      isDark ? Colors.white.withOpacity(0.10) : theme.dividerColor;
  Color get accentColor => Colors.indigoAccent;
}

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
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: context.scheme.onSurface),
        title: Text(
          widget.task == null ? "Add Task" : "Edit Task",
          style: TextStyle(color: context.scheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الهيدر الترحيبي
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.accentColor.withOpacity(0.2), context.accentColor.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.accentColor.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task == null ? "Create New Task" : "Edit Task",
                      style: TextStyle(
                        color: context.scheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Stay organized and never miss your deadlines.",
                      style: TextStyle(color: context.scheme.onSurface.withOpacity(.7), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // العنوان
              _buildSectionTitle(context, "Task Title"),
              const SizedBox(height: 12),
              _buildTextField(
                context: context,
                controller: titleController,
                hintText: "What do you need to do?",
                icon: Icons.title_rounded,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 24),

              // الوصف
              _buildSectionTitle(context, "Description"),
              const SizedBox(height: 12),
              _buildTextField(
                context: context,
                controller: descriptionController,
                hintText: "Add details or notes...",
                icon: Icons.notes_rounded,
                maxLines: 4,
              ),

              const SizedBox(height: 24),

              // الأولوية
              _buildSectionTitle(context, "Priority"),
              const SizedBox(height: 12),
              _buildDropdown(context),

              const SizedBox(height: 32),

              // التاريخ والوقت
              _buildSectionTitle(context, "Schedule"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPickerCard(
                      context: context,
                      title: "Date",
                      value: "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      icon: Icons.calendar_month_rounded,
                      color: Colors.blueAccent,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2035),
                          builder: (context, child) {
                            return Theme(
                              data: context.theme.copyWith(
                                colorScheme: context.isDark
                                    ? ColorScheme.dark(
                                  primary: context.accentColor,
                                  surface: context.scheme.surface,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.white,
                                )
                                    : ColorScheme.light(
                                  primary: context.accentColor,
                                  surface: context.scheme.surface,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPickerCard(
                      context: context,
                      title: "Time",
                      value: selectedTime.format(context),
                      icon: Icons.access_time_rounded,
                      color: Colors.orangeAccent,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (context, child) {
                            return Theme(
                              data: context.theme.copyWith(
                                colorScheme: context.isDark
                                    ? ColorScheme.dark(
                                  primary: context.accentColor,
                                  surface: context.scheme.surface,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.white,
                                )
                                    : ColorScheme.light(
                                  primary: context.accentColor,
                                  surface: context.scheme.surface,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
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
                ],
              ),

              const SizedBox(height: 32),

              // التذكير
              _buildSectionTitle(context, "Reminder"),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: context.scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.borderColor),
                ),
                child: SwitchListTile(
                  activeThumbColor: context.accentColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.notifications_active_rounded, color: context.accentColor),
                  ),
                  title: Text(
                    "Enable Reminder",
                    style: TextStyle(color: context.scheme.onSurface, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "Notify me before the task is due",
                    style: TextStyle(color: context.scheme.onSurface.withOpacity(0.6), fontSize: 12),
                  ),
                  value: reminderEnabled,
                  onChanged: (value) => setState(() => reminderEnabled = value),
                ),
              ),

              if (reminderEnabled) ...[
                const SizedBox(height: 16),
                _buildReminderDropdown(context),
              ],

              const SizedBox(height: 48),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: context.accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _saveTask,
                  child: Text(
                    widget.task == null ? "Create Task" : "Save Changes",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // عناوين الأقسام
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(color: context.scheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  // مربعات إدخال النصوص
  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputAction? textInputAction,
  }) {
    final hintColor = context.scheme.onSurface.withOpacity(0.6);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: textInputAction,
      style: TextStyle(color: context.scheme.onSurface),
      cursorColor: context.accentColor,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 70 : 0),
          child: Icon(icon, color: hintColor),
        ),
        filled: true,
        fillColor: context.scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        // تم إضافة الـ enabledBorder هنا حسب طلبك
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: context.accentColor.withOpacity(0.5), width: 1.5),
        ),
      ),
    );
  }

  // قائمة اختيار الأولوية
  Widget _buildDropdown(BuildContext context) {
    final hintColor = context.scheme.onSurface.withOpacity(0.6);

    return DropdownButtonFormField<String>(
      initialValue: priority,
      dropdownColor: context.scheme.surface,
      style: TextStyle(color: context.scheme.onSurface, fontSize: 16),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: hintColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: context.accentColor.withOpacity(0.5), width: 1.5),
        ),
      ),
      items: const [
        DropdownMenuItem(value: "High", child: Text("🔴 High Priority")),
        DropdownMenuItem(value: "Medium", child: Text("🟡 Medium Priority")),
        DropdownMenuItem(value: "Low", child: Text("🟢 Low Priority")),
      ],
      onChanged: (value) => setState(() => priority = value!),
    );
  }

  // كروت اختيار الوقت والتاريخ
  Widget _buildPickerCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: context.scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor),
          boxShadow: context.isDark
              ? []
              : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: context.scheme.onSurface.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: context.scheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // قائمة اختيار التذكير
  Widget _buildReminderDropdown(BuildContext context) {
    final hintColor = context.scheme.onSurface.withOpacity(0.6);

    return DropdownButtonFormField<int>(
      initialValue: reminderMinutes,
      dropdownColor: context.scheme.surface,
      style: TextStyle(color: context.scheme.onSurface, fontSize: 16),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: hintColor),
      decoration: InputDecoration(
        labelText: "Notify me",
        labelStyle: TextStyle(color: hintColor),
        prefixIcon: Icon(Icons.alarm_rounded, color: hintColor),
        filled: true,
        fillColor: context.scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: context.accentColor.withOpacity(0.5), width: 1.5),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 0, child: Text("At time of task")),
        DropdownMenuItem(value: 5, child: Text("5 minutes before")),
        DropdownMenuItem(value: 10, child: Text("10 minutes before")),
        DropdownMenuItem(value: 30, child: Text("30 minutes before")),
        DropdownMenuItem(value: 60, child: Text("1 hour before")),
      ],
      onChanged: (value) => setState(() => reminderMinutes = value!),
    );
  }

  Future<void> _saveTask() async {
    if (titleController.text.trim().isEmpty) {
      // تم تعديل الـ SnackBar ليتوافق مع ألوان الثيم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter task title",
            style: TextStyle(color: context.scheme.onSurface),
          ),
          backgroundColor: context.scheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          final reminderDate = task.dueDate.subtract(Duration(minutes: task.reminderMinutes));
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
          final reminderDate = widget.task!.dueDate.subtract(Duration(minutes: widget.task!.reminderMinutes));
          await NotificationService.scheduleNotification(
            id: widget.task!.key as int,
            title: widget.task!.title,
            body: "Task is due soon.",
            date: reminderDate,
          );
        } else {
          await NotificationService.cancel(widget.task!.key as int);
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
      // SnackBar الأخطاء احتفظنا به باللون الأحمر للتنبيه
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}