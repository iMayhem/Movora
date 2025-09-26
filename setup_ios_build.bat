@echo off
echo ========================================
echo    Movora iOS Build Setup for AltStore
echo ========================================
echo.

echo [1/4] Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found. Please install Flutter first.
    pause
    exit /b 1
)

echo.
echo [2/4] Getting Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies.
    pause
    exit /b 1
)

echo.
echo [3/4] Checking iOS project structure...
if not exist "ios\Runner.xcworkspace" (
    echo ERROR: iOS project not found. Run 'flutter create --platforms=ios .' first.
    pause
    exit /b 1
)

echo.
echo [4/4] Project ready for iOS build!
echo.
echo ========================================
echo    NEXT STEPS FOR .IPA BUILDING
echo ========================================
echo.
echo Option 1: GitHub Actions (Recommended)
echo --------------------------------------
echo 1. Push this project to GitHub
echo 2. GitHub Actions will automatically build .ipa
echo 3. Download .ipa from Actions tab
echo 4. Install with AltStore
echo.
echo Option 2: Codemagic (Alternative)
echo ---------------------------------
echo 1. Sign up at codemagic.io
echo 2. Connect your GitHub repository
echo 3. Configure iOS build settings
echo 4. Build and download .ipa
echo.
echo Option 3: macOS Access Required
echo --------------------------------
echo 1. Get access to macOS with Xcode
echo 2. Run: cd ios ^&^& pod install ^&^& cd ..
echo 3. Run: flutter build ipa --release
echo 4. Find .ipa at: build/ios/ipa/movora.ipa
echo.
echo ========================================
echo    PROJECT CONFIGURATION COMPLETE
echo ========================================
echo.
echo Your Flutter app is ready for iOS building!
echo Bundle ID: com.movora.app
echo App Name: Movora
echo Target: AltStore Sideloading
echo.
echo Press any key to continue...
pause >nul
