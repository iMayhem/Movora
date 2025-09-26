import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service for caching API data locally to improve app performance
class CacheService {
  static const String _cachePrefix = 'movora_cache_';
  static const String _timestampPrefix = 'movora_timestamp_';

  // Cache expiry times (in hours)
  static const int _popularCacheHours = 6; // Popular movies change frequently
  static const int _mostPopularCacheHours =
      12; // Most popular movies change less frequently
  static const int _topRatedCacheHours = 24; // Top rated movies change rarely
  static const int _upcomingCacheHours = 24; // Upcoming movies change daily
  static const int _nowPlayingCacheHours = 6; // Now playing changes frequently
  static const int _searchCacheHours = 1; // Search results should be fresh
  static const int _detailCacheHours = 48; // Movie/show details change rarely
  static const int _castCacheHours = 72; // Cast info changes very rarely

  /// Cache data with timestamp
  static Future<void> cacheData(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await prefs.setString('$_cachePrefix$key', jsonString);
      await prefs.setInt('$_timestampPrefix$key', timestamp);

      if (kDebugMode) {
        print('💾 Cached data for key: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error caching data for key $key: $e');
      }
    }
  }

  /// Get cached data if it's still valid
  static Future<Map<String, dynamic>?> getCachedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('$_cachePrefix$key');
      final timestamp = prefs.getInt('$_timestampPrefix$key');

      if (jsonString == null || timestamp == null) {
        return null;
      }

      // Check if cache is expired
      if (_isCacheExpired(key, timestamp)) {
        if (kDebugMode) {
          print('⏰ Cache expired for key: $key');
        }
        await _clearCache(key);
        return null;
      }

      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      if (kDebugMode) {
        print('📱 Retrieved cached data for key: $key');
      }
      return data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error retrieving cached data for key $key: $e');
      }
      return null;
    }
  }

  /// Check if cache is expired based on key type
  static bool _isCacheExpired(String key, int timestamp) {
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(cacheTime);

    int expiryHours;

    if (key.contains('popular')) {
      expiryHours = _popularCacheHours;
    } else if (key.contains('most_popular')) {
      expiryHours = _mostPopularCacheHours;
    } else if (key.contains('top_rated')) {
      expiryHours = _topRatedCacheHours;
    } else if (key.contains('upcoming')) {
      expiryHours = _upcomingCacheHours;
    } else if (key.contains('now_playing')) {
      expiryHours = _nowPlayingCacheHours;
    } else if (key.contains('search')) {
      expiryHours = _searchCacheHours;
    } else if (key.contains('detail')) {
      expiryHours = _detailCacheHours;
    } else if (key.contains('cast')) {
      expiryHours = _castCacheHours;
    } else {
      expiryHours = 24; // Default 24 hours
    }

    return difference.inHours >= expiryHours;
  }

  /// Clear specific cache entry
  static Future<void> _clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$key');
      await prefs.remove('$_timestampPrefix$key');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing cache for key $key: $e');
      }
    }
  }

  /// Clear all cached data
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || key.startsWith(_timestampPrefix)) {
          await prefs.remove(key);
        }
      }

      if (kDebugMode) {
        print('🗑️ Cleared all cached data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing all cache: $e');
      }
    }
  }

  /// Get cache size info
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      int cacheEntries = 0;
      int totalSize = 0;
      final Map<String, DateTime> cacheDetails = {};

      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          cacheEntries++;
          final data = prefs.getString(key);
          if (data != null) {
            totalSize += data.length;
          }

          final cacheKey = key.replaceFirst(_cachePrefix, '');
          final timestamp = prefs.getInt('$_timestampPrefix$cacheKey');
          if (timestamp != null) {
            cacheDetails[cacheKey] =
                DateTime.fromMillisecondsSinceEpoch(timestamp);
          }
        }
      }

      return {
        'entries': cacheEntries,
        'sizeBytes': totalSize,
        'sizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'details': cacheDetails,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting cache info: $e');
      }
      return {'entries': 0, 'sizeBytes': 0, 'sizeMB': '0.00', 'details': {}};
    }
  }

  /// Generate cache key for different data types
  static String generateKey(String type, {Map<String, dynamic>? params}) {
    String key = type;

    if (params != null) {
      final sortedParams = Map.fromEntries(
          params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
      key += '_${sortedParams.toString()}';
    }

    return key;
  }
}
