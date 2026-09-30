# Changelog

All notable changes to the Habityne project will be documented in this file.

## [1.0.0+2] - 2026-09-30

### Fixed
- **AdMob Banner Lifecycle**: Created `BannerAdWidget` stateful widget to isolate `BannerAd` lifecycle per screen and resolve "This AdWidget is already in the Widget tree" runtime exception.
- **Widget Test Compilation**: Fixed `HabitCard` missing required `logs` parameter in `test/presentation/widgets/habit_card_test.dart`.
- **Script Imports**: Corrected package import references in `scripts/test_streak_calculator.dart` from legacy `package:habit_streak_tracker` to `package:habityne`.
- **Flutter Deprecations**:
  - Replaced deprecated `ColorScheme.background` and `onBackground` with `surface` and `onSurface` in `AppTheme`.
  - Replaced deprecated `withOpacity()` with `withValues(alpha: ...)` across UI components (`HabitCard`, `GlassContainer`, `DateTimeline`, `HeatmapGrid`, `ProgressRing`, `WeeklyProgressChart`, `TipCard`, `MotivationBanner`).
  - Replaced `MaterialStateProperty` and `MaterialState` with `WidgetStateProperty` and `WidgetState`.
  - Fixed `surfaceVariant` deprecation by replacing with `surfaceContainerHighest` in `WeeklyProgressChart`.
- **Linting & Code Quality**:
  - Fixed `curly_braces_in_flow_control_structures` in `ProgressChart`, `WeeklyProgressChart`, and `StatisticsBloc`.
  - Fixed `unused_import` and `prefer_final_fields` in `HomeScreen`.
  - Resolved `use_null_aware_elements` warning in `ProgressRing`.
- **Git Branch Consolidation**: Merged all changes, verified codebase against `flutter analyze` and `flutter test`, and stabilized on `dev`.

### Added
- Comprehensive repository documentation:
  - `README.md` with setup, architecture, and build instructions.
  - `CHANGELOG.md` tracking fixes and enhancements.
  - `CONTRIBUTING.md` defining branching conventions and pull request guidelines.
  - `docs/ARCHITECTURE.md` describing Clean Architecture and BLoC integration.
  - `docs/SETUP.md` detailing step-by-step developer setup.
  - `docs/RELEASE.md` outlining release build procedures.
  - `docs/TROUBLESHOOTING.md` providing solutions to common build and environment issues.
