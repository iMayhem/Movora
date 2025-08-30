import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movora/providers/movie_provider.dart';
import 'package:movora/widgets/movie_list.dart';
import 'package:movora/theme/app_theme.dart';

class NetflixScreen extends StatefulWidget {
  const NetflixScreen({super.key});

  @override
  State<NetflixScreen> createState() => _NetflixScreenState();
}

class _NetflixScreenState extends State<NetflixScreen> {
  @override
  void initState() {
    super.initState();

    // Load Netflix catalogue data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadNetflixCatalogue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/');
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          title: const Text(
            'Netflix',
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ),
        body: Consumer<MovieProvider>(
          builder: (context, movieProvider, child) {
            if (movieProvider.isAnyLoading) {
              return _buildLoading();
            }

            return RefreshIndicator(
              onRefresh: () => movieProvider.refreshNetflixCatalogue(),
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.backgroundColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // New Releases 2024-2025
                    if (movieProvider.newReleasesNetflix.isNotEmpty)
                      _buildSectionHeader(
                          'New Releases 2024-2025', 'new-releases-netflix'),
                    if (movieProvider.newReleasesNetflix.isNotEmpty)
                      MovieList(
                        media:
                            movieProvider.newReleasesNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.newReleasesNetflixError != null)
                      _buildErrorWidget(movieProvider.newReleasesNetflixError!),

                    const SizedBox(height: 24),

                    // Trending Now
                    if (movieProvider.trendingNetflix.isNotEmpty)
                      _buildSectionHeader('Trending Now', 'trending-netflix'),
                    if (movieProvider.trendingNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.trendingNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.trendingNetflixError != null)
                      _buildErrorWidget(movieProvider.trendingNetflixError!),

                    const SizedBox(height: 24),

                    // Award Winners
                    if (movieProvider.awardWinnersNetflix.isNotEmpty)
                      _buildSectionHeader(
                          'Award Winners', 'award-winners-netflix'),
                    if (movieProvider.awardWinnersNetflix.isNotEmpty)
                      MovieList(
                        media:
                            movieProvider.awardWinnersNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.awardWinnersNetflixError != null)
                      _buildErrorWidget(
                          movieProvider.awardWinnersNetflixError!),

                    const SizedBox(height: 24),

                    // Top Rated
                    if (movieProvider.topRatedNetflix.isNotEmpty)
                      _buildSectionHeader(
                          'Top Rated on Netflix', 'top-rated-netflix'),
                    if (movieProvider.topRatedNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.topRatedNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.topRatedNetflixError != null)
                      _buildErrorWidget(movieProvider.topRatedNetflixError!),

                    const SizedBox(height: 24),

                    // Action & Adventure
                    if (movieProvider.actionNetflix.isNotEmpty)
                      _buildSectionHeader(
                          'Action & Adventure', 'action-netflix'),
                    if (movieProvider.actionNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.actionNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.actionNetflixError != null)
                      _buildErrorWidget(movieProvider.actionNetflixError!),

                    const SizedBox(height: 24),

                    // Comedy
                    if (movieProvider.comedyNetflix.isNotEmpty)
                      _buildSectionHeader('Comedies', 'comedy-netflix'),
                    if (movieProvider.comedyNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.comedyNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.comedyNetflixError != null)
                      _buildErrorWidget(movieProvider.comedyNetflixError!),

                    const SizedBox(height: 24),

                    // Drama
                    if (movieProvider.dramaNetflix.isNotEmpty)
                      _buildSectionHeader('Dramas', 'drama-netflix'),
                    if (movieProvider.dramaNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.dramaNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.dramaNetflixError != null)
                      _buildErrorWidget(movieProvider.dramaNetflixError!),

                    const SizedBox(height: 24),

                    // Thrillers
                    if (movieProvider.thrillerNetflix.isNotEmpty)
                      _buildSectionHeader('Thrillers', 'thriller-netflix'),
                    if (movieProvider.thrillerNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.thrillerNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.thrillerNetflixError != null)
                      _buildErrorWidget(movieProvider.thrillerNetflixError!),

                    const SizedBox(height: 24),

                    // Horror
                    if (movieProvider.horrorNetflix.isNotEmpty)
                      _buildSectionHeader('Horror', 'horror-netflix'),
                    if (movieProvider.horrorNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.horrorNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.horrorNetflixError != null)
                      _buildErrorWidget(movieProvider.horrorNetflixError!),

                    const SizedBox(height: 24),

                    // Sci-Fi & Fantasy
                    if (movieProvider.scifiNetflix.isNotEmpty)
                      _buildSectionHeader('Sci-Fi & Fantasy', 'scifi-netflix'),
                    if (movieProvider.scifiNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.scifiNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.scifiNetflixError != null)
                      _buildErrorWidget(movieProvider.scifiNetflixError!),

                    const SizedBox(height: 24),

                    // Family Content
                    if (movieProvider.familyContentNetflix.isNotEmpty)
                      _buildSectionHeader(
                          'Family Entertainment', 'family-content-netflix'),
                    if (movieProvider.familyContentNetflix.isNotEmpty)
                      MovieList(
                        media:
                            movieProvider.familyContentNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.familyContentNetflixError != null)
                      _buildErrorWidget(
                          movieProvider.familyContentNetflixError!),

                    const SizedBox(height: 24),

                    // Romance
                    if (movieProvider.romanceNetflix.isNotEmpty)
                      _buildSectionHeader('Romance', 'romance-netflix'),
                    if (movieProvider.romanceNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.romanceNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.romanceNetflixError != null)
                      _buildErrorWidget(movieProvider.romanceNetflixError!),

                    const SizedBox(height: 24),

                    // Mystery
                    if (movieProvider.mysteryNetflix.isNotEmpty)
                      _buildSectionHeader('Mystery', 'mystery-netflix'),
                    if (movieProvider.mysteryNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.mysteryNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.mysteryNetflixError != null)
                      _buildErrorWidget(movieProvider.mysteryNetflixError!),

                    const SizedBox(height: 24),

                    // Crime
                    if (movieProvider.crimeNetflix.isNotEmpty)
                      _buildSectionHeader('Crime', 'crime-netflix'),
                    if (movieProvider.crimeNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.crimeNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.crimeNetflixError != null)
                      _buildErrorWidget(movieProvider.crimeNetflixError!),

                    const SizedBox(height: 24),

                    // Animation
                    if (movieProvider.animationNetflix.isNotEmpty)
                      _buildSectionHeader('Animation', 'animation-netflix'),
                    if (movieProvider.animationNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.animationNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.animationNetflixError != null)
                      _buildErrorWidget(movieProvider.animationNetflixError!),

                    const SizedBox(height: 24),

                    // Documentary
                    if (movieProvider.documentaryNetflix.isNotEmpty)
                      _buildSectionHeader(
                          'Documentaries', 'documentary-netflix'),
                    if (movieProvider.documentaryNetflix.isNotEmpty)
                      MovieList(
                        media:
                            movieProvider.documentaryNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.documentaryNetflixError != null)
                      _buildErrorWidget(movieProvider.documentaryNetflixError!),

                    const SizedBox(height: 24),

                    // International
                    if (movieProvider.internationalNetflix.isNotEmpty)
                      _buildSectionHeader(
                          'International', 'international-netflix'),
                    if (movieProvider.internationalNetflix.isNotEmpty)
                      MovieList(
                        media:
                            movieProvider.internationalNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.internationalNetflixError != null)
                      _buildErrorWidget(
                          movieProvider.internationalNetflixError!),

                    const SizedBox(height: 24),

                    // Classics
                    if (movieProvider.classicNetflix.isNotEmpty)
                      _buildSectionHeader('Classics', 'classic-netflix'),
                    if (movieProvider.classicNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.classicNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.classicNetflixError != null)
                      _buildErrorWidget(movieProvider.classicNetflixError!),

                    const SizedBox(height: 24),

                    // Upcoming
                    if (movieProvider.upcomingNetflix.isNotEmpty)
                      _buildSectionHeader('Upcoming', 'upcoming-netflix'),
                    if (movieProvider.upcomingNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.upcomingNetflix.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.upcomingNetflixError != null)
                      _buildErrorWidget(movieProvider.upcomingNetflixError!),

                    const SizedBox(height: 24),

                    // Critically Acclaimed
                    if (movieProvider.criticallyAcclaimedNetflix.isNotEmpty)
                      _buildSectionHeader('Critically Acclaimed',
                          'critically-acclaimed-netflix'),
                    if (movieProvider.criticallyAcclaimedNetflix.isNotEmpty)
                      MovieList(
                        media: movieProvider.criticallyAcclaimedNetflix
                            .take(6)
                            .toList(),
                        title: null,
                      ),
                    if (movieProvider.criticallyAcclaimedNetflixError != null)
                      _buildErrorWidget(
                          movieProvider.criticallyAcclaimedNetflixError!),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String categorySlug) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/category',
                arguments: {
                  'title': title,
                  'categoryType': categorySlug,
                  'apiParams': {
                    'watch_region': 'US',
                    'with_watch_monetization_types': 'flatrate',
                    'with_watch_providers': '8',
                  },
                },
              );
            },
            child: Text(
              'More',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Netflix',
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discovering the best of Netflix content',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.destructiveColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.destructiveColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: AppTheme.destructiveColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
