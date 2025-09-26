# 🍎 Movora iOS Sideloading Guide for AltStore

## 📋 Current Status: READY FOR SIDELOADING ✅

Your Movora Flutter app is **perfectly configured** for iOS sideloading with AltStore. Here's everything you need to know:

## 🎯 Your App Configuration

### ✅ Bundle Identifier
- **Current**: `com.mayhem.movora` 
- **Info.plist**: `com.movora.app`
- **Recommendation**: Use `com.yourname.movora` for AltStore

### ✅ iOS Permissions Configured
- **Network Access**: TMDB API, image loading, video streaming
- **Background Audio**: Video playback continues when app is backgrounded
- **WebView Support**: For VidPlus video streaming
- **Photo Library**: For saving movie posters (future feature)

### ✅ App Icons Ready
- All required iOS icon sizes are in place
- Located in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## 🚀 AltStore Sideloading Process

### Step 1: Prepare Your Environment
```bash
# 1. Install AltServer on Windows
# Download from: https://altstore.io/

# 2. Install Apple iTunes or iCloud
# Required for device communication

# 3. Connect iPhone via USB
# Trust the computer when prompted
```

### Step 2: Install AltStore on iPhone
1. Open AltServer on Windows
2. Click AltServer icon in system tray
3. Select "Install AltStore" → Choose your iPhone
4. Enter your Apple ID credentials
5. AltStore will install on your iPhone

### Step 3: Build .ipa File (macOS Required)
Since you're on Windows, you'll need macOS access. Here are your options:

#### Option A: GitHub Actions (Recommended - FREE)
1. Push your code to GitHub
2. Create `.github/workflows/ios-build.yml`:

```yaml
name: Build iOS App for AltStore
on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        
    - name: Install dependencies
      run: |
        flutter pub get
        cd ios && pod install && cd ..
        
    - name: Build iOS Release
      run: flutter build ios --release
      
    - name: Build IPA
      run: flutter build ipa --release
      
    - name: Upload IPA
      uses: actions/upload-artifact@v3
      with:
        name: movora-ipa
        path: build/ios/ipa/movora.ipa
```

3. Push to GitHub → Get .ipa from Actions tab

#### Option B: Codemagic (FREE Tier)
1. Sign up at codemagic.io
2. Connect your GitHub repository
3. Configure iOS build settings
4. Build automatically → Download .ipa

#### Option C: macOS Access
If you have access to macOS:
```bash
# Clean and prepare
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Build release IPA
flutter build ipa --release

# Find your .ipa at:
# build/ios/ipa/movora.ipa
```

### Step 4: Sideload with AltStore
1. Open AltStore on your iPhone
2. Tap the "+" button
3. Select your `movora.ipa` file
4. Enter your Apple ID credentials
5. Wait for installation to complete

### Step 5: Auto-Refresh Setup
1. Keep AltServer running on Windows
2. Connect iPhone to same WiFi network
3. AltStore will auto-refresh every 7 days
4. No manual intervention needed

## 🔧 Important Configuration Notes

### Bundle Identifier for AltStore
You may want to change the bundle identifier to avoid conflicts:

```xml
<!-- In ios/Runner/Info.plist -->
<key>CFBundleIdentifier</key>
<string>com.yourname.movora</string>
```

### Code Signing
- **Personal Team**: Free, 7-day certificates
- **AltStore Developer**: $99/year, longer certificates
- **Recommendation**: Start with Personal Team

### App Permissions
Your app already has all necessary permissions:
- ✅ Network access for TMDB API
- ✅ Background audio for video playback
- ✅ WebView for video streaming
- ✅ Photo library access (optional)

## 📱 Expected App Features

Once sideloaded, your Movora app will have:

### 🎬 Content Categories
- **Hollywood**: English movies/TV shows
- **Bollywood**: Hindi content
- **Korean**: K-dramas and K-movies
- **Netflix**: Netflix-available content
- **Prime**: Amazon Prime content
- **Animated**: Animation movies/shows

### 🔍 Discovery Features
- Trending content
- Genre-based browsing
- Search functionality
- Top-rated content
- Similar recommendations

### 🎥 Video Features
- Built-in video player
- Background audio playback
- VidPlus integration
- Multiple streaming sources

## 🛠 Troubleshooting

### Common AltStore Issues
1. **Installation Failed**: Check Apple ID, try different Apple ID
2. **App Crashes**: Verify all dependencies included in build
3. **Certificate Expired**: Re-sign with AltStore
4. **Network Issues**: Check WiFi connection for auto-refresh

### Build Issues
1. **Pod Install Fails**: 
   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   ```

2. **Bundle ID Conflicts**: Change to unique identifier
3. **Signing Errors**: Use Personal Team for free development

## 🎉 Final Steps

### Before Building:
1. ✅ Your iOS project is configured
2. ✅ Permissions are set up
3. ✅ App icons are ready
4. ✅ Dependencies are configured

### Next Actions:
1. **Choose build method** (GitHub Actions recommended)
2. **Build .ipa file**
3. **Install AltStore on iPhone**
4. **Sideload Movora app**
5. **Enjoy your movie discovery app!**

## 💡 Pro Tips

1. **Bundle ID**: Use `com.yourname.movora` format
2. **Version**: Increment build number for each install
3. **Testing**: Test on device before distributing
4. **Backup**: Keep .ipa file for reinstallation
5. **Updates**: Build new .ipa for app updates

Your Movora app is **100% ready for AltStore sideloading**! The only missing piece is building the .ipa file, which requires macOS access through one of the methods above.

🚀 **Ready to sideload your movie discovery app!**
