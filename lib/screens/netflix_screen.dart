import 'package:flutter/material.dart';
import 'package:movora/widgets/infinite_scroll_list.dart';
import 'package:movora/services/tmdb_service.dart';
import 'package:movora/models/media.dart';
import 'package:movora/theme/app_theme.dart';

class NetflixScreen extends StatelessWidget {
  const NetflixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: const Text(
          'Netflix',
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
                    categoryType: 'netflix-movies',
                    fetchFunction: _fetchNetflixMovies,
                  ),
                  InfiniteScrollList(
                    title: 'Series',
                    categoryType: 'netflix-series',
                    fetchFunction: _fetchNetflixSeries,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Media>> _fetchNetflixMovies(int page) async {
    return await TMDBService.getPopularNetflixMovies(page: page);
  }

  Future<List<Media>> _fetchNetflixSeries(int page) async {
    return await TMDBService.getPopularNetflixTvShows(page: page);
  }
}
