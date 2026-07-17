import 'package:flutter/material.dart';
import 'package:focus_flow/models/task_model.dart';

class HomeTaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final ValueChanged<bool?> onChanged;

  const HomeTaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onTap,
      borderRadius: BorderRadius.circular(15),

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),

        decoration: BoxDecoration(
          color: const Color(0xff1E293B),
          borderRadius: BorderRadius.circular(15),
        ),

        child: CheckboxListTile(
          value: task.isCompleted,

          onChanged: onChanged,

          activeColor: Colors.green,

          title: Text(
            task.title,
            style: TextStyle(
              color: Colors.white,
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
