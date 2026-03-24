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
  @JsonKey(fromJson: _nameFromJson)
  final String name;

  @HiveField(2)
  @JsonKey(name: 'category_id', fromJson: _idFromJson)
  final String categoryId;

  @HiveField(3)
  @JsonKey(name: 'stream_icon', fromJson: JsonHelpers.asNullableString)
  final String? logoUrl;

  @HiveField(4)
  @JsonKey(name: 'direct_source', fromJson: JsonHelpers.asNullableString)
  final String? streamUrl;

  @HiveField(5)
  @JsonKey(fromJson: JsonHelpers.asNullableString)
  final String? plot;

  @HiveField(6)
  @JsonKey(name: 'releaseDate', fromJson: JsonHelpers.yearFromDate)
  final String? year;

  @HiveField(7)
  @JsonKey(fromJson: JsonHelpers.asNullableInt)
  final int? num;

  @HiveField(8)
  @JsonKey(fromJson: _ratingFromJson)
  final String? rating;

  @HiveField(9)
  @JsonKey(fromJson: JsonHelpers.asNullableString)
  final String? added;

  @HiveField(10)
  @JsonKey(name: 'container_extension', fromJson: JsonHelpers.asNullableString)
  final String? containerExtension;

  VodMovie({
    required this.id,
    required this.name,
    required this.categoryId,
    this.logoUrl,
    this.streamUrl,
    this.plot,
    this.year,
    this.num,
    this.rating,
    this.added,
    this.containerExtension,
  });

  factory VodMovie.fromJson(Map<String, dynamic> json) => _$VodMovieFromJson(json);

  Map<String, dynamic> toJson() => _$VodMovieToJson(this);

  static String _idFromJson(dynamic value) =>
      JsonHelpers.asString(value, fallback: '0');

  static String _nameFromJson(dynamic value) =>
      JsonHelpers.asString(value, fallback: 'Unknown movie');

  static String? _ratingFromJson(dynamic value) =>
      JsonHelpers.asNullableString(value);
}
