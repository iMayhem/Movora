import 'package:flutter/material.dart';
import 'package:movora/models/media.dart';
import 'package:movora/services/tmdb_service.dart';
import 'package:movora/widgets/infinite_scroll_list.dart';

class CategoryScreen extends StatelessWidget {
  final String title;
  final String categoryType;
  final Map<String, String> apiParams;

  const CategoryScreen({
    super.key,
    required this.title,
    required this.categoryType,
    required this.apiParams,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: InfiniteScrollList(
        title: title,
        categoryType: categoryType,
        fetchFunction: _fetchMedia,
      ),
    );
  }

  Future<List<Media>> _fetchMedia(int page) async {
    switch (categoryType) {
      case 'trending':
        return await TMDBService.getTrendingMedia(page: page);
      case 'animated-popular':
        return await TMDBService.getPopularAnimated(page: page);
      case 'prime-popular':
        return await TMDBService.getPopularPrime(page: page);
      case 'netflix-popular':
        return await TMDBService.getPopularNetflix(page: page);
      case 'korean-popular':
        return await TMDBService.getPopularKorean(page: page);
      case 'bollywood-popular':
        return await TMDBService.getPopularBollywood(page: page);
      case 'movies':
        return await TMDBService.getPopularMovies(page: page);
      case 'series':
        return await TMDBService.getPopularTvShows(page: page);
      default:
        return await TMDBService.getTrendingMedia(page: page);
    }
  }
}
