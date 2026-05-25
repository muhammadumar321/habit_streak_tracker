import 'dart:convert';
import '../../core/constants/database_constants.dart';

class Habit {
  final int? id;
  final String name;
  final String? description;
  final String? iconName;
  final String? colorHex;
  final String frequency; // 'daily', 'weekly', 'custom'
  final List<int>? targetDays; // For custom frequency (1=Mon, 7=Sun)
  final String? reminderTime; // HH:mm
  final bool reminderEnabled;
  final DateTime createdAt;
  final bool archived;

  Habit({
    this.id,
    required this.name,
    this.description,
    this.iconName,
    this.colorHex,
    this.frequency = 'daily',
    this.targetDays,
    this.reminderTime,
    this.reminderEnabled = true,
    required this.createdAt,
    this.archived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colName: name,
      DatabaseConstants.colDescription: description,
      DatabaseConstants.colIconName: iconName,
      DatabaseConstants.colColorHex: colorHex,
      DatabaseConstants.colFrequency: frequency,
      DatabaseConstants.colTargetDays: targetDays != null ? jsonEncode(targetDays) : null,
      DatabaseConstants.colReminderTime: reminderTime,
      DatabaseConstants.colReminderEnabled: reminderEnabled ? 1 : 0,
      DatabaseConstants.colCreatedAt: createdAt.toIso8601String(),
      DatabaseConstants.colArchived: archived ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map[DatabaseConstants.colId] as int?,
      name: map[DatabaseConstants.colName] as String,
      description: map[DatabaseConstants.colDescription] as String?,
      iconName: map[DatabaseConstants.colIconName] as String?,
      colorHex: map[DatabaseConstants.colColorHex] as String?,
      frequency: map[DatabaseConstants.colFrequency] as String? ?? 'daily',
      targetDays: map[DatabaseConstants.colTargetDays] != null
          ? List<int>.from(jsonDecode(map[DatabaseConstants.colTargetDays]))
          : null,
      reminderTime: map[DatabaseConstants.colReminderTime] as String?,
      reminderEnabled: (map[DatabaseConstants.colReminderEnabled] as int) == 1,
      createdAt: DateTime.parse(map[DatabaseConstants.colCreatedAt] as String),
      archived: (map[DatabaseConstants.colArchived] as int) == 1,
    );
  }

  Habit copyWith({
    int? id,
    String? name,
    String? description,
    String? iconName,
    String? colorHex,
    String? frequency,
    List<int>? targetDays,
    String? reminderTime,
    bool? reminderEnabled,
    DateTime? createdAt,
    bool? archived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      createdAt: createdAt ?? this.createdAt,
      archived: archived ?? this.archived,
    );
  }
}
