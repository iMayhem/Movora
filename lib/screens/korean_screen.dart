import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movora/providers/movie_provider.dart';
import 'package:movora/widgets/movie_list.dart';
import 'package:movora/theme/app_theme.dart';

class KoreanScreen extends StatefulWidget {
  const KoreanScreen({super.key});

  @override
  State<KoreanScreen> createState() => _KoreanScreenState();
}

class _KoreanScreenState extends State<KoreanScreen> {
  @override
  void initState() {
    super.initState();

    // Load Korean catalogue data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadKoreanCatalogue();
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
            'Korean',
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
              onRefresh: () => movieProvider.refreshKoreanCatalogue(),
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.backgroundColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // New Releases 2024-2025
                    if (movieProvider.newReleasesKorean.isNotEmpty)
                      _buildSectionHeader(
                          'New Releases 2024-2025', 'new-releases-korean'),
                    if (movieProvider.newReleasesKorean.isNotEmpty)
                      MovieList(
                        media: movieProvider.newReleasesKorean.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.newReleasesKoreanError != null)
                      _buildErrorWidget(movieProvider.newReleasesKoreanError!),

                    const SizedBox(height: 24),

                    // Blockbuster Hits
                    if (movieProvider.blockbusterHitsKorean.isNotEmpty)
                      _buildSectionHeader(
                          'Blockbuster Hits', 'blockbuster-hits-korean'),
                    if (movieProvider.blockbusterHitsKorean.isNotEmpty)
                      MovieList(
                        media: movieProvider.blockbusterHitsKorean
                            .take(6)
                            .toList(),
                        title: null,
                      ),
                    if (movieProvider.blockbusterHitsKoreanError != null)
                      _buildErrorWidget(
                          movieProvider.blockbusterHitsKoreanError!),

                    const SizedBox(height: 24),

                    // Critically Acclaimed
                    if (movieProvider.criticallyAcclaimedKorean.isNotEmpty)
                      _buildSectionHeader('Critically Acclaimed',
                          'critically-acclaimed-korean'),
                    if (movieProvider.criticallyAcclaimedKorean.isNotEmpty)
                      MovieList(
                        media: movieProvider.criticallyAcclaimedKorean
                            .take(6)
                            .toList(),
                        title: null,
                      ),
                    if (movieProvider.criticallyAcclaimedKoreanError != null)
                      _buildErrorWidget(
                          movieProvider.criticallyAcclaimedKoreanError!),

                    const SizedBox(height: 24),

                    // Action Thrillers
                    if (movieProvider.actionKorean.isNotEmpty)
                      _buildSectionHeader('Action Thrillers', 'action-korean'),
                    if (movieProvider.actionKorean.isNotEmpty)
                      MovieList(
                        media: movieProvider.actionKorean.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.actionKoreanError != null)
                      _buildErrorWidget(movieProvider.actionKoreanError!),

                    const SizedBox(height: 24),

                    // Romantic Dramas removed as requested

                    // Comedy Gold
                    if (movieProvider.comedyGoldKorean.isNotEmpty)
                      _buildSectionHeader('Comedy Gold', 'comedy-gold-korean'),
                    if (movieProvider.comedyGoldKorean.isNotEmpty)
                      MovieList(
                        media: movieProvider.comedyGoldKorean.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.comedyGoldKoreanError != null)
                      _buildErrorWidget(movieProvider.comedyGoldKoreanError!),

                    const SizedBox(height: 24),

                    // Family Entertainment
                    if (movieProvider.familyEntertainmentKorean.isNotEmpty)
                      _buildSectionHeader('Family Entertainment',
                          'family-entertainment-korean'),
                    if (movieProvider.familyEntertainmentKorean.isNotEmpty)
                      MovieList(
                        media: movieProvider.familyEntertainmentKorean
                            .take(6)
                            .toList(),
                        title: null,
                      ),
                    if (movieProvider.familyEntertainmentKoreanError != null)
                      _buildErrorWidget(
                          movieProvider.familyEntertainmentKoreanError!),

                    const SizedBox(height: 24),

                    // Mystery & Crime
                    if (movieProvider.mysteryCrimeKorean.isNotEmpty)
                      _buildSectionHeader(
                          'Mystery & Crime', 'mystery-crime-korean'),
                    if (movieProvider.mysteryCrimeKorean.isNotEmpty)
                      MovieList(
                        media:
                            movieProvider.mysteryCrimeKorean.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.mysteryCrimeKoreanError != null)
                      _buildErrorWidget(movieProvider.mysteryCrimeKoreanError!),

                    const SizedBox(height: 24),

                    // Biographical Films
                    if (movieProvider.biographicalKorean.isNotEmpty)
                      _buildSectionHeader(
                          'Biographical Films', 'biographical-korean'),
                    if (movieProvider.biographicalKorean.isNotEmpty)
                      MovieList(
                        media:
                            movieProvider.biographicalKorean.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.biographicalKoreanError != null)
                      _buildErrorWidget(movieProvider.biographicalKoreanError!),

                    const SizedBox(height: 24),

                    // Web Series & TV Shows
                    if (movieProvider.webSeriesKorean.isNotEmpty)
                      _buildSectionHeader(
                          'Web Series & TV Shows', 'web-series-korean'),
                    if (movieProvider.webSeriesKorean.isNotEmpty)
                      MovieList(
                        media: movieProvider.webSeriesKorean.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.webSeriesKoreanError != null)
                      _buildErrorWidget(movieProvider.webSeriesKoreanError!),

                    const SizedBox(height: 24),

                    // Upcoming Releases
                    if (movieProvider.upcomingKorean.isNotEmpty)
                      _buildSectionHeader(
                          'Upcoming Releases', 'upcoming-korean'),
                    if (movieProvider.upcomingKorean.isNotEmpty)
                      MovieList(
                        media: movieProvider.upcomingKorean.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.upcomingKoreanError != null)
                      _buildErrorWidget(movieProvider.upcomingKoreanError!),

                    const SizedBox(height: 24),

                    // Award Winners
                    if (movieProvider.awardWinnersKorean.isNotEmpty)
                      _buildSectionHeader(
                          'Award Winners', 'award-winners-korean'),
                    if (movieProvider.awardWinnersKorean.isNotEmpty)
                      MovieList(
                        media:
                            movieProvider.awardWinnersKorean.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.awardWinnersKoreanError != null)
                      _buildErrorWidget(movieProvider.awardWinnersKoreanError!),

                    const SizedBox(height: 24),

                    // Korean Classics
                    if (movieProvider.koreanClassics.isNotEmpty)
                      _buildSectionHeader('Korean Classics', 'korean-classics'),
                    if (movieProvider.koreanClassics.isNotEmpty)
                      MovieList(
                        media: movieProvider.koreanClassics.take(6).toList(),
                        title: null,
                      ),
                    if (movieProvider.koreanClassicsError != null)
                      _buildErrorWidget(movieProvider.koreanClassicsError!),

                    const SizedBox(height: 24),
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
                    'with_original_language': 'ko',
                    'region': 'KR',
                  },
                },
              );
            },
            child: Text(
              'More',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 16,
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
              'Loading Korean',
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discovering the best of Korean cinema',
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
