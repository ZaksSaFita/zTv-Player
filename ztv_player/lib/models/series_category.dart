// lib/models/series_category.dart
import 'package:hive_flutter/hive_flutter.dart';

part 'series_category.g.dart';

@HiveType(typeId: 5)
class SeriesCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  SeriesCategory({required this.id, required this.name});
}
