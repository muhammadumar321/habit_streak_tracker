# Release Guide

This document outlines the step-by-step procedure for preparing, building, and deploying a release of Habityne.

---

## 1. Version Bump

Update the version number in `pubspec.yaml`:

```yaml
version: 1.0.0+2
```
- The number before `+` is `versionName` (e.g., `1.0.0`).
- The number after `+` is `versionCode` (e.g., `2`).

---

## 2. Release Checklist

1. **Verify Static Analysis**:
   ```bash
   flutter analyze
   ```
2. **Run All Unit & Widget Tests**:
   ```bash
   flutter test
   ```
3. **Format Source Code**:
   ```bash
   dart format .
   ```

---

## 3. Building Release Artifacts

### Android App Bundle (AAB)
Required for Google Play Store publishing:

```bash
flutter build appbundle --release
```

Output path: `build/app/outputs/bundle/release/app-release.aab`

### Android Release APK
For direct distribution or side-loading:

```bash
flutter build apk --release
```

Output path: `build/app/outputs/flutter-apk/app-release.apk`

---

## 4. Signing Releases

Configure your production signing key in `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=<your-key-alias>
storeFile=<path-to-keystore-file>
```

> **Warning**: Never commit `key.properties` or keystore `.jks` files to Git repository!
