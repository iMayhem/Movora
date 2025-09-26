import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movora/models/media.dart';
import 'package:movora/theme/app_theme.dart';
import 'package:movora/widgets/native_video_player.dart';
import 'package:movora/services/tv_show_service.dart' as tv_service;
import 'package:movora/services/tmdb_service.dart';
import 'package:movora/widgets/movie_card.dart';
import 'package:movora/services/mixpanel_service.dart';
import 'package:movora/services/storage_service.dart';
import 'package:movora/models/media.dart';
import 'package:flutter/foundation.dart';

class DetailScreen extends StatefulWidget {
  final Media media;

  const DetailScreen({super.key, required this.media});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  tv_service.TvShowDetails? _tvShowDetails;
  List<Season> _seasons = [];
  List<tv_service.Episode> _episodes = [];
  bool _isLoadingTvData = false;
  int _selectedSeason = 1;
  int _selectedEpisode = 1;
  late TabController _tabController;
  List<Media> _similarContent = [];
  bool _isLoadingSimilar = false;
  Media? _mediaWithCertification;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Track detail screen view
    MixpanelService.trackScreenView('Detail Screen', properties: {
      'Media Type': widget.media.mediaType ?? 'unknown',
      'Media Title': widget.media.displayTitle,
      'Media ID': widget.media.id,
    });

    if (widget.media.mediaType == 'tv') {
      _loadTvShowData();
    } else if (widget.media.mediaType == 'movie') {
      _loadMovieDetails();
      _loadSimilarContent();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTvShowData() async {
    if (widget.media.id == null) return;

    setState(() {
      _isLoadingTvData = true;
    });

    try {
      final details =
          await tv_service.TvShowService.getTvShowDetails(widget.media.id!);
      setState(() {
        _tvShowDetails = details;
        _seasons = details?.seasons ?? [];
        if (_seasons.isNotEmpty) {
          _selectedSeason = _seasons.first.seasonNumber ?? 1;
          _loadEpisodes(_selectedSeason);
        }
      });
    } catch (e) {
      if (kDebugMode) print('Error loading TV show data: $e');
    } finally {
      setState(() {
        _isLoadingTvData = false;
      });
    }
  }

  Future<void> _loadMovieDetails() async {
    if (widget.media.id == null) return;

    try {
      final details = await TMDBService.getMovieDetails(widget.media.id!);
      if (details != null) {
        setState(() {
          _mediaWithCertification = details;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error loading movie details: $e');
    }
  }

  Future<void> _loadEpisodes(int seasonNumber) async {
    if (widget.media.id == null) return;

    try {
      final episodes = await tv_service.TvShowService.getEpisodes(
          widget.media.id!, seasonNumber);
      setState(() {
        _episodes = episodes;
        if (episodes.isNotEmpty) {
          _selectedEpisode = episodes.first.episodeNumber ?? 1;
        }
      });
    } catch (e) {
      if (kDebugMode) print('Error loading episodes: $e');
    }
  }

  Future<void> _loadSimilarContent() async {
    if (widget.media.id == null || widget.media.mediaType != 'movie') return;

    setState(() {
      _isLoadingSimilar = true;
    });

    try {
      _similarContent = await TMDBService.getSimilarMovies(widget.media.id!);
    } catch (e) {
      if (kDebugMode) print('Error loading similar content: $e');
    } finally {
      setState(() {
        _isLoadingSimilar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image section
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                children: [
                  // Backdrop image
                  if (widget.media.backdropUrl != null)
                    CachedNetworkImage(
                      imageUrl: _getHighQualityBackdropUrl(),
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium, // Reduced from high
                      memCacheWidth: 800, // Optimized cache size
                      memCacheHeight: 450,
                      maxWidthDiskCache: 800,
                      maxHeightDiskCache: 450,
                      httpHeaders: const {
                        'Cache-Control': 'max-age=86400',
                      },
                      placeholder: (context, url) => Container(
                        color: AppTheme.backgroundColor,
                      ),
                      errorWidget: (context, url, error) {
                        return Container(
                          color: AppTheme.backgroundColor,
                          child: const Icon(
                            Icons.movie,
                            color: Colors.white,
                            size: 100,
                          ),
                        );
                      },
                    ),
                  // Play button
                  Center(
                    child: GestureDetector(
                      onTap: () => _playContent(),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.black,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and basic info
                  Text(
                    widget.media.displayTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '95% Match',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getReleaseYear(),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.media.mediaType == 'tv' ? '1 Season' : 'HD',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _playContent(),
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.black),
                          label: const Text(
                            'Play',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'My List',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white70),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Synopsis
                  Text(
                    widget.media.overview ?? 'No description available.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Interaction buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInteractionButton(
                          Icons.add, 'My List', () => _addToMyList()),
                      _buildInteractionButton(
                          Icons.thumb_up, 'Like', () => _likeContent()),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            // Episodes section (only for TV shows)
            if (widget.media.mediaType == 'tv') _buildEpisodesSection(),
            // Tabs section (only for movies)
            if (widget.media.mediaType == 'movie') _buildTabsSection(),
          ],
        ),
      ),
    );
  }

  String _getReleaseYear() {
    if (widget.media.releaseDate == null) return 'N/A';
    try {
      final date = DateTime.parse(widget.media.releaseDate!);
      return date.year.toString();
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildInteractionButton(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesSection() {
    if (_isLoadingTvData) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_seasons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Season selector
          GestureDetector(
            onTap: () => _showSeasonSelector(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Season $_selectedSeason (${_episodes.length} EP)',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Episodes list
          ..._episodes.map((episode) => _buildEpisodeItem(episode)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildEpisodeItem(tv_service.Episode episode) {
    return GestureDetector(
      onTap: () => _playEpisode(episode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            // Episode thumbnail
            Container(
              width: 120,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[800],
              ),
              child: Stack(
                children: [
                  if (episode.stillPath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://image.tmdb.org/t/p/w780${episode.stillPath}', // Higher quality
                        width: 120,
                        height: 68,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        memCacheWidth: 240, // 2x resolution cache
                        memCacheHeight: 136,
                        maxWidthDiskCache: 240,
                        maxHeightDiskCache: 136,
                        httpHeaders: const {
                          'Cache-Control': 'max-age=86400',
                        },
                        placeholder: (context, url) => Container(
                          color: Colors.grey[800],
                        ),
                        errorWidget: (context, url, error) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.play_circle_outline,
                                color: Colors.white),
                          );
                        },
                      ),
                    ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Episode details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.name ?? 'Unknown Episode',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'E${episode.episodeNumber} • S$_selectedSeason • 45m',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  if (episode.overview != null &&
                      episode.overview!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      episode.overview!,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'More Like This'),
              Tab(text: 'More Details'),
            ],
          ),
          // Tab content
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMoreLikeThisTab(),
                _buildMoreDetailsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreLikeThisTab() {
    if (_isLoadingSimilar) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_similarContent.isEmpty) {
      return const Center(
        child: Text(
          'No similar content found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _similarContent.length,
      itemBuilder: (context, index) {
        return MovieCard(
          media: _similarContent[index],
          width: double.infinity,
          height: double.infinity,
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DetailScreen(media: _similarContent[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMoreDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Release Date', _getReleaseDate()),
          _buildDetailRow('Rating',
              '${widget.media.voteAverage?.toStringAsFixed(1) ?? 'N/A'}/10'),
          _buildAgeRatingRow(),
          _buildDetailRow('Vote Count', '${widget.media.voteCount ?? 0}'),
          _buildDetailRow('Language', _getLanguage()),
          _buildDetailRow(
              'Type', widget.media.mediaType?.toUpperCase() ?? 'UNKNOWN'),
          if (widget.media.mediaType == 'tv' && _tvShowDetails != null) ...[
            _buildDetailRow('Status', _tvShowDetails!.status ?? 'Unknown'),
            _buildDetailRow('Number of Seasons', '${_seasons.length}'),
            _buildDetailRow('Total Episodes', '${_episodes.length}'),
          ],
          const SizedBox(height: 20),
          const Text(
            'Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.media.overview ?? 'No description available.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRatingRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              'Age Rating',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (_mediaWithCertification ?? widget.media)
                        .ageRatingColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (_mediaWithCertification ?? widget.media)
                        .formattedAgeRating,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (_mediaWithCertification ?? widget.media)
                        .ageRatingDescription,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getReleaseDate() {
    if (widget.media.releaseDate == null) return 'N/A';
    try {
      final date = DateTime.parse(widget.media.releaseDate!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return widget.media.releaseDate ?? 'N/A';
    }
  }

  String _getLanguage() {
    // Since originalLanguage is not available in Media model, return default
    return 'English';
  }

  String _getHighQualityBackdropUrl() {
    final originalUrl = widget.media.backdropUrl ?? '';

    if (originalUrl.isEmpty) return '';

    // Replace with higher resolution backdrop
    // TMDB backdrop sizes: w300, w780, w1280, original
    if (originalUrl.contains('/w300/')) {
      return originalUrl.replaceAll('/w300/', '/w1280/'); // Much better quality
    } else if (originalUrl.contains('/w780/')) {
      return originalUrl.replaceAll('/w780/', '/w1280/'); // Better quality
    }

    return originalUrl;
  }

  void _addToMyList() async {
    // Track the action
    MixpanelService.trackEngagement('Add to My List', properties: {
      'Media Type': widget.media.mediaType ?? 'unknown',
      'Media Title': widget.media.displayTitle,
      'Media ID': widget.media.id,
    });

    // Save to storage
    final success = await StorageService.addToMyList(widget.media);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${widget.media.displayTitle}" to My List'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already in My List'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _likeContent() async {
    // Track the action
    MixpanelService.trackEngagement('Like Content', properties: {
      'Media Type': widget.media.mediaType ?? 'unknown',
      'Media Title': widget.media.displayTitle,
      'Media ID': widget.media.id,
    });

    // Save to storage
    final success = await StorageService.addToLikedVideos(widget.media);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Liked "${widget.media.displayTitle}"'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already liked'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _playContent() {
    // Track video play
    MixpanelService.trackVideoPlay(
      mediaType: widget.media.mediaType ?? 'unknown',
      mediaTitle: widget.media.displayTitle,
      mediaId: widget.media.id,
      season:
          widget.media.mediaType == 'tv' ? _selectedSeason.toString() : null,
      episode:
          widget.media.mediaType == 'tv' ? _selectedEpisode.toString() : null,
    );

    // Launch native video player
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NativeVideoPlayer(
          media: widget.media,
          season: widget.media.mediaType == 'tv' ? _selectedSeason : null,
          episode: widget.media.mediaType == 'tv' ? _selectedEpisode : null,
        ),
      ),
    );
  }

  void _playEpisode(tv_service.Episode episode) {
    // Track episode play
    MixpanelService.trackVideoPlay(
      mediaType: 'tv',
      mediaTitle: widget.media.displayTitle,
      mediaId: widget.media.id,
      season: _selectedSeason.toString(),
      episode: (episode.episodeNumber ?? 1).toString(),
    );

    // Launch native video player
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NativeVideoPlayer(
          media: widget.media,
          season: _selectedSeason,
          episode: episode.episodeNumber ?? 1,
        ),
      ),
    );
  }

  void _showSeasonSelector() {
    if (_seasons.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      'Select Season',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey),
              // Seasons list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _seasons.length,
                  itemBuilder: (context, index) {
                    final season = _seasons[index];
                    final isSelected = _selectedSeason == season.seasonNumber;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.red.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: Colors.red, width: 1)
                            : null,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(
                          'Season ${season.seasonNumber}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        subtitle: Text(
                          '${season.episodeCount ?? 0} episodes',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Colors.red, size: 24)
                            : const Icon(Icons.radio_button_unchecked,
                                color: Colors.grey, size: 24),
                        onTap: () {
                          setState(() {
                            _selectedSeason = season.seasonNumber ?? 1;
                          });
                          _loadEpisodes(_selectedSeason);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
