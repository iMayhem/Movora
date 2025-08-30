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
    this.width = 120,
    this.height = 180,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Performance optimization: Use CachedNetworkImage with better error handling
                CachedNetworkImage(
                  imageUrl: media.posterPath != null
                      ? 'https://image.tmdb.org/t/p/w500${media.posterPath}'
                      : '',
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: width,
                    height: height,
                    color: AppTheme.surfaceColor,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: width,
                    height: height,
                    color: AppTheme.surfaceColor,
                    child: const Icon(
                      Icons.movie,
                      color: AppTheme.textSecondaryColor,
                      size: 32,
                    ),
                  ),
                  // Performance optimization: Better caching
                  memCacheWidth: (width * 2).round(),
                  memCacheHeight: (height * 2).round(),
                ),

                // Performance optimization: Use const for static overlays
                _buildGradientOverlay(),
                _buildRatingBadge(),
                _buildTitleOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Performance optimization: Extract gradient overlay
  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  // Performance optimization: Extract rating badge
  Widget _buildRatingBadge() {
    if (media.voteAverage == null || media.voteAverage == 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          media.voteAverage!.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Performance optimization: Extract title overlay
  Widget _buildTitleOverlay() {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Text(
        media.displayTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
