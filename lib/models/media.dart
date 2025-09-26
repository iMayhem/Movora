import 'package:flutter/material.dart';
import 'package:movora/config/runtime_flags.dart';
// import 'package:movora/services/data_saver_service.dart'; // Removed - not working

class Media {
  final int? id;
  final String? title;
  final String? name;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final String? firstAirDate;
  final double? voteAverage;
  final int? voteCount;
  final double? popularity;
  final String? mediaType;
  final List<Genre>? genres;
  final int? runtime;
  final String? tagline;
  final int? numberOfSeasons;
  final List<Season>? seasons;
  final Videos? videos;
  final String? ageRating;
  final bool? adult;

  Media({
    this.id,
    this.title,
    this.name,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.firstAirDate,
    this.voteAverage,
    this.voteCount,
    this.popularity,
    this.mediaType,
    this.genres,
    this.runtime,
    this.tagline,
    this.numberOfSeasons,
    this.seasons,
    this.videos,
    this.ageRating,
    this.adult,
  });

  // Display helpers
  String get displayTitle => title ?? name ?? 'Unknown Title';
  String? get displayReleaseDate => releaseDate ?? firstAirDate;

  // Optimized image URLs (honor low-data flag)
  String? get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      // Return a placeholder image if no poster path
      return 'https://via.placeholder.com/500x750/333333/FFFFFF?text=${Uri.encodeComponent(displayTitle)}';
    }
    final lowData = RuntimeFlags.lowDataEnabled;
    final size =
        lowData ? 'w185' : 'w500'; // Increased from w92/w185 to w185/w500
    return 'https://image.tmdb.org/t/p/$size$posterPath';
  }

  String? get backdropUrl {
    if (backdropPath == null) return null;
    final lowData = RuntimeFlags.lowDataEnabled;
    final size =
        lowData ? 'w780' : 'w1280'; // Increased from w300/w780 to w780/w1280
    return 'https://image.tmdb.org/t/p/$size$backdropPath';
  }

  String get formattedRating => voteAverage?.toStringAsFixed(1) ?? 'N/A';

  String get formattedAgeRating {
    if (ageRating != null && ageRating!.isNotEmpty) {
      // Return the actual certification (PG-13, R, TV-MA, etc.)
      return ageRating!;
    }
    return 'Not Rated';
  }

  // Get age rating color for UI
  Color get ageRatingColor {
    final rating = ageRating?.toUpperCase();
    if (rating == null || rating.isEmpty) return Colors.grey;

    switch (rating) {
      case 'G':
      case 'TV-G':
        return Colors.green;
      case 'PG':
      case 'TV-PG':
        return Colors.yellow;
      case 'PG-13':
      case 'TV-14':
        return Colors.orange;
      case 'R':
      case 'NC-17':
      case 'TV-MA':
        return Colors.red;
      case '18+':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get age rating description
  String get ageRatingDescription {
    final rating = ageRating?.toUpperCase();
    if (rating == null || rating.isEmpty) return 'Not Rated';

    switch (rating) {
      case 'G':
        return 'General Audiences - All Ages Admitted';
      case 'PG':
        return 'Parental Guidance Suggested';
      case 'PG-13':
        return 'Parents Strongly Cautioned - Some Material May Be Inappropriate';
      case 'R':
        return 'Restricted - Under 17 Requires Accompanying Parent';
      case 'NC-17':
        return 'No One 17 and Under Admitted';
      case 'TV-G':
        return 'General Audiences - Suitable for All Ages';
      case 'TV-PG':
        return 'Parental Guidance Suggested';
      case 'TV-14':
        return 'Parents Strongly Cautioned - May Be Unsuitable for Children Under 14';
      case 'TV-MA':
        return 'Mature Audiences Only - May Be Unsuitable for Children Under 17';
      case '18+':
        return 'Adults Only - Not Suitable for Children';
      default:
        return 'Content Rating: $rating';
    }
  }

  String? get releaseYear {
    final date = displayReleaseDate;
    if (date == null) return null;
    try {
      return DateTime.parse(date).year.toString();
    } catch (_) {
      return null;
    }
  }

  String get genreNames {
    if (genres == null || genres!.isEmpty) return 'Unknown Genre';
    return genres!.map((g) => g.name).join(', ');
  }

  String? get primaryGenre =>
      (genres == null || genres!.isEmpty) ? null : genres!.first.name;

  bool get isMovie => mediaType == 'movie';
  bool get isTvShow => mediaType == 'tv';

  String? get formattedRuntime {
    if (runtime == null) return null;
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  // JSON
  factory Media.fromJson(Map<String, dynamic> json) {
    final computedAgeRating = json['certification'];
    return Media(
      id: json['id'],
      title: json['title'],
      name: json['name'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'],
      firstAirDate: json['first_air_date'],
      voteAverage: (json['vote_average'] is num)
          ? (json['vote_average'] as num).toDouble()
          : null,
      voteCount: json['vote_count'],
      popularity: (json['popularity'] is num)
          ? (json['popularity'] as num).toDouble()
          : null,
      mediaType: json['media_type'] ?? (json['title'] != null ? 'movie' : 'tv'),
      genres: json['genres'] != null
          ? List<Genre>.from(
              (json['genres'] as List).map((x) => Genre.fromJson(x)))
          : null,
      runtime: json['runtime'],
      tagline: json['tagline'],
      numberOfSeasons: json['number_of_seasons'],
      seasons: json['seasons'] != null
          ? List<Season>.from(
              (json['seasons'] as List).map((x) => Season.fromJson(x)))
          : null,
      videos: json['videos'] != null ? Videos.fromJson(json['videos']) : null,
      ageRating: computedAgeRating,
      adult: json['adult'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'name': name,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'first_air_date': firstAirDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'popularity': popularity,
      'media_type': mediaType,
      'genres': genres?.map((x) => x.toJson()).toList(),
      'runtime': runtime,
      'tagline': tagline,
      'number_of_seasons': numberOfSeasons,
      'seasons': seasons?.map((x) => x.toJson()).toList(),
      'videos': videos?.toJson(),
      'certification': ageRating,
      'adult': adult,
    };
  }
}

class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Season {
  final String? airDate;
  final int? episodeCount;
  final int? id;
  final String? name;
  final String? overview;
  final String? posterPath;
  final int? seasonNumber;

  Season({
    this.airDate,
    this.episodeCount,
    this.id,
    this.name,
    this.overview,
    this.posterPath,
    this.seasonNumber,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      airDate: json['air_date'],
      episodeCount: json['episode_count'],
      id: json['id'],
      name: json['name'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      seasonNumber: json['season_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'air_date': airDate,
      'episode_count': episodeCount,
      'id': id,
      'name': name,
      'overview': overview,
      'poster_path': posterPath,
      'season_number': seasonNumber,
    };
  }
}

class Videos {
  final List<Video> results;

  Videos({
    required this.results,
  });

  factory Videos.fromJson(Map<String, dynamic> json) {
    return Videos(
      results: List<Video>.from(
          (json['results'] as List).map((x) => Video.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((x) => x.toJson()).toList(),
    };
  }
}

class Video {
  final String? iso6391;
  final String? iso31661;
  final String? name;
  final String? key;
  final String? site;
  final int? size;
  final String? type;
  final bool? official;
  final String? publishedAt;
  final String? id;

  Video({
    this.iso6391,
    this.iso31661,
    this.name,
    this.key,
    this.site,
    this.size,
    this.type,
    this.official,
    this.publishedAt,
    this.id,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      iso6391: json['iso_639_1'],
      iso31661: json['iso_3166_1'],
      name: json['name'],
      key: json['key'],
      site: json['site'],
      size: json['size'],
      type: json['type'],
      official: json['official'],
      publishedAt: json['published_at'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iso_639_1': iso6391,
      'iso_3166_1': iso31661,
      'name': name,
      'key': key,
      'site': site,
      'size': size,
      'type': type,
      'official': official,
      'published_at': publishedAt,
      'id': id,
    };
  }

  bool get isYouTube => site == 'YouTube';
  String? get youtubeEmbedUrl =>
      !isYouTube || key == null ? null : 'https://www.youtube.com/embed/$key';
  bool get isTrailer => type == 'Trailer';
  bool get isOfficial => official == true;
}
