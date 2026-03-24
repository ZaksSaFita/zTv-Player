// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_tv_channel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LiveTvChannelAdapter extends TypeAdapter<LiveTvChannel> {
  @override
  final int typeId = 2;

  @override
  LiveTvChannel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LiveTvChannel(
      id: fields[0] as String,
      name: fields[1] as String,
      categoryId: fields[2] as String,
      logoUrl: fields[3] as String?,
      streamUrl: fields[4] as String?,
      num: fields[5] as int?,
      streamType: fields[6] as String,
      epgChannelId: fields[7] as String?,
      added: fields[8] as String?,
      customSid: fields[9] as String?,
      hasArchive: fields[10] as bool,
      archiveDuration: fields[11] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, LiveTvChannel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.categoryId)
      ..writeByte(3)
      ..write(obj.logoUrl)
      ..writeByte(4)
      ..write(obj.streamUrl)
      ..writeByte(5)
      ..write(obj.num)
      ..writeByte(6)
      ..write(obj.streamType)
      ..writeByte(7)
      ..write(obj.epgChannelId)
      ..writeByte(8)
      ..write(obj.added)
      ..writeByte(9)
      ..write(obj.customSid)
      ..writeByte(10)
      ..write(obj.hasArchive)
      ..writeByte(11)
      ..write(obj.archiveDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveTvChannelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveTvChannel _$LiveTvChannelFromJson(Map<String, dynamic> json) =>
    LiveTvChannel(
      id: _channelIdFromJson(json['stream_id']),
      name: _channelNameFromJson(json['name']),
      categoryId: _channelIdFromJson(json['category_id']),
      logoUrl: JsonHelpers.asNullableString(json['stream_icon']),
      streamUrl: JsonHelpers.asNullableString(json['direct_source']),
      num: JsonHelpers.asNullableInt(json['num']),
      streamType: _streamTypeFromJson(json['stream_type']),
      epgChannelId: JsonHelpers.asNullableString(json['epg_channel_id']),
      added: JsonHelpers.asNullableString(json['added']),
      customSid: JsonHelpers.asNullableString(json['custom_sid']),
      hasArchive: json['tv_archive'] == null
          ? false
          : _channelBoolFromInt(json['tv_archive']),
      archiveDuration: JsonHelpers.asNullableInt(json['tv_archive_duration']),
    );

Map<String, dynamic> _$LiveTvChannelToJson(LiveTvChannel instance) =>
    <String, dynamic>{
      'stream_id': instance.id,
      'name': instance.name,
      'category_id': instance.categoryId,
      'stream_icon': instance.logoUrl,
      'direct_source': instance.streamUrl,
      'num': instance.num,
      'stream_type': instance.streamType,
      'epg_channel_id': instance.epgChannelId,
      'added': instance.added,
      'custom_sid': instance.customSid,
      'tv_archive': instance.hasArchive,
      'tv_archive_duration': instance.archiveDuration,
    };
