import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ztv_player/helpers/json_helpers.dart';

part 'live_tv_channel.g.dart';

String _channelIdFromJson(dynamic value) =>
    JsonHelpers.asString(value, fallback: '0');

bool _channelBoolFromInt(dynamic value) => JsonHelpers.asInt(value) == 1;

@HiveType(typeId: 2)
@JsonSerializable()
class LiveTvChannel extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'stream_id', fromJson: _channelIdFromJson)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  @JsonKey(name: 'category_id', fromJson: _channelIdFromJson)
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

  @HiveField(6)
  @JsonKey(name: 'stream_type')
  final String streamType;

  @HiveField(7)
  @JsonKey(name: 'epg_channel_id')
  final String? epgChannelId;

  @HiveField(8)
  @JsonKey(name: 'added')
  final String? added;

  @HiveField(9)
  @JsonKey(name: 'custom_sid')
  final String? customSid;

  @HiveField(10)
  @JsonKey(name: 'tv_archive', fromJson: _channelBoolFromInt)
  final bool hasArchive;

  @HiveField(11)
  @JsonKey(name: 'tv_archive_duration', fromJson: JsonHelpers.asNullableInt)
  final int? archiveDuration;

  LiveTvChannel({
    required this.id,
    required this.name,
    required this.categoryId,
    this.logoUrl,
    this.streamUrl,
    this.num,
    this.streamType = 'live',
    this.epgChannelId,
    this.added,
    this.customSid,
    this.hasArchive = false,
    this.archiveDuration,
  });

  factory LiveTvChannel.fromJson(Map<String, dynamic> json) =>
      _$LiveTvChannelFromJson(json);

  Map<String, dynamic> toJson() => _$LiveTvChannelToJson(this);
}
