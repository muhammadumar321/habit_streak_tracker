import '../datasources/local/database_helper.dart';
import '../models/habit_log_model.dart';
import '../models/habit_model.dart';
import 'habit_repository.dart';
import '../../core/constants/database_constants.dart';
import '../../core/errors/exceptions.dart';

class HabitRepositoryImpl implements HabitRepository {
  final DatabaseHelper databaseHelper;

  HabitRepositoryImpl({required this.databaseHelper});

  @override
  Future<List<Habit>> getHabits() async {
    try {
      final List<Map<String, dynamic>> maps = await databaseHelper.queryAll(DatabaseConstants.tableHabits);
      return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<List<Habit>> getActiveHabits() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tableHabits,
        where: '${DatabaseConstants.colArchived} = ?',
        whereArgs: [0],
        orderBy: '${DatabaseConstants.colCreatedAt} DESC',
      );
      return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<List<Habit>> getArchivedHabits() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tableHabits,
        where: '${DatabaseConstants.colArchived} = ?',
        whereArgs: [1],
        orderBy: '${DatabaseConstants.colCreatedAt} DESC',
      );
      return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<int> insertHabit(Habit habit) async {
    try {
      return await databaseHelper.insert(DatabaseConstants.tableHabits, habit.toMap());
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<int> updateHabit(Habit habit) async {
    try {
      final db = await databaseHelper.database;
      return await db.update(
        DatabaseConstants.tableHabits,
        habit.toMap(),
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [habit.id],
      );
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<int> deleteHabit(int id) async {
    try {
      final db = await databaseHelper.database;
      return await db.delete(
        DatabaseConstants.tableHabits,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<int> archiveHabit(int id, bool archive) async {
    try {
      final db = await databaseHelper.database;
      return await db.update(
        DatabaseConstants.tableHabits,
        {DatabaseConstants.colArchived: archive ? 1 : 0},
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<List<HabitLog>> getHabitLogs(int habitId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tableHabitLogs,
        where: '${DatabaseConstants.colHabitId} = ?',
        whereArgs: [habitId],
        orderBy: '${DatabaseConstants.colCompletedDate} DESC',
      );
      return List.generate(maps.length, (i) => HabitLog.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<List<HabitLog>> getAllLogs() async {
    try {
      final List<Map<String, dynamic>> maps = await databaseHelper.queryAll(DatabaseConstants.tableHabitLogs);
      return List.generate(maps.length, (i) => HabitLog.fromMap(maps[i]));
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<int> logCompletion(HabitLog log) async {
    try {
      return await databaseHelper.insert(DatabaseConstants.tableHabitLogs, log.toMap());
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<int> deleteLog(int id) async {
    try {
      final db = await databaseHelper.database;
      return await db.delete(
        DatabaseConstants.tableHabitLogs,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }
  
  @override
  Future<int> deleteLogByDate(int habitId, DateTime date) async {
    try {
      final db = await databaseHelper.database;
      // Format date to string to match stored format YYYY-MM-DD
      final dateStr = date.toIso8601String().split('T')[0];
      return await db.delete(
        DatabaseConstants.tableHabitLogs,
        where: '${DatabaseConstants.colHabitId} = ? AND ${DatabaseConstants.colCompletedDate} = ?',
        whereArgs: [habitId, dateStr],
      );
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<int> getCompletionCount(int habitId) async {
    try {
      final db = await databaseHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseConstants.tableHabitLogs} WHERE ${DatabaseConstants.colHabitId} = ?',
        [habitId],
      );
      return DatabaseHelper.firstIntValue(result) ?? 0;
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }
}
