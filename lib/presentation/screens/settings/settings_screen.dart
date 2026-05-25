import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habityne/services/backup_service.dart';
import 'package:habityne/data/datasources/local/database_helper.dart';
import 'package:habityne/core/services/ad_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader(context, 'Data Management'),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Export Backup'),
                  subtitle: const Text('Save your data to a JSON file'),
                  onTap: () => _exportData(context),
                ),
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: const Text('Import Backup'),
                  subtitle: const Text('Restore data from a JSON file'),
                  onTap: () => _importBackup(context),
                ),
                const Divider(),
                _buildSectionHeader(context, 'About'),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  onTap: () => _showPrivacyPolicy(context),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: AdService().createBannerAdWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    const url = 'https://example.com/privacy';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: Text('URL: $url'),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('URL copied to clipboard')),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Copy URL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final dbHelper = DatabaseHelper();
      final service = BackupService(dbHelper: dbHelper);

      await service.exportData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup exported successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    try {
      final dbHelper = DatabaseHelper();
      final service = BackupService(dbHelper: dbHelper);

      await service.importData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Data restored successfully. Please restart app to see changes completely.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }
}
