// ignore_for_file: deprecated_member_use
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
      
      // Query all data
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
      
      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/habit_tracker_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      // Share file
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
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString);
        
        if (data['version'] != 1) {
          throw Exception('Unsupported backup version');
        }

        final db = await dbHelper.database;
        
        await db.transaction((txn) async {
          // Clear existing data
          await txn.delete(DatabaseConstants.tableHabits);
          await txn.delete(DatabaseConstants.tableHabitLogs);
          await txn.delete(DatabaseConstants.tableUserSettings);
          
          // Insert habits
          for (var habit in (data['habits'] as List)) {
             await txn.insert(DatabaseConstants.tableHabits, habit);
          }
          
          // Insert logs
          for (var log in (data['logs'] as List)) {
             await txn.insert(DatabaseConstants.tableHabitLogs, log);
          }
          
          // Insert settings
          for (var setting in (data['settings'] as List)) {
             await txn.insert(DatabaseConstants.tableUserSettings, setting);
          }
        });
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}
