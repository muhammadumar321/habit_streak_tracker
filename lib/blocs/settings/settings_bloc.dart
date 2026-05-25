import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/settings_model.dart';
import '../../data/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;
  static const String keyThemeMode = 'theme_mode';

  SettingsBloc({required this.repository}) : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateThemeMode>(_onUpdateThemeMode);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    try {
      final setting = await repository.getSetting(keyThemeMode);
      if (setting != null) {
        final mode = _parseThemeMode(setting.value);
        emit(state.copyWith(themeMode: mode));
      }
    } catch (_) {
      // Use default if error
    }
  }

  Future<void> _onUpdateThemeMode(UpdateThemeMode event, Emitter<SettingsState> emit) async {
    try {
      await repository.saveSetting(UserSetting(key: keyThemeMode, value: event.themeMode.toString()));
      emit(state.copyWith(themeMode: event.themeMode));
    } catch (_) {
      // Handle error
    }
  }

  ThemeMode _parseThemeMode(String value) {
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => ThemeMode.system,
    );
  }
}
