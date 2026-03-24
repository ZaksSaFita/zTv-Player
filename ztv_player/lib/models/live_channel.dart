import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ztv_player/helpers/json_helpers.dart';

part 'live_channel.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class LiveChannel extends HiveObject {
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
  @JsonKey(fromJson: JsonHelpers.asNullableInt)
  final int? num;

  LiveChannel({
    required this.id,
    required this.name,
    required this.categoryId,
    this.logoUrl,
    this.streamUrl,
    this.num,
  });

  factory LiveChannel.fromJson(Map<String, dynamic> json) =>
      _$LiveChannelFromJson(json);

  Map<String, dynamic> toJson() => _$LiveChannelToJson(this);

  static String _idFromJson(dynamic value) =>
      JsonHelpers.asString(value, fallback: '0');
}
