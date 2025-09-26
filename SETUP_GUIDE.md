# Movora Website to Flutter App Conversion - Setup Guide

## Overview

This guide will help you convert your Movora Next.js website into a fully functional Flutter mobile app. The app will maintain the same functionality and design aesthetic while providing a native mobile experience.

## What Has Been Created

I've already created the complete Flutter project structure with:

✅ **Core Files Created:**
- `pubspec.yaml` - Flutter dependencies and configuration
- `lib/main.dart` - App entry point
- `lib/theme/app_theme.dart` - Dark/light theme configuration
- `lib/models/media.dart` - Movie/TV show data model
- `lib/services/tmdb_service.dart` - TMDB API integration
- `lib/providers/movie_provider.dart` - State management
- `lib/widgets/movie_card.dart` - Individual movie display
- `lib/widgets/movie_list.dart` - Horizontal movie lists
- `lib/screens/home_screen.dart` - Main home screen
- `lib/config/app_config.dart` - App configuration
- `android/app/src/main/AndroidManifest.xml` - Android permissions
- `test/widget_test.dart` - Basic testing
- `setup_flutter.bat` - Windows setup script
- `README.md` - Project documentation

✅ **Directory Structure:**
- `lib/` - Main app code
- `assets/` - Images, icons, and fonts
- `android/` - Android-specific configuration
- `test/` - Testing files

## Next Steps to Complete the Setup

### 1. Install Flutter SDK

**Windows:**
1. Download Flutter SDK from: https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\flutter` (or your preferred location)
3. Add `C:\flutter\bin` to your PATH environment variable
4. Restart your terminal/command prompt

**Verify Installation:**
```bash
flutter doctor
```

### 2. Get TMDB API Key

1. Visit [The Movie Database](https://www.themoviedb.org/)
2. Create an account and sign in
3. Go to Settings → API → Request API Key
4. Choose "Developer" option
5. Fill out the form and submit
6. Copy your API key

### 3. Update API Key

Replace `YOUR_TMDB_API_KEY` in these files:
- `lib/services/tmdb_service.dart` (line 7)
- `lib/config/app_config.dart` (line 18)

### 4. Install Dependencies

Run this command in your project directory:
```bash
flutter pub get
```

### 5. Add Fonts (Optional)

For the best experience, download and add these fonts to `assets/fonts/`:
- Inter (Regular, Medium, SemiBold, Bold)
- Space Grotesk (Regular, Medium, SemiBold, Bold)

Or update `pubspec.yaml` to use system fonts by removing the font section.

### 6. Run the App

**Android:**
```bash
flutter run
```

**iOS (macOS only):**
```bash
flutter run -d ios
```

## Features Implemented

🎬 **Movie Discovery:**
- Trending now
- Newly released in theaters
- Most popular content
- Top rated movies and TV shows
- Genre-based categories (Action, Comedy, Sci-Fi, Horror, Thriller)

🎨 **UI/UX:**
- Material Design 3
- Dark theme (matches your website)
- Responsive design
- Smooth animations
- Pull-to-refresh
- Error handling with retry

📱 **Mobile Optimizations:**
- Touch-friendly interface
- Horizontal scrolling lists
- Image caching
- Optimized for mobile screens
- Native mobile feel

## Customization Options

### Colors and Theme
Edit `lib/theme/app_theme.dart` to change:
- Primary/secondary colors
- Background colors
- Text colors
- Card styles

### API Configuration
Edit `lib/config/app_config.dart` to modify:
- API endpoints
- Default parameters
- Genre mappings
- UI constants

### Adding New Features
- **Search**: Implement search functionality in `lib/screens/`
- **Details**: Create movie detail screens
- **Favorites**: Add local storage for saved items
- **Categories**: Add more genre-based sections

## Troubleshooting

### Common Issues:

1. **"Flutter command not found"**
   - Ensure Flutter is in your PATH
   - Restart terminal after installation

2. **"Package not found" errors**
   - Run `flutter pub get`
   - Check internet connection

3. **API errors**
   - Verify your TMDB API key is correct
   - Check API key is properly set in both files

4. **Build errors**
   - Run `flutter clean` then `flutter pub get`
   - Ensure Flutter version is 3.0.0+

### Getting Help:

- Flutter Documentation: https://flutter.dev/docs
- Flutter Community: https://flutter.dev/community
- Stack Overflow: Tag with `flutter`

## Performance Tips

- Images are cached automatically
- API calls are optimized with proper error handling
- State management prevents unnecessary rebuilds
- Pull-to-refresh for manual data updates

## Deployment

### Android:
```bash
flutter build apk --release
```

### iOS:
```bash
flutter build ios --release
```

## Next Development Steps

1. **Add Search Functionality**
2. **Create Movie Detail Screens**
3. **Implement User Authentication**
4. **Add Offline Support**
5. **Push Notifications**
6. **Analytics Integration**

## Support

If you encounter any issues during setup:
1. Check the troubleshooting section above
2. Verify Flutter installation with `flutter doctor`
3. Ensure all dependencies are installed
4. Check that API key is properly configured

The app is designed to be a direct conversion of your website's functionality, so it should work seamlessly once properly configured!
