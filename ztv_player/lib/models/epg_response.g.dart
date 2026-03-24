// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epg_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EpgResponse _$EpgResponseFromJson(Map<String, dynamic> json) => EpgResponse(
      epgListings: JsonHelpers.asMapList(json['epg_listings'])
          .map(EpgListing.fromJson)
          .toList(),
    );

Map<String, dynamic> _$EpgResponseToJson(EpgResponse instance) =>
    <String, dynamic>{
      'epg_listings': instance.epgListings,
    };
