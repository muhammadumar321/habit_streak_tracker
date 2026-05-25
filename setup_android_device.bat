@echo off
echo Setting up Android device for Habityne app deployment...
echo.

echo Checking if device is connected...
adb devices

echo.
echo If no device appears above, please:
echo 1. Connect your Android device via USB
echo 2. Enable Developer Options on your device (in Settings > About Phone, tap Build Number 7 times)
echo 3. Enable USB Debugging (in Settings > Developer Options)
echo 4. On some devices, you may need to accept a connection authorization on the device screen
echo.

echo Once your device is properly connected, run the Habityne app with:
echo flutter run
echo.

pause