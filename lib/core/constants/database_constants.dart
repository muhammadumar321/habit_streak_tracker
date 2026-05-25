class DatabaseConstants {
  static const String databaseName = 'habityne.db';
  static const int databaseVersion = 1;

  // Table Names
  static const String tableHabits = 'habits';
  static const String tableHabitLogs = 'habit_logs';
  static const String tableUserSettings = 'user_settings';

  // Common Columns
  static const String colId = 'id';

  // Habits Table Columns
  static const String colName = 'name';
  static const String colDescription = 'description';
  static const String colIconName = 'icon_name';
  static const String colColorHex = 'color_hex';
  static const String colFrequency = 'frequency';
  static const String colTargetDays = 'target_days';
  static const String colReminderTime = 'reminder_time';
  static const String colReminderEnabled = 'reminder_enabled';
  static const String colCreatedAt = 'created_at';
  static const String colArchived = 'archived';

  // Habit Logs Table Columns
  static const String colHabitId = 'habit_id';
  static const String colCompletedDate = 'completed_date';
  static const String colCompletedAt = 'completed_at';
  static const String colNotes = 'notes';

  // User Settings Table Columns
  static const String colKey = 'key';
  static const String colValue = 'value';

  // Create Table Statements
  static const String createTableHabits =
      '''
    CREATE TABLE $tableHabits (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colName TEXT NOT NULL,
      $colDescription TEXT,
      $colIconName TEXT,
      $colColorHex TEXT,
      $colFrequency TEXT DEFAULT 'daily',
      $colTargetDays TEXT,
      $colReminderTime TEXT,
      $colReminderEnabled INTEGER DEFAULT 1,
      $colCreatedAt TEXT NOT NULL,
      $colArchived INTEGER DEFAULT 0
    )
  ''';

  static const String createTableHabitLogs =
      '''
    CREATE TABLE $tableHabitLogs (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colHabitId INTEGER NOT NULL,
      $colCompletedDate TEXT NOT NULL,
      $colCompletedAt TEXT,
      $colNotes TEXT,
      FOREIGN KEY ($colHabitId) REFERENCES $tableHabits($colId) ON DELETE CASCADE,
      UNIQUE($colHabitId, $colCompletedDate)
    )
  ''';

  static const String createTableUserSettings =
      '''
    CREATE TABLE $tableUserSettings (
      $colKey TEXT PRIMARY KEY,
      $colValue TEXT NOT NULL
    )
  ''';
}
