// lib/models/live_category.dart
import 'package:hive_flutter/hive_flutter.dart';

part 'live_category.g.dart';

@HiveType(typeId: 1)
class LiveCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  int channelCount; // opcionalno, koliko kanala ima u kategoriji

  LiveCategory({required this.id, required this.name, this.channelCount = 0});

  // factory LiveCategory.fromJson(Map<String, dynamic> json) {
  //   return LiveCategory(
  //     id: json['category_id']?.toString() ?? '0',
  //     name:
  //         json['category_name']?.toString() ??
  //         json['name']?.toString() ??
  //         'Nepoznato',
  //     channelCount: 0,
  //   );
  // }
}
