/// Performance configuration for the Movora app
class PerformanceConfig {
  // Image caching and loading
  static const int imageCacheSize = 100; // MB
  static const Duration imageCacheExpiry = Duration(days: 7);
  static const int maxConcurrentImageLoads = 4;

  // List view optimizations
  static const double listViewCacheExtent = 1200.0;
  static const bool enableRepaintBoundaries = true;
  static const bool enableAutomaticKeepAlives = false;

  // API request optimizations
  static const Duration apiRequestTimeout = Duration(seconds: 10);
  static const int maxConcurrentApiRequests = 3;
  static const Duration apiCacheExpiry = Duration(minutes: 15);

  // UI rendering optimizations
  static const bool enableShadows = true;
  static const bool enableAnimations = true;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Memory management
  static const int maxCachedItems = 1000;
  static const Duration memoryCleanupInterval = Duration(minutes: 5);

  // Network optimizations
  static const bool enableCompression = true;
  static const bool enableKeepAlive = true;
  static const Duration keepAliveTimeout = Duration(seconds: 30);
}

