# Building .ipa for AltStore Sideloading

## 🚨 Important Limitation

**Building .ipa files requires macOS and Xcode**, which you don't have on Windows. However, I'll show you the complete process and provide alternative solutions.

## 📋 Complete .ipa Build Process (macOS Required)

### Step 1: Configure Release Build Settings

#### Update Info.plist for Release
```xml
<!-- Add to ios/Runner/Info.plist -->
<key>CFBundleDisplayName</key>
<string>Movora</string>
<key>CFBundleIdentifier</key>
<string>com.yourcompany.movora</string>
<key>CFBundleVersion</key>
<string>1.0.0</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

#### Configure Build Settings for AltStore
```bash
# Set build mode to release
flutter build ios --release

# Or configure in Xcode:
# Product → Scheme → Edit Scheme → Run → Build Configuration → Release
```

### Step 2: Code Signing for AltStore

#### Option A: Personal Team (Free)
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project
3. Go to "Signing & Capabilities"
4. Check "Automatically manage signing"
5. Select your Personal Team
6. Set Bundle Identifier: `com.yourname.movora`

#### Option B: AltStore Developer Account
1. Get AltStore Developer Account ($99/year)
2. Use AltStore's provisioning profile
3. Configure with AltStore's certificate

### Step 3: Build Commands

#### Method 1: Flutter Command Line
```bash
# Clean previous builds
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Build release .ipa
flutter build ios --release

# Archive for distribution
flutter build ipa --release
```

#### Method 2: Xcode Archive
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as target
3. Product → Archive
4. Distribute App → Ad Hoc
5. Save .ipa file

### Step 4: AltStore Sideloading

#### Prepare .ipa for AltStore
```bash
# The .ipa will be located at:
# build/ios/ipa/movora.ipa
```

#### AltStore Installation Process
1. Install AltStore on your Mac/PC
2. Connect iPhone via USB
3. Open AltStore
4. Drag .ipa file to AltStore
5. Install on device

## 🔄 Alternative Solutions (Windows Compatible)

### Option 1: Cloud Build Services

#### GitHub Actions (Free)
Create `.github/workflows/ios-build.yml`:
```yaml
name: Build iOS App
on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    - name: Install dependencies
      run: |
        flutter pub get
        cd ios && pod install && cd ..
    - name: Build iOS
      run: flutter build ios --release
    - name: Build IPA
      run: flutter build ipa --release
    - name: Upload IPA
      uses: actions/upload-artifact@v3
      with:
        name: movora.ipa
        path: build/ios/ipa/movora.ipa
```

#### Codemagic (Free Tier Available)
1. Connect your GitHub repository
2. Configure iOS build settings
3. Automatic .ipa generation
4. Download from Codemagic dashboard

### Option 2: macOS Virtual Machine
```bash
# Using VMware/VirtualBox
# Install macOS Monterey/Ventura
# Install Xcode
# Follow the build process above
```

### Option 3: MacinCloud/AWS Mac Instances
1. Rent macOS cloud instance
2. Upload your Flutter project
3. Build .ipa remotely
4. Download the result

## 🛠 Current Project Configuration

Your project is already configured for .ipa building:

### ✅ Ready for iOS Build
- iOS project structure created
- Dependencies configured
- Permissions set up
- App icons in place
- Release configuration ready

### 📱 AltStore Compatibility
- Bundle identifier can be set to personal team
- No special entitlements required
- Standard iOS app structure
- Compatible with AltStore sideloading

## 🚀 Immediate Next Steps

### For Windows Users:
1. **Use GitHub Actions** (Recommended)
   - Push your code to GitHub
   - Set up the workflow above
   - Get .ipa automatically built

2. **Use Codemagic**
   - Sign up for free account
   - Connect GitHub repository
   - Build .ipa in cloud

3. **Find macOS Access**
   - Use friend's Mac
   - Rent cloud Mac instance
   - Use macOS VM (if legal in your region)

### For macOS Users:
```bash
# Run these commands on macOS:
cd ios && pod install && cd ..
flutter build ipa --release
# Find .ipa at: build/ios/ipa/movora.ipa
```

## 📦 Expected .ipa File

Once built, you'll get:
- **File**: `movora.ipa`
- **Location**: `build/ios/ipa/`
- **Size**: ~50-100MB (depending on assets)
- **Compatible**: AltStore, Sideloadly, 3uTools

## 🔧 Troubleshooting

### Common Issues:
1. **Code Signing Errors**: Use Personal Team for free development
2. **Bundle ID Conflicts**: Change to unique identifier
3. **Provisioning Issues**: Enable "Automatically manage signing"
4. **Build Failures**: Clean project and rebuild

### AltStore Specific:
1. **Installation Failed**: Check device UDID registration
2. **App Crashes**: Verify all dependencies included
3. **Expired Certificate**: Re-sign with AltStore

## 💡 Pro Tips

1. **Bundle ID**: Use reverse domain notation (`com.yourname.movora`)
2. **Version**: Increment build number for each AltStore install
3. **Signing**: Personal Team works for 7-day sideloading
4. **Testing**: Test on device before distributing

Your Flutter app is **100% ready for .ipa building** - you just need macOS access to complete the build process!
