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
    );
  }

  @override
  void write(BinaryWriter writer, Season obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.seasonNumber)
      ..writeByte(1)
      ..write(obj.episodes);
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
      seasonNumber: (json['season_number'] as num).toInt(),
      episodes: json['episodes'] == null
          ? []
          : Season._episodesFromJson(json['episodes']),
    );

Map<String, dynamic> _$SeasonToJson(Season instance) => <String, dynamic>{
      'season_number': instance.seasonNumber,
      'episodes': instance.episodes.map((e) => e.toJson()).toList(),
    };
