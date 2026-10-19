import 'package:flutter/material.dart';
import 'package:focus_flow/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onEdit;
  final ValueChanged<bool?> onChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onChanged,
  });

  // دالة مساعدة لتحديد لون الأولوية لضمان تناسق الألوان
  Color _getPriorityColor() {
    switch (task.priority) {
      case "High":
        return Colors.redAccent;
      case "Medium":
        return Colors.orangeAccent;
      case "Low":
      default:
        return Colors.teal; // استخدام لون هادئ بدلاً من الأخضر الفاقع
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = _getPriorityColor();

    // تخفيف وضوح البطاقة بالكامل إذا كانت المهمة مكتملة
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: task.isCompleted ? 0.6 : 1.0,
      child: Container(
        // تم إزالة margin: EdgeInsets.only(bottom: 12) لأن ListView.separated
        // في شاشة المهام يقوم بعمل مسافات بين الكروت بشكل أفضل.
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? scheme.onSurface.withOpacity(0.08) // لون حدود متناسق مع الداكن
                : scheme.onSurface.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: isDark
              ? []
              : [
            BoxShadow(
              color: scheme.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onLongPress: onEdit,
            borderRadius: BorderRadius.circular(20),
            // استخدام Row بدلاً من CheckboxListTile للتحكم الكامل في التصميم والمسافات
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  Transform.scale(
                    scale: 1.1,
                    child: Checkbox(
                      value: task.isCompleted,
                      activeColor: scheme.primary, // استخدام لون الثيم الأساسي بدل الأخضر الثابت
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(
                        color: scheme.onSurface.withOpacity(0.3),
                        width: 1.5,
                      ),
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Texts and Badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        // Title
                        Text(
                          task.title,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: scheme.onSurface.withOpacity(0.5),
                            decorationThickness: 2,
                          ),
                        ),

                        // Description
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: scheme.onSurface.withOpacity(0.6),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Badges Row (Priority & Date)
                        Row(
                          children: [
                            // Priority Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.flag_rounded, size: 14, color: priorityColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.priority,
                                    style: TextStyle(
                                      color: priorityColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Date Badge
                            // Date & Time Badge
                            // Date & Time Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.onSurface.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        size: 14,
                                        color: scheme.onSurface.withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}",
                                        style: TextStyle(
                                          color: scheme.onSurface.withOpacity(0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 3),

                                  Padding(
                                    padding: const EdgeInsets.only(left: 19),
                                    child: Text(
                                      TimeOfDay.fromDateTime(task.dueDate).format(context),
                                      style: TextStyle(
                                        color: scheme.onSurface.withOpacity(0.7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}