import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:movora/config/image_cache_config.dart';
import 'package:movora/models/media.dart';

/// Intense caching service for aggressive image preloading and background caching
class IntenseCacheService {
  static final IntenseCacheService _instance = IntenseCacheService._internal();
  factory IntenseCacheService() => _instance;
  IntenseCacheService._internal();

  // Aggressive caching settings
  static const int _maxConcurrentPreloads =
      20; // Load many images simultaneously
  static const int _preloadLookahead = 50; // Preload 50 images ahead
  static const Duration _backgroundCacheInterval = Duration(seconds: 30);
  static const Duration _aggressivePreloadDelay = Duration(milliseconds: 100);

  // Cache management
  final Set<String> _aggressivelyCached = <String>{};
  final Map<String, DateTime> _cacheTimestamps = <String, DateTime>{};
  final Queue<String> _preloadQueue = Queue<String>();
  Timer? _backgroundCacheTimer;
  bool _isBackgroundCaching = false;

  /// Initialize intense caching
  void initialize() {
    _startBackgroundCaching();
    _scheduleCacheOptimization();
  }

  /// Aggressively preload images for a media list
  Future<void> aggressivePreload(
      List<Media> mediaList, BuildContext context) async {
    if (!mounted(context)) return;

    // Extract all image URLs
    final allUrls = <String>[];
    for (final media in mediaList) {
      if (media.posterUrl != null) allUrls.add(media.posterUrl!);
      if (media.backdropUrl != null) allUrls.add(media.backdropUrl!);
    }

    // Filter out already cached URLs
    final urlsToCache =
        allUrls.where((url) => !_aggressivelyCached.contains(url)).toList();

    if (urlsToCache.isEmpty) return;

    // Add to preload queue
    _preloadQueue.addAll(urlsToCache);

    // Start aggressive preloading
    _processPreloadQueue(context);
  }

  /// Process the preload queue with aggressive concurrency
  Future<void> _processPreloadQueue(BuildContext context) async {
    if (_preloadQueue.isEmpty || !mounted(context)) return;

    final batchSize = _maxConcurrentPreloads;
    final batch = <String>[];

    // Take a batch of URLs
    for (int i = 0; i < batchSize && _preloadQueue.isNotEmpty; i++) {
      batch.add(_preloadQueue.removeFirst());
    }

    if (batch.isEmpty) return;

    // Preload batch aggressively
    await _preloadBatchAggressively(batch, context);

    // Continue with next batch after a short delay
    Timer(_aggressivePreloadDelay, () => _processPreloadQueue(context));
  }

  /// Preload a batch of images aggressively
  Future<void> _preloadBatchAggressively(
      List<String> urls, BuildContext context) async {
    if (!mounted(context)) return;

    final futures = <Future<void>>[];

    for (final url in urls) {
      futures.add(_preloadSingleImage(url, context));
    }

    // Wait for all preloads to complete
    await Future.wait(futures);
  }

  /// Preload a single image with aggressive caching
  Future<void> _preloadSingleImage(String url, BuildContext context) async {
    if (!mounted(context)) return;

    try {
      // Use the existing preload mechanism
      await ImageCacheConfig.preloadImages([url], context);

      // Mark as aggressively cached
      _aggressivelyCached.add(url);
      _cacheTimestamps[url] = DateTime.now();

      debugPrint('IntenseCache: Aggressively cached $url');
    } catch (e) {
      debugPrint('IntenseCache: Failed to cache $url: $e');
    }
  }

  /// Predictive preloading based on user behavior
  Future<void> predictivePreload(BuildContext context, Media currentMedia,
      List<Media> relatedMedia) async {
    if (!mounted(context)) return;

    // Preload current media's backdrop and poster
    final currentUrls = <String>[];
    if (currentMedia.posterUrl != null)
      currentUrls.add(currentMedia.posterUrl!);
    if (currentMedia.backdropUrl != null)
      currentUrls.add(currentMedia.backdropUrl!);

    // Preload related media (similar content)
    final relatedUrls = <String>[];
    for (final media in relatedMedia.take(_preloadLookahead)) {
      if (media.posterUrl != null) relatedUrls.add(media.posterUrl!);
    }

    // Combine and preload aggressively
    final allUrls = [...currentUrls, ...relatedUrls];
    await aggressivePreload(
        allUrls.map((url) => Media(posterPath: url)).toList(), context);
  }

  /// Background caching for optimal performance
  void _startBackgroundCaching() {
    _backgroundCacheTimer = Timer.periodic(_backgroundCacheInterval, (timer) {
      if (!_isBackgroundCaching) {
        _performBackgroundCacheOptimization();
      }
    });
  }

  /// Perform background cache optimization
  Future<void> _performBackgroundCacheOptimization() async {
    _isBackgroundCaching = true;

    try {
      // Clean old cache entries
      _cleanOldCacheEntries();

      // Optimize memory usage
      _optimizeMemoryUsage();

      debugPrint('IntenseCache: Background optimization completed');
    } catch (e) {
      debugPrint('IntenseCache: Background optimization failed: $e');
    } finally {
      _isBackgroundCaching = false;
    }
  }

  /// Clean old cache entries
  void _cleanOldCacheEntries() {
    final now = DateTime.now();
    final cutoff =
        now.subtract(const Duration(days: 3)); // Keep 3 days of cache

    final urlsToRemove = <String>[];
    for (final entry in _cacheTimestamps.entries) {
      if (entry.value.isBefore(cutoff)) {
        urlsToRemove.add(entry.key);
      }
    }

    for (final url in urlsToRemove) {
      _aggressivelyCached.remove(url);
      _cacheTimestamps.remove(url);
    }

    if (urlsToRemove.isNotEmpty) {
      debugPrint(
          'IntenseCache: Cleaned ${urlsToRemove.length} old cache entries');
    }
  }

  /// Optimize memory usage
  void _optimizeMemoryUsage() {
    // If we have too many cached items, remove some older ones
    if (_aggressivelyCached.length > 1000) {
      final sortedEntries = _cacheTimestamps.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      final toRemove = sortedEntries.take(200).map((e) => e.key).toList();

      for (final url in toRemove) {
        _aggressivelyCached.remove(url);
        _cacheTimestamps.remove(url);
      }

      debugPrint(
          'IntenseCache: Removed ${toRemove.length} items for memory optimization');
    }
  }

  /// Schedule cache optimization
  void _scheduleCacheOptimization() {
    // Run optimization every 5 minutes
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _performBackgroundCacheOptimization();
    });
  }

  /// Get intense cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'aggressivelyCached': _aggressivelyCached.length,
      'preloadQueueSize': _preloadQueue.length,
      'backgroundCaching': _isBackgroundCaching,
      'cacheTimestamps': _cacheTimestamps.length,
      'lastOptimization': _backgroundCacheTimer?.isActive ?? false,
    };
  }

  /// Clear intense cache
  void clearIntenseCache() {
    _aggressivelyCached.clear();
    _cacheTimestamps.clear();
    _preloadQueue.clear();
    debugPrint('IntenseCache: All intense cache cleared');
  }

  /// Check if URL is aggressively cached
  bool isAggressivelyCached(String url) {
    return _aggressivelyCached.contains(url);
  }

  /// Get cache hit rate
  double getCacheHitRate() {
    final totalRequests = _aggressivelyCached.length + _preloadQueue.length;
    if (totalRequests == 0) return 0.0;
    return _aggressivelyCached.length / totalRequests;
  }

  /// Dispose resources
  void dispose() {
    _backgroundCacheTimer?.cancel();
    _backgroundCacheTimer = null;
    clearIntenseCache();
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
