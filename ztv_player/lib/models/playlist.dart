// lib/models/playlist.dart
import 'package:hive_flutter/hive_flutter.dart';

part 'playlist.g.dart';

@HiveType(typeId: 0)
class Playlist extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String server;

  @HiveField(3)
  final String username;

  @HiveField(4)
  final String password;

  Playlist({
    required this.id,
    required this.name,
    required this.server,
    required this.username,
    required this.password,
  });
}
