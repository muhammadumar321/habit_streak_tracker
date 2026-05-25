import 'package:flutter_test/flutter_test.dart';
import 'package:habit_streak_tracker/core/utils/streak_calculator.dart';
import 'package:habit_streak_tracker/data/models/habit_log_model.dart';
import 'package:habit_streak_tracker/core/utils/date_utils.dart';

void main() {
  group('StreakCalculator', () {
    final today = AppDateUtils.startOfDay(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    final threeDaysAgo = today.subtract(const Duration(days: 3));

    test('calculateCurrentStreak returns 0 for empty logs', () {
      expect(StreakCalculator.calculateCurrentStreak([]), 0);
    });

    test('calculateCurrentStreak returns 1 if completed today', () {
      final logs = [
        HabitLog(habitId: 1, completedDate: today, completedAt: DateTime.now()),
      ];
      expect(StreakCalculator.calculateCurrentStreak(logs), 1);
    });

    test('calculateCurrentStreak returns 1 if completed yesterday but not today', () {
      final logs = [
        HabitLog(habitId: 1, completedDate: yesterday, completedAt: DateTime.now()),
      ];
      expect(StreakCalculator.calculateCurrentStreak(logs), 1);
    });

    test('calculateCurrentStreak returns 0 if completed two days ago', () {
      final logs = [
        HabitLog(habitId: 1, completedDate: twoDaysAgo, completedAt: DateTime.now()),
      ];
      expect(StreakCalculator.calculateCurrentStreak(logs), 0);
    });

    test('calculateCurrentStreak counts continuous streak including today', () {
      final logs = [
        HabitLog(habitId: 1, completedDate: today, completedAt: DateTime.now()),
        HabitLog(habitId: 1, completedDate: yesterday, completedAt: DateTime.now()),
        HabitLog(habitId: 1, completedDate: twoDaysAgo, completedAt: DateTime.now()),
      ];
      expect(StreakCalculator.calculateCurrentStreak(logs), 3);
    });

    test('calculateCurrentStreak counts continuous streak ending yesterday', () {
      final logs = [
        HabitLog(habitId: 1, completedDate: yesterday, completedAt: DateTime.now()),
        HabitLog(habitId: 1, completedDate: twoDaysAgo, completedAt: DateTime.now()),
      ];
      expect(StreakCalculator.calculateCurrentStreak(logs), 2);
    });

    test('calculateCurrentStreak breaks on missing day', () {
      final logs = [
        HabitLog(habitId: 1, completedDate: today, completedAt: DateTime.now()),
        // Missing yesterday
        HabitLog(habitId: 1, completedDate: twoDaysAgo, completedAt: DateTime.now()),
      ];
      expect(StreakCalculator.calculateCurrentStreak(logs), 1);
    });
    
    test('calculateLongestStreak returns max streak', () {
      final logs = [
        HabitLog(habitId: 1, completedDate: today, completedAt: DateTime.now()),
        HabitLog(habitId: 1, completedDate: yesterday, completedAt: DateTime.now()),
        // Break
        HabitLog(habitId: 1, completedDate: threeDaysAgo, completedAt: DateTime.now()),
        HabitLog(habitId: 1, completedDate: threeDaysAgo.subtract(const Duration(days: 1)), completedAt: DateTime.now()),
        HabitLog(habitId: 1, completedDate: threeDaysAgo.subtract(const Duration(days: 2)), completedAt: DateTime.now()),
      ];
      // Current streak is 2.
      // Past streak is 3 (threeDaysAgo, -1, -2).
      // Max should be 3.
      expect(StreakCalculator.calculateLongestStreak(logs), 3);
    });
  });
}
