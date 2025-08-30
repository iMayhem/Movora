import 'package:flutter/material.dart';
import 'package:movora/models/media.dart';
import 'package:movora/services/tmdb_service.dart';
import 'package:movora/widgets/movie_card.dart';
import 'package:movora/screens/detail_screen.dart';
import 'package:movora/theme/app_theme.dart';
import 'package:movora/services/user_analytics_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Media> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Track screen view
      await UserAnalyticsService.trackScreenView(
        screenName: 'search',
        screenClass: 'SearchScreen',
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      // Track search query
      await UserAnalyticsService.trackSearchQuery(
        query: query,
        category: 'general',
      );

      // Search both movies and TV shows
      final movieResults = await TMDBService.searchMedia(query, 'movie');
      final tvResults = await TMDBService.searchMedia(query, 'tv');

      // Combine and remove duplicates
      final combined = [...movieResults, ...tvResults];
      final seen = <int>{};
      final uniqueResults = combined.where((item) {
        if (item.id == null) return false;
        final duplicate = seen.contains(item.id!);
        seen.add(item.id!);
        return !duplicate;
      }).toList();

      setState(() {
        _searchResults = uniqueResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Search failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: AppTheme.textPrimaryColor),
          decoration: InputDecoration(
            hintText: 'Search movies and TV shows...',
            hintStyle: const TextStyle(color: AppTheme.textSecondaryColor),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: AppTheme.primaryColor),
              onPressed: () => _performSearch(_searchController.text),
            ),
          ),
          onSubmitted: _performSearch,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
            )
          else if (_hasSearched && _searchResults.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppTheme.textSecondaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No results found',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_searchResults.isNotEmpty)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                // Performance optimizations
                cacheExtent: 500, // Cache more items for smoother scrolling
                addAutomaticKeepAlives:
                    false, // Don't keep items alive when off-screen
                addRepaintBoundaries: false, // Reduce repaint overhead
                addSemanticIndexes:
                    false, // Disable semantic indexing for performance
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio:
                      0.67, // Standard movie poster aspect ratio (2:3)
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return MovieCard(
                    media: _searchResults[index],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            media: _searchResults[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 64,
                      color: AppTheme.textSecondaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Search for movies and TV shows',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
