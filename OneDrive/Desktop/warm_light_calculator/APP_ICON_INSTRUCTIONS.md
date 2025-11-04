# App Icon Creation Instructions

The app icon should be a grid of 4 calculator buttons using the current warm theme colors.

## Design Specifications

- **Layout**: 2x2 grid of buttons
- **Buttons**: +, -, ×, ÷ (plus, minus, multiply, divide)
- **Colors**: Use the warm theme palette:
  - Button background: `#CA7C3A` (medium warm brown)
  - Button text: `#F5E6D3` (warm cream)
  - Background: `#F5E6D3` (warm cream)
  - Border: `#8B4513` (saddle brown)

## Button Layout

```
┌─────┬─────┐
│  +  │  -  │
├─────┼─────┤
│  ×  │  ÷  │
└─────┴─────┘
```

## Size Requirements

For Android, create icons in these sizes:
- `mipmap-mdpi`: 48x48px
- `mipmap-hdpi`: 72x72px
- `mipmap-xhdpi`: 96x96px
- `mipmap-xxhdpi`: 144x144px
- `mipmap-xxxhdpi`: 192x192px

For iOS, create:
- `Assets.xcassets/AppIcon.appiconset/` with various sizes

## Recommended Tools

1. **Figma** - Free design tool
2. **Canva** - Online design tool
3. **GIMP** - Free image editor
4. **Adobe Illustrator/Photoshop** - Professional tools

## Quick Creation Steps

1. Create a square canvas (1024x1024px for master)
2. Set background to warm cream (`#F5E6D3`)
3. Create 4 rounded rectangles (buttons) in a 2x2 grid
4. Add symbols: +, -, ×, ÷ centered in each button
5. Export at required sizes
6. Place in appropriate directories:
   - Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Alternative: Use Flutter Launcher Icons Package

You can also use the `flutter_launcher_icons` package:

1. Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon.png"
```

2. Run: `flutter pub get && flutter pub run flutter_launcher_icons`

This will automatically generate all required icon sizes from a single master image.

