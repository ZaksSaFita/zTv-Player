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
      num: fields[6] as int?,
      rating: fields[7] as String?,
      genre: fields[8] as String?,
      cast: fields[9] as String?,
      director: fields[10] as String?,
      backdropUrl: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Series obj) {
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
      ..write(obj.plot)
      ..writeByte(5)
      ..write(obj.year)
      ..writeByte(6)
      ..write(obj.num)
      ..writeByte(7)
      ..write(obj.rating)
      ..writeByte(8)
      ..write(obj.genre)
      ..writeByte(9)
      ..write(obj.cast)
      ..writeByte(10)
      ..write(obj.director)
      ..writeByte(11)
      ..write(obj.backdropUrl);
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Series _$SeriesFromJson(Map<String, dynamic> json) => Series(
      id: Series._idFromJson(json['series_id']),
      name: Series._nameFromJson(json['name']),
      categoryId: Series._idFromJson(json['category_id']),
      logoUrl: JsonHelpers.asNullableString(json['cover']),
      plot: JsonHelpers.asNullableString(json['plot']),
      year: JsonHelpers.yearFromDate(json['releaseDate']),
      num: JsonHelpers.asNullableInt(json['num']),
      rating: Series._ratingFromJson(json['rating']),
      genre: JsonHelpers.asNullableString(json['genre']),
      cast: JsonHelpers.asNullableString(json['cast']),
      director: JsonHelpers.asNullableString(json['director']),
      backdropUrl: JsonHelpers.asNullableString(
        Series._readBackdrop(json, 'backdropUrl'),
      ),
    );

Map<String, dynamic> _$SeriesToJson(Series instance) => <String, dynamic>{
      'series_id': instance.id,
      'name': instance.name,
      'category_id': instance.categoryId,
      'cover': instance.logoUrl,
      'plot': instance.plot,
      'releaseDate': instance.year,
      'num': instance.num,
      'rating': instance.rating,
      'genre': instance.genre,
      'cast': instance.cast,
      'director': instance.director,
      'backdropUrl': instance.backdropUrl,
    };
