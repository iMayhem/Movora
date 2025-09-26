import 'package:flutter/material.dart';
import 'package:movora/widgets/infinite_scroll_list.dart';
import 'package:movora/services/tmdb_service.dart';
import 'package:movora/models/media.dart';
import 'package:movora/theme/app_theme.dart';

class KoreanScreen extends StatelessWidget {
  const KoreanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: const Text(
          'Korean',
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
                    categoryType: 'korean-movies',
                    fetchFunction: _fetchKoreanMovies,
                  ),
                  InfiniteScrollList(
                    title: 'Series',
                    categoryType: 'korean-series',
                    fetchFunction: _fetchKoreanSeries,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Media>> _fetchKoreanMovies(int page) async {
    return await TMDBService.getPopularKoreanMovies(page: page);
  }

  Future<List<Media>> _fetchKoreanSeries(int page) async {
    return await TMDBService.getPopularKoreanTvShows(page: page);
  }
}
