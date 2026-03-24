// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epg_listing.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EpgListingAdapter extends TypeAdapter<EpgListing> {
  @override
  final int typeId = 10;

  @override
  EpgListing read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EpgListing(
      id: fields[0] as String,
      epgId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      lang: fields[4] as String,
      start: fields[5] as DateTime,
      end: fields[6] as DateTime,
      channelId: fields[7] as String,
      startTimestamp: fields[8] as int?,
      stopTimestamp: fields[9] as int?,
      nowPlaying: fields[10] as bool,
      hasArchive: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, EpgListing obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.epgId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.lang)
      ..writeByte(5)
      ..write(obj.start)
      ..writeByte(6)
      ..write(obj.end)
      ..writeByte(7)
      ..write(obj.channelId)
      ..writeByte(8)
      ..write(obj.startTimestamp)
      ..writeByte(9)
      ..write(obj.stopTimestamp)
      ..writeByte(10)
      ..write(obj.nowPlaying)
      ..writeByte(11)
      ..write(obj.hasArchive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpgListingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EpgListing _$EpgListingFromJson(Map<String, dynamic> json) => EpgListing(
      id: EpgListing._idFromJson(json['id']),
      epgId: EpgListing._idFromJson(json['epg_id']),
      title: EpgListing._decodeBase64(json['title']),
      description: EpgListing._decodeBase64(json['description']),
      lang: json['lang'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      channelId: EpgListing._idFromJson(json['channel_id']),
      startTimestamp: JsonHelpers.asNullableInt(json['start_timestamp']),
      stopTimestamp: JsonHelpers.asNullableInt(json['stop_timestamp']),
      nowPlaying: json['now_playing'] == null
          ? false
          : EpgListing._boolFromInt(json['now_playing']),
      hasArchive: json['has_archive'] == null
          ? false
          : EpgListing._boolFromInt(json['has_archive']),
    );

Map<String, dynamic> _$EpgListingToJson(EpgListing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'epg_id': instance.epgId,
      'title': instance.title,
      'description': instance.description,
      'lang': instance.lang,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'channel_id': instance.channelId,
      'start_timestamp': instance.startTimestamp,
      'stop_timestamp': instance.stopTimestamp,
      'now_playing': instance.nowPlaying,
      'has_archive': instance.hasArchive,
    };
