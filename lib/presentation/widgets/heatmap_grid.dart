import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/habit_log_model.dart';
import 'glass_container.dart';

class HeatmapGrid extends StatelessWidget {
  final Map<int, List<HabitLog>> habitLogs;

  const HeatmapGrid({super.key, required this.habitLogs});

  @override
  Widget build(BuildContext context) {
    // 5 weeks * 7 days = 35 days
    final today = AppDateUtils.startOfDay(DateTime.now());
    final startDate = today.subtract(const Duration(days: 34)); // 35 days total ending today

    // Calculate max completions in a single day for opacity normalization
    int maxCompletions = 0;
    Map<DateTime, int> completionsPerDay = {};

    for (int i = 0; i < 35; i++) {
        final date = startDate.add(Duration(days: i));
        int count = 0;
        habitLogs.forEach((_, logs) {
            if (logs.any((log) => AppDateUtils.isSameDay(log.completedDate, date))) {
                count++;
            }
        });
        completionsPerDay[date] = count;
        if (count > maxCompletions) maxCompletions = count;
    }
    
    if (maxCompletions == 0) maxCompletions = 1;

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            "ACTIVITY MAP",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 days (rows if horizontal, but here cols) -> Wait.
              // GitHub style: Rows = Days (Mon, Tue...), Cols = Weeks.
              // GridView fills row first. So crossAxisCount = 7 means 7 columns.
              // If we want 7 columns (days of week?), no usually it's Weeks on X, Days on Y.
              // But standard GridView is Row-major. 
              // Let's just do 7 columns = 7 days of week (Sun-Sat).
              // So 5 rows of weeks.
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              // Index 0 = startDate.
              final date = startDate.add(Duration(days: index));
              final count = completionsPerDay[date] ?? 0;
              final opacity = (count / maxCompletions).clamp(0.1, 1.0);
              
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(count == 0 ? 0.05 : opacity),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Tooltip(
                  message: '${DateFormat('MMM d').format(date)}: $count habits',
                  child: const SizedBox(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

