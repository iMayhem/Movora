@echo off
echo Setting up Movora Flutter App...
echo.

echo Checking if Flutter is installed...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo Flutter is installed!
echo.

echo Installing dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo Dependencies installed successfully!
echo.

echo IMPORTANT: You need to get a TMDB API key:
echo 1. Visit https://www.themoviedb.org/
echo 2. Create an account and request an API key
echo 3. Replace 'YOUR_TMDB_API_KEY' in lib/services/tmdb_service.dart
echo.

echo Setup complete! You can now run:
echo flutter run
echo.

pause
