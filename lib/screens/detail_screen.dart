import 'package:flutter/material.dart';
import 'package:movora/models/media.dart';
import 'package:movora/screens/video_player_screen.dart';
import 'package:movora/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:movora/services/user_analytics_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DetailScreen extends StatefulWidget {
  final Media media;

  const DetailScreen({
    super.key,
    required this.media,
  });

  @override
  State<DetailScreen> createState() => _DetailScreen();
}

class _DetailScreen extends State<DetailScreen> {
  int? _selectedSeason;
  int? _selectedEpisode;

  @override
  void initState() {
    super.initState();
    if (widget.media.mediaType == 'tv') {
      _selectedSeason = 1;
      _selectedEpisode = 1;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Track content view
      await UserAnalyticsService.trackContentInteraction(
        contentType: widget.media.mediaType ?? 'unknown',
        contentId: widget.media.id?.toString() ?? 'unknown',
        action: 'view',
        contentTitle: widget.media.displayTitle,
        contentGenre: widget.media.primaryGenre,
      );

      // Track screen view
      await UserAnalyticsService.trackScreenView(
        screenName: 'detail_${widget.media.mediaType}',
        screenClass: 'DetailScreen',
      );
    });
  }

  void _watchMedia() async {
    // Track media play action
    await UserAnalyticsService.trackContentInteraction(
      contentType: widget.media.mediaType ?? 'unknown',
      contentId: widget.media.id?.toString() ?? 'unknown',
      action: 'play',
      contentTitle: widget.media.displayTitle,
      contentGenre: widget.media.primaryGenre,
    );

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            media: widget.media,
            season: _selectedSeason,
            episode: _selectedEpisode,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with backdrop image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Backdrop image
                  CachedNetworkImage(
                    imageUrl: widget.media.backdropPath != null
                        ? 'https://image.tmdb.org/t/p/w1280${widget.media.backdropPath}'
                        : 'https://via.placeholder.com/1280x720/333/666?text=No+Image',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.surfaceColor,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.surfaceColor,
                      child:
                          const Icon(Icons.error, size: 50, color: Colors.red),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.backgroundColor.withOpacity(0.8),
                          AppTheme.backgroundColor,
                        ],
                      ),
                    ),
                  ),
                  // Content overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.media.displayTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (widget.media.releaseDate != null)
                              Text(
                                _parseYear(widget.media.releaseDate!),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            if (widget.media.releaseDate != null &&
                                widget.media.voteAverage != null)
                              const Text(' • ',
                                  style: TextStyle(color: Colors.white70)),
                            if (widget.media.voteAverage != null)
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.media.voteAverage!
                                        .toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Watch Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _watchMedia,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(
                        widget.media.mediaType == 'tv'
                            ? 'Watch Episode'
                            : 'Watch Movie',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TV Show Season/Episode Selector
                  if (widget.media.mediaType == 'tv')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Episode',
                          style: TextStyle(
                            color: AppTheme.textPrimaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedSeason,
                                decoration: const InputDecoration(
                                  labelText: 'Season',
                                  border: OutlineInputBorder(),
                                ),
                                items: List.generate(10, (index) => index + 1)
                                    .map((season) => DropdownMenuItem(
                                          value: season,
                                          child: Text('Season $season'),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSeason = value;
                                    _selectedEpisode = 1;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedEpisode,
                                decoration: const InputDecoration(
                                  labelText: 'Episode',
                                  border: OutlineInputBorder(),
                                ),
                                items: List.generate(20, (index) => index + 1)
                                    .map((episode) => DropdownMenuItem(
                                          value: episode,
                                          child: Text('Episode $episode'),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEpisode = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Overview
                  if (widget.media.overview != null &&
                      widget.media.overview!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                            color: AppTheme.textPrimaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.media.overview!,
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Additional Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Details',
                        style: TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                          'Type',
                          widget.media.mediaType == 'movie'
                              ? 'Movie'
                              : 'TV Show'),
                      if (widget.media.releaseDate != null)
                        _buildInfoRow('Release Date',
                            _formatDate(widget.media.releaseDate!)),
                      if (widget.media.voteAverage != null)
                        _buildInfoRow('Rating',
                            '${widget.media.voteAverage!.toStringAsFixed(1)}/10'),
                      if (widget.media.voteCount != null)
                        _buildInfoRow('Votes',
                            '${NumberFormat('#,###').format(widget.media.voteCount)}'),
                      if (widget.media.popularity != null)
                        _buildInfoRow('Popularity',
                            '${NumberFormat('#,###').format(widget.media.popularity)}'),
                      _buildInfoRow(
                          'Age Rating', widget.media.formattedAgeRating),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _parseYear(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return date.year.toString();
    } catch (e) {
      return dateString.split('-')[0]; // Fallback to first part of date string
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (e) {
      return dateString; // Fallback to original string
    }
  }
}
