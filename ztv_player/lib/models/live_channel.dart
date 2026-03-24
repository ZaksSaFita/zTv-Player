// lib/models/live_channel.dart
import 'package:hive_flutter/hive_flutter.dart';

part 'live_channel.g.dart';

@HiveType(typeId: 2)
class LiveChannel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String categoryId;

  @HiveField(3)
  final String? logoUrl;

  @HiveField(4)
  final String? streamUrl;

  @HiveField(5)
  final int? num;

  LiveChannel({
    required this.id,
    required this.name,
    required this.categoryId,
    this.logoUrl,
    this.streamUrl,
    this.num,
  });
}
