// lib/models/series.dart
import 'package:hive_flutter/hive_flutter.dart';

part 'series.g.dart';

@HiveType(typeId: 6)
class Series extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String categoryId;

  @HiveField(3)
  final String? logoUrl;

  @HiveField(4)
  final String? plot;

  @HiveField(5)
  final String? year;

  Series({
    required this.id,
    required this.name,
    required this.categoryId,
    this.logoUrl,
    this.plot,
    this.year,
  });
}
