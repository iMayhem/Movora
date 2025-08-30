# Movora - Movie Discovery & Streaming Platform

A comprehensive movie discovery and streaming platform available both as a web service and a Flutter mobile app.

## ✨ Features

### Core Functionality
* 📚 **Browse Movies & TV Shows** – Get details like title, description, genres, cast, release date, and ratings.
* 🖼 **Posters & Images** – High-quality posters, backdrops, and actor photos from TMDB.
* 🔍 **Search Functionality** – Find movies and shows instantly using TMDB's search.
* 🎬 **Trailers** – Watch official trailers via YouTube links.
* 🔗 **External Video Links** – Open movies/episodes through external sources (e.g., Videasy.net) inside the app.

### Platform Availability
* 🌐 **Web Platform** – Access via browser for desktop and mobile users
* 📱 **Mobile App** – Flutter-built APK that runs directly on Android devices

## ⚙️ How It Works

* All **movie/TV data & images** are fetched from **TMDB API**.
* The platform **does not store or host any videos**.
* When you tap **Play**, the app:

  1. Builds a link to an external video site.
  2. Opens that link in a built-in **WebView** (mobile) or new tab (web).
  3. Video is streamed directly from the external site's servers.
* Without internet, the platform **won't work** (no offline mode).

## Mobile App Features

- **Trending Now**: Discover what's currently popular
- **Newly Released**: Latest movies in theaters
- **Most Popular**: Top trending content
- **Top Rated**: Highest-rated movies and TV shows
- **Genre Categories**: Action, Comedy, Sci-Fi, Horror, Thriller
- **Beautiful UI**: Modern Material Design 3 interface
- **Dark Theme**: Eye-friendly dark mode
- **Responsive Design**: Optimized for all screen sizes

## Prerequisites

### For Web Platform
- Modern web browser
- Internet connection

### For Mobile App Development
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

## Setup Instructions

### Web Platform
Simply visit the website in your browser - no installation required!

### Mobile App Development

#### 1. Install Flutter
Follow the official Flutter installation guide: https://flutter.dev/docs/get-started/install

#### 2. Get TMDB API Key
1. Visit [The Movie Database](https://www.themoviedb.org/)
2. Create an account and request an API key
3. Replace `YOUR_TMDB_API_KEY` in `lib/services/tmdb_service.dart` with your actual API key

#### 3. Install Dependencies
```bash
flutter pub get
```

#### 4. Run the App
```bash
flutter run
```

## Project Structure

### Web Platform
```
src/
├── lib/
│   └── tmdb.ts           # TMDB API integration
└── ...                   # Other web-specific files
```

### Mobile App
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

### Web Platform
- Next.js framework
- TMDB API integration

### Mobile App
- **http**: For API calls
- **provider**: State management
- **cached_network_image**: Image caching
- **carousel_slider**: Horizontal scrolling lists
- **shimmer**: Loading placeholders
- **shared_preferences**: Local storage
- **url_launcher**: External links

## API Integration

The platform integrates with The Movie Database (TMDB) API to fetch:
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

---

**Enjoy Streaming! 🎬**
