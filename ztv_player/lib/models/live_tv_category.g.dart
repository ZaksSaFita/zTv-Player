// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_tv_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LiveTvCategoryAdapter extends TypeAdapter<LiveTvCategory> {
  @override
  final int typeId = 1;

  @override
  LiveTvCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LiveTvCategory(
      id: fields[0] as String,
      name: fields[1] as String,
      channelCount: fields[2] as int,
      parentId: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LiveTvCategory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.channelCount)
      ..writeByte(3)
      ..write(obj.parentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveTvCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveTvCategory _$LiveTvCategoryFromJson(Map<String, dynamic> json) =>
    LiveTvCategory(
      id: _liveTvCategoryIdFromJson(json['category_id']),
      name: json['category_name'] as String? ?? 'Unknown',
      parentId:
          json['parent_id'] == null ? 0 : JsonHelpers.asInt(json['parent_id']),
    );

Map<String, dynamic> _$LiveTvCategoryToJson(LiveTvCategory instance) =>
    <String, dynamic>{
      'category_id': instance.id,
      'category_name': instance.name,
      'parent_id': instance.parentId,
    };
