import 'package:flutter/material.dart';
import 'package:movora/models/media.dart';
import 'package:movora/services/intense_cache_service.dart';

/// Predictive caching service that analyzes user behavior and preloads likely-to-view content
class PredictiveCacheService {
  static final PredictiveCacheService _instance =
      PredictiveCacheService._internal();
  factory PredictiveCacheService() => _instance;
  PredictiveCacheService._internal();

  // User behavior tracking
  final Map<String, int> _viewCounts = <String, int>{};
  final Map<String, DateTime> _lastViewed = <String, DateTime>{};
  final List<String> _viewHistory = <String>[];
  final Map<String, List<String>> _genrePreferences = <String, List<String>>{};

  // Predictive settings
  static const int _maxHistorySize = 100;
  static const int _predictionLookahead = 30;
  static const Duration _preferenceDecayTime = Duration(hours: 24);

  /// Track when user views a media item
  void trackMediaView(Media media) {
    if (media.id == null) return;

    final mediaId = media.id.toString();

    // Update view count
    _viewCounts[mediaId] = (_viewCounts[mediaId] ?? 0) + 1;

    // Update last viewed time
    _lastViewed[mediaId] = DateTime.now();

    // Add to view history
    _viewHistory.add(mediaId);
    if (_viewHistory.length > _maxHistorySize) {
      _viewHistory.removeAt(0);
    }

    // Update genre preferences
    _updateGenrePreferences(media);

    debugPrint('PredictiveCache: Tracked view of ${media.displayTitle}');
  }

  /// Update genre preferences based on viewed content
  void _updateGenrePreferences(Media media) {
    if (media.genres == null) return;

    final now = DateTime.now();

    for (final genre in media.genres!) {
      if (!_genrePreferences.containsKey(genre.name)) {
        _genrePreferences[genre.name] = <String>[];
      }

      // Add media ID to genre preference list
      if (!_genrePreferences[genre.name]!.contains(media.id.toString())) {
        _genrePreferences[genre.name]!.add(media.id.toString()!);
      }
    }

    // Clean old preferences
    _cleanOldPreferences(now);
  }

  /// Clean old genre preferences
  void _cleanOldPreferences(DateTime now) {
    final cutoff = now.subtract(_preferenceDecayTime);

    for (final genre in _genrePreferences.keys.toList()) {
      _genrePreferences[genre]!.removeWhere((mediaId) {
        final lastView = _lastViewed[mediaId];
        return lastView == null || lastView.isBefore(cutoff);
      });

      // Remove empty genres
      if (_genrePreferences[genre]!.isEmpty) {
        _genrePreferences.remove(genre);
      }
    }
  }

  /// Get user's favorite genres
  List<String> getFavoriteGenres() {
    final genreScores = <String, double>{};

    for (final entry in _genrePreferences.entries) {
      final genre = entry.key;
      final mediaIds = entry.value;

      double score = 0;
      for (final mediaId in mediaIds) {
        final viewCount = _viewCounts[mediaId] ?? 0;
        final lastView = _lastViewed[mediaId];

        if (lastView != null) {
          final hoursSinceView = DateTime.now().difference(lastView).inHours;
          final timeDecay = 1.0 / (1.0 + hoursSinceView / 24.0);
          score += viewCount * timeDecay;
        }
      }

      genreScores[genre] = score;
    }

    // Sort by score and return top genres
    final sortedGenres = genreScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedGenres.take(5).map((e) => e.key).toList();
  }

  /// Predict and preload likely-to-view content
  Future<void> predictAndPreload(
      BuildContext context, List<Media> availableMedia) async {
    if (!mounted(context) || availableMedia.isEmpty) return;

    // Get user's favorite genres
    final favoriteGenres = getFavoriteGenres();

    // Score media items based on user preferences
    final scoredMedia = <Media, double>{};

    for (final media in availableMedia) {
      double score = 0;

      // Genre preference score
      if (media.genres != null) {
        for (final genre in media.genres!) {
          if (favoriteGenres.contains(genre.name)) {
            score += 10; // High score for favorite genres
          }
        }
      }

      // Recency score (newer content gets higher score)
      if (media.releaseDate != null) {
        try {
          final releaseDate = DateTime.parse(media.releaseDate!);
          final yearsSinceRelease = DateTime.now().year - releaseDate.year;
          score += (10 - yearsSinceRelease).clamp(0, 10).toDouble();
        } catch (e) {
          // Ignore parsing errors
        }
      }

      // Popularity score
      if (media.popularity != null) {
        score += (media.popularity! / 100).clamp(0, 10);
      }

      // Rating score
      if (media.voteAverage != null) {
        score += (media.voteAverage! / 2).clamp(0, 5);
      }

      scoredMedia[media] = score;
    }

    // Sort by score and take top items for preloading
    final sortedMedia = scoredMedia.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topMedia =
        sortedMedia.take(_predictionLookahead).map((e) => e.key).toList();

    if (topMedia.isNotEmpty) {
      debugPrint(
          'PredictiveCache: Preloading ${topMedia.length} predicted items');

      // Use intense caching for predicted content
      await IntenseCacheService().aggressivePreload(topMedia, context);
    }
  }

  /// Get personalized recommendations based on viewing history
  List<Media> getPersonalizedRecommendations(List<Media> availableMedia) {
    if (availableMedia.isEmpty) return [];

    // Score media based on user preferences
    final scoredMedia = <Media, double>{};

    for (final media in availableMedia) {
      double score = 0;

      // Genre preference score
      if (media.genres != null) {
        for (final genre in media.genres!) {
          if (_genrePreferences.containsKey(genre.name)) {
            score += 5;
          }
        }
      }

      // Avoid recently viewed content
      if (media.id != null && _lastViewed.containsKey(media.id.toString())) {
        score -= 20; // Penalty for recently viewed
      }

      // Bonus for high-rated content
      if (media.voteAverage != null && media.voteAverage! > 7.0) {
        score += 3;
      }

      scoredMedia[media] = score;
    }

    // Sort by score and return top recommendations
    final sortedMedia = scoredMedia.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedMedia.take(20).map((e) => e.key).toList();
  }

  /// Get viewing statistics
  Map<String, dynamic> getViewingStats() {
    return {
      'totalViews': _viewCounts.values.fold(0, (sum, count) => sum + count),
      'uniqueMediaViewed': _viewCounts.length,
      'favoriteGenres': getFavoriteGenres(),
      'viewHistorySize': _viewHistory.length,
      'genrePreferences': _genrePreferences.length,
    };
  }

  /// Clear viewing history and preferences
  void clearUserData() {
    _viewCounts.clear();
    _lastViewed.clear();
    _viewHistory.clear();
    _genrePreferences.clear();
    debugPrint('PredictiveCache: User data cleared');
  }

  /// Check if context is still mounted
  bool mounted(BuildContext context) {
    try {
      return context.mounted;
    } catch (e) {
      return false;
    }
  }
}
