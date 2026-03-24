import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/theme.dart';
import 'package:ztv_player/models/playlist.dart';

class SettingsService {
  const SettingsService();

  Box get _settingsBox => Hive.box('settings');
  Box<Playlist> get _playlistBox => Hive.box<Playlist>('playlists');

  Playlist? getCurrentPlaylist() {
    final currentPlaylistIndex =
        _settingsBox.get('currentPlaylist', defaultValue: -1) as int;

    if (currentPlaylistIndex >= 0 &&
        currentPlaylistIndex < _playlistBox.length) {
      return _playlistBox.getAt(currentPlaylistIndex);
    }

    if (_playlistBox.isNotEmpty) {
      final fallback = _playlistBox.getAt(0);
      if (fallback != null) {
        _settingsBox.put('currentPlaylist', 0);
      }
      return fallback;
    }

    return null;
  }

  List<Playlist> getPlaylists() {
    return _playlistBox.values.toList();
  }

  void saveTheme(AppThemeType type) {
    AppTheme.notifier.value = type;
    _settingsBox.put('theme', type.index);
  }

  void setCurrentPlaylist(Playlist? playlist) {
    if (playlist == null) {
      _settingsBox.put('currentPlaylist', -1);
      return;
    }

    final index = _playlistBox.values.toList().indexOf(playlist);
    if (index != -1) {
      _settingsBox.put('currentPlaylist', index);
    }
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    final index = _playlistBox.values.toList().indexOf(playlist);
    if (index != -1) {
      await _playlistBox.deleteAt(index);
    }
  }
}
