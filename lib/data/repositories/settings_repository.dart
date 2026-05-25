import '../models/settings_model.dart';

abstract class SettingsRepository {
  Future<UserSetting?> getSetting(String key);
  Future<void> saveSetting(UserSetting setting);
}
