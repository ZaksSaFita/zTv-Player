import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ztv_player/helpers/json_helpers.dart';

part 'series_category.g.dart';

@HiveType(typeId: 5)
@JsonSerializable()
class SeriesCategory extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'category_id', fromJson: _idFromJson)
  final String id;

  @HiveField(1)
  @JsonKey(name: 'category_name', defaultValue: 'Unknown')
  final String name;

  @HiveField(2)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final int? seriesCount;

  SeriesCategory({required this.id, required this.name, this.seriesCount});

  SeriesCategory copyWith({
    String? id,
    String? name,
    int? seriesCount,
  }) {
    return SeriesCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      seriesCount: seriesCount ?? this.seriesCount,
    );
  }

  factory SeriesCategory.fromJson(Map<String, dynamic> json) =>
      _$SeriesCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesCategoryToJson(this);

  static String _idFromJson(dynamic value) =>
      JsonHelpers.asString(value, fallback: '0');
}
