import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ztv_player/helpers/json_helpers.dart';

part 'live_category.g.dart';

String _liveCategoryIdFromJson(dynamic value) =>
    JsonHelpers.asString(value, fallback: '0');

@HiveType(typeId: 1)
@JsonSerializable()
class LiveCategory extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'category_id', fromJson: _liveCategoryIdFromJson)
  final String id;

  @HiveField(1)
  @JsonKey(name: 'category_name', defaultValue: 'Unknown')
  final String name;

  @HiveField(2)
  @JsonKey(includeFromJson: false, includeToJson: false)
  int channelCount;

  LiveCategory({required this.id, required this.name, this.channelCount = 0});

  factory LiveCategory.fromJson(Map<String, dynamic> json) =>
      _$LiveCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$LiveCategoryToJson(this);
}
