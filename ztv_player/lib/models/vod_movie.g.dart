// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vod_movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VodMovieAdapter extends TypeAdapter<VodMovie> {
  @override
  final int typeId = 4;

  @override
  VodMovie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VodMovie(
      id: fields[0] as String,
      name: fields[1] as String,
      categoryId: fields[2] as String,
      logoUrl: fields[3] as String?,
      streamUrl: fields[4] as String?,
      plot: fields[5] as String?,
      year: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VodMovie obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.plot)
      ..writeByte(6)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VodMovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
