import '../models/habit_model.dart';
import '../models/habit_log_model.dart';

abstract class HabitRepository {
  // Habits
  Future<List<Habit>> getHabits();
  Future<List<Habit>> getActiveHabits();
  Future<List<Habit>> getArchivedHabits();
  Future<int> insertHabit(Habit habit);
  Future<int> updateHabit(Habit habit);
  Future<int> deleteHabit(int id);
  Future<int> archiveHabit(int id, bool archive);

  // Logs
  Future<List<HabitLog>> getHabitLogs(int habitId);
  Future<List<HabitLog>> getAllLogs();
  Future<int> logCompletion(HabitLog log);
  Future<int> deleteLog(int id);
  Future<int> deleteLogByDate(int habitId, DateTime date);
  
  // Stats helpers
  Future<int> getCompletionCount(int habitId);
}
