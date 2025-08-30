import 'package:flutter/material.dart';
import 'package:movora/config/image_cache_config.dart';
import 'package:movora/models/media.dart';

/// Service for preloading images to improve user experience
class ImagePreloadService {
  static final Set<String> _preloadedUrls = <String>{};

  /// Preload poster images for a list of media items
  static Future<void> preloadPosters(
      List<Media> mediaList, BuildContext context) async {
    final urlsToPreload = <String>[];

    for (final media in mediaList) {
      if (media.posterUrl != null &&
          !_preloadedUrls.contains(media.posterUrl)) {
        urlsToPreload.add(media.posterUrl!);
        _preloadedUrls.add(media.posterUrl!);
      }
    }

    if (urlsToPreload.isNotEmpty) {
      await ImageCacheConfig.preloadImages(urlsToPreload, context);
    }
  }

  /// Preload backdrop images for a list of media items
  static Future<void> preloadBackdrops(
      List<Media> mediaList, BuildContext context) async {
    final urlsToPreload = <String>[];

    for (final media in mediaList) {
      if (media.backdropUrl != null &&
          !_preloadedUrls.contains(media.backdropUrl)) {
        urlsToPreload.add(media.backdropUrl!);
        _preloadedUrls.add(media.backdropUrl!);
      }
    }

    if (urlsToPreload.isNotEmpty) {
      await ImageCacheConfig.preloadImages(urlsToPreload, context);
    }
  }

  /// Preload images for a specific media item
  static Future<void> preloadMediaImages(
      Media media, BuildContext context) async {
    final urlsToPreload = <String>[];

    if (media.posterUrl != null && !_preloadedUrls.contains(media.posterUrl)) {
      urlsToPreload.add(media.posterUrl!);
      _preloadedUrls.add(media.posterUrl!);
    }

    if (media.backdropUrl != null &&
        !_preloadedUrls.contains(media.backdropUrl)) {
      urlsToPreload.add(media.backdropUrl!);
      _preloadedUrls.add(media.backdropUrl!);
    }

    if (urlsToPreload.isNotEmpty) {
      await ImageCacheConfig.preloadImages(urlsToPreload, context);
    }
  }

  /// Check if an image has been preloaded
  static bool isPreloaded(String url) {
    return _preloadedUrls.contains(url);
  }

  /// Get the count of preloaded images
  static int getPreloadedCount() {
    return _preloadedUrls.length;
  }

  /// Clear preloaded URLs cache (useful for testing)
  static void clearPreloadedCache() {
    _preloadedUrls.clear();
  }
}
