// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epg_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EpgResponse _$EpgResponseFromJson(Map<String, dynamic> json) => EpgResponse(
      epgListings: (json['epg_listings'] as List<dynamic>)
          .map((e) => EpgListing.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EpgResponseToJson(EpgResponse instance) =>
    <String, dynamic>{
      'epg_listings': instance.epgListings,
    };
