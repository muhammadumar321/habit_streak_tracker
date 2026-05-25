import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../data/datasources/local/database_helper.dart';
import '../core/constants/database_constants.dart';

class BackupService {
  final DatabaseHelper dbHelper;

  BackupService({required this.dbHelper});

  Future<void> exportData() async {
    try {
      final db = await dbHelper.database;

      final habits = await db.query(DatabaseConstants.tableHabits);
      final logs = await db.query(DatabaseConstants.tableHabitLogs);
      final settings = await db.query(DatabaseConstants.tableUserSettings);

      final data = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'habits': habits,
        'logs': logs,
        'settings': settings,
      };

      final jsonString = jsonEncode(data);

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/habit_tracker_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles([XFile(file.path)], text: 'Habit Tracker Backup');

    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  Future<void> importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        if (!await file.exists()) {
          throw Exception('Selected file does not exist');
        }

        final jsonString = await file.readAsString();
        if (jsonString.isEmpty) {
          throw Exception('Selected file is empty');
        }

        final data = jsonDecode(jsonString);
        if (data is! Map) {
          throw Exception('Invalid backup format: expected a JSON object');
        }

        final Map<String, dynamic> backup = data as Map<String, dynamic>;

        if (backup['version'] != 1) {
          throw Exception('Unsupported backup version');
        }

        if (!backup.containsKey('habits') || !backup.containsKey('logs') || !backup.containsKey('settings')) {
          throw Exception('Invalid backup format: missing required sections');
        }

        final habits = backup['habits'];
        final logs = backup['logs'];
        final settings = backup['settings'];

        if (habits is! List || logs is! List || settings is! List) {
          throw Exception('Invalid backup format: data sections must be arrays');
        }

        final validHabits = habits.whereType<Map<String, dynamic>>().toList();
        final validLogs = logs.whereType<Map<String, dynamic>>().toList();
        final validSettings = settings.whereType<Map<String, dynamic>>().toList();

        final db = await dbHelper.database;

        await db.transaction((txn) async {
          await txn.delete(DatabaseConstants.tableHabits);
          await txn.delete(DatabaseConstants.tableHabitLogs);
          await txn.delete(DatabaseConstants.tableUserSettings);

          for (final habit in validHabits) {
            await txn.insert(DatabaseConstants.tableHabits, habit);
          }

          for (final log in validLogs) {
            await txn.insert(DatabaseConstants.tableHabitLogs, log);
          }

          for (final setting in validSettings) {
            await txn.insert(DatabaseConstants.tableUserSettings, setting);
          }
        });
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}
