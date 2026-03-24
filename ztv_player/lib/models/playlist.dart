import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/models/live_tv_category.dart';
import 'package:ztv_player/models/live_tv_channel.dart';

part 'playlist.g.dart';

@HiveType(typeId: 0)
@JsonSerializable(explicitToJson: true)
class Playlist extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String server;

  @HiveField(3)
  final String username;

  @HiveField(4)
  final String password;

  @HiveField(5)
  final bool isValid;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  @JsonKey(defaultValue: <LiveTvCategory>[])
  final List<LiveTvCategory> liveCategories;

  @HiveField(8)
  @JsonKey(defaultValue: <LiveTvChannel>[])
  final List<LiveTvChannel> liveChannels;

  @HiveField(9)
  @JsonKey(
    fromJson: _epgCacheFromJson,
    toJson: _epgCacheToJson,
    defaultValue: <String, List<EpgListing>>{},
  )
  final Map<String, List<EpgListing>> epgCache;

  Playlist({
    required this.id,
    required this.name,
    required this.server,
    required this.username,
    required this.password,
    required this.isValid,
    required this.createdAt,
    this.liveCategories = const [],
    this.liveChannels = const [],
    this.epgCache = const {},
  });

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistToJson(this);

  Playlist copyWith({
    String? id,
    String? name,
    String? server,
    String? username,
    String? password,
    bool? isValid,
    DateTime? createdAt,
    List<LiveTvCategory>? liveCategories,
    List<LiveTvChannel>? liveChannels,
    Map<String, List<EpgListing>>? epgCache,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      server: server ?? this.server,
      username: username ?? this.username,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      createdAt: createdAt ?? this.createdAt,
      liveCategories: liveCategories ?? this.liveCategories,
      liveChannels: liveChannels ?? this.liveChannels,
      epgCache: epgCache ?? this.epgCache,
    );
  }

  static Map<String, List<EpgListing>> _epgCacheFromJson(dynamic json) {
    if (json is! Map) {
      return const <String, List<EpgListing>>{};
    }

    return json.map((key, value) {
      final listings = value is List
          ? value
              .whereType<Map>()
              .map((item) => EpgListing.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : <EpgListing>[];
      return MapEntry(key.toString(), listings);
    });
  }

  static Map<String, dynamic> _epgCacheToJson(
    Map<String, List<EpgListing>> value,
  ) {
    return value.map(
      (key, listings) =>
          MapEntry(key, listings.map((listing) => listing.toJson()).toList()),
    );
  }
}
