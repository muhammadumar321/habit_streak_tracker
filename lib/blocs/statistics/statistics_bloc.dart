import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/habit_repository.dart';
import '../../core/utils/streak_calculator.dart';
import '../../core/utils/date_utils.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final HabitRepository repository;

  StatisticsBloc({required this.repository}) : super(StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
  }

  Future<void> _onLoadStatistics(
      LoadStatistics event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    try {
      final habits = await repository.getHabits();
      final logs = await repository.getAllLogs();
      final activeHabits = habits.where((h) => !h.archived).toList();

      if (habits.isEmpty) {
        emit(const StatisticsLoaded(
          totalHabits: 0,
          totalCompletions: 0,
          bestStreak: 0,
          completionRate: 0,
          heatmapData: {},
          weeklyCompletion: [],
        ));
        return;
      }

      // 1. Total Completions
      final totalCompletions = logs.length;

      // 2. Best Streak (across all habits)
      int globalBestStreak = 0;
      // Group logs by habit
      final Map<int, List<dynamic>> logsByHabit = {};
      for (var log in logs) {
        if (!logsByHabit.containsKey(log.habitId)) logsByHabit[log.habitId] = [];
        logsByHabit[log.habitId]!.add(log);
      }
      
      for (var habitId in logsByHabit.keys) {
        // Need to cast to specifically List<HabitLog> for calculator
        // This dynamic casting is a bit fragile, keeping it simple for now
        final habitLogs = logs.where((l) => l.habitId == habitId).toList();
        final streak = StreakCalculator.calculateLongestStreak(habitLogs);
        if (streak > globalBestStreak) globalBestStreak = streak;
      }

      // 3. Heatmap Data
      final Map<DateTime, int> heatmapData = {};
      for (var log in logs) {
        final date = AppDateUtils.startOfDay(log.completedDate);
        heatmapData[date] = (heatmapData[date] ?? 0) + 1;
      }

      // 4. Completion Rate & Weekly Completion (Last 7 days)
      final List<double> weeklyCompletion = [];
      final today = AppDateUtils.startOfDay(DateTime.now());
      
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        // Count completions on this date
        final completionsOnDate = logs.where((l) => 
            AppDateUtils.isSameDay(l.completedDate, date)).length;
            
        // Expected completions: Active habits. 
        // Logic simplification: Assuming all active habits should be done daily.
        // In reality, should check frequency/day of week.
        final expected = activeHabits.length;
        
        if (expected == 0) {
          weeklyCompletion.add(0.0);
        } else {
          weeklyCompletion.add((completionsOnDate / expected).clamp(0.0, 1.0));
        }
      }
      
      // Overall rate (simplified: of all logs vs (days * active habits))
      // This is tricky without full history tracking.
      // Let's just average the weekly completion for now.
      double avgRate = 0;
      if (weeklyCompletion.isNotEmpty) {
        avgRate = weeklyCompletion.reduce((a, b) => a + b) / weeklyCompletion.length;
      }

      emit(StatisticsLoaded(
        totalHabits: activeHabits.length,
        totalCompletions: totalCompletions,
        bestStreak: globalBestStreak,
        completionRate: avgRate,
        heatmapData: heatmapData,
        weeklyCompletion: weeklyCompletion,
      ));
    } catch (e) {
      emit(StatisticsError("Failed to load statistics: ${e.toString()}"));
    }
  }
}
