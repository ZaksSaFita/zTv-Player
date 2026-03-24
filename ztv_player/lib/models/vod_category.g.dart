// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vod_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VodCategoryAdapter extends TypeAdapter<VodCategory> {
  @override
  final int typeId = 3;

  @override
  VodCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VodCategory(
      id: fields[0] as String,
      name: fields[1] as String,
      movieCount: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, VodCategory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.movieCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VodCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
