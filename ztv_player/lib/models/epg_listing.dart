import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

import 'package:ztv_player/helpers/json_helpers.dart';

part 'epg_listing.g.dart';

@HiveType(typeId: 10)
@JsonSerializable()
class EpgListing extends HiveObject {
  @HiveField(0)
  @JsonKey(fromJson: _idFromJson)
  final String id;

  @HiveField(1)
  @JsonKey(name: 'epg_id', fromJson: _idFromJson)
  final String epgId;

  @HiveField(2)
  @JsonKey(fromJson: _decodeBase64)
  final String title;

  @HiveField(3)
  @JsonKey(fromJson: _decodeBase64)
  final String description;

  @HiveField(4)
  final String lang;

  @HiveField(5)
  @JsonKey(fromJson: DateTime.parse)
  final DateTime start;

  @HiveField(6)
  @JsonKey(fromJson: DateTime.parse)
  final DateTime end;

  @HiveField(7)
  @JsonKey(name: 'channel_id', fromJson: _idFromJson)
  final String channelId;

  @HiveField(8)
  @JsonKey(name: 'start_timestamp', fromJson: JsonHelpers.asNullableInt)
  final int? startTimestamp;

  @HiveField(9)
  @JsonKey(name: 'stop_timestamp', fromJson: JsonHelpers.asNullableInt)
  final int? stopTimestamp;

  @HiveField(10)
  @JsonKey(name: 'now_playing', fromJson: _boolFromInt, defaultValue: false)
  final bool nowPlaying;

  @HiveField(11)
  @JsonKey(name: 'has_archive', fromJson: _boolFromInt, defaultValue: false)
  final bool hasArchive;

  EpgListing({
    required this.id,
    required this.epgId,
    required this.title,
    required this.description,
    required this.lang,
    required this.start,
    required this.end,
    required this.channelId,
    this.startTimestamp,
    this.stopTimestamp,
    required this.nowPlaying,
    required this.hasArchive,
  });

  factory EpgListing.fromJson(Map<String, dynamic> json) =>
      _$EpgListingFromJson(json);

  Map<String, dynamic> toJson() => _$EpgListingToJson(this);

  static String _idFromJson(dynamic value) =>
      JsonHelpers.asString(value, fallback: '0');

  static String _decodeBase64(dynamic value) {
    if (value == null) return '';
    try {
      return utf8.decode(base64.decode(value.toString()));
    } catch (_) {
      return value.toString();
    }
  }

  static bool _boolFromInt(dynamic value) {
    return JsonHelpers.asInt(value) == 1;
  }
}
