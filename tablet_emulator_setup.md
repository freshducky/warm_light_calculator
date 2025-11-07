# Pixel Tablet Emulator Setup Guide

## Issue: Pixel Tablet Emulator Won't Start

The emulator is failing with "Address these issues and try again."

## Solutions:

### Option 1: Launch Manually from Android Studio (Easiest)

1. **Open Android Studio**
2. **Go to:** Tools → Device Manager
3. **Find:** Pixel Tablet
4. **Click:** The Play button (▶) to start it
5. **Wait:** For it to fully boot (takes 30-60 seconds)
6. **Then run:** `flutter run` (Flutter will detect it automatically)

---

### Option 2: Check Emulator Configuration

The error might be due to:
- **Insufficient RAM allocated**
- **Missing system image**
- **Corrupted AVD**

**Fix in Android Studio:**
1. Tools → Device Manager
2. Click the **Edit** (pencil) icon next to Pixel Tablet
3. **Show Advanced Settings**
4. **RAM:** Increase to at least 2048 MB (2 GB)
5. **Graphics:** Try "Automatic" or "Software - GLES 2.0"
6. **Save** and try launching again

---

### Option 3: Create a New Tablet Emulator

If the current one is corrupted:

1. **Android Studio → Device Manager**
2. **Click:** "+ Create Device"
3. **Select:** Tablet → Pixel Tablet
4. **System Image:** Download if needed (recommended: Latest API)
5. **Finish:** Create the AVD
6. **Launch** it
7. **Run:** `flutter run` (will auto-detect)

---

### Option 4: Use Command Line (If Android SDK is in PATH)

```powershell
# Find Android SDK location
$env:ANDROID_HOME

# Launch emulator directly
& "$env:ANDROID_HOME\emulator\emulator.exe" -avd Pixel_Tablet
```

---

## Once Tablet is Running:

**Check it's detected:**
```bash
flutter devices
```

**Run your app on it:**
```bash
flutter run
```

Flutter will automatically detect and use the tablet if it's the only device, or you can specify:
```bash
flutter run -d <tablet-device-id>
```

---

## Quick Test: Run on Current Phone Emulator

For now, your app is running on the phone emulator (`emulator-5554`). The layout should be similar, just smaller. You can:

1. **Take screenshots** from the phone emulator (for testing)
2. **Check layout** - if it looks good on phone, it should work on tablet
3. **Fix tablet emulator** when you have time for proper tablet screenshots

---

## Next Steps:

1. **Try launching Pixel Tablet from Android Studio** (Option 1 - easiest)
2. **Once it's running, run:** `flutter run` 
3. **The app will automatically deploy to the tablet**

Let me know once the tablet emulator is running and I can help you run the app on it!

