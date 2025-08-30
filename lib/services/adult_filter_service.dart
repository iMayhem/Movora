import 'package:shared_preferences/shared_preferences.dart';

class AdultFilterService {
  // Toggle verbose logging for debugging
  static bool enableLogging = false;
  static const String _filterKey = 'adult_filter_enabled';

  // Default to true (family-friendly mode)
  static bool _isFilterEnabled = true;
  static bool _isInitialized = false;

  // Initialize the service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _isFilterEnabled = prefs.getBool(_filterKey) ?? true;
    _isInitialized = true;
  }

  // Get current filter status
  static bool get isFilterEnabled {
    if (!_isInitialized) {
      // If not initialized, default to family-friendly mode
      return true;
    }
    return _isFilterEnabled;
  }

  // Set filter status
  static Future<void> setFilterEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_filterKey, enabled);
    _isFilterEnabled = enabled;
  }

  // Check if content should be filtered
  static bool shouldFilterContent({
    required String? title,
    required String? overview,
    required List<String>? genres,
    required String? originalLanguage,
    required double? voteAverage,
    required int? voteCount,
    required String? releaseDate,
    required bool? adult,
    required String? ageRating,
  }) {
    if (enableLogging) {
      print('AdultFilterService: ===== STARTING CONTENT FILTER CHECK =====');
      print('AdultFilterService: Filter enabled: $_isFilterEnabled');
    }

    if (!_isFilterEnabled) {
      if (enableLogging) {
        print(
            'AdultFilterService: Filter is DISABLED - returning false (no filtering)');
      }
      return false; // Don't filter if adult mode is enabled
    }

    if (enableLogging) {
      print(
          'AdultFilterService: Checking content - Title: "$title", AgeRating: "$ageRating", Adult: $adult');
      print(
          'AdultFilterService: Genres: $genres, VoteAverage: $voteAverage, VoteCount: $voteCount');
    }

    // Filter based on age rating first (most reliable)
    if (ageRating != null && ageRating.isNotEmpty) {
      final lowerAgeRating = ageRating.toLowerCase();
      if (enableLogging) {
        print(
            'AdultFilterService: Checking age rating: "$ageRating" (lowercase: "$lowerAgeRating")');
      }
      if (_isAdultAgeRating(lowerAgeRating)) {
        if (enableLogging) {
          print(
              'AdultFilterService: Content filtered due to age rating: "$ageRating"');
        }
        return true;
      }
    } else {
      if (enableLogging) {
        print('AdultFilterService: No age rating available or empty');
      }
    }

    // Filter based on TMDB's adult flag
    if (adult == true) {
      if (enableLogging) {
        print('AdultFilterService: Content filtered due to adult flag: true');
      }
      return true;
    } else {
      if (enableLogging) {
        print('AdultFilterService: Adult flag is: $adult');
      }
    }

    // Filter based on content analysis
    if (title != null && title.isNotEmpty) {
      final lowerTitle = title.toLowerCase();
      if (_containsAdultKeywords(lowerTitle)) {
        if (enableLogging) {
          print(
              'AdultFilterService: Content filtered due to title keywords: "$title"');
        }
        return true;
      } else {
        if (enableLogging) {
          print('AdultFilterService: Title passed keyword check: "$title"');
        }
      }
    } else {
      if (enableLogging) {
        print('AdultFilterService: No title available or empty');
      }
    }

    if (overview != null && overview.isNotEmpty) {
      final lowerOverview = overview.toLowerCase();
      if (_containsAdultKeywords(lowerOverview)) {
        if (enableLogging) {
          print(
              'AdultFilterService: Content filtered due to overview keywords');
        }
        return true;
      } else {
        if (enableLogging) {
          print('AdultFilterService: Overview passed keyword check');
        }
      }
    } else {
      if (enableLogging) {
        print('AdultFilterService: No overview available or empty');
      }
    }

    // Filter based on genres that typically contain adult content
    if (genres != null && genres.isNotEmpty) {
      for (final genre in genres) {
        final lowerGenre = genre.toLowerCase();
        if (_isAdultGenre(lowerGenre)) {
          if (enableLogging) {
            print(
                'AdultFilterService: Content filtered due to genre: "$genre"');
          }
          return true;
        }
      }
      if (enableLogging) {
        print('AdultFilterService: All genres passed check: $genres');
      }
    } else {
      if (enableLogging) {
        print('AdultFilterService: No genres available or empty');
      }
    }

    // Filter based on original language if available
    if (originalLanguage != null && originalLanguage != 'en') {
      // Be more cautious with non-English content
      if (voteAverage != null && voteAverage < 6.0) {
        if (enableLogging) {
          print(
              'AdultFilterService: Content filtered due to low rating non-English content');
        }
        return true;
      } else {
        if (enableLogging) {
          print(
              'AdultFilterService: Non-English content passed rating check: $voteAverage');
        }
      }
    } else {
      if (enableLogging) {
        print('AdultFilterService: Original language: $originalLanguage');
      }
    }

    if (enableLogging) {
      print('AdultFilterService: ===== CONTENT PASSED ALL FILTERS =====');
    }
    return false;
  }

  // Check if title/overview contains adult keywords
  static bool _containsAdultKeywords(String text) {
    final adultKeywords = [
      'adult',
      'explicit',
      'mature',
      'nsfw',
      '18+',
      'r-rated',
      'nc-17',
      'x-rated',
      'porn',
      'erotic',
      'sexual',
      'nude',
      'nudity',
      'violence',
      'gore',
      'blood',
      'horror',
      'thriller',
      'crime',
      'murder',
      'death',
      'suicide',
      'drugs',
      'alcohol',
      'smoking',
      'profanity',
      'swearing',
      'cursing',
    ];

    for (final keyword in adultKeywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }

    return false;
  }

  // Check if genre is typically adult-oriented
  static bool _isAdultGenre(String genre) {
    final adultGenres = [
      'horror',
      'thriller',
      'crime',
      'war',
      'documentary',
      'mystery',
      'noir',
      'experimental',
      'art house',
      'indie',
      'foreign',
      'cult',
    ];

    return adultGenres.contains(genre);
  }

  // Check if age rating indicates adult content
  static bool _isAdultAgeRating(String ageRating) {
    final adultAgeRatings = [
      '18+',
      '19+',
      'r',
      'nc-17',
      'x',
      'adult',
      'mature',
      'explicit',
      '18',
      '19',
      'r-rated',
      'nc17',
      'x-rated',
      'adults only',
      'mature audiences',
      'explicit content',
      'restricted',
      'no one 17 and under admitted',
      'no one under 18 admitted',
      'no one under 19 admitted',
    ];

    if (enableLogging) {
      print(
          'AdultFilterService: Checking age rating: "$ageRating" against adult patterns');
    }

    for (final rating in adultAgeRatings) {
      if (ageRating.contains(rating)) {
        if (enableLogging) {
          print(
              'AdultFilterService: Age rating "$ageRating" matches adult pattern "$rating"');
        }
        return true;
      }
    }

    if (enableLogging) {
      print(
          'AdultFilterService: Age rating "$ageRating" does not match any adult patterns');
    }
    return false;
  }

  // Get filter status description
  static String get filterStatusDescription {
    return _isFilterEnabled
        ? 'Family Mode - Adult content filtered'
        : 'Adult Mode - All content visible';
  }

  // Get filter icon
  static String get filterIcon {
    return _isFilterEnabled ? '🔒' : '⚠️';
  }
}
