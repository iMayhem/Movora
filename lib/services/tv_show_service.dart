import 'dart:convert';
import 'package:movora/services/network_service.dart';

class TvShowService {
  static const String _apiKey = 'dfa4c2c7c1de1005adee824dc5593672';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  static Future<TvShowDetails?> getTvShowDetails(int tvShowId) async {
    try {
      final uri = Uri.parse('$_baseUrl/tv/$tvShowId').replace(
        queryParameters: {
          'api_key': _apiKey,
          'append_to_response': 'seasons,episodes',
        },
      );

      final response = await NetworkService.client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TvShowDetails.fromJson(data);
      }
    } catch (e) {
      print('Error fetching TV show details: $e');
    }
    return null;
  }

  static Future<List<Season>> getSeasons(int tvShowId) async {
    final details = await getTvShowDetails(tvShowId);
    return details?.seasons ?? [];
  }

  static Future<List<Episode>> getEpisodes(
      int tvShowId, int seasonNumber) async {
    try {
      final uri =
          Uri.parse('$_baseUrl/tv/$tvShowId/season/$seasonNumber').replace(
        queryParameters: {
          'api_key': _apiKey,
        },
      );

      final response = await NetworkService.client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final episodes = (data['episodes'] as List)
            .map((episode) => Episode.fromJson(episode))
            .toList();
        return episodes;
      }
    } catch (e) {
      print('Error fetching episodes: $e');
    }
    return [];
  }
}

class TvShowDetails {
  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final List<Season> seasons;
  final String? status;
  final String? firstAirDate;
  final String? lastAirDate;

  TvShowDetails({
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    this.backdropPath,
    required this.seasons,
    this.status,
    this.firstAirDate,
    this.lastAirDate,
  });

  factory TvShowDetails.fromJson(Map<String, dynamic> json) {
    return TvShowDetails(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      seasons: (json['seasons'] as List? ?? [])
          .map((season) => Season.fromJson(season))
          .toList(),
      status: json['status'],
      firstAirDate: json['first_air_date'],
      lastAirDate: json['last_air_date'],
    );
  }
}

class Season {
  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final int seasonNumber;
  final String? airDate;
  final int episodeCount;

  Season({
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    required this.seasonNumber,
    this.airDate,
    required this.episodeCount,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'],
      posterPath: json['poster_path'],
      seasonNumber: json['season_number'] ?? 0,
      airDate: json['air_date'],
      episodeCount: json['episode_count'] ?? 0,
    );
  }
}

class Episode {
  final int id;
  final String name;
  final String? overview;
  final String? stillPath;
  final int episodeNumber;
  final int seasonNumber;
  final String? airDate;
  final double? voteAverage;
  final int? voteCount;

  Episode({
    required this.id,
    required this.name,
    this.overview,
    this.stillPath,
    required this.episodeNumber,
    required this.seasonNumber,
    this.airDate,
    this.voteAverage,
    this.voteCount,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'],
      stillPath: json['still_path'],
      episodeNumber: json['episode_number'] ?? 0,
      seasonNumber: json['season_number'] ?? 0,
      airDate: json['air_date'],
      voteAverage: json['vote_average']?.toDouble(),
      voteCount: json['vote_count'],
    );
  }

  bool get isReleased {
    if (airDate == null) return false;
    final airDateTime = DateTime.tryParse(airDate!);
    if (airDateTime == null) return false;
    return airDateTime.isBefore(DateTime.now()) ||
        airDateTime.isAtSameMomentAs(DateTime.now());
  }

  String get releaseStatus {
    if (airDate == null) return 'TBA';
    final airDateTime = DateTime.tryParse(airDate!);
    if (airDateTime == null) return 'TBA';

    final now = DateTime.now();
    if (airDateTime.isAfter(now)) {
      final difference = airDateTime.difference(now);
      if (difference.inDays > 0) {
        return 'Releases in ${difference.inDays} days';
      } else if (difference.inHours > 0) {
        return 'Releases in ${difference.inHours} hours';
      } else {
        return 'Releases soon';
      }
    }
    return 'Released';
  }
}
