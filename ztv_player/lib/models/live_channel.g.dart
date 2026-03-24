// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_channel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LiveChannelAdapter extends TypeAdapter<LiveChannel> {
  @override
  final int typeId = 2;

  @override
  LiveChannel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LiveChannel(
      id: fields[0] as String,
      name: fields[1] as String,
      categoryId: fields[2] as String,
      logoUrl: fields[3] as String?,
      streamUrl: fields[4] as String?,
      num: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, LiveChannel obj) {
    writer
      ..writeByte(6)
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
      ..write(obj.num);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveChannelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveChannel _$LiveChannelFromJson(Map<String, dynamic> json) => LiveChannel(
      id: LiveChannel._idFromJson(json['stream_id']),
      name: json['name'] as String,
      categoryId: LiveChannel._idFromJson(json['category_id']),
      logoUrl: json['stream_icon'] as String?,
      streamUrl: json['direct_source'] as String?,
      num: JsonHelpers.asNullableInt(json['num']),
    );

Map<String, dynamic> _$LiveChannelToJson(LiveChannel instance) =>
    <String, dynamic>{
      'stream_id': instance.id,
      'name': instance.name,
      'category_id': instance.categoryId,
      'stream_icon': instance.logoUrl,
      'direct_source': instance.streamUrl,
      'num': instance.num,
    };
