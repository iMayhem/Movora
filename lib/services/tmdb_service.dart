import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:movora/models/media.dart';
import 'package:movora/services/network_service.dart';

class TMDBService {
  static const String _apiKey = 'dfa4c2c7c1de1005adee824dc5593672';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  // Toggle verbose logging for debugging only
  static const bool _verbose = false;

  // Very lightweight in-memory cache for GET requests during app session
  // Key: full URL, Value: decoded JSON Map
  // In-memory cache with size limit
  static final Map<String, Map<String, dynamic>> _responseCache = {};
  static const int _maxCacheSize = 50; // Limit cache size

  // Indian content filtering parameters for all screens
  static const Map<String, String> _indianContentParams = {
    'with_original_language': 'hi,en,ta,te,ml,bn,gu,kn,mr,pa',
    'region': 'IN',
    'watch_region': 'IN',
  };

  // Hollywood filtering parameters (exactly matching website)
  static const Map<String, String> _hollywoodParams = {
    'with_original_language': 'en',
    'region': 'US',
  };

  static const Map<String, String> _hollywoodVoteCount = {
    'vote_count.gte': '300',
  };

  static const Map<String, String> _hollywoodTvVoteCount = {
    'vote_count.gte': '200',
  };

  // New methods for infinite scroll
  static Future<List<Media>> getMostPopularHollywood(
      {int page = 1, int limit = 20}) async {
    // Fetch popular movies and TV shows separately
    final popularMovies = await getPopular('movie', pages: page);
    final popularTv = await getPopular('tv', pages: page);

    // Combine and sort by popularity
    final combined = [...popularMovies, ...popularTv];
    final unique = _removeDuplicates(combined);
    final released = _filterReleasedContent(unique);

    // Sort by popularity (highest first)
    released.sort((a, b) => (b.popularity ?? 0).compareTo(a.popularity ?? 0));

    return released.take(limit).toList();
  }

  static Future<List<Media>> getTrendingMedia({int page = 1}) async {
    final params = {
      'page': page.toString(),
    };
    return await _fetchData('/trending/all/week', params);
  }

  static Future<List<Media>> getPopularMovies({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_original_language': 'en',
      'region': 'US',
      'sort_by': 'release_date.desc', // Most recent first
      'vote_count.gte': '300',
    };
    return await _fetchData('/discover/movie', params);
  }

  static Future<List<Media>> getPopularTvShows({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_original_language': 'en',
      'region': 'US',
      'sort_by': 'first_air_date.desc', // Most recent first
      'vote_count.gte': '200',
    };
    return await _fetchData('/discover/tv', params);
  }

  // Bollywood content methods - Most recent first
  static Future<List<Media>> getPopularBollywood({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_original_language': 'hi', // Hindi language specifically
      'region': 'IN',
      'sort_by': 'release_date.desc', // Most recent first
      'vote_count.gte': '50',
    };
    return await _fetchData('/discover/movie', params);
  }

  static Future<List<Media>> getPopularBollywoodMovies({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_original_language': 'hi', // Hindi language specifically
      'region': 'IN',
      'sort_by': 'release_date.desc', // Most recent first
      'vote_count.gte': '50',
    };
    return await _fetchData('/discover/movie', params);
  }

  static Future<List<Media>> getPopularBollywoodTvShows({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_original_language': 'hi', // Hindi language specifically
      'region': 'IN',
      'sort_by': 'first_air_date.desc', // Most recent first
      'vote_count.gte': '30',
    };
    return await _fetchData('/discover/tv', params);
  }

  // Korean content methods - Most recent first
  static Future<List<Media>> getPopularKorean({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_original_language': 'ko',
      'region': 'KR',
      'sort_by': 'release_date.desc', // Most recent first
      'vote_count.gte': '100',
    };
    return await _fetchData('/discover/movie', params);
  }

  static Future<List<Media>> getPopularKoreanMovies({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_original_language': 'ko',
      'region': 'KR',
      'sort_by': 'release_date.desc', // Most recent first
      'vote_count.gte': '100',
    };
    return await _fetchData('/discover/movie', params);
  }

  static Future<List<Media>> getPopularKoreanTvShows({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_original_language': 'ko',
      'region': 'KR',
      'sort_by': 'first_air_date.desc', // Most recent first
      'vote_count.gte': '50',
    };
    return await _fetchData('/discover/tv', params);
  }

  // Netflix content methods - Netflix content available in US
  static Future<List<Media>> getPopularNetflix({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_watch_providers': '8', // Netflix provider ID
      'watch_region': 'US', // US region
      'sort_by': 'popularity.desc', // Most popular first
      'vote_count.gte': '30', // Lower threshold for more content
    };
    return await _fetchData('/discover/movie', params);
  }

  static Future<List<Media>> getPopularNetflixMovies({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_watch_providers': '8', // Netflix provider ID
      'watch_region': 'US', // US region
      'sort_by': 'popularity.desc', // Most popular first
      'vote_count.gte': '30', // Lower threshold for more content
    };
    return await _fetchData('/discover/movie', params);
  }

  static Future<List<Media>> getPopularNetflixTvShows({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_watch_providers': '8', // Netflix provider ID
      'watch_region': 'US', // US region
      'sort_by': 'popularity.desc', // Most popular first
      'vote_count.gte': '20', // Lower threshold for more content
    };
    return await _fetchData('/discover/tv', params);
  }

  // Prime content methods - Prime Video content available in US
  static Future<List<Media>> getPopularPrime({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_watch_providers': '9', // Prime Video provider ID
      'watch_region': 'US', // US region
      'sort_by': 'popularity.desc', // Most popular first
      'vote_count.gte': '30', // Lower threshold for more content
    };
    return await _fetchData('/discover/movie', params);
  }

  static Future<List<Media>> getPopularPrimeMovies({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_watch_providers': '9', // Prime Video provider ID
      'watch_region': 'US', // US region
      'sort_by': 'popularity.desc', // Most popular first
      'vote_count.gte': '30', // Lower threshold for more content
    };
    return await _fetchData('/discover/movie', params);
  }

  static Future<List<Media>> getPopularPrimeTvShows({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_watch_providers': '9', // Prime Video provider ID
      'watch_region': 'US', // US region
      'sort_by': 'popularity.desc', // Most popular first
      'vote_count.gte': '20', // Lower threshold for more content
    };
    return await _fetchData('/discover/tv', params);
  }

  // Animated content methods - Most recent first
  static Future<List<Media>> getPopularAnimated({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_genres': '16', // Animation genre ID
      'sort_by': 'release_date.desc', // Most recent first
      'vote_count.gte': '100', // Only popular animated content
    };
    return await _fetchData('/discover/movie', params);
  }

  static Future<List<Media>> getPopularAnimatedMovies({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_genres': '16', // Animation genre ID
      'sort_by': 'release_date.desc', // Most recent first
      'vote_count.gte': '100',
    };
    return await _fetchData('/discover/movie', params);
  }

  static Future<List<Media>> getPopularAnimatedTvShows({int page = 1}) async {
    final params = {
      'page': page.toString(),
      'with_genres': '16', // Animation genre ID
      'sort_by': 'first_air_date.desc', // Most recent first
      'vote_count.gte': '50',
    };
    return await _fetchData('/discover/tv', params);
  }

  // Similar content methods
  static Future<List<Media>> getSimilarMovies(int movieId) async {
    final params = {
      'page': '1',
    };
    return await _fetchData('/movie/$movieId/similar', params);
  }

  static Future<List<Media>> getSimilarTvShows(int tvId) async {
    final params = {
      'page': '1',
    };
    return await _fetchData('/tv/$tvId/similar', params);
  }

  static Future<List<Media>> _fetchData(
      String endpoint, Map<String, String> params) async {
    try {
      // Add adult content filter if enabled
      Map<String, String> queryParams = {
        'api_key': _apiKey,
        ...params,
      };

      // Always exclude adult content from TMDB API
      queryParams['include_adult'] = 'false';

      final uri =
          Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);

      final cacheKey = uri.toString();
      if (_responseCache.containsKey(cacheKey)) {
        if (_verbose) {
          // ignore: avoid_print
          print('TMDBService(cache): HIT $cacheKey');
        }
        final data = _responseCache[cacheKey]!;
        final results = (data['results'] as List? ?? []);
        return results.map((item) => Media.fromJson(item)).toList();
      }

      // Clean cache if it's too large
      _cleanCacheIfNeeded();

      final response = await NetworkService.client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        // Store in cache for the session
        _responseCache[cacheKey] = data;
        final results = data['results'] as List;

        return results.map((item) => Media.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  // Trending content (global, no region filter needed) - exactly like website
  static Future<List<Media>> getTrending(String mediaType, String timeWindow,
      {int pages = 3}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/trending/$mediaType/$timeWindow', {
        'page': page.toString(),
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  // Popular content with Hollywood filtering - exactly like website
  static Future<List<Media>> getPopular(String mediaType,
      {int pages = 1}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/$mediaType/popular', {
        'page': page.toString(),
        ..._hollywoodParams,
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  // Now playing movies with Hollywood filtering - exactly like website
  static Future<List<Media>> getNowPlayingMovies({int pages = 1}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/movie/now_playing', {
        'page': page.toString(),
        ..._hollywoodParams,
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  // Top rated movies with Hollywood filtering - exactly like website
  static Future<List<Media>> getTopRatedMovies({int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        ..._hollywoodParams,
        ..._hollywoodVoteCount,
        'sort_by': 'vote_average.desc',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  // Top rated TV shows with Hollywood filtering - exactly like website
  static Future<List<Media>> getTopRatedTvShows({int pages = 1}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/tv', {
        'page': page.toString(),
        ..._hollywoodParams,
        ..._hollywoodTvVoteCount,
        'sort_by': 'vote_average.desc',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  // Genre-specific movie discovery - exactly like website
  static Future<List<Media>> discoverMoviesByGenre(String genreIds,
      {int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        ..._hollywoodParams,
        'with_genres': genreIds,
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  // Search functionality - exactly like website
  static Future<List<Media>> searchMedia(String query, String mediaType) async {
    try {
      final uri =
          Uri.parse('$_baseUrl/search/$mediaType').replace(queryParameters: {
        'api_key': _apiKey,
        'query': query,
      });

      final response = await NetworkService.client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((item) => Media.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  // Movie details - exactly like website
  static Future<Media?> getMovieDetails(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/movie/$id').replace(queryParameters: {
        'api_key': _apiKey,
        'append_to_response': 'videos',
      });

      final response = await NetworkService.client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (kDebugMode) print('🎬 Fetching details for movie ID: $id');
        if (kDebugMode) print('🎬 Movie title: ${data['title']}');

        return Media.fromJson(data);
      } else {
        if (kDebugMode)
          print('❌ Failed to fetch movie details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // TV show details - exactly like website
  static Future<Media?> getTvShowDetails(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/tv/$id').replace(queryParameters: {
        'api_key': _apiKey,
        'append_to_response': 'videos,season_details',
      });

      final response = await NetworkService.client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return Media.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Similar content - exactly like website
  static Future<List<Media>> getSimilarContent(int id, String mediaType) async {
    try {
      final uri = Uri.parse('$_baseUrl/$mediaType/$id/similar')
          .replace(queryParameters: {
        'api_key': _apiKey,
      });

      final response = await NetworkService.client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((item) => Media.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Utility methods
  static List<Media> _removeDuplicates(List<Media> media) {
    final seen = <int>{};
    return media.where((item) {
      if (item.id == null) return false;
      final duplicate = seen.contains(item.id!);
      seen.add(item.id!);
      return !duplicate;
    }).toList();
  }

  static List<Media> _filterReleasedContent(List<Media> media) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return media.where((item) {
      if (item.releaseDate == null) return true;

      try {
        final releaseDate = DateTime.parse(item.releaseDate!);
        final releaseDateOnly =
            DateTime(releaseDate.year, releaseDate.month, releaseDate.day);
        return releaseDateOnly.isBefore(today) ||
            releaseDateOnly.isAtSameMomentAs(today);
      } catch (e) {
        return true;
      }
    }).toList();
  }

  // High-level catalogue methods - exactly like website
  static Future<List<Media>> getMostViewed({int limit = 12}) async {
    final popularMovies = await getPopular('movie');
    final popularTv = await getPopular('tv');

    final combined = [...popularMovies, ...popularTv];
    final unique = _removeDuplicates(combined);
    final released = _filterReleasedContent(unique);

    // Sort by popularity and limit - exactly like website
    released.sort((a, b) => (b.popularity ?? 0).compareTo(a.popularity ?? 0));
    return released.take(limit).toList();
  }

  static Future<List<Media>> getTopWeekly({int limit = 12}) async {
    final popularMovies = await getPopular('movie');
    final popularTv = await getPopular('tv');

    final combined = [...popularMovies, ...popularTv];
    final unique = _removeDuplicates(combined);
    final released = _filterReleasedContent(unique);

    // Sort by popularity and limit - exactly like website
    released.sort((a, b) => (b.popularity ?? 0).compareTo(a.popularity ?? 0));
    return released.take(limit).toList();
  }

  // Public method for custom data fetching (for Bollywood, Korean, etc.)
  static Future<List<Media>> fetchCustomData(
      String endpoint, Map<String, String> params) async {
    try {
      if (_verbose) {
        // ignore: avoid_print
        print('TMDBService: Fetching $endpoint params=$params');
      }

      // Apply default parameters and adult filtering
      final queryParams = {
        'api_key': _apiKey,
        ...params,
      };

      // Always exclude adult content from TMDB API
      queryParams['include_adult'] = 'false';

      final uri =
          Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);

      if (_verbose) {
        // ignore: avoid_print
        print('TMDBService: URL: $uri');
      }

      final cacheKey = uri.toString();
      if (_responseCache.containsKey(cacheKey)) {
        if (_verbose) {
          // ignore: avoid_print
          print('TMDBService(cache): HIT $cacheKey');
        }
        final data = _responseCache[cacheKey]!;
        final results = data['results'] as List?;
        if (results == null) return [];
        return results.map((item) => Media.fromJson(item)).toList();
      }

      final response = await NetworkService.client.get(uri);

      if (_verbose) {
        // ignore: avoid_print
        print(
            'TMDBService: status=${response.statusCode} len=${response.body.length}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _responseCache[cacheKey] = data; // cache
        if (_verbose) {
          // ignore: avoid_print
          print('TMDBService: keys=${data.keys.toList()}');
        }

        if (data.containsKey('results')) {
          final results = data['results'] as List;
          if (_verbose) {
            // ignore: avoid_print
            print('TMDBService: results=${results.length}');
          }

          // Early map without extra certification fetches to reduce latency
          // Detailed certification fetch is disabled in non-verbose mode to keep navigation fast

          final mediaList = await Future.wait(results.map((item) async {
            try {
              // Try to get certification data for movies
              if (_verbose &&
                  (item['media_type'] == 'movie' || item['title'] != null)) {
                try {
                  final movieId = item['id'];
                  final certificationResponse = await http.get(
                    Uri.parse('$_baseUrl/movie/$movieId/release_dates').replace(
                      queryParameters: {'api_key': _apiKey},
                    ),
                  );

                  if (certificationResponse.statusCode == 200) {
                    final certData = json.decode(certificationResponse.body);
                    if (_verbose) {
                      // ignore: avoid_print
                      print(
                          'TMDBService: Certification response for movie ${item['id']}');
                    }
                    final results = certData['results'] as List?;
                    if (results != null && results.isNotEmpty) {
                      if (_verbose) {
                        // ignore: avoid_print
                        print(
                            'TMDBService: Found ${results.length} certification entries');
                      }
                      // Priority order: KR (Korean), US, then any other
                      String? certification;

                      // First try Korean certification
                      final krResults = results
                          .where((r) => r['iso_3166_1'] == 'KR')
                          .toList();
                      if (krResults.isNotEmpty) {
                        if (_verbose) {
                          // ignore: avoid_print
                          print(
                              'TMDBService: Found Korean certification data for movie ${item['id']}');
                        }
                        final releaseDates =
                            krResults.first['release_dates'] as List?;
                        if (releaseDates != null && releaseDates.isNotEmpty) {
                          certification = releaseDates.first['certification'];
                          if (_verbose) {
                            // ignore: avoid_print
                            print(
                                'TMDBService: Korean certification: $certification');
                          }
                        }
                      }

                      // If no Korean certification, try US
                      if (certification == null) {
                        final usResults = results
                            .where((r) => r['iso_3166_1'] == 'US')
                            .toList();
                        if (usResults.isNotEmpty) {
                          if (_verbose) {
                            // ignore: avoid_print
                            print('TMDBService: Found US certification data');
                          }
                          final releaseDates =
                              usResults.first['release_dates'] as List?;
                          if (releaseDates != null && releaseDates.isNotEmpty) {
                            certification = releaseDates.first['certification'];
                            if (_verbose) {
                              // ignore: avoid_print
                              print(
                                  'TMDBService: US certification: $certification');
                            }
                          }
                        }
                      }

                      // If still no certification, try any available
                      if (certification == null && results.isNotEmpty) {
                        final firstResult = results.first;
                        if (_verbose) {
                          // ignore: avoid_print
                          print(
                              'TMDBService: Using first available certification');
                        }
                        final releaseDates =
                            firstResult['release_dates'] as List?;
                        if (releaseDates != null && releaseDates.isNotEmpty) {
                          certification = releaseDates.first['certification'];
                          if (_verbose) {
                            // ignore: avoid_print
                            print(
                                'TMDBService: First available certification: $certification');
                          }
                        }
                      }

                      if (certification != null) {
                        item['certification'] = certification;
                        if (_verbose) {
                          // ignore: avoid_print
                          print(
                              'TMDBService: Found certification: $certification');
                        }
                      } else {
                        if (_verbose) {
                          // ignore: avoid_print
                          print('TMDBService: No certification found');
                        }
                      }
                    } else {
                      if (_verbose) {
                        // ignore: avoid_print
                        print('TMDBService: No certification results found');
                      }
                    }
                  } else {
                    if (_verbose) {
                      // ignore: avoid_print
                      print(
                          'TMDBService: Certification request failed ${certificationResponse.statusCode}');
                    }
                  }
                } catch (e) {
                  // If certification fetch fails, continue without it
                  if (_verbose) {
                    // ignore: avoid_print
                    print('TMDBService: Failed to fetch certification: $e');
                  }
                }
              }

              return Media.fromJson(item);
            } catch (e) {
              if (_verbose) {
                // ignore: avoid_print
                print('TMDBService: Error parsing item: $e');
              }
              rethrow;
            }
          }));

          if (_verbose) {
            // ignore: avoid_print
            print('TMDBService: Parsed ${mediaList.length} items');
          }
          return mediaList;
        } else {
          if (_verbose) {
            // ignore: avoid_print
            print('TMDBService: No results key in response');
          }
          throw Exception('No results found in API response');
        }
      } else {
        if (_verbose) {
          // ignore: avoid_print
          print('TMDBService: HTTP error ${response.statusCode}');
        }
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      if (_verbose) {
        // ignore: avoid_print
        print('TMDBService: Exception in fetchCustomData: $e');
      }
      throw Exception('Failed to fetch data: $e');
    }
  }

  // Indian content methods for all screens
  static Future<List<Media>> getIndianTrending(
      String mediaType, String timeWindow,
      {int pages = 3}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/trending/$mediaType/$timeWindow', {
        'page': page.toString(),
        ..._indianContentParams,
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  static Future<List<Media>> getIndianPopular(String mediaType,
      {int pages = 1}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/$mediaType/popular', {
        'page': page.toString(),
        ..._indianContentParams,
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  static Future<List<Media>> getIndianTopRated(String mediaType,
      {int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/$mediaType', {
        'page': page.toString(),
        ..._indianContentParams,
        'vote_count.gte': '100',
        'sort_by': 'vote_average.desc',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  static Future<List<Media>> getIndianMoviesByGenre(String genreIds,
      {int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        ..._indianContentParams,
        'with_genres': genreIds,
        'vote_count.gte': '50',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  static Future<List<Media>> getIndianStreamingContent(String providerId,
      {int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        ..._indianContentParams,
        'with_watch_providers': providerId,
        'watch_region': 'IN',
        'with_watch_monetization_types': 'flatrate',
        'vote_count.gte': '25',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  static Future<List<Media>> getIndianTvShows(String providerId,
      {int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/tv', {
        'page': page.toString(),
        ..._indianContentParams,
        'with_watch_providers': providerId,
        'watch_region': 'IN',
        'with_watch_monetization_types': 'flatrate',
        'vote_count.gte': '25',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  // Regional language specific methods
  static Future<List<Media>> getTamilMovies({int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        'with_original_language': 'ta',
        'region': 'IN',
        'vote_count.gte': '50',
        'sort_by': 'popularity.desc',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  static Future<List<Media>> getTeluguMovies({int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        'with_original_language': 'te',
        'region': 'IN',
        'vote_count.gte': '50',
        'sort_by': 'popularity.desc',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  static Future<List<Media>> getMalayalamMovies({int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        'with_original_language': 'ml',
        'region': 'IN',
        'vote_count.gte': '50',
        'sort_by': 'popularity.desc',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  static Future<List<Media>> getMarathiMovies({int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        'with_original_language': 'mr',
        'region': 'IN',
        'vote_count.gte': '50',
        'sort_by': 'popularity.desc',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  static Future<List<Media>> getBengaliMovies({int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        'with_original_language': 'bn',
        'region': 'IN',
        'vote_count.gte': '50',
        'sort_by': 'popularity.desc',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  // Indian genre specific methods
  static Future<List<Media>> getBollywoodMasala({int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        'with_original_language': 'hi',
        'region': 'IN',
        'with_genres': '28,35,10749', // Action, Comedy, Romance
        'vote_count.gte': '100',
        'sort_by': 'popularity.desc',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  static Future<List<Media>> getSouthIndianAction({int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        'with_original_language': 'ta,te,ml',
        'region': 'IN',
        'with_genres': '28,12', // Action, Adventure
        'vote_count.gte': '100',
        'sort_by': 'popularity.desc',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  static Future<List<Media>> getMarathiCinema({int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        'with_original_language': 'mr',
        'region': 'IN',
        'vote_count.gte': '50',
        'sort_by': 'popularity.desc',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  // Indian streaming platform methods
  static Future<List<Media>> getHotstarContent({int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        ..._indianContentParams,
        'with_watch_providers': '122', // Hotstar provider ID
        'watch_region': 'IN',
        'with_watch_monetization_types': 'flatrate',
        'vote_count.gte': '25',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  static Future<List<Media>> getSonyLIVContent({int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        ..._indianContentParams,
        'with_watch_providers': '220', // SonyLIV provider ID
        'watch_region': 'IN',
        'with_watch_monetization_types': 'flatrate',
        'vote_count.gte': '25',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  static Future<List<Media>> getZee5Content({int pages = 2}) async {
    List<Media> allResults = [];

    for (int page = 1; page <= pages; page++) {
      final results = await _fetchData('/discover/movie', {
        'page': page.toString(),
        ..._indianContentParams,
        'with_watch_providers': '232', // Zee5 provider ID
        'watch_region': 'IN',
        'with_watch_monetization_types': 'flatrate',
        'vote_count.gte': '25',
      });
      allResults.addAll(results);
    }

    return _removeDuplicates(allResults);
  }

  // Clean cache if it exceeds the maximum size
  static void _cleanCacheIfNeeded() {
    if (_responseCache.length > _maxCacheSize) {
      // Remove oldest entries (simple FIFO)
      final keysToRemove = _responseCache.keys
          .take(_responseCache.length - _maxCacheSize)
          .toList();
      for (final key in keysToRemove) {
        _responseCache.remove(key);
      }
      if (_verbose) {
        print(
            'TMDBService: Cleaned cache, removed ${keysToRemove.length} entries');
      }
    }
  }
}
