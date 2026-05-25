import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/habit_log_model.dart';
import '../utils/streak_calculator.dart';

class RewardService {
  static final RewardService _instance = RewardService._internal();
  factory RewardService() => _instance;
  RewardService._internal();

  bool _isUnlimitedUnlocked = false;

  bool get isUnlimitedUnlocked => _isUnlimitedUnlocked;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isUnlimitedUnlocked = prefs.getBool('unlimited_unlocked') ?? false;
  }
  
  Future<void> checkStreakUnlock(List<Habit> habits, Map<int, List<HabitLog>> logs) async {
    if (_isUnlimitedUnlocked) return;

    int habitsWith5DayStreak = 0;
    for (var habit in habits) {
      final habitLogs = logs[habit.id] ?? [];
      final streak = StreakCalculator.calculateCurrentStreak(habitLogs);
      if (streak >= 5) {
        habitsWith5DayStreak++;
      }
    }

    if (habitsWith5DayStreak >= 3) {
       await _unlockUnlimited();
    }
  }

  Future<void> _unlockUnlimited() async {
    _isUnlimitedUnlocked = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('unlimited_unlocked', true);
  }
}
