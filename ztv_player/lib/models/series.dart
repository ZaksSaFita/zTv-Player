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
  final String name;

  @HiveField(2)
  @JsonKey(name: 'category_id', fromJson: _idFromJson)
  final String categoryId;

  @HiveField(3)
  @JsonKey(name: 'cover')
  final String? logoUrl;

  @HiveField(4)
  final String? plot;

  @HiveField(5)
  @JsonKey(name: 'releaseDate', fromJson: JsonHelpers.yearFromDate)
  final String? year;

  Series({
    required this.id,
    required this.name,
    required this.categoryId,
    this.logoUrl,
    this.plot,
    this.year,
  });

  factory Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesToJson(this);

  static String _idFromJson(dynamic value) =>
      JsonHelpers.asString(value, fallback: '0');
}
