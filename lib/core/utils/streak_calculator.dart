import '../../data/models/habit_log_model.dart';
import 'date_utils.dart';

class StreakCalculator {
  /// Calculates the current streak given a list of logs and the habit frequency.
  /// Currently supports 'daily' frequency.
  static int calculateCurrentStreak(List<HabitLog> logs) {
    if (logs.isEmpty) return 0;
    
    // Sort logs by date descending (newest first)
    final sortedLogs = List<HabitLog>.from(logs)
      ..sort((a, b) => b.completedDate.compareTo(a.completedDate));
    
    int streak = 0;
    DateTime checkDate = AppDateUtils.startOfDay(DateTime.now());
    
    // Check if completed today
    bool completedToday = sortedLogs.any((log) => 
      AppDateUtils.isSameDay(log.completedDate, checkDate));
      
    if (!completedToday) {
      // If not completed today, check if completed yesterday to keep streak alive
      checkDate = checkDate.subtract(const Duration(days: 1));
      bool completedYesterday = sortedLogs.any((log) => 
        AppDateUtils.isSameDay(log.completedDate, checkDate));
        
      if (!completedYesterday) {
        return 0; // Streak broken
      }
    }
    
    // Iterate backwards to count streak
    // We already established the starting point (either today or yesterday)
    // Now we check consecutive days backwards
    
    // Optimization: Since logs are sorted, we can iterate through them
    // But logs might have gaps or duplicates (though DB constraint prevents dups for same habit/date)
    // Safer to check date by date for now
    
    while (true) {
      bool found = sortedLogs.any((log) => 
        AppDateUtils.isSameDay(log.completedDate, checkDate));
        
      if (found) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }
  
  static int calculateLongestStreak(List<HabitLog> logs) {
    if (logs.isEmpty) return 0;

    final sortedLogs = List<HabitLog>.from(logs)
      ..sort((a, b) => a.completedDate.compareTo(b.completedDate)); // Ascending

    int currentStreak = 0;
    int maxStreak = 0;
    DateTime? lastDate;

    for (var log in sortedLogs) {
      if (lastDate == null) {
        currentStreak = 1;
        lastDate = log.completedDate;
        maxStreak = 1;
        continue;
      }

      final diff = log.completedDate.difference(lastDate).inDays;

      if (diff == 1) {
        currentStreak++;
      } else if (diff > 1) {
        currentStreak = 1;
      }
      // If diff == 0 (same day), do nothing

      if (currentStreak > maxStreak) {
        maxStreak = currentStreak;
      }
      lastDate = log.completedDate;
    }

    return maxStreak;
  }
}
