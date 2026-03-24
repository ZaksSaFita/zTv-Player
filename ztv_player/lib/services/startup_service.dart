import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/models/playlist.dart';

class StartupService {
  const StartupService();

  Future<bool> hasSavedPlaylist() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Hive.box<Playlist>('playlists').isNotEmpty;
  }
}
