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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onEdit,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xff1E293B),
          borderRadius: BorderRadius.circular(15),
        ),
        child: CheckboxListTile(
          value: task.isCompleted,
          activeColor: Colors.green,
          onChanged: onChanged,
          title: Text(
            task.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description.isNotEmpty)
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                if (task.description.isNotEmpty) const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 16,
                      color: task.priority == "High"
                          ? Colors.red
                          : task.priority == "Medium"
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      task.priority,
                      style: TextStyle(
                        color: task.priority == "High"
                            ? Colors.red
                            : task.priority == "Medium"
                            ? Colors.orange
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.calendar_today,
                      size: 15,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
