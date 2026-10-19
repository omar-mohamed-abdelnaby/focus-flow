import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final box = Hive.box<TaskModel>('tasks');
    final focusBox = Hive.box('focus');

    // ألوان متجاوبة مع الوضعين (Light / Dark)
    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = scheme.surface;
    final textColor = isDark ? Colors.white : scheme.onSurface;

    final completedColor = Colors.tealAccent.shade400;
    final remainingColor = Colors.redAccent.shade400;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Statistics",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
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

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Overview",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatCard(context, "Total Tasks", "$totalTasks", Icons.list_alt_rounded, Colors.blueAccent)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard(context, "Completed", "$completedTasks", Icons.check_circle_rounded, completedColor)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard(context, "Remaining", "$remainingTasks", Icons.pending_actions_rounded, remainingColor)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard(context, "Completion", "$progress%", Icons.pie_chart_rounded, Colors.purpleAccent)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard(context, "Sessions", "$sessions", Icons.local_fire_department_rounded, Colors.orangeAccent)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard(context, "Focus Time", "$minutes m", Icons.schedule_rounded, Colors.indigoAccent)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.10)
                          : theme.dividerColor,
                      width: 1,
                    ),
                    boxShadow: isDark
                        ? []
                        : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Task Distribution",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        height: 200,
                        child: totalTasks == 0
                            ? const Center(
                          child: Text(
                            "No tasks yet",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                            : PieChart(
                          PieChartData(
                            centerSpaceRadius: 60,
                            sectionsSpace: 4,
                            startDegreeOffset: -90,
                            borderData: FlBorderData(show: false),
                            sections: [
                              PieChartSectionData(
                                value: completedTasks.toDouble(),
                                color: completedColor,
                                radius: 40,
                                title: "$completedTasks",
                                titleStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              PieChartSectionData(
                                value: remainingTasks.toDouble(),
                                color: remainingColor,
                                radius: 40,
                                title: "$remainingTasks",
                                titleStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem(context, "Completed", completedColor),
                          const SizedBox(width: 24),
                          _buildLegendItem(context, "Remaining", remainingColor),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // تم تمرير BuildContext للوصول للثيم بشكل صحيح
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.10)
              : theme.dividerColor,
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1), // خلفية شفافة بنفس لون الأيقونة بتدي شكل أنيق جداً
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : scheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurface.withOpacity(.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // تم تمرير BuildContext هنا أيضاً
  Widget _buildLegendItem(BuildContext context, String text, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
              color: isDark ? Colors.white70 : theme.colorScheme.onSurface.withOpacity(.7),
              fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }
}