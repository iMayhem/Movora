import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Centralized configuration for image caching across the app
class ImageCacheConfig {
  // Cache configuration constants
  static const Duration defaultCacheTimeout = Duration(days: 7);
  static const Duration placeholderFadeInDuration = Duration(milliseconds: 0);
  static const Duration placeholderFadeOutDuration = Duration(milliseconds: 0);

  // Default placeholder widget
  static Widget defaultPlaceholder(BuildContext context, String? url) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[400]!,
          ],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }

  // Default error widget
  static Widget defaultErrorWidget(
      BuildContext context, String? url, dynamic error) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 32,
        ),
      ),
    );
  }

  // Optimized CachedNetworkImage configuration for posters
  static CachedNetworkImage optimizedPoster({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    PlaceholderWidgetBuilder? placeholder,
    LoadingErrorWidgetBuilder? errorWidget,
    Duration? fadeInDuration,
    Duration? fadeOutDuration,
  }) {
    final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    final targetWidth = (width * devicePixelRatio).clamp(64, 256).round();
    final targetHeight = (height * devicePixelRatio).clamp(96, 384).round();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      filterQuality: FilterQuality.none, // Fastest rendering
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      memCacheWidth: targetWidth,
      memCacheHeight: targetHeight,
      maxWidthDiskCache: targetWidth,
      maxHeightDiskCache: targetHeight,
      placeholder: placeholder ?? defaultPlaceholder,
      errorWidget: errorWidget ?? defaultErrorWidget,
      cacheKey: _generateCacheKey(imageUrl, targetWidth, targetHeight),
    );
  }

  // Optimized CachedNetworkImage configuration for backdrops
  static CachedNetworkImage optimizedBackdrop({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    PlaceholderWidgetBuilder? placeholder,
    LoadingErrorWidgetBuilder? errorWidget,
    Duration? fadeInDuration,
    Duration? fadeOutDuration,
  }) {
    final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    final targetWidth = (width * devicePixelRatio).clamp(200, 800).round();
    final targetHeight = (height * devicePixelRatio).clamp(120, 480).round();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      filterQuality: FilterQuality.none, // Fastest rendering
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      memCacheWidth: targetWidth,
      memCacheHeight: targetHeight,
      maxWidthDiskCache: targetWidth,
      maxHeightDiskCache: targetHeight,
      placeholder: placeholder ?? defaultPlaceholder,
      errorWidget: errorWidget ?? defaultErrorWidget,
      cacheKey: _generateCacheKey(imageUrl, targetWidth, targetHeight),
    );
  }

  // Generate unique cache key for different image sizes
  static String _generateCacheKey(String url, int width, int height) {
    return '${url}_${width}x$height';
  }

  // Preload images for better UX
  static Future<void> preloadImages(
      List<String> urls, BuildContext context) async {
    for (final url in urls) {
      try {
        await precacheImage(
          CachedNetworkImageProvider(url),
          context,
        );
      } catch (e) {
        // Silently handle preload errors
        debugPrint('Failed to preload image: $url');
      }
    }
  }

  // Clear image cache (useful for testing or memory management)
  static Future<void> clearCache() async {
    await CachedNetworkImage.evictFromCache('');
  }

  // Get cache statistics (useful for debugging)
  static Future<void> printCacheStats() async {
    // Note: This is a placeholder - actual cache stats would require
    // implementing a custom cache manager or using platform channels
    debugPrint(
        'Image cache stats: Using CachedNetworkImage with optimized settings');
  }
}
