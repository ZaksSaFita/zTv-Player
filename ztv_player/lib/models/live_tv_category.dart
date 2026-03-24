import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ztv_player/helpers/json_helpers.dart';

part 'live_tv_category.g.dart';

String _liveTvCategoryIdFromJson(dynamic value) =>
    JsonHelpers.asString(value, fallback: '0');

@HiveType(typeId: 1)
@JsonSerializable()
class LiveTvCategory extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'category_id', fromJson: _liveTvCategoryIdFromJson)
  final String id;

  @HiveField(1)
  @JsonKey(name: 'category_name', defaultValue: 'Unknown')
  final String name;

  @HiveField(2)
  @JsonKey(includeFromJson: false, includeToJson: false)
  int channelCount;

  @HiveField(3)
  @JsonKey(name: 'parent_id', fromJson: JsonHelpers.asInt)
  final int parentId;

  LiveTvCategory({
    required this.id,
    required this.name,
    this.channelCount = 0,
    this.parentId = 0,
  });

  factory LiveTvCategory.fromJson(Map<String, dynamic> json) =>
      _$LiveTvCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$LiveTvCategoryToJson(this);
}
