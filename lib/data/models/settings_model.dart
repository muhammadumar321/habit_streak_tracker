import '../../core/constants/database_constants.dart';

class UserSetting {
  final String key;
  final String value;

  UserSetting({required this.key, required this.value});

  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colKey: key,
      DatabaseConstants.colValue: value,
    };
  }

  factory UserSetting.fromMap(Map<String, dynamic> map) {
    return UserSetting(
      key: map[DatabaseConstants.colKey] as String,
      value: map[DatabaseConstants.colValue] as String,
    );
  }
}
