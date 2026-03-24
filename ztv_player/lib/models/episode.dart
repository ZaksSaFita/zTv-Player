import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ztv_player/helpers/json_helpers.dart';

part 'episode.g.dart';

@HiveType(typeId: 8)
@JsonSerializable()
class Episode extends HiveObject {
  @HiveField(0)
  @JsonKey(fromJson: _idFromJson)
  final String id;

  @HiveField(1)
  @JsonKey(name: 'title')
  final String name;

  @HiveField(2)
  @JsonKey(name: 'season', fromJson: JsonHelpers.asInt)
  final int seasonNumber;

  @HiveField(3)
  @JsonKey(name: 'episode_num', fromJson: JsonHelpers.asInt)
  final int episodeNumber;

  @HiveField(4)
  @JsonKey(readValue: _readMovieImage)
  final String? logoUrl;

  @HiveField(5)
  @JsonKey(name: 'direct_source')
  final String? streamUrl;

  @HiveField(6)
  @JsonKey(readValue: _readPlot)
  final String? plot;

  @HiveField(7)
  @JsonKey(readValue: _readDuration)
  final String? duration;

  @HiveField(8)
  @JsonKey(name: 'container_extension', fromJson: JsonHelpers.asNullableString)
  final String? containerExtension;

  @HiveField(9)
  @JsonKey(readValue: _readReleasedate)
  final String? releaseDate;

  @HiveField(10)
  @JsonKey(readValue: _readRating)
  final String? rating;

  Episode({
    required this.id,
    required this.name,
    required this.seasonNumber,
    required this.episodeNumber,
    this.logoUrl,
    this.streamUrl,
    this.plot,
    this.duration,
    this.containerExtension,
    this.releaseDate,
    this.rating,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => _$EpisodeFromJson(json);

  Map<String, dynamic> toJson() => _$EpisodeToJson(this);

  static String _idFromJson(dynamic value) =>
      JsonHelpers.asString(value, fallback: '0');

  static Object? _readMovieImage(Map json, String key) {
    return JsonHelpers.asNullableString((json['info'] as Map?)?['movie_image']);
  }

  static Object? _readPlot(Map json, String key) {
    return JsonHelpers.asNullableString((json['info'] as Map?)?['plot']);
  }

  static Object? _readDuration(Map json, String key) {
    return JsonHelpers.asNullableString((json['info'] as Map?)?['duration']);
  }

  static Object? _readReleasedate(Map json, String key) {
    return JsonHelpers.asNullableString((json['info'] as Map?)?['releasedate']);
  }

  static Object? _readRating(Map json, String key) {
    return JsonHelpers.asNullableString((json['info'] as Map?)?['rating']);
  }
}
