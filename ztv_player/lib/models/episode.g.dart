// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EpisodeAdapter extends TypeAdapter<Episode> {
  @override
  final int typeId = 8;

  @override
  Episode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Episode(
      id: fields[0] as String,
      name: fields[1] as String,
      seasonNumber: fields[2] as int,
      episodeNumber: fields[3] as int,
      logoUrl: fields[4] as String?,
      streamUrl: fields[5] as String?,
      plot: fields[6] as String?,
      duration: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Episode obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.seasonNumber)
      ..writeByte(3)
      ..write(obj.episodeNumber)
      ..writeByte(4)
      ..write(obj.logoUrl)
      ..writeByte(5)
      ..write(obj.streamUrl)
      ..writeByte(6)
      ..write(obj.plot)
      ..writeByte(7)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Episode _$EpisodeFromJson(Map<String, dynamic> json) => Episode(
      id: Episode._idFromJson(json['id']),
      name: json['title'] as String,
      seasonNumber: JsonHelpers.asInt(json['season']),
      episodeNumber: JsonHelpers.asInt(json['episode_num']),
      logoUrl: Episode._readMovieImage(json, 'logoUrl') as String?,
      streamUrl: json['direct_source'] as String?,
      plot: Episode._readPlot(json, 'plot') as String?,
      duration: Episode._readDuration(json, 'duration') as String?,
    );

Map<String, dynamic> _$EpisodeToJson(Episode instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.name,
      'season': instance.seasonNumber,
      'episode_num': instance.episodeNumber,
      'logoUrl': instance.logoUrl,
      'direct_source': instance.streamUrl,
      'plot': instance.plot,
      'duration': instance.duration,
    };
