# Troubleshooting Guide

Common issues encountered during development and building, along with their solutions.

---

## 1. Gradle Build Failures

### Issue: `AndroidLocationsException: Several environment variables and/or system properties contain different paths to the Android Preferences folder.`
**Cause**: Both `ANDROID_PREFS_ROOT` and `ANDROID_USER_HOME` environment variables are defined on the system.
**Solution**: Remove `ANDROID_PREFS_ROOT` from system environment variables:
```powershell
Remove-Item Env:\ANDROID_PREFS_ROOT -ErrorAction SilentlyContinue
```

### Issue: `The Java version used for the build is X, which is incompatible with Gradle Y.`
**Cause**: Flutter is configured with an incompatible JDK version.
**Solution**: Configure Flutter to use Android Studio's bundled JDK or Temurin JDK:
```bash
flutter config --jdk-dir="C:\Program Files\Android\Android Studio\jbr"
```

---

## 2. Dependencies & Analyzer Issues

### Issue: `Target of URI doesn't exist: package:habit_streak_tracker/...`
**Cause**: The `pubspec.yaml` defines the package name as `habityne`. Importing `package:habit_streak_tracker` causes unresolved import errors.
**Solution**: Use `package:habityne/...` for internal package imports.

### Issue: Deprecation Warnings for `withOpacity()`
**Cause**: Flutter 3.22+ deprecated `Color.withOpacity()` in favor of `.withValues()`.
**Solution**: Use `color.withValues(alpha: 0.5)` or `.withValues(alpha: opacity)`.

---

## 3. Database Issues

### Issue: `SqfliteFfiException` during testing or web run
**Cause**: SQLite native driver is not loaded in unit tests or web environment.
**Solution**: `DatabaseHelper` includes a mock driver for Web environments. Unit tests should mock `HabitRepository` using `mocktail`.
