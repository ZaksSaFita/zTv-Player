// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeriesAdapter extends TypeAdapter<Series> {
  @override
  final int typeId = 6;

  @override
  Series read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Series(
      id: fields[0] as String,
      name: fields[1] as String,
      categoryId: fields[2] as String,
      logoUrl: fields[3] as String?,
      plot: fields[4] as String?,
      year: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Series obj) {
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
      ..write(obj.plot)
      ..writeByte(5)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeriesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
