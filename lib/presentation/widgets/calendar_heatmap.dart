import 'package:flutter/material.dart';
import '../../core/utils/date_utils.dart';

class CalendarHeatMap extends StatelessWidget {
  final Map<DateTime, int> heatmapData;
  final DateTime endDate;
  final int daysToShow;

  const CalendarHeatMap({
    super.key,
    required this.heatmapData,
    required this.endDate,
    this.daysToShow = 84, // 12 weeks
  });

  @override
  Widget build(BuildContext context) {
    // Generate dates
    final dates = <DateTime>[];
    final startDate = endDate.subtract(Duration(days: daysToShow - 1));

    // Adjust start date to be a Monday (or Sunday depending on preference)
    // Let's align to start of week (Monday = 1)
    int daysToSubtract = startDate.weekday - 1;
    final displayStartDate = startDate.subtract(Duration(days: daysToSubtract));

    // Total cells to fill grid (7 rows * N columns)
    int totalCells = ((daysToShow + daysToSubtract) / 7).ceil() * 7;

    for (int i = 0; i < totalCells; i++) {
      dates.add(displayStartDate.add(Duration(days: i)));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consistency Map',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildHeatMapGrid(context, dates),
            // Re-implementing with Row of Columns for correct Heatmap layout
          ],
        ),
      ),
    );
  }

  Widget _buildHeatMapGrid(BuildContext context, List<DateTime> dates) {
    // Organize by weeks
    List<List<DateTime>> weeks = [];
    List<DateTime> currentWeek = [];

    for (var date in dates) {
      currentWeek.add(date);
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }
    // Add remaining partial week if any (logic above ensures full weeks though)
    if (currentWeek.isNotEmpty) weeks.add(currentWeek);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // Show newest on right
      child: Row(
        children: weeks.map((week) {
          return Column(
            children: week.map((date) {
              final count = heatmapData[AppDateUtils.startOfDay(date)] ?? 0;
              // Opacity based on count. 1 = 0.4, 2 = 0.6, 3+ = 0.8-1.0
              // or just simple binary if count > 0 for now?
              // Let's use tiered.
              double opacity = 0.1;
              if (count > 0) opacity = 0.4;
              if (count > 2) opacity = 0.7;
              if (count > 4) opacity = 1.0;

              if (count == 0) opacity = 0.1;

              final color = count > 0
                  ? Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: opacity)
                  : Theme.of(context).colorScheme.surfaceContainerHighest;

              return Tooltip(
                message:
                    '${date.year}-${date.month}-${date.day}: $count completed',
                child: Container(
                  margin: const EdgeInsets.all(2),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
