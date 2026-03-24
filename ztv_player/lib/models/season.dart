// lib/models/season.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'episode.dart'; // ← dodaj ovaj import

part 'season.g.dart';

@HiveType(typeId: 7)
class Season extends HiveObject {
  @HiveField(0)
  final int seasonNumber;

  @HiveField(1)
  final List<Episode> episodes;

  Season({required this.seasonNumber, required this.episodes});
}
