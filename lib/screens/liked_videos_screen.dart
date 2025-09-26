import 'package:flutter/material.dart';
import 'package:movora/models/media.dart';
import 'package:movora/services/storage_service.dart';
import 'package:movora/widgets/movie_card.dart';
import 'package:movora/screens/detail_screen.dart';
import 'package:movora/theme/app_theme.dart';
import 'package:movora/services/mixpanel_service.dart';

class LikedVideosScreen extends StatefulWidget {
  const LikedVideosScreen({super.key});

  @override
  State<LikedVideosScreen> createState() => _LikedVideosScreenState();
}

class _LikedVideosScreenState extends State<LikedVideosScreen> {
  List<Media> _likedVideos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    MixpanelService.trackScreenView('Liked Videos Screen');
    _loadLikedVideos();
  }

  Future<void> _loadLikedVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final likedVideos = await StorageService.getLikedVideos();
      setState(() {
        _likedVideos = likedVideos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading liked videos: $e');
    }
  }

  Future<void> _removeFromLiked(int mediaId) async {
    try {
      final success = await StorageService.removeFromLikedVideos(mediaId);
      if (success) {
        setState(() {
          _likedVideos.removeWhere((video) => video.id == mediaId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from Liked Videos'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error removing from liked videos: $e');
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Liked Videos',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          if (_likedVideos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () => _showClearAllDialog(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _likedVideos.isEmpty
              ? _buildEmptyState()
              : _buildLikedVideosList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            color: Colors.grey[600],
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            'No Liked Videos Yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Like videos to see them here',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikedVideosList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_likedVideos.length} Liked Videos',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.67,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _likedVideos.length,
              itemBuilder: (context, index) {
                final media = _likedVideos[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(media: media),
                      ),
                    );
                  },
                  onLongPress: () => _showRemoveDialog(media),
                  child: Stack(
                    children: [
                      MovieCard(
                        media: media,
                        width: 100,
                        height: 150,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(media: media),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(Media media) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Remove from Liked Videos?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove "${media.displayTitle}" from your liked videos?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFromLiked(media.id!);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Clear All Liked Videos?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will remove all videos from your liked list. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              for (final media in _likedVideos) {
                await StorageService.removeFromLikedVideos(media.id!);
              }
              setState(() {
                _likedVideos.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All liked videos cleared'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
