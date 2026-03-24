// lib/models/episode.dart
import 'package:hive_flutter/hive_flutter.dart';

part 'episode.g.dart';

@HiveType(typeId: 8)
class Episode extends HiveObject {
  @HiveField(0)
  final String id; // stream_id

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int seasonNumber;

  @HiveField(3)
  final int episodeNumber;

  @HiveField(4)
  final String? logoUrl;

  @HiveField(5)
  final String? streamUrl; // pun URL za reprodukciju

  @HiveField(6)
  final String? plot; // opis epizode

  @HiveField(7)
  final String? duration; // trajanje

  Episode({
    required this.id,
    required this.name,
    required this.seasonNumber,
    required this.episodeNumber,
    this.logoUrl,
    this.streamUrl,
    this.plot,
    this.duration,
  });
}
