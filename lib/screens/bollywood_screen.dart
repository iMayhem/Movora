import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movora/providers/movie_provider.dart';
import 'package:movora/widgets/movie_list.dart';
import 'package:movora/theme/app_theme.dart';

class BollywoodScreen extends StatefulWidget {
  const BollywoodScreen({super.key});

  @override
  State<BollywoodScreen> createState() => _BollywoodScreenState();
}

class _BollywoodScreenState extends State<BollywoodScreen> {
  @override
  void initState() {
    super.initState();

    // Load Bollywood catalogue data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadBollywoodCatalogue();
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
            'Bollywood',
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
              onRefresh: () => movieProvider.refreshBollywoodCatalogue(),
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.backgroundColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // New Releases 2024-2025
                    if (movieProvider.newReleasesBollywood.isNotEmpty) ...[
                      _buildSectionHeader(
                          'New Releases 2024-2025', 'new-releases-bollywood'),
                      MovieList(
                        media: movieProvider.newReleasesBollywood
                            .take(12)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.newReleasesBollywoodError != null)
                        _buildErrorWidget(
                            movieProvider.newReleasesBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Blockbuster Hits
                    if (movieProvider.blockbusterHitsBollywood.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Blockbuster Hits', 'blockbuster-hits-bollywood'),
                      MovieList(
                        media: movieProvider.blockbusterHitsBollywood
                            .take(12)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.blockbusterHitsBollywoodError != null)
                        _buildErrorWidget(
                            movieProvider.blockbusterHitsBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Critically Acclaimed
                    if (movieProvider
                        .criticallyAcclaimedBollywood.isNotEmpty) ...[
                      _buildSectionHeader('Critically Acclaimed',
                          'critically-acclaimed-bollywood'),
                      MovieList(
                        media: movieProvider.criticallyAcclaimedBollywood
                            .take(12)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.criticallyAcclaimedBollywoodError !=
                          null)
                        _buildErrorWidget(
                            movieProvider.criticallyAcclaimedBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Latest Bollywood Releases
                    if (movieProvider.latestBollywood.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Latest Bollywood Releases', 'latest-bollywood'),
                      MovieList(
                        media: movieProvider.latestBollywood.take(12).toList(),
                        title: null,
                      ),
                      if (movieProvider.latestBollywoodError != null)
                        _buildErrorWidget(movieProvider.latestBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Action Thrillers
                    if (movieProvider.actionThrillersBollywood.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Action Thrillers', 'action-thrillers-bollywood'),
                      MovieList(
                        media: movieProvider.actionThrillersBollywood
                            .take(12)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.actionThrillersBollywoodError != null)
                        _buildErrorWidget(
                            movieProvider.actionThrillersBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Romantic Dramas
                    if (movieProvider.romanticDramasBollywood.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Romantic Dramas', 'romantic-dramas-bollywood'),
                      MovieList(
                        media: movieProvider.romanticDramasBollywood
                            .take(12)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.romanticDramasBollywoodError != null)
                        _buildErrorWidget(
                            movieProvider.romanticDramasBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Comedy Gold
                    if (movieProvider.comedyGoldBollywood.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Comedy Gold', 'comedy-gold-bollywood'),
                      MovieList(
                        media:
                            movieProvider.comedyGoldBollywood.take(12).toList(),
                        title: null,
                      ),
                      if (movieProvider.comedyGoldBollywoodError != null)
                        _buildErrorWidget(
                            movieProvider.comedyGoldBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Family Entertainment
                    if (movieProvider
                        .familyEntertainmentBollywood.isNotEmpty) ...[
                      _buildSectionHeader('Family Entertainment',
                          'family-entertainment-bollywood'),
                      MovieList(
                        media: movieProvider.familyEntertainmentBollywood
                            .take(12)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.familyEntertainmentBollywoodError !=
                          null)
                        _buildErrorWidget(
                            movieProvider.familyEntertainmentBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Mystery & Crime
                    if (movieProvider.mysteryCrimeBollywood.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Mystery & Crime', 'mystery-crime-bollywood'),
                      MovieList(
                        media: movieProvider.mysteryCrimeBollywood
                            .take(12)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.mysteryCrimeBollywoodError != null)
                        _buildErrorWidget(
                            movieProvider.mysteryCrimeBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Biographical Films
                    if (movieProvider.biographicalBollywood.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Biographical Films', 'biographical-bollywood'),
                      MovieList(
                        media: movieProvider.biographicalBollywood
                            .take(12)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.biographicalBollywoodError != null)
                        _buildErrorWidget(
                            movieProvider.biographicalBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Web Series
                    if (movieProvider.webSeriesBollywood.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Web Series & TV Shows', 'web-series-bollywood'),
                      MovieList(
                        media:
                            movieProvider.webSeriesBollywood.take(12).toList(),
                        title: null,
                      ),
                      if (movieProvider.webSeriesBollywoodError != null)
                        _buildErrorWidget(
                            movieProvider.webSeriesBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Netflix Bollywood
                    if (movieProvider.netflixBollywood.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Netflix Bollywood', 'netflix-bollywood'),
                      MovieList(
                        media: movieProvider.netflixBollywood.take(12).toList(),
                        title: null,
                      ),
                      if (movieProvider.netflixBollywoodError != null)
                        _buildErrorWidget(movieProvider.netflixBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Amazon Prime Bollywood
                    if (movieProvider.primeBollywood.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Amazon Prime Bollywood', 'prime-bollywood'),
                      MovieList(
                        media: movieProvider.primeBollywood.take(12).toList(),
                        title: null,
                      ),
                      if (movieProvider.primeBollywoodError != null)
                        _buildErrorWidget(movieProvider.primeBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Upcoming Releases
                    if (movieProvider.upcomingBollywood.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Upcoming Releases', 'upcoming-bollywood'),
                      MovieList(
                        media:
                            movieProvider.upcomingBollywood.take(12).toList(),
                        title: null,
                      ),
                      if (movieProvider.upcomingBollywoodError != null)
                        _buildErrorWidget(
                            movieProvider.upcomingBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Award Winners
                    if (movieProvider.awardWinnersBollywood.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Award Winners', 'award-winners-bollywood'),
                      MovieList(
                        media: movieProvider.awardWinnersBollywood
                            .take(12)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.awardWinnersBollywoodError != null)
                        _buildErrorWidget(
                            movieProvider.awardWinnersBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Bollywood Classics
                    if (movieProvider.classicsBollywood.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Bollywood Classics', 'classics-bollywood'),
                      MovieList(
                        media:
                            movieProvider.classicsBollywood.take(12).toList(),
                        title: null,
                      ),
                      if (movieProvider.classicsBollywoodError != null)
                        _buildErrorWidget(
                            movieProvider.classicsBollywoodError!),
                      const SizedBox(height: 24),
                    ],

                    // Masala Movies
                    if (movieProvider.masalaMovies.isNotEmpty) ...[
                      _buildSectionHeader('Masala Movies', 'masala-bollywood'),
                      MovieList(
                        media: movieProvider.masalaMovies.take(12).toList(),
                        title: null,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Patriotic Movies
                    if (movieProvider.patrioticMovies.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Patriotic Movies', 'patriotic-bollywood'),
                      MovieList(
                        media: movieProvider.patrioticMovies.take(12).toList(),
                        title: null,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Social Dramas
                    if (movieProvider.socialDramas.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Social Dramas', 'social-dramas-bollywood'),
                      MovieList(
                        media: movieProvider.socialDramas.take(12).toList(),
                        title: null,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Comedy Dramas
                    if (movieProvider.comedyDramas.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Comedy Dramas', 'comedy-dramas-bollywood'),
                      MovieList(
                        media: movieProvider.comedyDramas.take(12).toList(),
                        title: null,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Action Comedies
                    if (movieProvider.actionComedies.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Action Comedies', 'action-comedies-bollywood'),
                      MovieList(
                        media: movieProvider.actionComedies.take(12).toList(),
                        title: null,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Hindi TV Shows
                    if (movieProvider.tvShowsHindi.isNotEmpty) ...[
                      _buildSectionHeader('Hindi TV Shows', 'tv-shows-hindi'),
                      MovieList(
                        media: movieProvider.tvShowsHindi.take(12).toList(),
                        title: null,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Reality Shows
                    if (movieProvider.realityShowsHindi.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Reality Shows', 'reality-shows-hindi'),
                      MovieList(
                        media:
                            movieProvider.realityShowsHindi.take(12).toList(),
                        title: null,
                      ),
                      const SizedBox(height: 24),
                    ],
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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
                  'apiParams': {},
                },
              );
            },
            child: Text(
              'More',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
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
              'Loading Bollywood',
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discovering the best of Indian cinema',
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
}
