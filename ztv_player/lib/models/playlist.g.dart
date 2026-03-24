// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaylistAdapter extends TypeAdapter<Playlist> {
  @override
  final int typeId = 0;

  @override
  Playlist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Playlist(
      id: fields[0] as String,
      name: fields[1] as String,
      server: fields[2] as String,
      username: fields[3] as String,
      password: fields[4] as String,
      isValid: fields[5] as bool? ?? true,
      createdAt:
          fields[6] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0),
      expiresAt: fields[14] as DateTime?,
      liveCategories:
          (fields[7] as List?)?.cast<LiveTvCategory>() ??
          const <LiveTvCategory>[],
      liveChannels:
          (fields[8] as List?)?.cast<LiveTvChannel>() ??
          const <LiveTvChannel>[],
      epgCache: ((fields[9] as Map?) ?? const <String, List<EpgListing>>{}).map(
        (dynamic key, dynamic value) => MapEntry(
          key as String,
          (value as List).cast<EpgListing>(),
        ),
      ),
      vodCategories:
          (fields[10] as List?)?.cast<VodCategory>() ?? const <VodCategory>[],
      vodMovies: (fields[11] as List?)?.cast<VodMovie>() ?? const <VodMovie>[],
      seriesCategories:
          (fields[12] as List?)?.cast<SeriesCategory>() ??
          const <SeriesCategory>[],
      series: (fields[13] as List?)?.cast<Series>() ?? const <Series>[],
    );
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.server)
      ..writeByte(3)
      ..write(obj.username)
      ..writeByte(4)
      ..write(obj.password)
      ..writeByte(5)
      ..write(obj.isValid)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.expiresAt)
      ..writeByte(7)
      ..write(obj.liveCategories)
      ..writeByte(8)
      ..write(obj.liveChannels)
      ..writeByte(9)
      ..write(obj.epgCache)
      ..writeByte(10)
      ..write(obj.vodCategories)
      ..writeByte(11)
      ..write(obj.vodMovies)
      ..writeByte(12)
      ..write(obj.seriesCategories)
      ..writeByte(13)
      ..write(obj.series);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Playlist _$PlaylistFromJson(Map<String, dynamic> json) => Playlist(
  id: json['id'] as String,
  name: json['name'] as String,
  server: json['server'] as String,
  username: json['username'] as String,
  password: json['password'] as String,
  isValid: json['isValid'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? DateTime.fromMillisecondsSinceEpoch(0)
      : DateTime.parse(json['createdAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  liveCategories:
      (json['liveCategories'] as List<dynamic>?)
          ?.map((e) => LiveTvCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <LiveTvCategory>[],
  liveChannels:
      (json['liveChannels'] as List<dynamic>?)
          ?.map((e) => LiveTvChannel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <LiveTvChannel>[],
  epgCache:
      json['epgCache'] == null
          ? const <String, List<EpgListing>>{}
          : Playlist._epgCacheFromJson(json['epgCache']),
  vodCategories:
      (json['vodCategories'] as List<dynamic>?)
          ?.map((e) => VodCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <VodCategory>[],
  vodMovies:
      (json['vodMovies'] as List<dynamic>?)
          ?.map((e) => VodMovie.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <VodMovie>[],
  seriesCategories:
      (json['seriesCategories'] as List<dynamic>?)
          ?.map((e) => SeriesCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SeriesCategory>[],
  series:
      (json['series'] as List<dynamic>?)
          ?.map((e) => Series.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Series>[],
);

Map<String, dynamic> _$PlaylistToJson(Playlist instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'server': instance.server,
  'username': instance.username,
  'password': instance.password,
  'isValid': instance.isValid,
  'createdAt': instance.createdAt.toIso8601String(),
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'liveCategories': instance.liveCategories.map((e) => e.toJson()).toList(),
  'liveChannels': instance.liveChannels.map((e) => e.toJson()).toList(),
  'epgCache': Playlist._epgCacheToJson(instance.epgCache),
  'vodCategories': instance.vodCategories.map((e) => e.toJson()).toList(),
  'vodMovies': instance.vodMovies.map((e) => e.toJson()).toList(),
  'seriesCategories': instance.seriesCategories.map((e) => e.toJson()).toList(),
  'series': instance.series.map((e) => e.toJson()).toList(),
};
