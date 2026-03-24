import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ztv_player/helpers/json_helpers.dart';
import 'episode.dart';

part 'season.g.dart';

@HiveType(typeId: 7)
@JsonSerializable(explicitToJson: true)
class Season extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'season_number')
  final int seasonNumber;

  @HiveField(1)
  @JsonKey(fromJson: _episodesFromJson, defaultValue: <Episode>[])
  final List<Episode> episodes;

  @HiveField(2)
  @JsonKey(name: 'name')
  final String? name;

  @HiveField(3)
  @JsonKey(name: 'overview')
  final String? overview;

  @HiveField(4)
  @JsonKey(name: 'cover_big')
  final String? coverUrl;

  @HiveField(5)
  @JsonKey(name: 'episode_count', fromJson: JsonHelpers.asNullableInt)
  final int? episodeCount;

  @HiveField(6)
  @JsonKey(name: 'vote_average', fromJson: _voteAverageFromJson)
  final String? voteAverage;

  Season({
    required this.seasonNumber,
    required this.episodes,
    this.name,
    this.overview,
    this.coverUrl,
    this.episodeCount,
    this.voteAverage,
  });

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);

  Map<String, dynamic> toJson() => _$SeasonToJson(this);

  static List<Episode> _episodesFromJson(dynamic value) {
    if (value is List) {
      return value
          .map((item) => Episode.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    return <Episode>[];
  }

  static String? _voteAverageFromJson(dynamic value) =>
      JsonHelpers.asNullableString(value);
}
