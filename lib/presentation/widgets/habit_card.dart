import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/habit_log_model.dart';
import '../../core/utils/date_utils.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final List<HabitLog> logs;
  final VoidCallback onMobilePressed;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.logs,
    required this.onMobilePressed,
    required this.onComplete,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Neomorphic decoration
    final decoration = BoxDecoration(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        // Dark shadow bottom-right
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(4, 4),
          blurRadius: 10,
        ),
        // Light shadow top-left
        BoxShadow(
          color: Colors.white.withOpacity(0.05),
          offset: const Offset(-4, -4),
          blurRadius: 10,
        ),
      ],
    );

    return Dismissible(
      key: Key('habit_${habit.id}'),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onComplete();
          return false;
        } else {
            _showOptions(context);
            return false;
        }
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Icon(Icons.check, color: theme.colorScheme.primary),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.settings, color: theme.colorScheme.error),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onMobilePressed,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Quick-Tap Checkmark
                  GestureDetector(
                    onTap: onComplete,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: isCompleted 
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4)
                                )
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.05),
                                  offset: const Offset(-2, -2),
                                  blurRadius: 4
                                ),
                              ],
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.circle_outlined,
                        color: isCompleted ? Colors.white : Colors.white30,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? Colors.white54 : Colors.white,
                          ),
                        ),
                        if (habit.description?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              habit.description!,
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 12),
                        // Sparkline Chart
                        SizedBox(
                          height: 30,
                          child: _buildSparkline(context),
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

  Widget _buildSparkline(BuildContext context) {
    // Get last 7 days data (1 if completed, 0 if not)
    final today = AppDateUtils.startOfDay(DateTime.now());
    final spots = List.generate(7, (index) {
      final date = today.subtract(Duration(days: 6 - index));
      final completed = logs.any((log) => AppDateUtils.isSameDay(log.completedDate, date));
      return FlSpot(index.toDouble(), completed ? 1 : 0);
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: -0.1,
        maxY: 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Edit', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: Colors.white),
              title: Text(habit.archived ? 'Unarchive' : 'Archive', style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                onArchive();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
