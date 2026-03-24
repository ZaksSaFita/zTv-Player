import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ztv_player/helpers/json_helpers.dart';

part 'vod_movie.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class VodMovie extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'stream_id', fromJson: _idFromJson)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  @JsonKey(name: 'category_id', fromJson: _idFromJson)
  final String categoryId;

  @HiveField(3)
  @JsonKey(name: 'stream_icon')
  final String? logoUrl;

  @HiveField(4)
  @JsonKey(name: 'direct_source')
  final String? streamUrl;

  @HiveField(5)
  final String? plot;

  @HiveField(6)
  @JsonKey(name: 'releaseDate', fromJson: JsonHelpers.yearFromDate)
  final String? year;

  VodMovie({
    required this.id,
    required this.name,
    required this.categoryId,
    this.logoUrl,
    this.streamUrl,
    this.plot,
    this.year,
  });

  factory VodMovie.fromJson(Map<String, dynamic> json) => _$VodMovieFromJson(json);

  Map<String, dynamic> toJson() => _$VodMovieToJson(this);

  static String _idFromJson(dynamic value) =>
      JsonHelpers.asString(value, fallback: '0');
}
