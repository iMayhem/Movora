import 'package:flutter/material.dart';
import 'package:movora/models/media.dart';
import 'package:movora/services/tmdb_service.dart';
import 'package:movora/widgets/movie_card.dart';
import 'package:movora/screens/detail_screen.dart';
import 'package:movora/theme/app_theme.dart';

class CategoryScreen extends StatefulWidget {
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
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Media> _media = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  String? _error;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    print('CategoryScreen: Loading data for category: ${widget.categoryType}');
    print('CategoryScreen: API params: ${widget.apiParams}');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Media> results = [];

      switch (widget.categoryType) {
        case 'trending':
          print('CategoryScreen: Loading trending movies...');
          results = await TMDBService.fetchCustomData('/trending/movie/week', {
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} trending movies');

          print('CategoryScreen: Loading trending TV shows...');
          final tvResults =
              await TMDBService.fetchCustomData('/trending/tv/week', {
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${tvResults.length} trending TV shows');
          results.addAll(tvResults);
          break;

        case 'movie':
          print('CategoryScreen: Loading now playing movies...');
          results = await TMDBService.fetchCustomData('/movie/now_playing', {
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} now playing movies');
          break;

        case 'tv':
          print('CategoryScreen: Loading popular TV shows...');
          results = await TMDBService.fetchCustomData('/tv/popular', {
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} popular TV shows');
          break;

        case 'popular':
          print('CategoryScreen: Loading popular movies...');
          results = await TMDBService.fetchCustomData('/movie/popular', {
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} popular movies');

          print('CategoryScreen: Loading popular TV shows...');
          final tvResults = await TMDBService.fetchCustomData('/tv/popular', {
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${tvResults.length} popular TV shows');
          results.addAll(tvResults);
          break;

        case 'top-rated-movies':
          print('CategoryScreen: Loading top rated movies...');
          results = await TMDBService.fetchCustomData('/movie/top_rated', {
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} top rated movies');
          break;

        case 'top-rated-tv':
          print('CategoryScreen: Loading top rated TV shows...');
          results = await TMDBService.fetchCustomData('/tv/top_rated', {
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} top rated TV shows');
          break;

        case 'action-adventure':
          print('CategoryScreen: Loading action adventure movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '28,12',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} action adventure movies');
          break;

        case 'comedy':
          print('CategoryScreen: Loading comedy movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '35',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} comedy movies');
          break;

        case 'scifi-fantasy':
          print('CategoryScreen: Loading sci-fi fantasy movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '878,14',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} sci-fi fantasy movies');
          break;

        case 'horror':
          print('CategoryScreen: Loading horror movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '27',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} horror movies');
          break;

        case 'thriller':
          print('CategoryScreen: Loading thriller movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '53',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} thriller movies');
          break;

        case 'drama':
          print('CategoryScreen: Loading drama movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '18',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} drama movies');
          break;

        case 'romance':
          print('CategoryScreen: Loading romance movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10749',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} romance movies');
          break;

        case 'animation':
          print('CategoryScreen: Loading animation movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} animation movies');
          break;

        case 'family':
          print('CategoryScreen: Loading family movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10751',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} family movies');
          break;

        case 'documentary':
          print('CategoryScreen: Loading documentary movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '99',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} documentary movies');
          break;

        case 'crime':
          print('CategoryScreen: Loading crime movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '80',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} crime movies');
          break;

        case 'mystery':
          print('CategoryScreen: Loading mystery movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '9648',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} mystery movies');
          break;

        case 'war':
          print('CategoryScreen: Loading war movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10752',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} war movies');
          break;

        case 'western':
          print('CategoryScreen: Loading western movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '37',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} western movies');
          break;

        case 'music':
          print('CategoryScreen: Loading music movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '13',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} music movies');
          break;

        case 'history':
          print('CategoryScreen: Loading history movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '36',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} history movies');
          break;

        case 'upcoming':
          print('CategoryScreen: Loading upcoming movies...');
          results = await TMDBService.fetchCustomData('/movie/upcoming', {
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} upcoming movies');
          break;

        case 'award-winners':
          print('CategoryScreen: Loading award winners...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'vote_average.gte': '8.0',
            'vote_count.gte': '1000',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} award winners');
          break;

        case 'indie':
          print('CategoryScreen: Loading indie films...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '210024',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} indie films');
          break;

        case 'foreign':
          print('CategoryScreen: Loading foreign films...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': '!en',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} foreign films');
          break;

        case 'classics':
          print('CategoryScreen: Loading classic movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'primary_release_date.lte': '1980-12-31',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} classic movies');
          break;

        case 'teen':
          print('CategoryScreen: Loading teen movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '210024',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} teen movies');
          break;

        // New Hollywood category types
        case 'superhero':
          print('CategoryScreen: Loading superhero movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '180547', // Superhero keyword
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} superhero movies');
          break;

        case 'musical':
          print('CategoryScreen: Loading musical movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10402',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} musical movies');
          break;

        case 'sports':
          print('CategoryScreen: Loading sports movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '180547', // Sports keyword
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} sports movies');
          break;

        case 'biographical':
          print('CategoryScreen: Loading biographical movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '968', // Biography keyword
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} biographical movies');
          break;

        case 'spy-thrillers':
          print('CategoryScreen: Loading spy thrillers...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '180547', // Spy keyword
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} spy thrillers');
          break;

        // New category types for Indian Cartoons
        case 'indian-cartoons-cn':
        case 'indian-cartoons-pogo':
        case 'indian-cartoons-nick':
        case 'indian-cartoons-disney':
        case 'indian-cartoons-hungama':
        case 'indian-cartoons-disney-xd':
        case 'indian-cartoons-other':
          print('CategoryScreen: Loading Indian cartoons...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} Indian cartoons');
          break;

        // New category types for Adventure
        case 'survival-docs':
        case 'explorer-docs':
        case 'wildlife-docs':
        case 'competition-docs':
        case 'expedition-docs':
          print('CategoryScreen: Loading adventure content...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_genres': '99,12',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} adventure content');
          break;

        // New category types for other sections
        case 'latest-bollywood':
        case 'classics-bollywood':
        case 'netflix-bollywood':
        case 'prime-bollywood':
        case 'action-bollywood':
        case 'romance-bollywood':
        case 'thriller-bollywood':
          print('CategoryScreen: Loading Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '28,35,53',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} Bollywood content');
          break;

        // Korean categories - each with specific content focus
        case 'featured-korean':
          print('CategoryScreen: Loading featured Korean content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'latest-korean':
          print('CategoryScreen: Loading latest Korean releases...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'sort_by': 'primary_release_date.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'top-rated-korean':
          print('CategoryScreen: Loading top rated Korean movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'vote_average.gte': '7.5',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'action-korean':
          print('CategoryScreen: Loading Korean action movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'with_genres': '28',
            'page': _currentPage.toString(),
          });
          break;

        case 'thriller-korean':
          print('CategoryScreen: Loading Korean thriller movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'with_genres': '53',
            'page': _currentPage.toString(),
          });
          break;

        case 'popular-korean-tv':
          print('CategoryScreen: Loading popular Korean TV shows...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_original_language': 'ko',
            'region': 'KR',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'top-rated-korean-tv':
          print('CategoryScreen: Loading top rated Korean TV shows...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_original_language': 'ko',
            'region': 'KR',
            'vote_average.gte': '7.5',
            'vote_count.gte': '200',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'new-releases-korean':
          print('CategoryScreen: Loading new Korean releases...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'sort_by': 'primary_release_date.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'blockbuster-hits-korean':
          print('CategoryScreen: Loading Korean blockbuster hits...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'vote_count.gte': '1000',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'critically-acclaimed-korean':
          print(
              'CategoryScreen: Loading critically acclaimed Korean movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'vote_average.gte': '8.0',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'family-entertainment-korean':
          print('CategoryScreen: Loading Korean family entertainment...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'with_genres': '10751',
            'page': _currentPage.toString(),
          });
          break;

        case 'comedy-gold-korean':
          print('CategoryScreen: Loading Korean comedy movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'with_genres': '35',
            'page': _currentPage.toString(),
          });
          break;

        case 'romantic-dramas-korean':
          print('CategoryScreen: Loading Korean romantic dramas...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'with_genres': '10749,18',
            'page': _currentPage.toString(),
          });
          break;

        case 'mystery-crime-korean':
          print('CategoryScreen: Loading Korean mystery and crime movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'with_genres': '80,9648',
            'page': _currentPage.toString(),
          });
          break;

        case 'biographical-korean':
          print('CategoryScreen: Loading Korean biographical movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'with_keywords': '968',
            'page': _currentPage.toString(),
          });
          break;

        case 'web-series-korean':
          print('CategoryScreen: Loading Korean web series...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_original_language': 'ko',
            'region': 'KR',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'upcoming-korean':
          print('CategoryScreen: Loading upcoming Korean movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'sort_by': 'primary_release_date.asc',
            'page': _currentPage.toString(),
          });
          break;

        case 'award-winners-korean':
          print('CategoryScreen: Loading award-winning Korean movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'vote_average.gte': '8.5',
            'vote_count.gte': '1000',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'korean-classics':
          print('CategoryScreen: Loading Korean classic movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'primary_release_date.lte': '2010-12-31',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        // Netflix categories - each with specific content focus
        case 'top-rated-netflix':
          print('CategoryScreen: Loading top rated Netflix content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'vote_average.gte': '7.5',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'action-netflix':
          print('CategoryScreen: Loading Netflix action content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '28',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'comedy-netflix':
          print('CategoryScreen: Loading Netflix comedy content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '35',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'drama-netflix':
          print('CategoryScreen: Loading Netflix drama content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '18',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'thriller-netflix':
          print('CategoryScreen: Loading Netflix thriller content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '53',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'horror-netflix':
          print('CategoryScreen: Loading Netflix horror content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '27',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'scifi-netflix':
          print('CategoryScreen: Loading Netflix sci-fi content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '878',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'new-releases-netflix':
          print('CategoryScreen: Loading Netflix new releases...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'sort_by': 'primary_release_date.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'trending-netflix':
          print('CategoryScreen: Loading Netflix trending content...');
          results = await TMDBService.fetchCustomData('/trending/movie/week', {
            'page': _currentPage.toString(),
          });
          break;

        case 'award-winners-netflix':
          print('CategoryScreen: Loading Netflix award winners...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'vote_average.gte': '8.0',
            'vote_count.gte': '1000',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'family-content-netflix':
          print('CategoryScreen: Loading Netflix family content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10751',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'romance-netflix':
          print('CategoryScreen: Loading Netflix romance content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10749',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'mystery-netflix':
          print('CategoryScreen: Loading Netflix mystery content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '9648',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'crime-netflix':
          print('CategoryScreen: Loading Netflix crime content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '80',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'animation-netflix':
          print('CategoryScreen: Loading Netflix animation content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'documentary-netflix':
          print('CategoryScreen: Loading Netflix documentary content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '99',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'international-netflix':
          print('CategoryScreen: Loading Netflix international content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': '!en',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'classic-netflix':
          print('CategoryScreen: Loading Netflix classic content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'primary_release_date.lte': '1980-12-31',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'upcoming-netflix':
          print('CategoryScreen: Loading Netflix upcoming content...');
          results = await TMDBService.fetchCustomData('/movie/upcoming', {
            'page': _currentPage.toString(),
          });
          break;

        case 'critically-acclaimed-netflix':
          print(
              'CategoryScreen: Loading Netflix critically acclaimed content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'vote_average.gte': '8.5',
            'vote_count.gte': '1000',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        // Prime categories - each with specific content focus
        case 'top-rated-prime':
          print('CategoryScreen: Loading top rated Prime content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'vote_average.gte': '7.5',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'action-prime':
          print('CategoryScreen: Loading Prime action content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '28',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'comedy-prime':
          print('CategoryScreen: Loading Prime comedy content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '35',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'drama-prime':
          print('CategoryScreen: Loading Prime drama content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '18',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'thriller-prime':
          print('CategoryScreen: Loading Prime thriller content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '53',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'scifi-prime':
          print('CategoryScreen: Loading Prime sci-fi content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '878',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'romance-prime':
          print('CategoryScreen: Loading Prime romance content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10749',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        // Animated categories - each with specific content focus
        case 'top-rated-animated':
          print('CategoryScreen: Loading top rated animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'vote_average.gte': '7.5',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'pixar-animation':
          print('CategoryScreen: Loading Pixar animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_companies': '3', // Pixar company ID
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'studio-ghibli':
          print('CategoryScreen: Loading Studio Ghibli animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_companies': '10342', // Studio Ghibli company ID
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'recent-animated':
          print('CategoryScreen: Loading recent animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'sort_by': 'primary_release_date.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'popular-animated-tv':
          print('CategoryScreen: Loading popular animated TV shows...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_genres': '16',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'top-rated-documentaries':
        case 'recent-documentaries':
        case 'biographical-docs':
        case 'netflix-docs':
        case 'prime-docs':
        case 'popular-docuseries':
          print('CategoryScreen: Loading documentary content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '99',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} documentary content');
          break;

        // Bollywood categories
        case 'new-releases-bollywood':
          print('CategoryScreen: Loading new releases Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'primary_release_date.gte': '2024-01-01',
            'sort_by': 'primary_release_date.desc',
            'vote_average.gte': '6.0',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} new releases Bollywood content');
          break;

        case 'blockbuster-hits-bollywood':
          print(
              'CategoryScreen: Loading blockbuster hits Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'vote_average.gte': '7.0',
            'vote_count.gte': '100',
            'sort_by': 'revenue.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} blockbuster hits Bollywood content');
          break;

        case 'critically-acclaimed-bollywood':
          print(
              'CategoryScreen: Loading critically acclaimed Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'vote_average.gte': '7.5',
            'vote_count.gte': '200',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} critically acclaimed Bollywood content');
          break;

        case 'family-entertainment-bollywood':
          print(
              'CategoryScreen: Loading family entertainment Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '10751',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} family entertainment Bollywood content');
          break;

        case 'comedy-gold-bollywood':
          print('CategoryScreen: Loading comedy gold Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '35',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} comedy gold Bollywood content');
          break;

        case 'romantic-dramas-bollywood':
          print('CategoryScreen: Loading romantic dramas Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '10749',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} romantic dramas Bollywood content');
          break;

        case 'mystery-crime-bollywood':
          print('CategoryScreen: Loading mystery crime Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '80,9648',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} mystery crime Bollywood content');
          break;

        case 'biographical-bollywood':
          print('CategoryScreen: Loading biographical Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '36',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} biographical Bollywood content');
          break;

        case 'web-series-bollywood':
          print('CategoryScreen: Loading web series Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_original_language': 'hi',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} web series Bollywood content');
          break;

        case 'upcoming-bollywood':
          print('CategoryScreen: Loading upcoming Bollywood content...');
          results = await TMDBService.fetchCustomData('/movie/upcoming', {
            'with_original_language': 'hi',
            'region': 'IN',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} upcoming Bollywood content');
          break;

        case 'award-winners-bollywood':
          print('CategoryScreen: Loading award winners Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'vote_average.gte': '7.5',
            'vote_count.gte': '300',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} award winners Bollywood content');
          break;

        case 'bollywood-classics':
          print('CategoryScreen: Loading Bollywood classics content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'primary_release_date.lte': '2000-12-31',
            'vote_average.gte': '7.0',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} Bollywood classics content');
          break;

        case 'masala-bollywood':
          print('CategoryScreen: Loading masala Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '28,35,10749',
            'vote_average.gte': '6.0',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} masala Bollywood content');
          break;

        case 'tv-shows-hindi':
          print('CategoryScreen: Loading Hindi TV shows content...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_original_language': 'hi',
            'vote_average.gte': '6.0',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} Hindi TV shows content');
          break;

        case 'regional-cinema-bollywood':
          print('CategoryScreen: Loading regional cinema Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '18',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} regional cinema Bollywood content');
          break;

        case 'indie-bollywood':
          print('CategoryScreen: Loading indie Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'vote_average.gte': '6.5',
            'vote_count.gte': '50',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} indie Bollywood content');
          break;

        case 'period-dramas-bollywood':
          print('CategoryScreen: Loading period dramas Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '18,36',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} period dramas Bollywood content');
          break;

        case 'action-thrillers-bollywood':
          print(
              'CategoryScreen: Loading action thrillers Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '28,53',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} action thrillers Bollywood content');
          break;

        case 'musical-bollywood':
          print('CategoryScreen: Loading musical Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '10402',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} musical Bollywood content');
          break;

        case 'social-dramas-bollywood':
          print('CategoryScreen: Loading social dramas Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '18',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} social dramas Bollywood content');
          break;

        case 'latest-bollywood':
          print('CategoryScreen: Loading latest Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'sort_by': 'primary_release_date.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} latest Bollywood content');
          break;

        case 'classics-bollywood':
          print('CategoryScreen: Loading classics Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'primary_release_date.lte': '2000-12-31',
            'vote_average.gte': '7.0',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} classics Bollywood content');
          break;

        case 'netflix-bollywood':
          print('CategoryScreen: Loading Netflix Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} Netflix Bollywood content');
          break;

        case 'prime-bollywood':
          print('CategoryScreen: Loading Prime Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} Prime Bollywood content');
          break;

        case 'action-bollywood':
          print('CategoryScreen: Loading action Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '28',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} action Bollywood content');
          break;

        case 'romance-bollywood':
          print('CategoryScreen: Loading romance Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '10749',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} romance Bollywood content');
          break;

        case 'thriller-bollywood':
          print('CategoryScreen: Loading thriller Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '53',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} thriller Bollywood content');
          break;

        case 'comedy-dramas-bollywood':
          print('CategoryScreen: Loading comedy dramas Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '35,18',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} comedy dramas Bollywood content');
          break;

        case 'action-comedies-bollywood':
          print('CategoryScreen: Loading action comedies Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '28,35',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} action comedies Bollywood content');
          break;

        case 'patriotic-bollywood':
          print('CategoryScreen: Loading patriotic Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '18,36',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} patriotic Bollywood content');
          break;

        case 'reality-shows-hindi':
          print('CategoryScreen: Loading Hindi reality shows content...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_original_language': 'hi',
            'with_genres': '10764',
            'vote_average.gte': '6.0',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          print(
              'CategoryScreen: Loaded ${results.length} Hindi reality shows content');
          break;

        // Hollywood categories (for when users click More from Hollywood sections)
        case 'trending-hollywood':
        case 'new-releases-hollywood':
        case 'blockbuster-hits-hollywood':
        case 'critically-acclaimed-hollywood':
        case 'action-adventure-hollywood':
        case 'comedy-hollywood':
        case 'drama-hollywood':
        case 'thriller-hollywood':
        case 'scifi-fantasy-hollywood':
        case 'horror-hollywood':
        case 'romance-hollywood':
        case 'animation-hollywood':
        case 'family-hollywood':
        case 'documentary-hollywood':
        case 'crime-hollywood':
        case 'mystery-hollywood':
        case 'war-hollywood':
        case 'western-hollywood':
        case 'music-hollywood':
        case 'history-hollywood':
        case 'upcoming-hollywood':
        case 'award-winners-hollywood':
        case 'indie-hollywood':
        case 'foreign-hollywood':
        case 'classics-hollywood':
        case 'teen-hollywood':
        case 'superhero-hollywood':
        case 'musical-hollywood':
        case 'sports-hollywood':
        case 'biographical-hollywood':
        case 'spy-thrillers-hollywood':
          print('CategoryScreen: Loading Hollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'en',
            'region': 'US',
            'page': _currentPage.toString(),
          });
          print('CategoryScreen: Loaded ${results.length} Hollywood content');
          break;

        // Generic categories that should load content specific to their category
        case 'trending':
          print('CategoryScreen: Loading trending content...');
          results = await TMDBService.fetchCustomData('/trending/movie/week', {
            'page': _currentPage.toString(),
          });
          final tvResults =
              await TMDBService.fetchCustomData('/trending/tv/week', {
            'page': _currentPage.toString(),
          });
          results.addAll(tvResults);
          break;

        case 'movie':
          print('CategoryScreen: Loading now playing movies...');
          results = await TMDBService.fetchCustomData('/movie/now_playing', {
            'page': _currentPage.toString(),
          });
          break;

        case 'popular':
          print('CategoryScreen: Loading popular content...');
          results = await TMDBService.fetchCustomData('/movie/popular', {
            'page': _currentPage.toString(),
          });
          final tvResults = await TMDBService.fetchCustomData('/tv/popular', {
            'page': _currentPage.toString(),
          });
          results.addAll(tvResults);
          break;

        case 'top-rated-movies':
          print('CategoryScreen: Loading top rated movies...');
          results = await TMDBService.fetchCustomData('/movie/top_rated', {
            'page': _currentPage.toString(),
          });
          break;

        case 'top-rated-tv':
          print('CategoryScreen: Loading top rated TV shows...');
          results = await TMDBService.fetchCustomData('/tv/top_rated', {
            'page': _currentPage.toString(),
          });
          break;

        case 'upcoming':
          print('CategoryScreen: Loading upcoming movies...');
          results = await TMDBService.fetchCustomData('/movie/upcoming', {
            'page': _currentPage.toString(),
          });
          break;

        case 'award-winners':
          print('CategoryScreen: Loading award winning movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'vote_average.gte': '8.0',
            'vote_count.gte': '1000',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'indie':
          print('CategoryScreen: Loading indie movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '210024',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'foreign':
          print('CategoryScreen: Loading foreign movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': '!en',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'classics':
          print('CategoryScreen: Loading classic movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'primary_release_date.lte': '1980-12-31',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'teen':
          print('CategoryScreen: Loading teen movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '210024',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'superhero':
          print('CategoryScreen: Loading superhero movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '180547',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'musical':
          print('CategoryScreen: Loading musical movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10402',
            'page': _currentPage.toString(),
          });
          break;

        case 'sports':
          print('CategoryScreen: Loading sports movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '180547',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'biographical':
          print('CategoryScreen: Loading biographical movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '968',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'spy-thrillers':
          print('CategoryScreen: Loading spy thrillers...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '180547',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        // Genre-based categories
        case 'action-adventure':
          print('CategoryScreen: Loading action adventure movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '28,12',
            'page': _currentPage.toString(),
          });
          break;

        case 'comedy':
          print('CategoryScreen: Loading comedy movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '35',
            'page': _currentPage.toString(),
          });
          break;

        case 'scifi-fantasy':
          print('CategoryScreen: Loading sci-fi fantasy movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '878,14',
            'page': _currentPage.toString(),
          });
          break;

        case 'horror':
          print('CategoryScreen: Loading horror movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '27',
            'page': _currentPage.toString(),
          });
          break;

        case 'thriller':
          print('CategoryScreen: Loading thriller movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '53',
            'page': _currentPage.toString(),
          });
          break;

        case 'drama':
          print('CategoryScreen: Loading drama movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '18',
            'page': _currentPage.toString(),
          });
          break;

        case 'romance':
          print('CategoryScreen: Loading romance movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10749',
            'page': _currentPage.toString(),
          });
          break;

        case 'animation':
          print('CategoryScreen: Loading animation movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'page': _currentPage.toString(),
          });
          break;

        case 'family':
          print('CategoryScreen: Loading family movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10751',
            'page': _currentPage.toString(),
          });
          break;

        case 'documentary':
          print('CategoryScreen: Loading documentary movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '99',
            'page': _currentPage.toString(),
          });
          break;

        case 'crime':
          print('CategoryScreen: Loading crime movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '80',
            'page': _currentPage.toString(),
          });
          break;

        case 'mystery':
          print('CategoryScreen: Loading mystery movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '878,14',
            'page': _currentPage.toString(),
          });
          break;

        case 'war':
          print('CategoryScreen: Loading war movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10752',
            'page': _currentPage.toString(),
          });
          break;

        case 'western':
          print('CategoryScreen: Loading western movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '37',
            'page': _currentPage.toString(),
          });
          break;

        case 'music':
          print('CategoryScreen: Loading music movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '13',
            'page': _currentPage.toString(),
          });
          break;

        case 'history':
          print('CategoryScreen: Loading history movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '36',
            'page': _currentPage.toString(),
          });
          break;

        default:
          print(
              'CategoryScreen: Using default case for category: ${widget.categoryType}');
          // Handle custom API parameters
          if (widget.apiParams.isNotEmpty) {
            if (widget.apiParams.containsKey('with_genres')) {
              print(
                  'CategoryScreen: Using discoverMoviesByGenre with genres: ${widget.apiParams['with_genres']}');
              results = await TMDBService.discoverMoviesByGenre(
                widget.apiParams['with_genres']!,
                pages: _currentPage,
              );
            } else {
              print('CategoryScreen: Using getPopular as fallback');
              results =
                  await TMDBService.getPopular('movie', pages: _currentPage);
            }
          } else {
            print('CategoryScreen: Using getPopular as final fallback');
            // Fallback to popular movies if no specific category type
            results =
                await TMDBService.getPopular('movie', pages: _currentPage);
          }
      }

      print('CategoryScreen: Total results loaded: ${results.length}');

      if (_currentPage == 1) {
        _media = results;
      } else {
        _media.addAll(results);
      }

      setState(() {
        _isLoading = false;
        // TMDB typically returns 20 results per page, so if we get less than 20, we've reached the end
        _hasMoreData = results.length >= 20;
      });

      print(
          'CategoryScreen: Data loaded successfully. Total media: ${_media.length}, Has more: $_hasMoreData');
    } catch (e) {
      print('CategoryScreen: Error loading category data: $e');
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMoreData) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _currentPage++;
      List<Media> results = [];

      switch (widget.categoryType) {
        case 'trending':
          results = await TMDBService.fetchCustomData('/trending/movie/week', {
            'page': _currentPage.toString(),
          });
          results
              .addAll(await TMDBService.fetchCustomData('/trending/tv/week', {
            'page': _currentPage.toString(),
          }));
          break;
        case 'movie':
          results = await TMDBService.fetchCustomData('/movie/now_playing', {
            'page': _currentPage.toString(),
          });
          break;
        case 'tv':
          results = await TMDBService.fetchCustomData('/tv/popular', {
            'page': _currentPage.toString(),
          });
          break;
        case 'popular':
          results = await TMDBService.fetchCustomData('/movie/popular', {
            'page': _currentPage.toString(),
          });
          results.addAll(await TMDBService.fetchCustomData('/tv/popular', {
            'page': _currentPage.toString(),
          }));
          break;
        case 'top-rated-movies':
          results = await TMDBService.fetchCustomData('/movie/top_rated', {
            'page': _currentPage.toString(),
          });
          break;
        case 'top-rated-tv':
          results = await TMDBService.fetchCustomData('/tv/top_rated', {
            'page': _currentPage.toString(),
          });
          break;
        case 'action-adventure':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '28,12',
            'page': _currentPage.toString(),
          });
          break;
        case 'comedy':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '35',
            'page': _currentPage.toString(),
          });
          break;
        case 'scifi-fantasy':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '878,14',
            'page': _currentPage.toString(),
          });
          break;
        case 'horror':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '27',
            'page': _currentPage.toString(),
          });
          break;
        case 'thriller':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '53',
            'page': _currentPage.toString(),
          });
          break;
        case 'drama':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '18',
            'page': _currentPage.toString(),
          });
          break;
        case 'romance':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10749',
            'page': _currentPage.toString(),
          });
          break;
        case 'animation':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'page': _currentPage.toString(),
          });
          break;
        case 'family':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10751',
            'page': _currentPage.toString(),
          });
          break;
        case 'documentary':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '99',
            'page': _currentPage.toString(),
          });
          break;
        case 'crime':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '80',
            'page': _currentPage.toString(),
          });
          break;
        case 'mystery':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '9648',
            'page': _currentPage.toString(),
          });
          break;
        case 'war':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10752',
            'page': _currentPage.toString(),
          });
          break;
        case 'western':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '37',
            'page': _currentPage.toString(),
          });
          break;
        case 'music':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '13',
            'page': _currentPage.toString(),
          });
          break;
        case 'history':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '36',
            'page': _currentPage.toString(),
          });
          break;
        case 'upcoming':
          results = await TMDBService.fetchCustomData('/movie/upcoming', {
            'page': _currentPage.toString(),
          });
          break;
        case 'award-winners':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'vote_average.gte': '8.0',
            'vote_count.gte': '1000',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;
        case 'indie':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '210024',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;
        case 'foreign':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': '!en',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;
        case 'classics':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'primary_release_date.lte': '1980-12-31',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;
        case 'teen':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '210024',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        // New Hollywood category types
        case 'superhero':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '180547', // Superhero keyword
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'musical':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10402',
            'page': _currentPage.toString(),
          });
          break;

        case 'sports':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '180547', // Sports keyword
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'biographical':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '968', // Biography keyword
            'page': _currentPage.toString(),
          });
          break;

        case 'spy-thrillers':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '180547', // Spy keyword
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        // New category types for Indian Cartoons
        case 'indian-cartoons-cn':
        case 'indian-cartoons-pogo':
        case 'indian-cartoons-nick':
        case 'indian-cartoons-disney':
        case 'indian-cartoons-hungama':
        case 'indian-cartoons-disney-xd':
        case 'indian-cartoons-other':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'page': _currentPage.toString(),
          });
          break;
        // New category types for Adventure
        case 'survival-docs':
        case 'explorer-docs':
        case 'wildlife-docs':
        case 'competition-docs':
        case 'expedition-docs':
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_genres': '99,12',
            'page': _currentPage.toString(),
          });
          break;
        // New category types for other sections
        case 'latest-bollywood':
        case 'classics-bollywood':
        case 'netflix-bollywood':
        case 'prime-bollywood':
        case 'action-bollywood':
        case 'romance-bollywood':
        case 'thriller-bollywood':
        case 'new-releases-bollywood':
        case 'blockbuster-hits-bollywood':
        case 'critically-acclaimed-bollywood':
        case 'family-entertainment-bollywood':
        case 'comedy-gold-bollywood':
        case 'action-thrillers-bollywood':
        case 'romantic-dramas-bollywood':
        case 'mystery-crime-bollywood':
        case 'biographical-bollywood':
        case 'web-series-bollywood':
        case 'upcoming-bollywood':
        case 'award-winners-bollywood':
        case 'masala-bollywood':
        case 'patriotic-bollywood':
        case 'social-dramas-bollywood':
        case 'comedy-dramas-bollywood':
        case 'action-comedies-bollywood':
        case 'tv-shows-hindi':
        case 'reality-shows-hindi':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'page': _currentPage.toString(),
          });
          break;
        // Korean categories for load more - each with specific content focus
        case 'featured-korean':
          print('CategoryScreen: Loading more featured Korean content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'latest-korean':
          print('CategoryScreen: Loading more latest Korean releases...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'sort_by': 'primary_release_date.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'top-rated-korean':
          print('CategoryScreen: Loading more top rated Korean movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'vote_average.gte': '7.5',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'action-korean':
          print('CategoryScreen: Loading more Korean action movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'with_genres': '28',
            'page': _currentPage.toString(),
          });
          break;

        case 'thriller-korean':
          print('CategoryScreen: Loading more Korean thriller movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'with_genres': '53',
            'page': _currentPage.toString(),
          });
          break;

        case 'popular-korean-tv':
          print('CategoryScreen: Loading more popular Korean TV shows...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_original_language': 'ko',
            'region': 'KR',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'top-rated-korean-tv':
          print('CategoryScreen: Loading more top rated Korean TV shows...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_original_language': 'ko',
            'region': 'KR',
            'vote_average.gte': '7.5',
            'vote_count.gte': '200',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'new-releases-korean':
          print('CategoryScreen: Loading more new Korean releases...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'sort_by': 'primary_release_date.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'blockbuster-hits-korean':
          print('CategoryScreen: Loading more Korean blockbuster hits...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'vote_count.gte': '1000',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'critically-acclaimed-korean':
          print(
              'CategoryScreen: Loading more critically acclaimed Korean movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'vote_average.gte': '8.0',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'family-entertainment-korean':
          print('CategoryScreen: Loading more Korean family entertainment...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'with_genres': '10751',
            'page': _currentPage.toString(),
          });
          break;

        case 'comedy-gold-korean':
          print('CategoryScreen: Loading more Korean comedy movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'with_genres': '35',
            'page': _currentPage.toString(),
          });
          break;

        case 'romantic-dramas-korean':
          print('CategoryScreen: Loading more Korean romantic dramas...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'with_genres': '10749,18',
            'page': _currentPage.toString(),
          });
          break;

        case 'mystery-crime-korean':
          print(
              'CategoryScreen: Loading more Korean mystery and crime movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'with_genres': '80,9648',
            'page': _currentPage.toString(),
          });
          break;

        case 'biographical-korean':
          print('CategoryScreen: Loading more Korean biographical movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'with_keywords': '968',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'web-series-korean':
          print('CategoryScreen: Loading more Korean web series...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_original_language': 'ko',
            'region': 'KR',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'upcoming-korean':
          print('CategoryScreen: Loading more upcoming Korean movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'sort_by': 'primary_release_date.asc',
            'page': _currentPage.toString(),
          });
          break;

        case 'award-winners-korean':
          print('CategoryScreen: Loading more award-winning Korean movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'vote_average.gte': '8.5',
            'vote_count.gte': '1000',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'korean-classics':
          print('CategoryScreen: Loading more Korean classic movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'ko',
            'region': 'KR',
            'primary_release_date.lte': '2010-12-31',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;
        // Netflix categories for load more - each with specific content focus
        case 'top-rated-netflix':
          print('CategoryScreen: Loading more top rated Netflix content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'vote_average.gte': '7.5',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'action-netflix':
          print('CategoryScreen: Loading more Netflix action content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '28',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'comedy-netflix':
          print('CategoryScreen: Loading more Netflix comedy content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '35',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'drama-netflix':
          print('CategoryScreen: Loading more Netflix drama content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '18',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'thriller-netflix':
          print('CategoryScreen: Loading more Netflix thriller content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '53',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'horror-netflix':
          print('CategoryScreen: Loading more Netflix horror content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '27',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'scifi-netflix':
          print('CategoryScreen: Loading more Netflix sci-fi content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '878',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'new-releases-netflix':
          print('CategoryScreen: Loading more Netflix new releases...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'sort_by': 'primary_release_date.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'trending-netflix':
          print('CategoryScreen: Loading more Netflix trending content...');
          results = await TMDBService.fetchCustomData('/trending/movie/week', {
            'page': _currentPage.toString(),
          });
          break;

        case 'award-winners-netflix':
          print('CategoryScreen: Loading more Netflix award winners...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'vote_average.gte': '8.0',
            'vote_count.gte': '1000',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'family-content-netflix':
          print('CategoryScreen: Loading more Netflix family content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10751',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'romance-netflix':
          print('CategoryScreen: Loading more Netflix romance content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10749',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'mystery-netflix':
          print('CategoryScreen: Loading more Netflix mystery content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '9648',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'crime-netflix':
          print('CategoryScreen: Loading more Netflix crime content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '80',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'animation-netflix':
          print('CategoryScreen: Loading more Netflix animation content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'documentary-netflix':
          print('CategoryScreen: Loading more Netflix documentary content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '99',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'international-netflix':
          print(
              'CategoryScreen: Loading more Netflix international content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': '!en',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'classic-netflix':
          print('CategoryScreen: Loading more Netflix classic content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'primary_release_date.lte': '1980-12-31',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'upcoming-netflix':
          print('CategoryScreen: Loading more Netflix upcoming content...');
          results = await TMDBService.fetchCustomData('/movie/upcoming', {
            'page': _currentPage.toString(),
          });
          break;

        case 'critically-acclaimed-netflix':
          print(
              'CategoryScreen: Loading more Netflix critically acclaimed content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'vote_average.gte': '8.5',
            'vote_count.gte': '1000',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;
        // Prime categories for load more - each with specific content focus
        case 'top-rated-prime':
          print('CategoryScreen: Loading more top rated Prime content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'vote_average.gte': '7.5',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'action-prime':
          print('CategoryScreen: Loading more Prime action content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '28',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'comedy-prime':
          print('CategoryScreen: Loading more Prime comedy content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '35',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'drama-prime':
          print('CategoryScreen: Loading more Prime drama content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '18',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'thriller-prime':
          print('CategoryScreen: Loading more Prime thriller content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '53',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'scifi-prime':
          print('CategoryScreen: Loading more Prime sci-fi content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '878',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'romance-prime':
          print('CategoryScreen: Loading more Prime romance content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10749',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'new-releases-prime':
          print('CategoryScreen: Loading more Prime new releases...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'sort_by': 'primary_release_date.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'trending-prime':
          print('CategoryScreen: Loading more Prime trending content...');
          results = await TMDBService.fetchCustomData('/trending/movie/week', {
            'page': _currentPage.toString(),
          });
          break;

        case 'award-winners-prime':
          print('CategoryScreen: Loading more Prime award winners...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'vote_average.gte': '8.0',
            'vote_count.gte': '1000',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'family-content-prime':
          print('CategoryScreen: Loading more Prime family content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10751',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'mystery-prime':
          print('CategoryScreen: Loading more Prime mystery content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '9648',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'crime-prime':
          print('CategoryScreen: Loading more Prime crime content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '80',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'animation-prime':
          print('CategoryScreen: Loading more Prime animation content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'documentary-prime':
          print('CategoryScreen: Loading more Prime documentary content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '99',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'international-prime':
          print('CategoryScreen: Loading more Prime international content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': '!en',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'classic-prime':
          print('CategoryScreen: Loading more Prime classic content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'primary_release_date.lte': '1980-12-31',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'upcoming-prime':
          print('CategoryScreen: Loading more Prime upcoming content...');
          results = await TMDBService.fetchCustomData('/movie/upcoming', {
            'page': _currentPage.toString(),
          });
          break;

        case 'critically-acclaimed-prime':
          print(
              'CategoryScreen: Loading more Prime critically acclaimed content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'vote_average.gte': '8.5',
            'vote_count.gte': '1000',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'horror-prime':
          print('CategoryScreen: Loading more Prime horror content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '27',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'war-prime':
          print('CategoryScreen: Loading more Prime war content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10752',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'western-prime':
          print('CategoryScreen: Loading more Prime western content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '37',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'musical-prime':
          print('CategoryScreen: Loading more Prime musical content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10402',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'biographical-prime':
          print('CategoryScreen: Loading more Prime biographical content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '968',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'sports-prime':
          print('CategoryScreen: Loading more Prime sports content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '180547',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'adventure-prime':
          print('CategoryScreen: Loading more Prime adventure content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '12',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'fantasy-prime':
          print('CategoryScreen: Loading more Prime fantasy content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '14',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'superhero-prime':
          print('CategoryScreen: Loading more Prime superhero content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '180547',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'indie-prime':
          print('CategoryScreen: Loading more Prime indie content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '210024',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'foreign-prime':
          print('CategoryScreen: Loading more Prime foreign content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': '!en',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'teen-prime':
          print('CategoryScreen: Loading more Prime teen content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '210024',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'kids-prime':
          print('CategoryScreen: Loading more Prime kids content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10751',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'reality-tv-prime':
          print('CategoryScreen: Loading more Prime reality TV content...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_genres': '10764',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'game-show-prime':
          print('CategoryScreen: Loading more Prime game show content...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_genres': '10764',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'talk-show-prime':
          print('CategoryScreen: Loading more Prime talk show content...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_genres': '10767',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'variety-prime':
          print('CategoryScreen: Loading more Prime variety content...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_genres': '10764',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'news-prime':
          print('CategoryScreen: Loading more Prime news content...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_genres': '10763',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'educational-prime':
          print('CategoryScreen: Loading more Prime educational content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '99',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;
        // Animated categories for load more - each with specific content focus
        case 'top-rated-animated':
          print('CategoryScreen: Loading more top rated animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'vote_average.gte': '7.5',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'pixar-animation':
          print('CategoryScreen: Loading more Pixar animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_companies': '3', // Pixar company ID
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'studio-ghibli':
          print(
              'CategoryScreen: Loading more Studio Ghibli animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_companies': '10342', // Studio Ghibli company ID
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'recent-animated':
          print('CategoryScreen: Loading more recent animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'sort_by': 'primary_release_date.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'popular-animated-tv':
          print('CategoryScreen: Loading more popular animated TV shows...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_genres': '16',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'new-releases-animated':
          print('CategoryScreen: Loading more new animated releases...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'sort_by': 'primary_release_date.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'trending-animated':
          print('CategoryScreen: Loading more trending animated content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'award-winners-animated':
          print(
              'CategoryScreen: Loading more award-winning animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'vote_average.gte': '8.0',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'family-animated':
          print('CategoryScreen: Loading more family animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16,10751',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'comedy-animated':
          print('CategoryScreen: Loading more comedy animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16,35',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'adventure-animated':
          print('CategoryScreen: Loading more adventure animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16,12',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'fantasy-animated':
          print('CategoryScreen: Loading more fantasy animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16,14',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'superhero-animated':
          print('CategoryScreen: Loading more superhero animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '180547',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'musical-animated':
          print('CategoryScreen: Loading more musical animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16,10402',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'classic-animated':
          print('CategoryScreen: Loading more classic animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'primary_release_date.lte': '2000-12-31',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'upcoming-animated':
          print('CategoryScreen: Loading more upcoming animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'sort_by': 'primary_release_date.asc',
            'page': _currentPage.toString(),
          });
          break;

        case 'critically-acclaimed-animated':
          print(
              'CategoryScreen: Loading more critically acclaimed animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'vote_average.gte': '8.0',
            'vote_count.gte': '1000',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'indie-animated':
          print('CategoryScreen: Loading more indie animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'foreign-animated':
          print('CategoryScreen: Loading more foreign animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_original_language': '!en',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'teen-animated':
          print('CategoryScreen: Loading more teen animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'kids-animated':
          print('CategoryScreen: Loading more kids animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16,10751',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'stop-motion-animated':
          print('CategoryScreen: Loading more stop-motion animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'computer-generated-animated':
          print(
              'CategoryScreen: Loading more computer-generated animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'hand-drawn-animated':
          print('CategoryScreen: Loading more hand-drawn animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'anime-animated':
          print('CategoryScreen: Loading more anime movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_original_language': 'ja',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'european-animated':
          print('CategoryScreen: Loading more European animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_origin_country': 'FR,IT,DE,ES,GB',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'disney-animated':
          print('CategoryScreen: Loading more Disney animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_companies': '2', // Walt Disney Pictures company ID
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'dreamworks-animated':
          print('CategoryScreen: Loading more DreamWorks animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_companies': '521', // DreamWorks Animation company ID
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'illumination-animated':
          print('CategoryScreen: Loading more Illumination animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_companies': '33', // Illumination company ID
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'sony-animated':
          print('CategoryScreen: Loading more Sony animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_companies': '34', // Sony Pictures Animation company ID
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'warner-animated':
          print('CategoryScreen: Loading more Warner animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_companies': '17', // Warner Bros. company ID
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'paramount-animated':
          print('CategoryScreen: Loading more Paramount animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_companies': '4', // Paramount company ID
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'universal-animated':
          print('CategoryScreen: Loading more Universal animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_companies': '33', // Universal company ID
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'fox-animated':
          print('CategoryScreen: Loading more Fox animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_companies': '25', // 20th Century Fox company ID
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'manga-animated':
          print('CategoryScreen: Loading more manga-based animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'cartoon-network-animated':
          print(
              'CategoryScreen: Loading more Cartoon Network animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'nickelodeon-animated':
          print('CategoryScreen: Loading more Nickelodeon animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'disney-channel-animated':
          print(
              'CategoryScreen: Loading more Disney Channel animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_companies': '2',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'netflix-animated':
          print('CategoryScreen: Loading more Netflix animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'prime-animated':
          print('CategoryScreen: Loading more Prime animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'hulu-animated':
          print('CategoryScreen: Loading more Hulu animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'hbo-animated':
          print('CategoryScreen: Loading more HBO animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'apple-animated':
          print('CategoryScreen: Loading more Apple animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'peacock-animated':
          print('CategoryScreen: Loading more Peacock animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'paramount-plus-animated':
          print('CategoryScreen: Loading more Paramount+ animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'disney-plus-animated':
          print('CategoryScreen: Loading more Disney+ animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_companies': '2',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'max-animated':
          print('CategoryScreen: Loading more Max animated movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'with_keywords': '210024',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'top-rated-documentaries':
        case 'recent-documentaries':
        case 'biographical-docs':
        case 'netflix-docs':
        case 'prime-docs':
        case 'popular-docuseries':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '99',
            'page': _currentPage.toString(),
          });
          break;

        // Bollywood categories for load more
        case 'new-releases-bollywood':
          print(
              'CategoryScreen: Loading more new releases Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'primary_release_date.gte': '2024-01-01',
            'sort_by': 'primary_release_date.desc',
            'vote_average.gte': '6.0',
            'page': _currentPage.toString(),
          });
          break;

        case 'blockbuster-hits-bollywood':
          print(
              'CategoryScreen: Loading more blockbuster hits Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'vote_average.gte': '7.0',
            'vote_count.gte': '100',
            'sort_by': 'revenue.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'critically-acclaimed-bollywood':
          print(
              'CategoryScreen: Loading more critically acclaimed Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'vote_average.gte': '7.5',
            'vote_count.gte': '200',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'family-entertainment-bollywood':
          print(
              'CategoryScreen: Loading more family entertainment Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '10751',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'comedy-gold-bollywood':
          print(
              'CategoryScreen: Loading more comedy gold Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '35',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'romantic-dramas-bollywood':
          print(
              'CategoryScreen: Loading more romantic dramas Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '10749',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'mystery-crime-bollywood':
          print(
              'CategoryScreen: Loading more mystery crime Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '80,9648',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'biographical-bollywood':
          print(
              'CategoryScreen: Loading more biographical Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '36',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'web-series-bollywood':
          print('CategoryScreen: Loading more web series Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_original_language': 'hi',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'upcoming-bollywood':
          print('CategoryScreen: Loading more upcoming Bollywood content...');
          results = await TMDBService.fetchCustomData('/movie/upcoming', {
            'with_original_language': 'hi',
            'region': 'IN',
            'page': _currentPage.toString(),
          });
          break;

        case 'award-winners-bollywood':
          print(
              'CategoryScreen: Loading more award winners Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'vote_average.gte': '7.5',
            'vote_count.gte': '300',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'bollywood-classics':
          print('CategoryScreen: Loading more Bollywood classics content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'primary_release_date.lte': '2000-12-31',
            'vote_average.gte': '7.0',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'masala-bollywood':
          print('CategoryScreen: Loading more masala Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '28,35,10749',
            'vote_average.gte': '6.0',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'tv-shows-hindi':
          print('CategoryScreen: Loading more Hindi TV shows content...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_original_language': 'hi',
            'vote_average.gte': '6.0',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'regional-cinema-bollywood':
          print(
              'CategoryScreen: Loading more regional cinema Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '18',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'indie-bollywood':
          print('CategoryScreen: Loading more indie Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'vote_average.gte': '6.5',
            'vote_count.gte': '50',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'period-dramas-bollywood':
          print(
              'CategoryScreen: Loading more period dramas Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '18,36',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'action-thrillers-bollywood':
          print(
              'CategoryScreen: Loading more action thrillers Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '28,53',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'musical-bollywood':
          print('CategoryScreen: Loading more musical Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '10402',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'social-dramas-bollywood':
          print(
              'CategoryScreen: Loading more social dramas Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '18',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'latest-bollywood':
          print('CategoryScreen: Loading more latest Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'sort_by': 'primary_release_date.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'classics-bollywood':
          print('CategoryScreen: Loading more classics Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'primary_release_date.lte': '2000-12-31',
            'vote_average.gte': '7.0',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'netflix-bollywood':
          print('CategoryScreen: Loading more Netflix Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'prime-bollywood':
          print('CategoryScreen: Loading more Prime Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'action-bollywood':
          print('CategoryScreen: Loading more action Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '28',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'romance-bollywood':
          print('CategoryScreen: Loading more romance Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '10749',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'thriller-bollywood':
          print('CategoryScreen: Loading more thriller Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '53',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'comedy-dramas-bollywood':
          print(
              'CategoryScreen: Loading more comedy dramas Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '35,18',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'action-comedies-bollywood':
          print(
              'CategoryScreen: Loading more action comedies Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '28,35',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'patriotic-bollywood':
          print('CategoryScreen: Loading more patriotic Bollywood content...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'hi',
            'region': 'IN',
            'with_genres': '18,36',
            'vote_average.gte': '6.5',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'reality-shows-hindi':
          print('CategoryScreen: Loading more Hindi reality shows content...');
          results = await TMDBService.fetchCustomData('/discover/tv', {
            'with_original_language': 'hi',
            'with_genres': '10764',
            'vote_average.gte': '6.0',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        // Hollywood categories for load more
        case 'trending-hollywood':
        case 'new-releases-hollywood':
        case 'blockbuster-hits-hollywood':
        case 'critically-acclaimed-hollywood':
        case 'action-adventure-hollywood':
        case 'comedy-hollywood':
        case 'drama-hollywood':
        case 'thriller-hollywood':
        case 'scifi-fantasy-hollywood':
        case 'horror-hollywood':
        case 'romance-hollywood':
        case 'animation-hollywood':
        case 'family-hollywood':
        case 'documentary-hollywood':
        case 'crime-hollywood':
        case 'mystery-hollywood':
        case 'war-hollywood':
        case 'western-hollywood':
        case 'music-hollywood':
        case 'history-hollywood':
        case 'upcoming-hollywood':
        case 'award-winners-hollywood':
        case 'indie-hollywood':
        case 'foreign-hollywood':
        case 'classics-hollywood':
        case 'teen-hollywood':
        case 'superhero-hollywood':
        case 'musical-hollywood':
        case 'sports-hollywood':
        case 'biographical-hollywood':
        case 'spy-thrillers-hollywood':
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': 'en',
            'region': 'US',
            'page': _currentPage.toString(),
          });
          break;

        // Generic categories that should load content specific to their category
        case 'trending':
          print('CategoryScreen: Loading more trending content...');
          results = await TMDBService.fetchCustomData('/trending/movie/week', {
            'page': _currentPage.toString(),
          });
          final tvResults =
              await TMDBService.fetchCustomData('/trending/tv/week', {
            'page': _currentPage.toString(),
          });
          results.addAll(tvResults);
          break;

        case 'movie':
          print('CategoryScreen: Loading more now playing movies...');
          results = await TMDBService.fetchCustomData('/movie/now_playing', {
            'page': _currentPage.toString(),
          });
          break;

        case 'popular':
          print('CategoryScreen: Loading more popular content...');
          results = await TMDBService.fetchCustomData('/movie/popular', {
            'page': _currentPage.toString(),
          });
          final tvResults = await TMDBService.fetchCustomData('/tv/popular', {
            'page': _currentPage.toString(),
          });
          results.addAll(tvResults);
          break;

        case 'top-rated-movies':
          print('CategoryScreen: Loading more top rated movies...');
          results = await TMDBService.fetchCustomData('/movie/top_rated', {
            'page': _currentPage.toString(),
          });
          break;

        case 'top-rated-tv':
          print('CategoryScreen: Loading more top rated TV shows...');
          results = await TMDBService.fetchCustomData('/tv/top_rated', {
            'page': _currentPage.toString(),
          });
          break;

        case 'upcoming':
          print('CategoryScreen: Loading more upcoming movies...');
          results = await TMDBService.fetchCustomData('/movie/upcoming', {
            'page': _currentPage.toString(),
          });
          break;

        case 'award-winners':
          print('CategoryScreen: Loading more award winning movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'vote_average.gte': '8.0',
            'vote_count.gte': '1000',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'indie':
          print('CategoryScreen: Loading more indie movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '210024',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'foreign':
          print('CategoryScreen: Loading more foreign movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_original_language': '!en',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'classics':
          print('CategoryScreen: Loading more classic movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'primary_release_date.lte': '1980-12-31',
            'vote_count.gte': '500',
            'sort_by': 'vote_average.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'teen':
          print('CategoryScreen: Loading more teen movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '210024',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'superhero':
          print('CategoryScreen: Loading more superhero movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '180547',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'musical':
          print('CategoryScreen: Loading more musical movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10402',
            'page': _currentPage.toString(),
          });
          break;

        case 'sports':
          print('CategoryScreen: Loading more sports movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '180547',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'biographical':
          print('CategoryScreen: Loading more biographical movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '968',
            'vote_count.gte': '100',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        case 'spy-thrillers':
          print('CategoryScreen: Loading more spy thrillers...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_keywords': '180547',
            'vote_count.gte': '50',
            'sort_by': 'popularity.desc',
            'page': _currentPage.toString(),
          });
          break;

        // Genre-based categories
        case 'action-adventure':
          print('CategoryScreen: Loading more action adventure movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '28,12',
            'page': _currentPage.toString(),
          });
          break;

        case 'comedy':
          print('CategoryScreen: Loading more comedy movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '35',
            'page': _currentPage.toString(),
          });
          break;

        case 'scifi-fantasy':
          print('CategoryScreen: Loading more sci-fi fantasy movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '878,14',
            'page': _currentPage.toString(),
          });
          break;

        case 'horror':
          print('CategoryScreen: Loading more horror movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '27',
            'page': _currentPage.toString(),
          });
          break;

        case 'thriller':
          print('CategoryScreen: Loading more thriller movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '53',
            'page': _currentPage.toString(),
          });
          break;

        case 'drama':
          print('CategoryScreen: Loading more drama movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '18',
            'page': _currentPage.toString(),
          });
          break;

        case 'romance':
          print('CategoryScreen: Loading more romance movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10749',
            'page': _currentPage.toString(),
          });
          break;

        case 'animation':
          print('CategoryScreen: Loading more animation movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'page': _currentPage.toString(),
          });
          break;

        case 'family':
          print('CategoryScreen: Loading more family movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10751',
            'page': _currentPage.toString(),
          });
          break;

        case 'documentary':
          print('CategoryScreen: Loading more documentary movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '99',
            'page': _currentPage.toString(),
          });
          break;

        case 'crime':
          print('CategoryScreen: Loading more crime movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '80',
            'page': _currentPage.toString(),
          });
          break;

        case 'mystery':
          print('CategoryScreen: Loading more mystery movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '878,14',
            'page': _currentPage.toString(),
          });
          break;

        case 'war':
          print('CategoryScreen: Loading more war movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '10752',
            'page': _currentPage.toString(),
          });
          break;

        case 'western':
          print('CategoryScreen: Loading more western movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '37',
            'page': _currentPage.toString(),
          });
          break;

        case 'music':
          print('CategoryScreen: Loading more music movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '13',
            'page': _currentPage.toString(),
          });
          break;

        case 'history':
          print('CategoryScreen: Loading more history movies...');
          results = await TMDBService.fetchCustomData('/discover/movie', {
            'with_genres': '16',
            'page': _currentPage.toString(),
          });
          break;
        default:
          // Handle custom API parameters
          if (widget.apiParams.isNotEmpty) {
            if (widget.apiParams.containsKey('with_genres')) {
              results = await TMDBService.discoverMoviesByGenre(
                widget.apiParams['with_genres']!,
                pages: _currentPage,
              );
            } else {
              results =
                  await TMDBService.getPopular('movie', pages: _currentPage);
            }
          } else {
            results =
                await TMDBService.getPopular('movie', pages: _currentPage);
          }
      }

      // Add new results to existing media list
      _media.addAll(results);

      print(
          'CategoryScreen: Loaded page $_currentPage with ${results.length} items. Total items: ${_media.length}');

      setState(() {
        _isLoading = false;
        // TMDB typically returns 20 results per page, so if we get less than 20, we've reached the end
        _hasMoreData = results.length >= 20;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load more data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    _currentPage = 1;
    _hasMoreData = true;
    await _loadData();
  }

  Future<void> _loadFallbackData() async {
    print('CategoryScreen: Loading fallback data (popular movies)');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load popular movies as fallback
      final results = await TMDBService.getPopular('movie', pages: 1);

      setState(() {
        _media = results;
        _isLoading = false;
        _hasMoreData = false; // Don't paginate fallback data
      });

      print(
          'CategoryScreen: Fallback data loaded successfully. Total media: ${_media.length}');
    } catch (e) {
      print('CategoryScreen: Error loading fallback data: $e');
      setState(() {
        _error = 'Failed to load fallback data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.title,
          style: AppTheme.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppTheme.textPrimaryColor,
              size: 24,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0B0B0B),
                Color(0xFF0B0B0B),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.backgroundColor,
          child: _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.destructiveColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Content',
                          style: AppTheme.headlineMedium.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: _refresh,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor:
                                    AppTheme.primaryColor.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Try Again'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Fallback to popular movies
                                setState(() {
                                  _error = null;
                                  _isLoading = true;
                                });
                                _loadFallbackData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.surfaceColor,
                                foregroundColor: AppTheme.textPrimaryColor,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Show Popular'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : _isLoading && _media.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading content...',
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _media.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.movie_outlined,
                                size: 64,
                                color: AppTheme.textSecondaryColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No content found',
                                style: AppTheme.headlineMedium.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try refreshing or check back later',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadFallbackData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor:
                                      AppTheme.primaryColor.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Load Popular Content'),
                              ),
                            ],
                          ),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200) {
                              if (!_isLoading && _hasMoreData) {
                                print(
                                    'CategoryScreen: Triggering pagination. Current items: ${_media.length}, Loading: $_isLoading, HasMore: $_hasMoreData');
                                _loadMoreData();
                              }
                            }
                            return false;
                          },
                          child: GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            // Performance optimizations
                            cacheExtent: 1000, // Cache more items for smoother scrolling
                            addAutomaticKeepAlives: false, // Don't keep items alive when off-screen
                            addRepaintBoundaries: false, // Reduce repaint overhead
                            addSemanticIndexes: false, // Disable semantic indexing for performance
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  3, // 3 items per row for consistent grid
                              childAspectRatio:
                                  0.67, // Standard movie poster aspect ratio (2:3)
                              crossAxisSpacing:
                                  16, // Consistent spacing between columns
                              mainAxisSpacing:
                                  20, // Consistent spacing between rows
                            ),
                            itemCount: _media.length + (_hasMoreData ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _media.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.primaryColor),
                                    ),
                                  ),
                                );
                              }

                              return MovieCard(
                                media: _media[index],
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                        media: _media[index],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
        ),
      ),
    );
  }
}
