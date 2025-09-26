import 'package:flutter/material.dart';
import 'package:movora/widgets/infinite_scroll_list.dart';
import 'package:movora/services/tmdb_service.dart';
import 'package:movora/models/media.dart';
import 'package:movora/widgets/app_drawer.dart';
import 'package:movora/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Hollywood',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimaryColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
        ],
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
                    categoryType: 'hollywood-movies',
                    fetchFunction: _fetchHollywoodMovies,
                  ),
                  InfiniteScrollList(
                    title: 'Series',
                    categoryType: 'hollywood-series',
                    fetchFunction: _fetchHollywoodSeries,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Media>> _fetchHollywoodMovies(int page) async {
    return await TMDBService.getPopularMovies(page: page);
  }

  Future<List<Media>> _fetchHollywoodSeries(int page) async {
    return await TMDBService.getPopularTvShows(page: page);
  }
}
