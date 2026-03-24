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
    );
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer
      ..writeByte(10)
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
      ..writeByte(7)
      ..write(obj.liveCategories)
      ..writeByte(8)
      ..write(obj.liveChannels)
      ..writeByte(9)
      ..write(obj.epgCache);
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
);

Map<String, dynamic> _$PlaylistToJson(Playlist instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'server': instance.server,
  'username': instance.username,
  'password': instance.password,
  'isValid': instance.isValid,
  'createdAt': instance.createdAt.toIso8601String(),
  'liveCategories': instance.liveCategories.map((e) => e.toJson()).toList(),
  'liveChannels': instance.liveChannels.map((e) => e.toJson()).toList(),
  'epgCache': Playlist._epgCacheToJson(instance.epgCache),
};
