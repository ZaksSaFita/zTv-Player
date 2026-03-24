// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeasonAdapter extends TypeAdapter<Season> {
  @override
  final int typeId = 7;

  @override
  Season read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Season(
      seasonNumber: fields[0] as int,
      episodes: (fields[1] as List).cast<Episode>(),
      name: fields[2] as String?,
      overview: fields[3] as String?,
      coverUrl: fields[4] as String?,
      episodeCount: fields[5] as int?,
      voteAverage: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Season obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.seasonNumber)
      ..writeByte(1)
      ..write(obj.episodes)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.overview)
      ..writeByte(4)
      ..write(obj.coverUrl)
      ..writeByte(5)
      ..write(obj.episodeCount)
      ..writeByte(6)
      ..write(obj.voteAverage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Season _$SeasonFromJson(Map<String, dynamic> json) => Season(
      seasonNumber: JsonHelpers.asInt(json['season_number'], fallback: 1),
      episodes: json['episodes'] == null
          ? []
          : Season._episodesFromJson(json['episodes']),
      name: JsonHelpers.asNullableString(json['name']),
      overview: JsonHelpers.asNullableString(json['overview']),
      coverUrl: JsonHelpers.asNullableString(json['cover_big'] ?? json['cover']),
      episodeCount: JsonHelpers.asNullableInt(json['episode_count']),
      voteAverage: Season._voteAverageFromJson(json['vote_average']),
    );

Map<String, dynamic> _$SeasonToJson(Season instance) => <String, dynamic>{
      'season_number': instance.seasonNumber,
      'episodes': instance.episodes.map((e) => e.toJson()).toList(),
      'name': instance.name,
      'overview': instance.overview,
      'cover_big': instance.coverUrl,
      'episode_count': instance.episodeCount,
      'vote_average': instance.voteAverage,
    };
