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
      num: fields[7] as int?,
      rating: fields[8] as String?,
      added: fields[9] as String?,
      containerExtension: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VodMovie obj) {
    writer
      ..writeByte(11)
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
      ..write(obj.year)
      ..writeByte(7)
      ..write(obj.num)
      ..writeByte(8)
      ..write(obj.rating)
      ..writeByte(9)
      ..write(obj.added)
      ..writeByte(10)
      ..write(obj.containerExtension);
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VodMovie _$VodMovieFromJson(Map<String, dynamic> json) => VodMovie(
      id: VodMovie._idFromJson(json['stream_id']),
      name: VodMovie._nameFromJson(json['name']),
      categoryId: VodMovie._idFromJson(json['category_id']),
      logoUrl: JsonHelpers.asNullableString(json['stream_icon']),
      streamUrl: JsonHelpers.asNullableString(json['direct_source']),
      plot: JsonHelpers.asNullableString(json['plot']),
      year: JsonHelpers.yearFromDate(json['releaseDate']),
      num: JsonHelpers.asNullableInt(json['num']),
      rating: VodMovie._ratingFromJson(json['rating']),
      added: JsonHelpers.asNullableString(json['added']),
      containerExtension: JsonHelpers.asNullableString(
        json['container_extension'],
      ),
    );

Map<String, dynamic> _$VodMovieToJson(VodMovie instance) => <String, dynamic>{
      'stream_id': instance.id,
      'name': instance.name,
      'category_id': instance.categoryId,
      'stream_icon': instance.logoUrl,
      'direct_source': instance.streamUrl,
      'plot': instance.plot,
      'releaseDate': instance.year,
      'num': instance.num,
      'rating': instance.rating,
      'added': instance.added,
      'container_extension': instance.containerExtension,
    };
