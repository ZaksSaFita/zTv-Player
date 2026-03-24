import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'episode.dart';

part 'season.g.dart';

@HiveType(typeId: 7)
@JsonSerializable(explicitToJson: true)
class Season extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'season_number')
  final int seasonNumber;

  @HiveField(1)
  @JsonKey(fromJson: _episodesFromJson, defaultValue: <Episode>[])
  final List<Episode> episodes;

  Season({required this.seasonNumber, required this.episodes});

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);

  Map<String, dynamic> toJson() => _$SeasonToJson(this);

  static List<Episode> _episodesFromJson(dynamic value) {
    if (value is List) {
      return value
          .map((item) => Episode.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    return <Episode>[];
  }
}
