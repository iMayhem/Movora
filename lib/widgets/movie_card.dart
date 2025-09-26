import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movora/models/media.dart';
import 'package:movora/theme/app_theme.dart';

class MovieCard extends StatelessWidget {
  final Media media;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const MovieCard({
    super.key,
    required this.media,
    this.width = 100,
    this.height = 150,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppTheme.surfaceColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildSimplePoster(),
        ),
      ),
    );
  }

  Widget _buildSimplePoster() {
    final imageUrl = _getHighQualityPosterUrl();

    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: AppTheme.surfaceColor,
        child: const Icon(
          Icons.movie,
          color: AppTheme.textTertiaryColor,
          size: 20,
        ),
      );
    }

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          filterQuality:
              FilterQuality.high, // Changed back to high for better quality
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          memCacheWidth: width.isFinite
              ? (width * 2).round()
              : 400, // Increased cache size for better quality
          memCacheHeight: height.isFinite ? (height * 2).round() : 600,
          maxWidthDiskCache: width.isFinite
              ? (width * 3).round()
              : 600, // Increased disk cache
          maxHeightDiskCache: height.isFinite ? (height * 3).round() : 900,
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            color: AppTheme.surfaceColor,
          ),
          errorWidget: (context, url, error) => Container(
            width: width,
            height: height,
            color: AppTheme.surfaceColor,
            child: const Icon(
              Icons.error_outline,
              color: AppTheme.textTertiaryColor,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  String _getHighQualityPosterUrl() {
    final originalUrl = media.posterUrl ?? '';

    if (originalUrl.isEmpty) return '';

    // Use higher quality poster sizes for better visual experience
    // TMDB poster sizes: w92, w154, w185, w342, w500, w780, original
    if (originalUrl.contains('/w185/')) {
      return originalUrl.replaceAll(
          '/w185/', '/w500/'); // Upgrade to higher quality
    } else if (originalUrl.contains('/w342/')) {
      return originalUrl.replaceAll(
          '/w342/', '/w500/'); // Upgrade to higher quality
    } else if (originalUrl.contains('/w780/')) {
      return originalUrl.replaceAll(
          '/w780/', '/w500/'); // Use w500 for consistency
    }

    return originalUrl;
  }
}
