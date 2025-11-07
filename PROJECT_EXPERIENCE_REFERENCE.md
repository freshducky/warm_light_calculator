# Warm Light Calculator - Project Experience Reference

## Project Overview
Flutter calculator app with warm, accessible design featuring:
- Tip calculation functionality
- Multiple themes (light, dark, high contrast)
- Accessibility features (text-to-speech, haptic feedback, large touch targets)
- Splash screen with animated logo
- Settings screen with privacy policy
- iOS and Android deployment via Codemagic CI/CD

---

## Key Technical Learnings

### 1. OneDrive File Locking Issues
**Problem:** OneDrive sync causes file locking that breaks Gradle builds
**Solution:** 
- Move Flutter projects to `Desktop` instead of `Documents` (OneDrive syncs Documents by default)
- If issues persist, force-delete `build/` directory: `Remove-Item -Recurse -Force build`

### 2. Android Gradle Plugin (AGP) Compatibility
**Problem:** AGP < 8.2.1 incompatible with Java 21
**Solution:**
- Update `android/settings.gradle`: `id "com.android.application" version "8.2.1"`
- Update `android/build.gradle`: `classpath 'com.android.tools.build:gradle:8.2.1'`
- Update `android/app/build.gradle`: 
  - `sourceCompatibility JavaVersion.VERSION_17`
  - `targetCompatibility JavaVersion.VERSION_17`
  - `jvmTarget '17'`

### 3. iOS Code Signing with Codemagic
**Problem:** Multiple issues with code signing and IPA generation
**Final Solution:** Simplified workflow using Codemagic's automatic signing:
```yaml
workflows:
  ios-production:
    name: iOS Production Build
    environment:
      groups:
        - app_store_credentials
      xcode: latest
    scripts:
      - name: Get Flutter packages
        script: |
          cd "OneDrive/Desktop/warm_light_calculator"
          flutter packages pub get
      - name: Build iOS
        script: |
          cd "OneDrive/Desktop/warm_light_calculator"
          flutter build ipa --release
    artifacts:
      - build/ios/ipa/*.ipa
    publishing:
      app_store_connect:
        api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        key_id: $APP_STORE_CONNECT_KEY_ID
        issuer_id: $APP_STORE_CONNECT_ISSUER_ID
```

**Key Points:**
- Use `flutter build ipa --release` (not `flutter build ios`)
- Let Codemagic handle automatic signing via `app_store_credentials` environment group
- No need for manual `xcode-project` commands in most cases
- Ensure bundle identifier matches App Store Connect: `com.freshducky.warmlightcalculator`

### 4. iOS App Icons
**Required Sizes:**
- iPhone: 20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024
- iPad: 76x76, 152x152, 167x167 (often missing!)
- Update `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`

**PowerShell Resize Command:**
```powershell
# Resize 1024.png to create missing sizes
$icon = "C:\path\to\1024.png"
$sizes = @(76, 152, 167)
foreach ($size in $sizes) {
    $output = "C:\path\to\${size}.png"
    # Use ImageMagick or similar tool
}
```

### 5. Splash Screen Implementation
**Pattern:**
- Use `StatefulWidget` with `SingleTickerProviderStateMixin`
- `AnimationController` for animations
- Circular logo with `ClipOval` and `BoxFit.cover`
- Loading indicator around logo

```dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ));

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0)
        .animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Circular loading indicator
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF8B4513).withOpacity(0.8 * _pulseAnimation.value),
                    ),
                    strokeWidth: 4,
                  ),
                ),
                // Circular logo with pulse
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B4513).withOpacity(0.3 * _pulseAnimation.value),
                          blurRadius: 20 * _pulseAnimation.value,
                          spreadRadius: 5 * _pulseAnimation.value,
                        ),
                      ],
                      border: Border.all(color: const Color(0xFF8B4513), width: 3),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/freshducky.jpg',
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 180,
                            height: 180,
                            color: const Color(0xFF8B4513),
                            child: const Icon(Icons.calculate, size: 100, color: Color(0xFFF5E6D3)),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

### 6. Settings Persistence Pattern
**Model:**
```dart
class AppSettings {
  bool highContrast = false;
  bool darkMode = false;
  bool soundEnabled = true;
  bool hapticEnabled = true;
  bool ttsEnabled = true;
  
  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings()
      ..highContrast = prefs.getBool('high_contrast') ?? false
      ..darkMode = prefs.getBool('dark_mode') ?? false
      ..soundEnabled = prefs.getBool('sound_enabled') ?? true
      ..hapticEnabled = prefs.getBool('haptic_enabled') ?? true
      ..ttsEnabled = prefs.getBool('tts_enabled') ?? true;
  }
  
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', highContrast);
    await prefs.setBool('dark_mode', darkMode);
    await prefs.setBool('sound_enabled', soundEnabled);
    await prefs.setBool('haptic_enabled', hapticEnabled);
    await prefs.setBool('tts_enabled', ttsEnabled);
  }
}
```

### 7. Undo Functionality Pattern
```dart
class _CalculatorScreenState extends State<CalculatorScreen> {
  String? _previousDisplay;
  
  void _saveStateForUndo() {
    _previousDisplay = _display;
  }
  
  void _undo() {
    if (_previousDisplay != null) {
      setState(() {
        _display = _previousDisplay!;
        _previousDisplay = null;
      });
      _playSound();
    }
  }
  
  // Call _saveStateForUndo() before operations that modify _display
}
```

### 8. Currency Formatting & Rounding
**Pattern:**
```dart
// Format with commas
String _formatNumber(String value) {
  try {
    final num = double.parse(value.replaceAll(',', ''));
    return num.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  } catch (e) {
    return value;
  }
}

// Round to 2 decimal places (currency)
double roundedResult = (result * 100).round() / 100;
```

### 9. Theme Management
**Pattern:**
```dart
ThemeData _getTheme() {
  if (_settings.highContrast) {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.orange,
      // High contrast colors
    );
  } else if (_settings.darkMode) {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: MaterialColor(
        0xFF8B4513,
        {
          50: Color(0xFFF5E6D3),
          // ... warm dark theme colors
        },
      ),
    );
  } else {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: MaterialColor(
        0xFF8B4513,
        {
          50: Color(0xFFF5E6D3),
          // ... warm light theme colors
        },
      ),
    );
  }
}
```

### 10. Accessibility Features
- **Text-to-Speech:** `flutter_tts` package
- **Haptic Feedback:** `HapticFeedback.lightImpact()`
- **Sound Effects:** `audioplayers` package
- **Large Touch Targets:** Minimum 48x48dp
- **High Contrast:** Custom color scheme
- **Screen Reader:** Flutter's built-in semantics

### 11. App Store Connect Checklist
- ✅ Age Rating (complete all content descriptions)
- ✅ Privacy Policy URL (hosted, not just local)
- ✅ Choose a build (upload via Codemagic)
- ✅ Primary category (e.g., "Utilities")
- ✅ App Privacy section (declare data collection)
- ✅ App Accessibility (VoiceOver, Dark Interface, etc.)
- ✅ Screenshots (iPhone 6.5" and iPad)
- ✅ App icon (all required sizes including iPad)
- ✅ Bundle identifier matches App Store Connect

### 12. Android Emulator Management
**PowerShell Script:**
```powershell
# Check devices
$devices = flutter devices
if ($devices -match "emulator") {
    $deviceId = ($devices | Select-String "emulator" | Select-Object -First 1) -replace ".*• ([^\s]+) •.*", '$1'
    Write-Host "Found device: $deviceId"
    flutter run -d $deviceId
} else {
    Write-Host "No emulator found. Please start one from Android Studio."
    flutter devices
}
```

**Common Issues:**
- Emulator may not appear immediately after launch - wait 10-30 seconds
- Pixel Tablet requires manual launch from Android Studio Device Manager
- Use `flutter emulators --launch <name>` for automatic launch

---

## Project Structure Best Practices

```
warm_light_calculator/
├── lib/
│   ├── main.dart              # Main app, screens
│   ├── models/
│   │   └── settings_model.dart # Settings persistence
│   └── utils/
│       └── number_formatter.dart # Number formatting utilities
├── assets/
│   └── freshducky.jpg         # Developer logo
├── android/                   # Android-specific config
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       └── res/
│   │           └── drawable/
│   │               └── ic_launcher.xml
│   ├── build.gradle
│   └── settings.gradle
├── ios/                       # iOS-specific config
│   ├── Runner/
│   │   └── Assets.xcassets/
│   │       └── AppIcon.appiconset/
│   └── Runner.xcodeproj/
├── codemagic.yaml             # CI/CD configuration
└── pubspec.yaml               # Dependencies
```

---

## Common Flutter Commands

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Build for production
flutter build apk --release        # Android
flutter build ipa --release        # iOS

# Device management
flutter devices
flutter emulators
flutter emulators --launch <name>

# Check for issues
flutter doctor
flutter doctor -v
```

---

## Git Workflow

```bash
# Check status
git status

# Add and commit
git add .
git commit -m "Description of changes"

# Push to GitHub
git push origin main

# Check recent commits
git log --oneline -5
```

---

## Dependencies Used

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2    # Settings persistence
  flutter_tts: ^4.0.2            # Text-to-speech
  audioplayers: ^5.2.1           # Sound effects
```

---

## Key Design Decisions

1. **Warm Color Palette:** Brown (#8B4513) and cream (#F5E6D3) for cozy, accessible design
2. **Currency Rounding:** Always 2 decimal places (cents) for money calculations
3. **Tip Buttons:** Common percentages (15%, 20%, 25%) instead of custom input
4. **Splash Screen:** Developer logo with loading animation (not app icon)
5. **App Icon:** Calculator operation symbols (division symbol ÷) instead of logo
6. **Undo:** Simple single-step undo (not full history)
7. **Settings:** Nested privacy policy instead of separate screen

---

## Future Project Quick Start

1. **Create new Flutter project:** `flutter create project_name`
2. **Move to Desktop:** Avoid OneDrive sync issues
3. **Update Gradle:** AGP 8.2.1, Java 17
4. **Add iOS platform:** `flutter create --platforms=ios .`
5. **Set bundle ID:** Match App Store Connect
6. **Configure Codemagic:** Use simplified YAML pattern
7. **Add app icons:** All required sizes including iPad
8. **Test on emulators:** Both phone and tablet

---

## Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| OneDrive file locks | Move project to Desktop |
| AGP/Java compatibility | Update to AGP 8.2.1, Java 17 |
| iOS build fails | Use `flutter build ipa --release` |
| Codemagic no pubspec.yaml | Add `cd` to project path in YAML |
| Missing iPad icons | Add 76x76, 152x152, 167x167 to Contents.json |
| Emulator not detected | Wait 10-30 seconds after launch |
| Code signing errors | Use Codemagic automatic signing |
| App Store submission errors | Check Age Rating, Privacy Policy, Build selection |

---

*Last Updated: January 2025*
*Project: Warm Light Calculator*
*Developer: FreshDucky*

