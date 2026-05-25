import '../datasources/local/database_helper.dart';
import '../models/settings_model.dart';
import 'settings_repository.dart';
import '../../core/constants/database_constants.dart';
import '../../core/errors/exceptions.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final DatabaseHelper databaseHelper;

  SettingsRepositoryImpl({required this.databaseHelper});

  @override
  Future<UserSetting?> getSetting(String key) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tableUserSettings,
        where: '${DatabaseConstants.colKey} = ?',
        whereArgs: [key],
      );
      if (maps.isNotEmpty) {
        return UserSetting.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<void> saveSetting(UserSetting setting) async {
    try {
      await databaseHelper.insert(
        DatabaseConstants.tableUserSettings,
        setting.toMap(),
        conflictAlgorithm: 'replace',
      );
    } catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }
}
