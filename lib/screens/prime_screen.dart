import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movora/providers/movie_provider.dart';
import 'package:movora/widgets/movie_list.dart';
import 'package:movora/theme/app_theme.dart';

class PrimeScreen extends StatefulWidget {
  const PrimeScreen({super.key});

  @override
  State<PrimeScreen> createState() => _PrimeScreenState();
}

class _PrimeScreenState extends State<PrimeScreen> {
  @override
  void initState() {
    super.initState();

    // Load Prime catalogue data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadPrimeCatalogue();
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
            'Amazon Prime',
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
              onRefresh: () => movieProvider.refreshPrimeCatalogue(),
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.backgroundColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // New Releases 2024-2025
                    if (movieProvider.newReleasesPrime.isNotEmpty) ...[
                      _buildSectionHeader(
                          'New Releases 2024-2025', 'new-releases-prime'),
                      MovieList(
                        media: movieProvider.newReleasesPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.newReleasesPrimeError != null)
                        _buildErrorWidget(movieProvider.newReleasesPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Trending Now
                    if (movieProvider.trendingPrime.isNotEmpty) ...[
                      _buildSectionHeader('Trending Now', 'trending-prime'),
                      MovieList(
                        media: movieProvider.trendingPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.trendingPrimeError != null)
                        _buildErrorWidget(movieProvider.trendingPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Award Winners
                    if (movieProvider.awardWinnersPrime.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Award Winners', 'award-winners-prime'),
                      MovieList(
                        media: movieProvider.awardWinnersPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.awardWinnersPrimeError != null)
                        _buildErrorWidget(
                            movieProvider.awardWinnersPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Top Rated
                    if (movieProvider.topRatedPrime.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Top Rated on Prime', 'top-rated-prime'),
                      MovieList(
                        media: movieProvider.topRatedPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.topRatedPrimeError != null)
                        _buildErrorWidget(movieProvider.topRatedPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Action & Adventure
                    if (movieProvider.actionPrime.isNotEmpty) ...[
                      _buildSectionHeader('Action & Adventure', 'action-prime'),
                      MovieList(
                        media: movieProvider.actionPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.actionPrimeError != null)
                        _buildErrorWidget(movieProvider.actionPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Comedy
                    if (movieProvider.comedyPrime.isNotEmpty) ...[
                      _buildSectionHeader('Comedies', 'comedy-prime'),
                      MovieList(
                        media: movieProvider.comedyPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.comedyPrimeError != null)
                        _buildErrorWidget(movieProvider.comedyPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Drama
                    if (movieProvider.dramaPrime.isNotEmpty) ...[
                      _buildSectionHeader('Dramas', 'drama-prime'),
                      MovieList(
                        media: movieProvider.dramaPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.dramaPrimeError != null)
                        _buildErrorWidget(movieProvider.dramaPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Thrillers
                    if (movieProvider.thrillerPrime.isNotEmpty) ...[
                      _buildSectionHeader('Thrillers', 'thriller-prime'),
                      MovieList(
                        media: movieProvider.thrillerPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.thrillerPrimeError != null)
                        _buildErrorWidget(movieProvider.thrillerPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Sci-Fi & Fantasy
                    if (movieProvider.scifiPrime.isNotEmpty) ...[
                      _buildSectionHeader('Sci-Fi & Fantasy', 'scifi-prime'),
                      MovieList(
                        media: movieProvider.scifiPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.scifiPrimeError != null)
                        _buildErrorWidget(movieProvider.scifiPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Romantic Movies
                    if (movieProvider.romancePrime.isNotEmpty) ...[
                      _buildSectionHeader('Romantic Movies', 'romance-prime'),
                      MovieList(
                        media: movieProvider.romancePrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.romancePrimeError != null)
                        _buildErrorWidget(movieProvider.romancePrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Family Content
                    if (movieProvider.familyContentPrime.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Family Entertainment', 'family-content-prime'),
                      MovieList(
                        media:
                            movieProvider.familyContentPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.familyContentPrimeError != null)
                        _buildErrorWidget(
                            movieProvider.familyContentPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Mystery
                    if (movieProvider.mysteryPrime.isNotEmpty) ...[
                      _buildSectionHeader('Mystery', 'mystery-prime'),
                      MovieList(
                        media: movieProvider.mysteryPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.mysteryPrimeError != null)
                        _buildErrorWidget(movieProvider.mysteryPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Crime
                    if (movieProvider.crimePrime.isNotEmpty) ...[
                      _buildSectionHeader('Crime', 'crime-prime'),
                      MovieList(
                        media: movieProvider.crimePrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.crimePrimeError != null)
                        _buildErrorWidget(movieProvider.crimePrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Animation
                    if (movieProvider.animationPrime.isNotEmpty) ...[
                      _buildSectionHeader('Animation', 'animation-prime'),
                      MovieList(
                        media: movieProvider.animationPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.animationPrimeError != null)
                        _buildErrorWidget(movieProvider.animationPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Documentary
                    if (movieProvider.documentaryPrime.isNotEmpty) ...[
                      _buildSectionHeader('Documentaries', 'documentary-prime'),
                      MovieList(
                        media: movieProvider.documentaryPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.documentaryPrimeError != null)
                        _buildErrorWidget(movieProvider.documentaryPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // International
                    if (movieProvider.internationalPrime.isNotEmpty) ...[
                      _buildSectionHeader(
                          'International', 'international-prime'),
                      MovieList(
                        media:
                            movieProvider.internationalPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.internationalPrimeError != null)
                        _buildErrorWidget(
                            movieProvider.internationalPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Classics
                    if (movieProvider.classicPrime.isNotEmpty) ...[
                      _buildSectionHeader('Classics', 'classic-prime'),
                      MovieList(
                        media: movieProvider.classicPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.classicPrimeError != null)
                        _buildErrorWidget(movieProvider.classicPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Upcoming
                    if (movieProvider.upcomingPrime.isNotEmpty) ...[
                      _buildSectionHeader('Upcoming', 'upcoming-prime'),
                      MovieList(
                        media: movieProvider.upcomingPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.upcomingPrimeError != null)
                        _buildErrorWidget(movieProvider.upcomingPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Critically Acclaimed
                    if (movieProvider.criticallyAcclaimedPrime.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Critically Acclaimed', 'critically-acclaimed-prime'),
                      MovieList(
                        media: movieProvider.criticallyAcclaimedPrime
                            .take(6)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.criticallyAcclaimedPrimeError != null)
                        _buildErrorWidget(
                            movieProvider.criticallyAcclaimedPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Horror
                    if (movieProvider.horrorPrime.isNotEmpty) ...[
                      _buildSectionHeader('Horror', 'horror-prime'),
                      MovieList(
                        media: movieProvider.horrorPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.horrorPrimeError != null)
                        _buildErrorWidget(movieProvider.horrorPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // War
                    if (movieProvider.warPrime.isNotEmpty) ...[
                      _buildSectionHeader('War', 'war-prime'),
                      MovieList(
                        media: movieProvider.warPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.warPrimeError != null)
                        _buildErrorWidget(movieProvider.warPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Western
                    if (movieProvider.westernPrime.isNotEmpty) ...[
                      _buildSectionHeader('Western', 'western-prime'),
                      MovieList(
                        media: movieProvider.westernPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.westernPrimeError != null)
                        _buildErrorWidget(movieProvider.westernPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Musical
                    if (movieProvider.musicalPrime.isNotEmpty) ...[
                      _buildSectionHeader('Musical', 'musical-prime'),
                      MovieList(
                        media: movieProvider.musicalPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.musicalPrimeError != null)
                        _buildErrorWidget(movieProvider.musicalPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Biographical
                    if (movieProvider.biographicalPrime.isNotEmpty) ...[
                      _buildSectionHeader('Biographical', 'biographical-prime'),
                      MovieList(
                        media: movieProvider.biographicalPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.biographicalPrimeError != null)
                        _buildErrorWidget(
                            movieProvider.biographicalPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Sports
                    if (movieProvider.sportsPrime.isNotEmpty) ...[
                      _buildSectionHeader('Sports', 'sports-prime'),
                      MovieList(
                        media: movieProvider.sportsPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.sportsPrimeError != null)
                        _buildErrorWidget(movieProvider.sportsPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Adventure
                    if (movieProvider.adventurePrime.isNotEmpty) ...[
                      _buildSectionHeader('Adventure', 'adventure-prime'),
                      MovieList(
                        media: movieProvider.adventurePrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.adventurePrimeError != null)
                        _buildErrorWidget(movieProvider.adventurePrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Fantasy
                    if (movieProvider.fantasyPrime.isNotEmpty) ...[
                      _buildSectionHeader('Fantasy', 'fantasy-prime'),
                      MovieList(
                        media: movieProvider.fantasyPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.fantasyPrimeError != null)
                        _buildErrorWidget(movieProvider.fantasyPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Superhero
                    if (movieProvider.superheroPrime.isNotEmpty) ...[
                      _buildSectionHeader('Superhero', 'superhero-prime'),
                      MovieList(
                        media: movieProvider.superheroPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.superheroPrimeError != null)
                        _buildErrorWidget(movieProvider.superheroPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Indie
                    if (movieProvider.indiePrime.isNotEmpty) ...[
                      _buildSectionHeader('Indie', 'indie-prime'),
                      MovieList(
                        media: movieProvider.indiePrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.indiePrimeError != null)
                        _buildErrorWidget(movieProvider.indiePrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Foreign
                    if (movieProvider.foreignPrime.isNotEmpty) ...[
                      _buildSectionHeader('Foreign', 'foreign-prime'),
                      MovieList(
                        media: movieProvider.foreignPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.foreignPrimeError != null)
                        _buildErrorWidget(movieProvider.foreignPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Teen
                    if (movieProvider.teenPrime.isNotEmpty) ...[
                      _buildSectionHeader('Teen', 'teen-prime'),
                      MovieList(
                        media: movieProvider.teenPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.teenPrimeError != null)
                        _buildErrorWidget(movieProvider.teenPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Kids
                    if (movieProvider.kidsPrime.isNotEmpty) ...[
                      _buildSectionHeader('Kids', 'kids-prime'),
                      MovieList(
                        media: movieProvider.kidsPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.kidsPrimeError != null)
                        _buildErrorWidget(movieProvider.kidsPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Popular TV Shows
                    if (movieProvider.popularTvPrime.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Popular TV Shows', 'popular-tv-prime'),
                      MovieList(
                        media: movieProvider.popularTvPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.popularTvPrimeError != null)
                        _buildErrorWidget(movieProvider.popularTvPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Binge-Worthy Comedies
                    if (movieProvider.comedyTvPrime.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Binge-Worthy Comedies', 'comedy-tv-prime'),
                      MovieList(
                        media: movieProvider.comedyTvPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.comedyTvPrimeError != null)
                        _buildErrorWidget(movieProvider.comedyTvPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Gripping Dramas
                    if (movieProvider.dramaTvPrime.isNotEmpty) ...[
                      _buildSectionHeader('Gripping Dramas', 'drama-tv-prime'),
                      MovieList(
                        media: movieProvider.dramaTvPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.dramaTvPrimeError != null)
                        _buildErrorWidget(movieProvider.dramaTvPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Reality TV
                    if (movieProvider.realityTvPrime.isNotEmpty) ...[
                      _buildSectionHeader('Reality TV', 'reality-tv-prime'),
                      MovieList(
                        media: movieProvider.realityTvPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.realityTvPrimeError != null)
                        _buildErrorWidget(movieProvider.realityTvPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Game Shows
                    if (movieProvider.gameShowPrime.isNotEmpty) ...[
                      _buildSectionHeader('Game Shows', 'game-show-prime'),
                      MovieList(
                        media: movieProvider.gameShowPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.gameShowPrimeError != null)
                        _buildErrorWidget(movieProvider.gameShowPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Talk Shows
                    if (movieProvider.talkShowPrime.isNotEmpty) ...[
                      _buildSectionHeader('Talk Shows', 'talk-show-prime'),
                      MovieList(
                        media: movieProvider.talkShowPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.talkShowPrimeError != null)
                        _buildErrorWidget(movieProvider.talkShowPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Variety
                    if (movieProvider.varietyPrime.isNotEmpty) ...[
                      _buildSectionHeader('Variety', 'variety-prime'),
                      MovieList(
                        media: movieProvider.varietyPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.varietyPrimeError != null)
                        _buildErrorWidget(movieProvider.varietyPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // News
                    if (movieProvider.newsPrime.isNotEmpty) ...[
                      _buildSectionHeader('News', 'news-prime'),
                      MovieList(
                        media: movieProvider.newsPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.newsPrimeError != null)
                        _buildErrorWidget(movieProvider.newsPrimeError!),
                      const SizedBox(height: 24),
                    ],

                    // Educational
                    if (movieProvider.educationalPrime.isNotEmpty) ...[
                      _buildSectionHeader('Educational', 'educational-prime'),
                      MovieList(
                        media: movieProvider.educationalPrime.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.educationalPrimeError != null)
                        _buildErrorWidget(movieProvider.educationalPrimeError!),
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
                    'with_watch_providers': '9',
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
              'Loading Prime',
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discovering the best of Amazon Prime content',
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
