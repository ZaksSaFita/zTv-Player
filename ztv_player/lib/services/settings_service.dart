import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/theme.dart';
import 'package:ztv_player/models/playlist.dart';
import 'package:ztv_player/storage/playlist_repository.dart';

class SettingsService {
  const SettingsService({
    PlaylistRepository repository = const PlaylistRepository(),
  }) : _repository = repository;

  final PlaylistRepository _repository;
  Box get _settingsBox => Hive.box('settings');

  Playlist? getCurrentPlaylist() {
    return _repository.getActivePlaylist();
  }

  List<Playlist> getPlaylists() {
    return _repository.getAllPlaylists();
  }

  void saveTheme(AppThemeType type) {
    AppTheme.notifier.value = type;
    _settingsBox.put('theme', type.index);
  }

  Future<void> setCurrentPlaylist(Playlist? playlist) {
    return _repository.setActivePlaylist(playlist?.id);
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    await _repository.deletePlaylist(playlist.id);
  }
}
