import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ztv_player/helpers/json_helpers.dart';

part 'series.g.dart';

@HiveType(typeId: 6)
@JsonSerializable()
class Series extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'series_id', fromJson: _idFromJson)
  final String id;

  @HiveField(1)
  @JsonKey(fromJson: _nameFromJson)
  final String name;

  @HiveField(2)
  @JsonKey(name: 'category_id', fromJson: _idFromJson)
  final String categoryId;

  @HiveField(3)
  @JsonKey(name: 'cover', fromJson: JsonHelpers.asNullableString)
  final String? logoUrl;

  @HiveField(4)
  @JsonKey(fromJson: JsonHelpers.asNullableString)
  final String? plot;

  @HiveField(5)
  @JsonKey(name: 'releaseDate', fromJson: JsonHelpers.yearFromDate)
  final String? year;

  @HiveField(6)
  @JsonKey(fromJson: JsonHelpers.asNullableInt)
  final int? num;

  @HiveField(7)
  @JsonKey(fromJson: _ratingFromJson)
  final String? rating;

  @HiveField(8)
  @JsonKey(fromJson: JsonHelpers.asNullableString)
  final String? genre;

  @HiveField(9)
  @JsonKey(fromJson: JsonHelpers.asNullableString)
  final String? cast;

  @HiveField(10)
  @JsonKey(fromJson: JsonHelpers.asNullableString)
  final String? director;

  @HiveField(11)
  @JsonKey(readValue: _readBackdrop)
  final String? backdropUrl;

  Series({
    required this.id,
    required this.name,
    required this.categoryId,
    this.logoUrl,
    this.plot,
    this.year,
    this.num,
    this.rating,
    this.genre,
    this.cast,
    this.director,
    this.backdropUrl,
  });

  factory Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesToJson(this);

  static String _idFromJson(dynamic value) =>
      JsonHelpers.asString(value, fallback: '0');

  static String _nameFromJson(dynamic value) =>
      JsonHelpers.asString(value, fallback: 'Unknown series');

  static String? _ratingFromJson(dynamic value) =>
      JsonHelpers.asNullableString(value);

  static Object? _readBackdrop(Map json, String key) {
    final value = json['backdrop_path'];
    if (value is List && value.isNotEmpty) {
      return value.first;
    }

    return value;
  }
}
