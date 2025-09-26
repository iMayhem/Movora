import 'package:flutter/material.dart';
import 'package:movora/widgets/infinite_scroll_list.dart';
import 'package:movora/services/tmdb_service.dart';
import 'package:movora/models/media.dart';
import 'package:movora/theme/app_theme.dart';

class PrimeScreen extends StatelessWidget {
  const PrimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: const Text(
          'Prime',
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
                    categoryType: 'prime-movies',
                    fetchFunction: _fetchPrimeMovies,
                  ),
                  InfiniteScrollList(
                    title: 'Series',
                    categoryType: 'prime-series',
                    fetchFunction: _fetchPrimeSeries,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Media>> _fetchPrimeMovies(int page) async {
    return await TMDBService.getPopularPrimeMovies(page: page);
  }

  Future<List<Media>> _fetchPrimeSeries(int page) async {
    return await TMDBService.getPopularPrimeTvShows(page: page);
  }
}
