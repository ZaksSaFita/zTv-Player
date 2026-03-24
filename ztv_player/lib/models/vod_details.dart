import 'package:ztv_player/helpers/json_helpers.dart';

class VodDetails {
  const VodDetails({
    required this.movieId,
    required this.name,
    this.originalName,
    this.coverUrl,
    this.backdropUrl,
    this.releaseDate,
    this.duration,
    this.director,
    this.cast,
    this.description,
    this.country,
    this.genre,
    this.rating,
    this.tmdbUrl,
    this.youtubeTrailer,
  });

  final String movieId;
  final String name;
  final String? originalName;
  final String? coverUrl;
  final String? backdropUrl;
  final String? releaseDate;
  final String? duration;
  final String? director;
  final String? cast;
  final String? description;
  final String? country;
  final String? genre;
  final String? rating;
  final String? tmdbUrl;
  final String? youtubeTrailer;

  factory VodDetails.fromJson(Map<String, dynamic> json) {
    final info = json['info'] is Map
        ? Map<String, dynamic>.from(json['info'] as Map)
        : const <String, dynamic>{};
    final movieData = json['movie_data'] is Map
        ? Map<String, dynamic>.from(json['movie_data'] as Map)
        : const <String, dynamic>{};
    final backdropPath = info['backdrop_path'];

    return VodDetails(
      movieId: JsonHelpers.asString(
        movieData['stream_id'] ?? json['vod_id'],
        fallback: '0',
      ),
      name: JsonHelpers.asString(
        info['name'] ?? movieData['name'],
        fallback: 'Unknown movie',
      ),
      originalName: JsonHelpers.asNullableString(info['o_name']),
      coverUrl: JsonHelpers.asNullableString(
        info['cover_big'] ?? info['movie_image'],
      ),
      backdropUrl: _backdropFromJson(backdropPath),
      releaseDate: JsonHelpers.asNullableString(info['releasedate']),
      duration: JsonHelpers.asNullableString(
        info['duration'] ?? info['episode_run_time'],
      ),
      director: JsonHelpers.asNullableString(info['director']),
      cast: JsonHelpers.asNullableString(info['cast'] ?? info['actors']),
      description: JsonHelpers.asNullableString(
        info['description'] ?? info['plot'],
      ),
      country: JsonHelpers.asNullableString(info['country']),
      genre: JsonHelpers.asNullableString(info['genre']),
      rating: JsonHelpers.asNullableString(info['rating']),
      tmdbUrl: JsonHelpers.asNullableString(info['tmdb_url']),
      youtubeTrailer: JsonHelpers.asNullableString(info['youtube_trailer']),
    );
  }

  static String? _backdropFromJson(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return JsonHelpers.asNullableString(value.first);
    }

    return JsonHelpers.asNullableString(value);
  }
}
