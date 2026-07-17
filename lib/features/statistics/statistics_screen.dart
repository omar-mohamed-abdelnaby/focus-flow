import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:focus_flow/core/widgets/stat_card.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TaskModel>('tasks');
    final focusBox = Hive.box('focus');

    return Scaffold(
      appBar: AppBar(title: const Text("Statistics"), centerTitle: true),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<TaskModel> box, _) {
          final tasks = box.values.toList();

          final totalTasks = tasks.length;
          final completedTasks = tasks.where((task) => task.isCompleted).length;
          final remainingTasks = totalTasks - completedTasks;

          final progress = totalTasks == 0
              ? 0
              : (completedTasks / totalTasks * 100).toInt();

          final sessions = focusBox.get('sessions', defaultValue: 0);

          final minutes = focusBox.get('minutes', defaultValue: 0);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              StatCard(
                icon: Icons.list_alt,
                title: "Total Tasks",
                value: "$totalTasks",
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              StatCard(
                icon: Icons.check_circle,
                title: "Completed Tasks",
                value: "$completedTasks",
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              StatCard(
                icon: Icons.pending_actions,
                title: "Remaining Tasks",
                value: "$remainingTasks",
                color: Colors.orange,
              ),

              const SizedBox(height: 20),

              StatCard(
                icon: Icons.pie_chart,
                title: "Completion Rate",
                value: "$progress%",
                color: Colors.deepPurple,
              ),

              const SizedBox(height: 20),

              StatCard(
                icon: Icons.local_fire_department,
                title: "Focus Sessions",
                value: "$sessions",
                color: Colors.deepOrange,
              ),

              const SizedBox(height: 20),

              StatCard(
                icon: Icons.schedule,
                title: "Focus Time",
                value: "$minutes min",
                color: Colors.teal,
              ),

              const SizedBox(height: 35),

              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 70,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                    borderData: FlBorderData(show: false),
                    sections: [
                      PieChartSectionData(
                        value: completedTasks.toDouble(),
                        color: Colors.green,
                        radius: 60,
                        title: "$completedTasks",
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      PieChartSectionData(
                        value: remainingTasks.toDouble(),
                        color: Colors.red,
                        radius: 60,
                        title: "$remainingTasks",
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Center(
                child: Text(
                  "Task Distribution",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              const SizedBox(height: 20),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 6, backgroundColor: Colors.green),

                      SizedBox(width: 6),

                      Text("Completed"),
                    ],
                  ),

                  Row(
                    children: [
                      CircleAvatar(radius: 6, backgroundColor: Colors.red),

                      SizedBox(width: 6),

                      Text("Remaining"),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
