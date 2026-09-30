# Developer Setup Guide

This guide describes how to set up your environment for developing Habityne on Windows, macOS, or Linux.

---

## 1. Environment Requirements

| Requirement | Minimum Version | Recommended |
|---|---|---|
| Flutter SDK | 3.22.0 | 3.47.2 / latest stable |
| Dart SDK | 3.4.0 | 3.13.2 / latest stable |
| Java JDK | JDK 17 | JDK 21 / Temurin 24 |
| Android Studio | 2024.1+ | 2026.1+ |
| Gradle | 8.14 | 8.14 / 9.1 |

---

## 2. JDK & Android Setup

### Android Studio JDK Configuration
Ensure Flutter uses a compatible JDK version:

```bash
flutter config --jdk-dir="C:\Program Files\Android\Android Studio\jbr"
```

Verify with:
```bash
flutter doctor -v
```

### Environment Variables
Avoid setting conflicting environment variables:
- Set `ANDROID_HOME` or `ANDROID_SDK_ROOT` to your Android SDK directory.
- Avoid setting both `ANDROID_PREFS_ROOT` and `ANDROID_USER_HOME` simultaneously as this causes Gradle plugin initialization errors.

---

## 3. Getting Dependencies

Run the following command in the project root:

```bash
flutter pub get
```

---

## 4. Verification

Run static checks and tests to verify installation:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```
