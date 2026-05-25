// ignore_for_file: avoid_print
import 'package:habit_streak_tracker/core/utils/streak_calculator.dart';
import 'package:habit_streak_tracker/data/models/habit_log_model.dart';
import 'package:habit_streak_tracker/core/utils/date_utils.dart';

void main() {
  print('Running StreakCalculator Tests...');
  
  final today = AppDateUtils.startOfDay(DateTime.now());
  final yesterday = today.subtract(const Duration(days: 1));
  final twoDaysAgo = today.subtract(const Duration(days: 2));
  final threeDaysAgo = today.subtract(const Duration(days: 3));

  // Test 1: Empty logs
  assert(StreakCalculator.calculateCurrentStreak([]) == 0, 'Test 1 Failed');
  print('Test 1 Passed: Empty logs');

  // Test 2: Completed today
  final logs2 = [
    HabitLog(habitId: 1, completedDate: today, completedAt: DateTime.now()),
  ];
  assert(StreakCalculator.calculateCurrentStreak(logs2) == 1, 'Test 2 Failed');
  print('Test 2 Passed: Completed today');

  // Test 3: Completed yesterday
  final logs3 = [
    HabitLog(habitId: 1, completedDate: yesterday, completedAt: DateTime.now()),
  ];
  assert(StreakCalculator.calculateCurrentStreak(logs3) == 1, 'Test 3 Failed');
  print('Test 3 Passed: Completed yesterday');

  // Test 4: Completed two days ago (broken streak)
  final logs4 = [
    HabitLog(habitId: 1, completedDate: twoDaysAgo, completedAt: DateTime.now()),
  ];
  assert(StreakCalculator.calculateCurrentStreak(logs4) == 0, 'Test 4 Failed');
  print('Test 4 Passed: Broken streak');

  // Test 5: Continuous streak (3 days)
  final logs5 = [
    HabitLog(habitId: 1, completedDate: today, completedAt: DateTime.now()),
    HabitLog(habitId: 1, completedDate: yesterday, completedAt: DateTime.now()),
    HabitLog(habitId: 1, completedDate: twoDaysAgo, completedAt: DateTime.now()),
  ];
  assert(StreakCalculator.calculateCurrentStreak(logs5) == 3, 'Test 5 Failed');
  print('Test 5 Passed: Continuous streak 3 days');

  // Test 6: Continuous streak ending yesterday (2 days)
  final logs6 = [
    HabitLog(habitId: 1, completedDate: yesterday, completedAt: DateTime.now()),
    HabitLog(habitId: 1, completedDate: twoDaysAgo, completedAt: DateTime.now()),
  ];
  assert(StreakCalculator.calculateCurrentStreak(logs6) == 2, 'Test 6 Failed');
  print('Test 6 Passed: Continuous streak ending yesterday');

  // Test 7: Broken streak (gap)
  final logs7 = [
    HabitLog(habitId: 1, completedDate: today, completedAt: DateTime.now()),
    HabitLog(habitId: 1, completedDate: threeDaysAgo, completedAt: DateTime.now()),
  ];
   assert(StreakCalculator.calculateCurrentStreak(logs7) == 1, 'Test 7 Failed');
  print('Test 7 Passed: Gap breakage');
  
  // Test 8: Longest streak
  final logs8 = [
    HabitLog(habitId: 1, completedDate: today, completedAt: DateTime.now()),
    HabitLog(habitId: 1, completedDate: yesterday, completedAt: DateTime.now()),
    HabitLog(habitId: 1, completedDate: threeDaysAgo, completedAt: DateTime.now()),
    HabitLog(habitId: 1, completedDate: threeDaysAgo.subtract(const Duration(days: 1)), completedAt: DateTime.now()),
    HabitLog(habitId: 1, completedDate: threeDaysAgo.subtract(const Duration(days: 2)), completedAt: DateTime.now()),
  ];
  assert(StreakCalculator.calculateLongestStreak(logs8) == 3, 'Test 8 Failed ${StreakCalculator.calculateLongestStreak(logs8)}');
  print('Test 8 Passed: Longest streak is 3');

  print('All tests passed!');
}
