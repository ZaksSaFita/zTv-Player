// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeriesCategoryAdapter extends TypeAdapter<SeriesCategory> {
  @override
  final int typeId = 5;

  @override
  SeriesCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeriesCategory(
      id: fields[0] as String,
      name: fields[1] as String,
      seriesCount: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SeriesCategory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.seriesCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeriesCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeriesCategory _$SeriesCategoryFromJson(Map<String, dynamic> json) =>
    SeriesCategory(
      id: SeriesCategory._idFromJson(json['category_id']),
      name: JsonHelpers.asString(json['category_name'], fallback: 'Unknown'),
    );

Map<String, dynamic> _$SeriesCategoryToJson(SeriesCategory instance) =>
    <String, dynamic>{
      'category_id': instance.id,
      'category_name': instance.name,
    };
