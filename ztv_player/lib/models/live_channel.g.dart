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
