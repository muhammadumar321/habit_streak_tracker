import '../../core/constants/database_constants.dart';

class HabitLog {
  final int? id;
  final int habitId;
  final DateTime completedDate; // YYYY-MM-DD (time stripped)
  final DateTime? completedAt; // Full timestamp
  final String? notes;

  HabitLog({
    this.id,
    required this.habitId,
    required this.completedDate,
    this.completedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colHabitId: habitId,
      DatabaseConstants.colCompletedDate: completedDate.toIso8601String().split('T')[0],
      DatabaseConstants.colCompletedAt: completedAt?.toIso8601String(),
      DatabaseConstants.colNotes: notes,
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map[DatabaseConstants.colId] as int?,
      habitId: map[DatabaseConstants.colHabitId] as int,
      completedDate: DateTime.parse(map[DatabaseConstants.colCompletedDate] as String),
      completedAt: map[DatabaseConstants.colCompletedAt] != null
          ? DateTime.parse(map[DatabaseConstants.colCompletedAt] as String)
          : null,
      notes: map[DatabaseConstants.colNotes] as String?,
    );
  }
}
