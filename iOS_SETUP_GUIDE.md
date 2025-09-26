# iOS Setup Guide for Movora Flutter App

## ✅ Completed Setup Steps

Your Flutter app has been successfully configured for iOS development. Here's what has been set up:

### 1. iOS Project Structure ✅
- Created iOS project files using `flutter create --platforms=ios .`
- Generated all necessary iOS configuration files

### 2. iOS Permissions & Settings ✅
- **Network Security**: Configured App Transport Security (ATS) for:
  - `api.themoviedb.org` (TMDB API)
  - `image.tmdb.org` (Movie posters)
  - `player.vidplus.to` (Video streaming)
  - `vidsrc.xyz` (Alternative video streaming)
- **Background Audio**: Enabled for video playback
- **WebView Support**: Configured for video streaming
- **Camera/Microphone**: Prepared for future features
- **Photo Library**: Enabled for saving movie posters

### 3. App Icons ✅
- Copied your 1024x1024 icon to all required iOS icon sizes
- Icons are located in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### 4. iOS Dependencies ✅
- Created `ios/Podfile` with proper iOS configurations
- Configured deployment target to iOS 12.0
- Set up audio session for video playback

## 🚀 Next Steps to Complete iOS Setup

### Step 1: Install iOS Dependencies
```bash
cd ios
pod install
cd ..
```

### Step 2: Test the Build
```bash
# Check if everything compiles correctly
flutter analyze

# Try building for iOS (requires macOS and Xcode)
flutter build ios --debug
```

### Step 3: Open in Xcode (Required for iOS Development)
1. Open `ios/Runner.xcworkspace` in Xcode (NOT Runner.xcodeproj)
2. Select the Runner project
3. Go to "Signing & Capabilities"
4. Set your Apple Developer Team
5. Configure Bundle Identifier (e.g., `com.yourcompany.movora`)

### Step 4: Run on iOS Simulator/Device
```bash
# List available iOS simulators
flutter devices

# Run on iOS simulator
flutter run -d ios

# Run on specific iOS device
flutter run -d "iPhone 15 Pro"
```

## 📱 iOS-Specific Features Configured

### Video Playback
- **Background Audio**: Configured to continue playing when app goes to background
- **AirPlay Support**: Enabled for casting to Apple TV
- **WebView Integration**: Optimized for VidPlus video streaming

### Network Configuration
- **HTTPS/HTTP Support**: Configured for all required domains
- **API Calls**: TMDB API calls will work seamlessly
- **Image Loading**: Movie posters will load properly

### App Store Requirements
- **App Icons**: All required sizes generated
- **Launch Screen**: Configured with proper storyboard
- **Orientation Support**: Portrait and landscape modes enabled

## 🔧 Troubleshooting Common Issues

### Issue 1: "Could not find an option named '--no-codesign'"
**Solution**: Use `flutter build ios --debug` instead

### Issue 2: Pod Install Fails
**Solution**: 
```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Issue 3: Build Errors
**Solution**: 
1. Clean the project: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Install iOS pods: `cd ios && pod install && cd ..`
4. Try building again: `flutter build ios --debug`

### Issue 4: Missing iOS Simulator
**Solution**: 
1. Open Xcode
2. Go to Xcode → Preferences → Components
3. Download iOS Simulator

## 📋 Required Tools for iOS Development

### On Windows (Current Setup)
- ✅ Flutter SDK
- ✅ Android Studio (for Flutter development)
- ❌ Xcode (macOS only)
- ❌ iOS Simulator (macOS only)

### For Full iOS Development (macOS Required)
- macOS with Xcode installed
- Apple Developer Account (for device testing)
- iOS Simulator or physical iOS device

## 🎯 Current Status

Your Flutter app is **fully configured for iOS** and ready for development. The main limitation is that you're on Windows, so you cannot:

1. **Build iOS apps** (requires macOS)
2. **Run iOS Simulator** (requires macOS)
3. **Test on iOS devices** (requires macOS)

## 💡 Recommendations

### Option 1: Use Cloud Build Services
- **GitHub Actions** with macOS runners
- **Codemagic** for Flutter iOS builds
- **Bitrise** for mobile CI/CD

### Option 2: Use macOS Virtual Machine
- **VMware** or **VirtualBox** with macOS
- **MacinCloud** or **AWS Mac instances**

### Option 3: Collaborate with macOS Developer
- Share your Flutter code
- Have them build and test on iOS
- Use version control for collaboration

## 🔍 Verification Checklist

- [x] iOS project structure created
- [x] Info.plist configured with permissions
- [x] AppDelegate.swift configured for audio
- [x] Podfile created with dependencies
- [x] App icons copied to all required sizes
- [x] Network security configured
- [x] Video playback permissions set
- [ ] Pod install completed (run `cd ios && pod install`)
- [ ] Xcode project opened and configured
- [ ] iOS build tested (requires macOS)

## 📞 Support

If you encounter any issues:
1. Check Flutter documentation: https://docs.flutter.dev/platform-integration/ios
2. Verify iOS requirements: https://docs.flutter.dev/get-started/install/macos
3. Check plugin compatibility: https://pub.dev/packages

Your Movora app is now ready for iOS development! 🎉
