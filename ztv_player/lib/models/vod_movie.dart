// lib/models/vod_movie.dart
import 'package:hive_flutter/hive_flutter.dart';

part 'vod_movie.g.dart';

@HiveType(typeId: 4)
class VodMovie extends HiveObject {
  @HiveField(0)
  final String id; // stream_id

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String categoryId;

  @HiveField(3)
  final String? logoUrl;

  @HiveField(4)
  final String? streamUrl; // pun URL za play

  @HiveField(5)
  final String? plot; // opis filma (opcionalno)

  @HiveField(6)
  final String? year; // godina

  VodMovie({
    required this.id,
    required this.name,
    required this.categoryId,
    this.logoUrl,
    this.streamUrl,
    this.plot,
    this.year,
  });
}
