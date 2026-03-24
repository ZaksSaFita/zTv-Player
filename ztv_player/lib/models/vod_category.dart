import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ztv_player/helpers/json_helpers.dart';

part 'vod_category.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class VodCategory extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'category_id', fromJson: _idFromJson)
  final String id;

  @HiveField(1)
  @JsonKey(name: 'category_name', defaultValue: 'Unknown')
  final String name;

  @HiveField(2)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final int? movieCount;

  VodCategory({required this.id, required this.name, this.movieCount});

  VodCategory copyWith({
    String? id,
    String? name,
    int? movieCount,
  }) {
    return VodCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      movieCount: movieCount ?? this.movieCount,
    );
  }

  factory VodCategory.fromJson(Map<String, dynamic> json) =>
      _$VodCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$VodCategoryToJson(this);

  static String _idFromJson(dynamic value) =>
      JsonHelpers.asString(value, fallback: '0');
}
