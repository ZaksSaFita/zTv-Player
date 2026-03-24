import 'package:json_annotation/json_annotation.dart';
import 'epg_listing.dart';

part 'epg_response.g.dart';

@JsonSerializable()
class EpgResponse {
  @JsonKey(name: 'epg_listings')
  final List<EpgListing> epgListings;

  EpgResponse({required this.epgListings});

  factory EpgResponse.fromJson(Map<String, dynamic> json) =>
      _$EpgResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EpgResponseToJson(this);
}
