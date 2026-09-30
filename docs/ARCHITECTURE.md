# Architecture Documentation

## Architectural Pattern

Habityne uses **Clean Architecture** paired with the **BLoC (Business Logic Component)** pattern for state management. This ensures decoupling between UI, business logic, and data sources.

```text
+-------------------------------------------------------+
|                 Presentation Layer                    |
|      (Screens, Widgets, Dialogs, Theme, Routing)      |
+---------------------------+---------------------------+
                            | (Events / States)
+---------------------------v---------------------------+
|                   Business Logic                      |
|            (HabitBloc, StatisticsBloc, SettingsBloc)  |
+---------------------------+---------------------------+
                            | (Repository Interfaces)
+---------------------------v---------------------------+
|                      Data Layer                       |
|   (HabitRepositoryImpl, DatabaseHelper, SQLite)       |
+-------------------------------------------------------+
```

---

## Component Overview

### 1. Presentation Layer (`lib/presentation/`)
- **Screens**:
  - `HomeScreen`: Daily view, date timeline, active habits, motivation banner, activity heatmap.
  - `HabitsListScreen`: Tabbed list of active vs. archived habits.
  - `ProgressScreen`: Performance statistics, completion metrics, calendar heatmap, weekly chart.
  - `SettingsScreen`: Backup export/import, version info, privacy policy.
  - `OnboardingScreen`: Interactive welcome walkthrough for new users.
- **Widgets**: Reusable components (`HabitCard`, `GlassContainer`, `DateTimeline`, `ProgressRing`, `HeatmapGrid`).
- **Dialogs**: Add and edit habit form modal (`AddEditHabitDialog`).

### 2. Business Logic Layer (`lib/blocs/`)
- **`HabitBloc`**: Manages loading, adding, updating, deleting, archiving, and logging completion of habits.
- **`StatisticsBloc`**: Computes total completions, best streaks, heatmaps, and weekly completion rates.
- **`SettingsBloc`**: Handles app preferences, themes, and notification toggle states.

### 3. Data Layer (`lib/data/`)
- **Models**: Immutable data classes (`Habit`, `HabitLog`, `SettingsModel`) with JSON and SQLite map serialization.
- **Datasources**: `DatabaseHelper` manages SQLite database tables (`habits`, `habit_logs`, `user_settings`) and indexing. A mock web database driver enables web runtime compatibility.
- **Repositories**: `HabitRepositoryImpl` and `SettingsRepositoryImpl` implement repository contracts and handle CRUD operations.

### 4. Core & Services (`lib/core/` and `lib/services/`)
- **`StreakCalculator`**: Core utility for calculating consecutive completion streaks and longest historical streaks.
- **`BackupService`**: Exports and imports application state via structured JSON files.
- **`NotificationService`**: Schedules local daily reminders using `flutter_local_notifications` and timezone rules.
- **`AdService`**: Controls Google Mobile Ads integration (banner and interstitial ads).
- **`RewardService`**: Unlocks features based on streak milestones.
- **`injection_container.dart`**: `GetIt` service locator setup for dependency injection.
