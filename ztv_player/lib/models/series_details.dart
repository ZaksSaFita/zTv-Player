import 'package:ztv_player/helpers/json_helpers.dart';
import 'package:ztv_player/models/episode.dart';
import 'package:ztv_player/models/season.dart';

class SeriesDetails {
  const SeriesDetails({
    required this.seriesId,
    required this.name,
    required this.seasons,
    this.coverUrl,
    this.backdropUrl,
    this.plot,
    this.cast,
    this.director,
    this.genre,
    this.releaseDate,
    this.rating,
    this.episodeRunTime,
    this.youtubeTrailer,
  });

  final String seriesId;
  final String name;
  final String? coverUrl;
  final String? backdropUrl;
  final String? plot;
  final String? cast;
  final String? director;
  final String? genre;
  final String? releaseDate;
  final String? rating;
  final String? episodeRunTime;
  final String? youtubeTrailer;
  final List<Season> seasons;

  factory SeriesDetails.fromJson(Map<String, dynamic> json, String seriesId) {
    final info = json['info'] is Map
        ? Map<String, dynamic>.from(json['info'] as Map)
        : const <String, dynamic>{};
    final seasonsJson = _extractSeasonMaps(json['seasons']);
    final seasonEpisodes = _extractEpisodesBySeason(json['episodes']);

    final seasons = seasonsJson
        .map((item) => _buildSeason(item, seasonEpisodes))
        .whereType<Season>()
        .toList()
      ..sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));

    for (final entry in seasonEpisodes.entries) {
      if (seasons.any((season) => season.seasonNumber == entry.key)) {
        continue;
      }

      seasons.add(
        Season(
          seasonNumber: entry.key,
          episodes: entry.value,
          name: 'Season ${entry.key}',
          episodeCount: entry.value.length,
        ),
      );
    }

    seasons.sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));

    return SeriesDetails(
      seriesId: seriesId,
      name: JsonHelpers.asString(info['name'], fallback: 'Unknown series'),
      coverUrl: JsonHelpers.asNullableString(info['cover']),
      backdropUrl: _backdropFromJson(info['backdrop_path']),
      plot: JsonHelpers.asNullableString(info['plot']),
      cast: JsonHelpers.asNullableString(info['cast']),
      director: JsonHelpers.asNullableString(info['director']),
      genre: JsonHelpers.asNullableString(info['genre']),
      releaseDate: JsonHelpers.asNullableString(info['releaseDate']),
      rating: JsonHelpers.asNullableString(info['rating']),
      episodeRunTime: JsonHelpers.asNullableString(info['episode_run_time']),
      youtubeTrailer: JsonHelpers.asNullableString(info['youtube_trailer']),
      seasons: seasons,
    );
  }

  static String? _backdropFromJson(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return JsonHelpers.asNullableString(value.first);
    }

    return JsonHelpers.asNullableString(value);
  }

  static List<Map<String, dynamic>> _extractSeasonMaps(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (raw is Map) {
      return raw.values
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return const <Map<String, dynamic>>[];
  }

  static Map<int, List<Episode>> _extractEpisodesBySeason(dynamic raw) {
    final seasonEpisodes = <int, List<Episode>>{};

    if (raw is Map) {
      for (final entry in raw.entries) {
        final seasonNumber = JsonHelpers.asInt(entry.key, fallback: -1);
        final rawEpisodes = entry.value is List ? entry.value as List : const [];
        final episodes = rawEpisodes
            .whereType<Map>()
            .map(
              (item) => _buildEpisode(
                Map<String, dynamic>.from(item),
                fallbackSeasonNumber: seasonNumber,
              ),
            )
            .toList()
          ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));

        if (episodes.isNotEmpty) {
          seasonEpisodes[_normalizedSeasonNumber(seasonNumber)] = episodes;
        }
      }
    } else if (raw is List) {
      for (final item in raw.whereType<Map>()) {
        final episode = _buildEpisode(Map<String, dynamic>.from(item));
        seasonEpisodes.putIfAbsent(episode.seasonNumber, () => <Episode>[]).add(
          episode,
        );
      }

      for (final episodes in seasonEpisodes.values) {
        episodes.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
      }
    }

    return seasonEpisodes;
  }

  static Season? _buildSeason(
    Map<String, dynamic> json,
    Map<int, List<Episode>> seasonEpisodes,
  ) {
    final seasonNumber = _normalizedSeasonNumber(
      JsonHelpers.asInt(json['season_number'], fallback: -1),
    );
    if (seasonNumber <= 0) {
      return null;
    }

    return Season(
      seasonNumber: seasonNumber,
      episodes: seasonEpisodes[seasonNumber] ?? const <Episode>[],
      name: JsonHelpers.asNullableString(json['name']) ?? 'Season $seasonNumber',
      overview: JsonHelpers.asNullableString(json['overview']),
      coverUrl: JsonHelpers.asNullableString(
        json['cover_big'] ?? json['cover'],
      ),
      episodeCount: JsonHelpers.asNullableInt(json['episode_count']),
      voteAverage: JsonHelpers.asNullableString(json['vote_average']),
    );
  }

  static Episode _buildEpisode(
    Map<String, dynamic> json, {
    int fallbackSeasonNumber = -1,
  }) {
    final info = json['info'] is Map
        ? Map<String, dynamic>.from(json['info'] as Map)
        : const <String, dynamic>{};
    final seasonNumber = _normalizedSeasonNumber(
      JsonHelpers.asInt(
        json['season'] ?? info['season'],
        fallback: fallbackSeasonNumber,
      ),
    );

    return Episode(
      id: JsonHelpers.asString(json['id'], fallback: '0'),
      name:
          JsonHelpers.asNullableString(json['title'] ?? json['name']) ??
          'Episode ${JsonHelpers.asInt(json['episode_num'], fallback: 0)}',
      seasonNumber: seasonNumber,
      episodeNumber: JsonHelpers.asInt(json['episode_num'], fallback: 0),
      logoUrl: JsonHelpers.asNullableString(
        info['movie_image'] ?? info['cover_big'] ?? info['cover'],
      ),
      streamUrl: JsonHelpers.asNullableString(json['direct_source']),
      plot: JsonHelpers.asNullableString(info['plot']),
      duration: JsonHelpers.asNullableString(info['duration']),
      containerExtension: JsonHelpers.asNullableString(
        json['container_extension'],
      ),
      releaseDate: JsonHelpers.asNullableString(info['releasedate']),
      rating: JsonHelpers.asNullableString(info['rating']),
    );
  }

  static int _normalizedSeasonNumber(int value) {
    return value <= 0 ? 1 : value;
  }
}
