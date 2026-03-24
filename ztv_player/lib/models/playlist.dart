import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/models/live_tv_category.dart';
import 'package:ztv_player/models/live_tv_channel.dart';
import 'package:ztv_player/models/series.dart';
import 'package:ztv_player/models/series_category.dart';
import 'package:ztv_player/models/vod_category.dart';
import 'package:ztv_player/models/vod_movie.dart';

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

  @HiveField(14)
  final DateTime? expiresAt;

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

  @HiveField(10)
  @JsonKey(defaultValue: <VodCategory>[])
  final List<VodCategory> vodCategories;

  @HiveField(11)
  @JsonKey(defaultValue: <VodMovie>[])
  final List<VodMovie> vodMovies;

  @HiveField(12)
  @JsonKey(defaultValue: <SeriesCategory>[])
  final List<SeriesCategory> seriesCategories;

  @HiveField(13)
  @JsonKey(defaultValue: <Series>[])
  final List<Series> series;

  Playlist({
    required this.id,
    required this.name,
    required this.server,
    required this.username,
    required this.password,
    required this.isValid,
    required this.createdAt,
    this.expiresAt,
    this.liveCategories = const [],
    this.liveChannels = const [],
    this.epgCache = const {},
    this.vodCategories = const [],
    this.vodMovies = const [],
    this.seriesCategories = const [],
    this.series = const [],
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
    DateTime? expiresAt,
    List<LiveTvCategory>? liveCategories,
    List<LiveTvChannel>? liveChannels,
    Map<String, List<EpgListing>>? epgCache,
    List<VodCategory>? vodCategories,
    List<VodMovie>? vodMovies,
    List<SeriesCategory>? seriesCategories,
    List<Series>? series,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      server: server ?? this.server,
      username: username ?? this.username,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      liveCategories: liveCategories ?? this.liveCategories,
      liveChannels: liveChannels ?? this.liveChannels,
      epgCache: epgCache ?? this.epgCache,
      vodCategories: vodCategories ?? this.vodCategories,
      vodMovies: vodMovies ?? this.vodMovies,
      seriesCategories: seriesCategories ?? this.seriesCategories,
      series: series ?? this.series,
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
