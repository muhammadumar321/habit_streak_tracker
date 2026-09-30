# Habityne — Habit & Streak Tracker

Habityne (Habit Streak Tracker) is a modern, cross-platform Flutter application built to help users build consistency, track daily habits, visualize streak progress, and stay motivated using clean architecture, BLoC state management, and SQLite persistence.

---

## Features

- **Daily Habit Tracking**: Quick-tap checkmarks with instant visual feedback and completion status.
- **Streak Calculation Engine**: Accurate current and longest streak calculation logic.
- **Activity & Heatmap Visualization**: Visual GitHub-style activity heatmaps and progress charts for habit analytics.
- **Reminders & Local Notifications**: Scheduled local notifications using `flutter_local_notifications` and timezone support.
- **Data Backup & Restore**: JSON import/export capability for complete offline data management.
- **Reward System**: Tiered feature unlocks based on consistent streak milestones.
- **Dark Neomorphic UI**: Styled using Google Fonts (Inter & Montserrat) with dark glassmorphism aesthetic.
- **Onboarding Flow**: Smooth introduction for first-time users saved via `shared_preferences`.

---

## Architecture & Technology Stack

### Architecture
Habityne follows Clean Architecture principles separated into presentation, domain/BLoC, data, and core layers:

```text
lib/
├── main.dart
├── presentation/         # Screens, widgets, dialogs, and navigation
├── blocs/                # BLoC state management (Habit, Settings, Statistics)
├── data/
│   ├── datasources/     # Local SQLite helper & Web mock database
│   ├── models/          # Data transfer objects (Habit, HabitLog, Settings)
│   └── repositories/    # Habit & Settings repository implementations
├── services/             # Local backup and notification services
└── core/                 # Theme, dependency injection (GetIt), constants, & utils
```

### Technology Stack
- **Framework**: Flutter (SDK ^3.10.8) / Dart
- **State Management**: `flutter_bloc` (^8.1.3), `equatable`
- **Dependency Injection**: `get_it` (^7.6.4)
- **Database & Storage**: `sqflite` (^2.3.0), `shared_preferences` (^2.2.2)
- **Charts & Visualization**: `fl_chart` (^0.66.0)
- **Monetization & Ads**: `google_mobile_ads` (^5.0.0)
- **Notifications & Sharing**: `flutter_local_notifications`, `share_plus`, `file_picker`

---

## Project Structure

```text
habit_streak_tracker/
├── android/              # Android native runner and configuration
├── ios/                  # iOS native runner and configuration
├── lib/                  # Core application source code
├── scripts/              # Utility scripts and standalone test runners
├── test/                 # Automated unit, bloc, and widget test suites
├── docs/                 # Detailed architecture, setup, and release guides
├── analysis_options.yaml # Static analysis and linting rules
└── pubspec.yaml          # Project dependencies and asset definitions
```

---

## Prerequisites

- **Flutter SDK**: 3.22.0 or higher
- **Dart SDK**: 3.4.0 or higher
- **Java Development Kit (JDK)**: JDK 17 or JDK 21
- **Android SDK**: API 34+ (Build-Tools 34.0.0+)
- **IDE**: Android Studio or Visual Studio Code with Flutter extensions

---

## Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/muhammadumar321/habit_streak_tracker.git
   cd habit_streak_tracker
   ```

2. **Fetch dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify environment setup**:
   ```bash
   flutter doctor
   ```

---

## Running the Project

Run the app in debug mode on a connected device or emulator:

```bash
flutter run
```

To run on a specific target:
```bash
flutter run -d chrome
flutter run -d windows
```

---

## Running Quality & Test Checks

### Static Analysis & Formatting
```bash
dart format --set-exit-if-changed .
flutter analyze
```

### Automated Unit & Widget Tests
```bash
flutter test
```

---

## Building the Application

### Android Debug APK
```bash
flutter build apk --debug
```

### Android Release Bundle (AAB)
```bash
flutter build appbundle --release
```

---

## Documentation

For further information, please see the guides in the [`docs/`](docs/) directory:
- [Architecture Guide](docs/ARCHITECTURE.md)
- [Setup Guide](docs/SETUP.md)
- [Release Guide](docs/RELEASE.md)
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md)

---

## Development Guidelines

1. All feature development and bug fixes take place on `dev`.
2. Follow standard Dart conventions and ensure `flutter analyze` passes with zero errors.
3. Add unit tests for new business logic and widget tests for new UI components.
