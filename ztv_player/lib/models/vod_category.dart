// lib/models/vod_category.dart
import 'package:hive_flutter/hive_flutter.dart';

part 'vod_category.g.dart';

@HiveType(typeId: 3)
class VodCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int? movieCount;

  VodCategory({required this.id, required this.name, this.movieCount});
}
