import 'package:flutter/material.dart';
import 'package:movora/models/media.dart';
import 'package:movora/services/storage_service.dart';
import 'package:movora/widgets/movie_card.dart';
import 'package:movora/screens/detail_screen.dart';
import 'package:movora/theme/app_theme.dart';
import 'package:movora/services/mixpanel_service.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  List<Media> _myList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    MixpanelService.trackScreenView('My List Screen');
    _loadMyList();
  }

  Future<void> _loadMyList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final myList = await StorageService.getMyList();
      setState(() {
        _myList = myList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading my list: $e');
    }
  }

  Future<void> _removeFromMyList(int mediaId) async {
    try {
      final success = await StorageService.removeFromMyList(mediaId);
      if (success) {
        setState(() {
          _myList.removeWhere((video) => video.id == mediaId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from My List'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error removing from my list: $e');
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
          'My List',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          if (_myList.isNotEmpty)
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
          : _myList.isEmpty
              ? _buildEmptyState()
              : _buildMyListContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_add,
            color: Colors.grey[600],
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            'Your List is Empty',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add movies and shows to your list',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyListContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_myList.length} Items in Your List',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              cacheExtent: 200, // Add cache extent
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.67,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _myList.length,
              itemBuilder: (context, index) {
                final media = _myList[index];
                return RepaintBoundary(
                  // Add repaint boundary
                  child: GestureDetector(
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
                                builder: (context) =>
                                    DetailScreen(media: media),
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
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
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
        title: const Text('Remove from My List?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove "${media.displayTitle}" from your list?',
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
              _removeFromMyList(media.id!);
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
        title:
            const Text('Clear My List?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will remove all items from your list. This action cannot be undone.',
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
              for (final media in _myList) {
                await StorageService.removeFromMyList(media.id!);
              }
              setState(() {
                _myList.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('My list cleared'),
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
