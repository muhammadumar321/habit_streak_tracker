import 'package:flutter/material.dart';
import 'package:habityne/services/backup_service.dart';
import 'package:habityne/data/datasources/local/database_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  onTap: () {
                    // Placeholder for Privacy Policy URL
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Privacy Policy URL: https://example.com/privacy',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // AdMob Banner
          SizedBox(
            width: double.infinity,
            height: 50,
            child: AdWidget(ad: AdService().createBannerAd()..load()),
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

  Future<void> _exportData(BuildContext context) async {
    try {
      // Create service on fly or inject. Ideally inject.
      // For quick implementation:
      final dbHelper = DatabaseHelper(); // This singleton usage is fine
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

      await service.importData(); // This returns void but handles throwing

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Data restored successfully. Please restart app to see changes completely.',
            ),
          ),
        );
        // Trigger generic reload if possible
        // context.read<HabitBloc>().add(LoadHabits());
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
