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
    return 1;
  }

  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    return 1;
  }
  
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    return queryAll(table);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
     if (sql.contains('COUNT(*)')) {
        return [{'COUNT(*)': 0}]; // Return 0 for count queries on web for now
     }
     return [];
  }
}
