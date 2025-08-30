import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movora/providers/movie_provider.dart';
import 'package:movora/widgets/movie_list.dart';
import 'package:movora/theme/app_theme.dart';

class AnimatedScreen extends StatefulWidget {
  const AnimatedScreen({super.key});

  @override
  State<AnimatedScreen> createState() => _AnimatedScreenState();
}

class _AnimatedScreenState extends State<AnimatedScreen> {
  @override
  void initState() {
    super.initState();

    // Load Animated catalogue data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadAnimatedCatalogue();
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
            'Animated',
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
              onRefresh: () => movieProvider.refreshAnimatedCatalogue(),
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.backgroundColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // New Releases 2024-2025
                    if (movieProvider.newReleasesAnimated.isNotEmpty) ...[
                      _buildSectionHeader(
                          'New Releases 2024-2025', 'new-releases-animated'),
                      MovieList(
                        media:
                            movieProvider.newReleasesAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.newReleasesAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.newReleasesAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Trending Now
                    if (movieProvider.trendingAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Trending Now', 'trending-animated'),
                      MovieList(
                        media: movieProvider.trendingAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.trendingAnimatedError != null)
                        _buildErrorWidget(movieProvider.trendingAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Award Winners
                    if (movieProvider.awardWinnersAnimated.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Award Winners', 'award-winners-animated'),
                      MovieList(
                        media:
                            movieProvider.awardWinnersAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.awardWinnersAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.awardWinnersAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Top Rated Animated Movies
                    if (movieProvider.topRatedAnimated.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Top Rated Animated Movies', 'top-rated-animated'),
                      MovieList(
                        media: movieProvider.topRatedAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.topRatedAnimatedError != null)
                        _buildErrorWidget(movieProvider.topRatedAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Pixar Animation Studios
                    if (movieProvider.pixarAnimated.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Pixar Animation Studios', 'pixar-animated'),
                      MovieList(
                        media: movieProvider.pixarAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.pixarAnimatedError != null)
                        _buildErrorWidget(movieProvider.pixarAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Studio Ghibli
                    if (movieProvider.ghibliAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Studio Ghibli', 'ghibli-animated'),
                      MovieList(
                        media: movieProvider.ghibliAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.ghibliAnimatedError != null)
                        _buildErrorWidget(movieProvider.ghibliAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Disney Animated
                    if (movieProvider.disneyAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Disney Classics', 'disney-animated'),
                      MovieList(
                        media: movieProvider.disneyAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.disneyAnimatedError != null)
                        _buildErrorWidget(movieProvider.disneyAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Dreamworks Animated
                    if (movieProvider.dreamworksAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Dreamworks', 'dreamworks-animated'),
                      MovieList(
                        media:
                            movieProvider.dreamworksAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.dreamworksAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.dreamworksAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Illumination Animated
                    if (movieProvider.illuminationAnimated.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Illumination', 'illumination-animated'),
                      MovieList(
                        media:
                            movieProvider.illuminationAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.illuminationAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.illuminationAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Family Entertainment
                    if (movieProvider.familyAnimated.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Family Entertainment', 'family-animated'),
                      MovieList(
                        media: movieProvider.familyAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.familyAnimatedError != null)
                        _buildErrorWidget(movieProvider.familyAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Comedy Animated
                    if (movieProvider.comedyAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Comedy', 'comedy-animated'),
                      MovieList(
                        media: movieProvider.comedyAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.comedyAnimatedError != null)
                        _buildErrorWidget(movieProvider.comedyAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Adventure Animated
                    if (movieProvider.adventureAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Adventure', 'adventure-animated'),
                      MovieList(
                        media: movieProvider.adventureAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.adventureAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.adventureAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Fantasy Animated
                    if (movieProvider.fantasyAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Fantasy', 'fantasy-animated'),
                      MovieList(
                        media: movieProvider.fantasyAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.fantasyAnimatedError != null)
                        _buildErrorWidget(movieProvider.fantasyAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Superhero Animated
                    if (movieProvider.superheroAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Superhero', 'superhero-animated'),
                      MovieList(
                        media: movieProvider.superheroAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.superheroAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.superheroAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Musical Animated
                    if (movieProvider.musicalAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Musical', 'musical-animated'),
                      MovieList(
                        media: movieProvider.musicalAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.musicalAnimatedError != null)
                        _buildErrorWidget(movieProvider.musicalAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Classics
                    if (movieProvider.classicAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Classics', 'classic-animated'),
                      MovieList(
                        media: movieProvider.classicAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.classicAnimatedError != null)
                        _buildErrorWidget(movieProvider.classicAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Recent & Upcoming
                    if (movieProvider.recentUpcomingAnimated.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Recent & Upcoming', 'recent-animated'),
                      MovieList(
                        media: movieProvider.recentUpcomingAnimated
                            .take(6)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.recentUpcomingAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.recentUpcomingAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Upcoming
                    if (movieProvider.upcomingAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Upcoming', 'upcoming-animated'),
                      MovieList(
                        media: movieProvider.upcomingAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.upcomingAnimatedError != null)
                        _buildErrorWidget(movieProvider.upcomingAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Critically Acclaimed
                    if (movieProvider
                        .criticallyAcclaimedAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Critically Acclaimed',
                          'critically-acclaimed-animated'),
                      MovieList(
                        media: movieProvider.criticallyAcclaimedAnimated
                            .take(6)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.criticallyAcclaimedAnimatedError !=
                          null)
                        _buildErrorWidget(
                            movieProvider.criticallyAcclaimedAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Indie Animated
                    if (movieProvider.indieAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Indie', 'indie-animated'),
                      MovieList(
                        media: movieProvider.indieAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.indieAnimatedError != null)
                        _buildErrorWidget(movieProvider.indieAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Foreign Animated
                    if (movieProvider.foreignAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Foreign', 'foreign-animated'),
                      MovieList(
                        media: movieProvider.foreignAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.foreignAnimatedError != null)
                        _buildErrorWidget(movieProvider.foreignAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Teen Animated
                    if (movieProvider.teenAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Teen', 'teen-animated'),
                      MovieList(
                        media: movieProvider.teenAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.teenAnimatedError != null)
                        _buildErrorWidget(movieProvider.teenAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Kids Animated
                    if (movieProvider.kidsAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Kids', 'kids-animated'),
                      MovieList(
                        media: movieProvider.kidsAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.kidsAnimatedError != null)
                        _buildErrorWidget(movieProvider.kidsAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Stop Motion
                    if (movieProvider.stopMotionAnimated.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Stop Motion', 'stop-motion-animated'),
                      MovieList(
                        media:
                            movieProvider.stopMotionAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.stopMotionAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.stopMotionAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Computer Generated
                    if (movieProvider.computerGeneratedAnimated.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Computer Generated', 'computer-generated-animated'),
                      MovieList(
                        media: movieProvider.computerGeneratedAnimated
                            .take(6)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.computerGeneratedAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.computerGeneratedAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Hand Drawn
                    if (movieProvider.handDrawnAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Hand Drawn', 'hand-drawn-animated'),
                      MovieList(
                        media: movieProvider.handDrawnAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.handDrawnAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.handDrawnAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Anime
                    if (movieProvider.animeAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Anime', 'anime-animated'),
                      MovieList(
                        media: movieProvider.animeAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.animeAnimatedError != null)
                        _buildErrorWidget(movieProvider.animeAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // European Animated
                    if (movieProvider.europeanAnimated.isNotEmpty) ...[
                      _buildSectionHeader('European', 'european-animated'),
                      MovieList(
                        media: movieProvider.europeanAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.europeanAnimatedError != null)
                        _buildErrorWidget(movieProvider.europeanAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Manga
                    if (movieProvider.mangaAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Manga', 'manga-animated'),
                      MovieList(
                        media: movieProvider.mangaAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.mangaAnimatedError != null)
                        _buildErrorWidget(movieProvider.mangaAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Popular Animated TV Shows
                    if (movieProvider.popularAnimatedTv.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Popular Animated TV Shows', 'popular-animated-tv'),
                      MovieList(
                        media: movieProvider.popularAnimatedTv.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.popularAnimatedTvError != null)
                        _buildErrorWidget(
                            movieProvider.popularAnimatedTvError!),
                      const SizedBox(height: 24),
                    ],

                    // Cartoon Network
                    if (movieProvider.cartoonNetworkAnimated.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Cartoon Network', 'cartoon-network-animated'),
                      MovieList(
                        media: movieProvider.cartoonNetworkAnimated
                            .take(6)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.cartoonNetworkAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.cartoonNetworkAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Nickelodeon
                    if (movieProvider.nickelodeonAnimated.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Nickelodeon', 'nickelodeon-animated'),
                      MovieList(
                        media:
                            movieProvider.nickelodeonAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.nickelodeonAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.nickelodeonAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Disney Channel
                    if (movieProvider.disneyChannelAnimated.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Disney Channel', 'disney-channel-animated'),
                      MovieList(
                        media: movieProvider.disneyChannelAnimated
                            .take(6)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.disneyChannelAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.disneyChannelAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Netflix Animated
                    if (movieProvider.netflixAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Netflix', 'netflix-animated'),
                      MovieList(
                        media: movieProvider.netflixAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.netflixAnimatedError != null)
                        _buildErrorWidget(movieProvider.netflixAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Prime Animated
                    if (movieProvider.primeAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Prime', 'prime-animated'),
                      MovieList(
                        media: movieProvider.primeAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.primeAnimatedError != null)
                        _buildErrorWidget(movieProvider.primeAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Hulu Animated
                    if (movieProvider.huluAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Hulu', 'hulu-animated'),
                      MovieList(
                        media: movieProvider.huluAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.huluAnimatedError != null)
                        _buildErrorWidget(movieProvider.huluAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // HBO Animated
                    if (movieProvider.hboAnimated.isNotEmpty) ...[
                      _buildSectionHeader('HBO', 'hbo-animated'),
                      MovieList(
                        media: movieProvider.hboAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.hboAnimatedError != null)
                        _buildErrorWidget(movieProvider.hboAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Apple Animated
                    if (movieProvider.appleAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Apple TV+', 'apple-animated'),
                      MovieList(
                        media: movieProvider.appleAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.appleAnimatedError != null)
                        _buildErrorWidget(movieProvider.appleAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Peacock Animated
                    if (movieProvider.peacockAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Peacock', 'peacock-animated'),
                      MovieList(
                        media: movieProvider.peacockAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.peacockAnimatedError != null)
                        _buildErrorWidget(movieProvider.peacockAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Paramount Plus Animated
                    if (movieProvider.paramountPlusAnimated.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Paramount Plus', 'paramount-plus-animated'),
                      MovieList(
                        media: movieProvider.paramountPlusAnimated
                            .take(6)
                            .toList(),
                        title: null,
                      ),
                      if (movieProvider.paramountPlusAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.paramountPlusAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Disney Plus Animated
                    if (movieProvider.disneyPlusAnimated.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Disney Plus', 'disney-plus-animated'),
                      MovieList(
                        media:
                            movieProvider.disneyPlusAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.disneyPlusAnimatedError != null)
                        _buildErrorWidget(
                            movieProvider.disneyPlusAnimatedError!),
                      const SizedBox(height: 24),
                    ],

                    // Max Animated
                    if (movieProvider.maxAnimated.isNotEmpty) ...[
                      _buildSectionHeader('Max', 'max-animated'),
                      MovieList(
                        media: movieProvider.maxAnimated.take(6).toList(),
                        title: null,
                      ),
                      if (movieProvider.maxAnimatedError != null)
                        _buildErrorWidget(movieProvider.maxAnimatedError!),
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
                    'with_genres': '16', // Animation
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
              'Loading Animated',
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discovering the best of animation',
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
