# LendLedger - Setup Guide

Complete guide to set up and run the LendLedger Flutter application.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (3.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Dart SDK** (3.0 or higher)
   - Comes bundled with Flutter

3. **IDE** (Choose one)
   - Android Studio (recommended for Android development)
   - VS Code with Flutter extension
   - IntelliJ IDEA

4. **Platform-specific requirements:**
   - **For Android:**
     - Android Studio
     - Android SDK (API level 21 or higher)
     - Android Emulator or physical device
   
   - **For iOS:**
     - macOS
     - Xcode (latest version)
     - CocoaPods
     - iOS Simulator or physical device

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/VDVDVDVDVDVDDVDV/lendledger.git
cd lendledger
```

### 2. Install Dependencies

```bash
flutter pub get
```

This will install all the required packages listed in `pubspec.yaml`.

### 3. Platform-Specific Setup

#### Android Setup

1. **Update `android/app/build.gradle`:**

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.lendledger.app"
        minSdkVersion 23  // Required for biometric auth
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

2. **Add permissions in `android/app/src/main/AndroidManifest.xml`:**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Biometric Authentication -->
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
    
    <!-- Internet (for cloud backup - optional) -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application
        android:label="LendLedger"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
</manifest>
```

#### iOS Setup

1. **Update `ios/Runner/Info.plist`:**

```xml
<dict>
    <!-- Biometric Authentication -->
    <key>NSFaceIDUsageDescription</key>
    <string>LendLedger needs Face ID to secure your financial data</string>
    
    <!-- ... other keys ... -->
</dict>
```

2. **Update minimum iOS version in `ios/Podfile`:**

```ruby
platform :ios, '12.0'
```

3. **Install CocoaPods dependencies:**

```bash
cd ios
pod install
cd ..
```

### 4. Run the App

#### On Android:

```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run
```

#### On iOS:

```bash
# Open iOS Simulator
open -a Simulator

# Run on simulator
flutter run
```

#### For specific device:

```bash
flutter run -d <device-id>
```

## Configuration

### 1. Biometric Authentication

The app uses biometric authentication by default. To disable it during development:

1. Open `lib/services/auth_service.dart`
2. Set `_biometricEnabled = false` in the constructor

### 2. Database

The app uses SQLite for local storage. The database is automatically created on first launch at:
- **Android:** `/data/data/com.lendledger.app/databases/lendledger.db`
- **iOS:** `Library/Application Support/lendledger.db`

### 3. Cloud Backup (Optional)

To enable Firebase cloud backup:

1. Create a Firebase project at https://console.firebase.google.com
2. Add your Android/iOS app to the project
3. Download configuration files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
4. Uncomment Firebase initialization in `lib/main.dart`

## Development

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── loan.dart
│   ├── payment.dart
│   └── audit_log.dart
├── services/                 # Business logic
│   ├── database_service.dart
│   ├── auth_service.dart
│   └── interest_calculator.dart
├── screens/                  # UI screens
│   ├── auth_screen.dart
│   ├── dashboard_screen.dart
│   ├── add_transaction_screen.dart
│   ├── transaction_feed_screen.dart
│   └── transaction_detail_screen.dart
├── widgets/                  # Reusable components
│   └── transaction_card.dart
└── utils/                    # Utilities
    └── constants.dart
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Building for Production

#### Android APK:

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

#### Android App Bundle (for Play Store):

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

#### iOS:

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode and archive.

## Troubleshooting

### Common Issues

1. **"Gradle build failed"**
   - Solution: Update Android SDK and Gradle
   - Run: `flutter clean && flutter pub get`

2. **"CocoaPods not installed"**
   - Solution: Install CocoaPods
   - Run: `sudo gem install cocoapods`

3. **"Biometric authentication not working"**
   - Ensure device has biometric hardware
   - Check permissions in AndroidManifest.xml / Info.plist
   - Test on physical device (emulators may not support biometrics)

4. **"Database error"**
   - Clear app data and reinstall
   - Run: `flutter clean`

### Debug Mode

Enable debug logging:

```dart
// In main.dart
void main() {
  debugPrint('Debug mode enabled');
  runApp(const LendLedgerApp());
}
```

## Performance Optimization

1. **Enable code shrinking (Android):**

```gradle
buildTypes {
    release {
        shrinkResources true
        minifyEnabled true
    }
}
```

2. **Optimize images:**
   - Use appropriate image formats
   - Compress assets before adding

3. **Profile the app:**

```bash
flutter run --profile
```

## Security Best Practices

1. **Never commit sensitive data:**
   - Add `.env` files to `.gitignore`
   - Use environment variables for API keys

2. **Enable ProGuard (Android):**
   - Obfuscates code in release builds
   - Already configured in `build.gradle`

3. **Enable App Transport Security (iOS):**
   - Already configured in `Info.plist`

## Next Steps

1. **Customize the app:**
   - Update app name in `pubspec.yaml`
   - Change package name
   - Add custom app icon

2. **Add features:**
   - Implement notification service
   - Add cloud backup
   - Create reports and analytics

3. **Deploy:**
   - Publish to Google Play Store
   - Publish to Apple App Store

## Support

For issues and questions:
- GitHub Issues: https://github.com/VDVDVDVDVDVDDVDV/lendledger/issues
- Documentation: See README.md

## License

MIT License - See LICENSE file for details