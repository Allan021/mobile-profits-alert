#!/usr/bin/env bash
set -e

EMULATOR="$LOCALAPPDATA/Android/Sdk/emulator/emulator.exe"
ADB="$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe"
AVD="ProfitAlerts_Demo"
DEVICE="emulator-5554"

echo "Starting emulator: $AVD"
"$EMULATOR" -avd "$AVD" &

echo "Waiting for emulator to boot..."
until "$ADB" -s "$DEVICE" shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; do
  sleep 3
done

echo "Emulator ready. Launching ProfitAlerts..."
flutter run -d "$DEVICE"
