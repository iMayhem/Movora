import 'package:flutter/material.dart';
import 'package:movora/widgets/infinite_scroll_list.dart';
import 'package:movora/services/tmdb_service.dart';
import 'package:movora/models/media.dart';
import 'package:movora/theme/app_theme.dart';

class AnimatedScreen extends StatelessWidget {
  const AnimatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: const Text(
          'Animated',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryColor,
              tabs: [
                Tab(text: 'Movies'),
                Tab(text: 'Series'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  InfiniteScrollList(
                    title: 'Movies',
                    categoryType: 'animated-movies',
                    fetchFunction: _fetchAnimatedMovies,
                  ),
                  InfiniteScrollList(
                    title: 'Series',
                    categoryType: 'animated-series',
                    fetchFunction: _fetchAnimatedSeries,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Media>> _fetchAnimatedMovies(int page) async {
    return await TMDBService.getPopularAnimatedMovies(page: page);
  }

  Future<List<Media>> _fetchAnimatedSeries(int page) async {
    return await TMDBService.getPopularAnimatedTvShows(page: page);
  }
}
