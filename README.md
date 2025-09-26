# Movora - Flutter App

A Flutter mobile app version of the Movora movie discovery website. This app provides a beautiful, native mobile experience for browsing movies and TV shows.

## Features

- **Trending Now**: Discover what's currently popular
- **Newly Released**: Latest movies in theaters
- **Most Popular**: Top trending content
- **Top Rated**: Highest-rated movies and TV shows
- **Genre Categories**: Action, Comedy, Sci-Fi, Horror, Thriller
- **Beautiful UI**: Modern Material Design 3 interface
- **Dark Theme**: Eye-friendly dark mode
- **Responsive Design**: Optimized for all screen sizes

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

## Setup Instructions

### 1. Install Flutter

Follow the official Flutter installation guide: https://flutter.dev/docs/get-started/install

### 2. Get TMDB API Key

1. Visit [The Movie Database](https://www.themoviedb.org/)
2. Create an account and request an API key
3. Replace `YOUR_TMDB_API_KEY` in `lib/services/tmdb_service.dart` with your actual API key

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/
│   └── media.dart         # Movie/TV show data model
├── providers/
│   └── movie_provider.dart # State management
├── screens/
│   └── home_screen.dart   # Main home screen
├── services/
│   └── tmdb_service.dart  # API service
├── theme/
│   └── app_theme.dart     # App theme configuration
└── widgets/
    ├── movie_card.dart    # Individual movie card
    └── movie_list.dart    # Movie list/carousel
```

## Dependencies

- **http**: For API calls
- **provider**: State management
- **cached_network_image**: Image caching
- **carousel_slider**: Horizontal scrolling lists
- **shimmer**: Loading placeholders
- **shared_preferences**: Local storage
- **url_launcher**: External links

## API Integration

The app integrates with The Movie Database (TMDB) API to fetch:
- Popular movies and TV shows
- Trending content
- Genre-based recommendations
- Search functionality

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Acknowledgments

- [The Movie Database](https://www.themoviedb.org/) for providing the movie data API
- Flutter team for the amazing framework
- Material Design team for the design system
