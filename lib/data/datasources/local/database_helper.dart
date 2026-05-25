import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as mobile;
import '../../../core/constants/database_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static dynamic _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<dynamic> get database async {
    if (_database != null) return _database!;
    if (kIsWeb) {
      _database = _WebMockDatabase();
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<mobile.Database> _initDatabase() async {
    final dbPath = await mobile.getDatabasesPath();
    final path = p.join(dbPath, DatabaseConstants.databaseName);

    return await mobile.openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(mobile.Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(mobile.Database db, int version) async {
    await db.execute(DatabaseConstants.createTableHabits);
    await db.execute(DatabaseConstants.createTableHabitLogs);
    await db.execute(DatabaseConstants.createTableUserSettings);
    await _createIndexes(db);
  }

  Future<void> _onUpgrade(mobile.Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createIndexes(db);
    }
  }

  Future<void> _createIndexes(mobile.Database db) async {
    await db.execute(DatabaseConstants.indexHabitLogsHabitId);
    await db.execute(DatabaseConstants.indexHabitLogsDate);
    await db.execute(DatabaseConstants.indexHabitsArchived);
  }

  Future<int> insert(String table, Map<String, dynamic> data, {String? conflictAlgorithm}) async {
    final db = await database;
    if (kIsWeb) {
      return (db as _WebMockDatabase).insert(table, data);
    }
    return await (db as mobile.Database).insert(
      table, 
      data, 
      conflictAlgorithm: _getAlgorithm(conflictAlgorithm),
    );
  }

  mobile.ConflictAlgorithm? _getAlgorithm(String? alg) {
    if (alg == 'replace') return mobile.ConflictAlgorithm.replace;
    return null;
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    if (kIsWeb) {
      return (db as _WebMockDatabase).queryAll(table);
    }
    return await (db as mobile.Database).query(table);
  }

  Future<dynamic> get rawDatabase async => database;

  static int? firstIntValue(List<Map<String, dynamic>> list) {
    if (list.isEmpty || list.first.isEmpty) return null;
    return list.first.values.first as int?;
  }
}

class _WebMockDatabase {
  final Map<String, List<Map<String, dynamic>>> _tables = {
    DatabaseConstants.tableHabits: [],
    DatabaseConstants.tableHabitLogs: [],
    DatabaseConstants.tableUserSettings: [],
  };
  int _nextId = 1;

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final mutableData = Map<String, dynamic>.from(data);
    if (mutableData[DatabaseConstants.colId] == null) {
      mutableData[DatabaseConstants.colId] = _nextId++;
    }
    _tables[table]?.add(mutableData);
    return mutableData[DatabaseConstants.colId];
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    return List<Map<String, dynamic>>.from(_tables[table] ?? []);
  }

  Future<int> update(String table, Map<String, dynamic> data, {String? where, List<dynamic>? whereArgs}) async {
    final rows = _tables[table];
    if (rows == null) return 0;
    int updated = 0;
    for (int i = 0; i < rows.length; i++) {
      if (where != null && whereArgs != null) {
        final col = where.replaceAll(' = ?', '');
        if (rows[i][col]?.toString() == whereArgs.first?.toString()) {
          rows[i] = Map<String, dynamic>.from(data);
          updated++;
        }
      }
    }
    return updated;
  }

  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    final rows = _tables[table];
    if (rows == null) return 0;
    int before = rows.length;
    if (where != null && whereArgs != null) {
      final col = where.replaceAll(' = ?', '');
      rows.removeWhere((row) => row[col]?.toString() == whereArgs.first?.toString());
    }
    return before - rows.length;
  }
  
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    var rows = List<Map<String, dynamic>>.from(_tables[table] ?? []);
    if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
      final col = where.replaceAll(' = ?', '');
      rows = rows.where((row) => row[col]?.toString() == whereArgs.first?.toString()).toList();
    }
    return rows;
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    if (sql.contains('COUNT(*)')) {
      final tableMatch = RegExp(r'FROM\s+(\w+)').firstMatch(sql);
      if (tableMatch != null) {
        final table = tableMatch.group(1);
        if (arguments != null && arguments.isNotEmpty && sql.contains('WHERE')) {
          final colMatch = RegExp(r'(\w+)\s*=\s*\?').firstMatch(sql);
          if (colMatch != null) {
            final col = colMatch.group(1);
            final count = (_tables[table] ?? [])
                .where((row) => row[col]?.toString() == arguments.first?.toString())
                .length;
            return [{SqlTypeMapKey.count: count}];
          }
        }
        return [{SqlTypeMapKey.count: _tables[table]?.length ?? 0}];
      }
      return [{SqlTypeMapKey.count: 0}];
    }
    return [];
  }
}

class SqlTypeMapKey {
  static const String count = 'COUNT(*)';
}
