import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movora/providers/movie_provider.dart';
import 'package:movora/widgets/movie_list.dart';
import 'package:movora/widgets/app_drawer.dart';
import 'package:movora/theme/app_theme.dart';
import 'package:movora/models/media.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Performance optimization: Cache the app drawer
  late final AppDrawer _appDrawer;

  @override
  void initState() {
    super.initState();
    _appDrawer = const AppDrawer();

    // Performance optimization: Use microtask for better performance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MovieProvider>();
      // Only perform the heavy initial load once per app session
      if (!provider.hasLoadedHome) {
        // Use microtask to avoid blocking the UI
        Future.microtask(() {
          provider.loadCatalogue();
          provider.loadHollywoodCatalogue();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: _appDrawer, // Use cached drawer
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Consumer<MovieProvider>(
          builder: (context, movieProvider, child) {
            // Show the cinematic loading screen only on first app start
            if (!movieProvider.hasLoadedHome && movieProvider.isAnyLoading) {
              return _buildWebsiteLoading();
            }

            return RefreshIndicator(
              onRefresh: () async {
                // Performance optimization: Batch refresh operations
                await Future.wait([
                  movieProvider.refreshCatalogue(),
                  movieProvider.refreshHollywoodCatalogue(),
                ]);
              },
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.backgroundColor,
              child: CustomScrollView(
                slivers: [
                  // Performance optimization: Use const for static elements
                  _buildSliverAppBar(context),
                  // Performance optimization: Lazy load content sections
                  ..._buildContentSections(movieProvider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Performance optimization: Extract app bar to reduce rebuilds
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0B0B0B),
                Color(0xFF0B0B0B),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  // MOVORA Logo
                  const Text(
                    'MOVORA',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 24,
                    ),
                  ),
                  const Spacer(),
                  // Search Button
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/search');
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Performance optimization: Build content sections efficiently
  List<Widget> _buildContentSections(MovieProvider movieProvider) {
    return [
      if (movieProvider.trendingNow.isNotEmpty)
        SliverToBoxAdapter(
          child: _buildCategorySection(
            title: 'Trending Now',
            media: movieProvider.trendingNow,
            onMoreTap: () =>
                Navigator.pushNamed(context, '/category', arguments: {
              'title': 'Trending Now',
              'categoryType': 'trending',
            }),
          ),
        ),
      if (movieProvider.newlyReleased.isNotEmpty)
        SliverToBoxAdapter(
          child: _buildCategorySection(
            title: 'Newly Released',
            media: movieProvider.newlyReleased,
            onMoreTap: () =>
                Navigator.pushNamed(context, '/category', arguments: {
              'title': 'Newly Released',
              'categoryType': 'newly-released',
            }),
          ),
        ),
      if (movieProvider.mostPopular.isNotEmpty)
        SliverToBoxAdapter(
          child: _buildCategorySection(
            title: 'Most Popular',
            media: movieProvider.mostPopular,
            onMoreTap: () =>
                Navigator.pushNamed(context, '/category', arguments: {
              'title': 'Most Popular',
              'categoryType': 'popular',
            }),
          ),
        ),
      if (movieProvider.topRatedMovies.isNotEmpty)
        SliverToBoxAdapter(
          child: _buildCategorySection(
            title: 'Top Rated',
            media: movieProvider.topRatedMovies,
            onMoreTap: () =>
                Navigator.pushNamed(context, '/category', arguments: {
              'title': 'Top Rated',
              'categoryType': 'top-rated',
            }),
          ),
        ),
      if (movieProvider.actionAdventure.isNotEmpty)
        SliverToBoxAdapter(
          child: _buildCategorySection(
            title: 'Action & Adventure',
            media: movieProvider.actionAdventure,
            onMoreTap: () =>
                Navigator.pushNamed(context, '/category', arguments: {
              'title': 'Action & Adventure',
              'categoryType': 'action-adventure',
            }),
          ),
        ),
      if (movieProvider.comedy.isNotEmpty)
        SliverToBoxAdapter(
          child: _buildCategorySection(
            title: 'Comedy',
            media: movieProvider.comedy,
            onMoreTap: () =>
                Navigator.pushNamed(context, '/category', arguments: {
              'title': 'Comedy',
              'categoryType': 'comedy',
            }),
          ),
        ),
      if (movieProvider.scifiFantasy.isNotEmpty)
        SliverToBoxAdapter(
          child: _buildCategorySection(
            title: 'Sci-Fi & Fantasy',
            media: movieProvider.scifiFantasy,
            onMoreTap: () =>
                Navigator.pushNamed(context, '/category', arguments: {
              'title': 'Sci-Fi & Fantasy',
              'categoryType': 'scifi-fantasy',
            }),
          ),
        ),
      if (movieProvider.horror.isNotEmpty)
        SliverToBoxAdapter(
          child: _buildCategorySection(
            title: 'Horror',
            media: movieProvider.horror,
            onMoreTap: () =>
                Navigator.pushNamed(context, '/category', arguments: {
              'title': 'Horror',
              'categoryType': 'horror',
            }),
          ),
        ),
      if (movieProvider.drama.isNotEmpty)
        SliverToBoxAdapter(
          child: _buildCategorySection(
            title: 'Drama',
            media: movieProvider.drama,
            onMoreTap: () =>
                Navigator.pushNamed(context, '/category', arguments: {
              'title': 'Drama',
              'categoryType': 'drama',
            }),
          ),
        ),
      if (movieProvider.romance.isNotEmpty)
        SliverToBoxAdapter(
          child: _buildCategorySection(
            title: 'Romance',
            media: movieProvider.romance,
            onMoreTap: () =>
                Navigator.pushNamed(context, '/category', arguments: {
              'title': 'Romance',
              'categoryType': 'romance',
            }),
          ),
        ),
      if (movieProvider.animation.isNotEmpty)
        SliverToBoxAdapter(
          child: _buildCategorySection(
            title: 'Animation',
            media: movieProvider.animation,
            onMoreTap: () =>
                Navigator.pushNamed(context, '/category', arguments: {
              'title': 'Animation',
              'categoryType': 'animation',
            }),
          ),
        ),
    ];
  }

  Widget _buildCategorySection({
    required String title,
    required List<Media> media,
    required VoidCallback onMoreTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: onMoreTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'More',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          MovieList(
            media: media,
            height: 200,
            itemWidth: 120,
            itemHeight: 180,
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteLoading() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Netflix-style loading spinner
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 4,
                ),
              ),
              child: const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Loading Movora',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Discovering the best movies and TV shows',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 48),
            // Made by Mayhem
            Text(
              'Made by Mayhem',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.destructiveColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.destructiveColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.destructiveColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.destructiveColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
