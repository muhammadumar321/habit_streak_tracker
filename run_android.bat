@echo off
echo Checking for connected Android devices...
flutter devices

echo.
echo To run the app on an Android device:
echo 1. Connect your Android phone via USB with Developer Options enabled
echo 2. Or start an Android emulator from Android Studio
echo 3. Then run: flutter run -d <device-id>
echo.
echo Available devices:
flutter devices
echo.
if errorlevel 1 pause