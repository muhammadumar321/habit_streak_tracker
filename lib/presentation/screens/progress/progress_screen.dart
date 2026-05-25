import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habityne/blocs/statistics/statistics_bloc.dart';
import 'package:habityne/blocs/statistics/statistics_state.dart';
import 'package:habityne/presentation/widgets/calendar_heatmap.dart';
import 'package:habityne/presentation/widgets/progress_chart.dart';
import 'package:habityne/core/services/ad_service.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<StatisticsBloc, StatisticsState>(
              builder: (context, state) {
                if (state is StatisticsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is StatisticsLoaded) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Key Metrics
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                'Total Habits',
                                state.totalHabits.toString(),
                                Icons.list,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                'Best Streak',
                                state.bestStreak.toString(),
                                Icons.local_fire_department,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                'Total Completions',
                                state.totalCompletions.toString(),
                                Icons.check_circle,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                'Completion Rate',
                                '${(state.completionRate * 100).toInt()}%',
                                Icons.pie_chart,
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Heatmap
                        CalendarHeatMap(
                          heatmapData: state.heatmapData,
                          endDate: DateTime.now(),
                        ),
                        const SizedBox(height: 24),

                        // Chart
                        ProgressChart(weeklyData: state.weeklyCompletion),
                      ],
                    ),
                  );
                } else if (state is StatisticsError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          // AdMob Banner
          SizedBox(
            width: double.infinity,
            height: 50,
            child: AdService().createBannerAdWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
