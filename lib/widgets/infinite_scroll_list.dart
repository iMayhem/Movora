import 'package:flutter/material.dart';
import 'package:movora/models/media.dart';
import 'package:movora/widgets/movie_card.dart';

class InfiniteScrollList extends StatefulWidget {
  final String title;
  final String categoryType;
  final Future<List<Media>> Function(int page) fetchFunction;
  final int initialPage;

  const InfiniteScrollList({
    super.key,
    required this.title,
    required this.categoryType,
    required this.fetchFunction,
    this.initialPage = 1,
  });

  @override
  State<InfiniteScrollList> createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> {
  final ScrollController _scrollController = ScrollController();
  List<Media> _mediaList = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await widget.fetchFunction(_currentPage);
      setState(() {
        _mediaList = data;
        _isLoading = false;
        _hasMore = data.length >= 20;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _currentPage++;
      final newData = await widget.fetchFunction(_currentPage);

      setState(() {
        _mediaList.addAll(newData);
        _isLoading = false;
        _hasMore = newData.length >= 20;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_mediaList.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(4),
      cacheExtent: 200, // Add cache extent for better performance
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _mediaList.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _mediaList.length) {
          return RepaintBoundary(
            // Add repaint boundary for performance
            child: MovieCard(
              media: _mediaList[index],
              width: double.infinity,
              height: double.infinity,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: _mediaList[index],
                );
              },
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
