class AppConfig {
  // App Information
  static const String appName = 'Movora';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Your ultimate destination for movies and TV shows';

  // API Configuration
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/';
  static const String tmdbApiKey =
      'dfa4c2c7c1de1005adee824dc5593672'; // TMDB API key

  // Image Sizes
  static const String posterSize = 'w500';
  static const String backdropSize = 'original';
  static const String profileSize = 'w185';

  // Default Parameters
  static const Map<String, String> defaultApiParams = {
    'language': 'en-US',
    'include_adult': 'false',
  };

  // Hollywood Filter Parameters
  static const Map<String, String> hollywoodParams = {
    'with_original_language': 'en',
    'region': 'US',
  };

  // Vote Count Thresholds
  static const Map<String, String> hollywoodVoteCount = {
    'vote_count.gte': '300',
  };

  static const Map<String, String> hollywoodTvVoteCount = {
    'vote_count.gte': '200',
  };

  // Genre IDs
  static const Map<String, String> genreIds = {
    'action': '28,12',
    'comedy': '35',
    'scifi': '878,14',
    'horror': '27',
    'thriller': '53',
    'drama': '18',
    'romance': '10749',
    'documentary': '99',
    'animation': '16',
    'family': '10751',
  };

  // UI Constants
  static const double cardWidth = 150.0;
  static const double cardHeight = 225.0;
  static const double cardSpacing = 12.0;
  static const double sectionSpacing = 24.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Cache Settings
  static const Duration imageCacheDuration = Duration(days: 7);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Error Messages
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String apiErrorMessage =
      'Failed to load data. Please try again.';
  static const String generalErrorMessage =
      'Something went wrong. Please try again.';
}
