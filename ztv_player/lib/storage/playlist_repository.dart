import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/models/live_tv_category.dart';
import 'package:ztv_player/models/live_tv_channel.dart';
import 'package:ztv_player/models/playlist.dart';

class PlaylistRepository {
  const PlaylistRepository();

  static const int maxPlaylists = 5;
  static const String _activePlaylistIdKey = 'activePlaylistId';

  Box<Playlist> get _playlistBox => Hive.box<Playlist>('playlists');
  Box get _settingsBox => Hive.box('settings');
  Box<LiveTvCategory> get _liveCategoryBox =>
      Hive.box<LiveTvCategory>('live_categories');
  Box<LiveTvChannel> get _liveChannelBox =>
      Hive.box<LiveTvChannel>('live_channels');

  List<Playlist> getAllPlaylists() {
    return _playlistBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  String? getActivePlaylistId() {
    final value = _settingsBox.get(_activePlaylistIdKey);
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    final legacyIndex = _settingsBox.get('currentPlaylist');
    if (legacyIndex is int &&
        legacyIndex >= 0 &&
        legacyIndex < _playlistBox.length) {
      return _playlistBox.getAt(legacyIndex)?.id;
    }

    return null;
  }

  Playlist? getActivePlaylist() {
    final activeId = getActivePlaylistId();
    if (activeId == null) {
      return getAllPlaylists().isEmpty ? null : getAllPlaylists().first;
    }

    return _playlistBox.get(activeId);
  }

  bool canCreatePlaylist() => _playlistBox.length < maxPlaylists;

  Future<void> initialize() async {
    final playlists = getAllPlaylists();
    if (playlists.isEmpty) {
      await clearActivePlaylist();
      return;
    }

    final activeId = getActivePlaylistId();
    final activePlaylist =
        activeId == null ? playlists.first : _playlistBox.get(activeId);

    await setActivePlaylist(activePlaylist?.id ?? playlists.first.id);
    await _settingsBox.delete('currentPlaylist');
  }

  Future<void> savePlaylist(
    Playlist playlist, {
    bool setAsActive = true,
  }) async {
    final alreadyExists = _playlistBox.containsKey(playlist.id);
    if (!alreadyExists && _playlistBox.length >= maxPlaylists) {
      throw Exception('Maximum of 5 playlists reached.');
    }

    await _playlistBox.put(playlist.id, playlist);
    if (setAsActive) {
      await setActivePlaylist(playlist.id);
    }
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    await _playlistBox.put(playlist.id, playlist);
    if (playlist.id == getActivePlaylistId()) {
      await _hydrateActiveSnapshot(playlist);
    }
  }

  Future<void> setActivePlaylist(String? playlistId) async {
    if (playlistId == null) {
      await clearActivePlaylist();
      return;
    }

    final playlist = _playlistBox.get(playlistId);
    if (playlist == null) {
      throw Exception('Playlist not found.');
    }

    await _settingsBox.put(_activePlaylistIdKey, playlistId);
    await _hydrateActiveSnapshot(playlist);
  }

  Future<void> clearActivePlaylist() async {
    await _settingsBox.delete(_activePlaylistIdKey);
    await _liveCategoryBox.clear();
    await _liveChannelBox.clear();
  }

  Future<void> deletePlaylist(String playlistId) async {
    final wasActive = getActivePlaylistId() == playlistId;
    await _playlistBox.delete(playlistId);

    if (_playlistBox.isEmpty) {
      await clearActivePlaylist();
      return;
    }

    if (wasActive) {
      final fallback = getAllPlaylists().first;
      await setActivePlaylist(fallback.id);
    }
  }

  Future<void> cacheEpg({
    required String playlistId,
    required String streamId,
    required List<EpgListing> listings,
  }) async {
    final playlist = _playlistBox.get(playlistId);
    if (playlist == null) {
      return;
    }

    final nextCache = Map<String, List<EpgListing>>.from(playlist.epgCache);
    nextCache[streamId] = listings;
    await updatePlaylist(playlist.copyWith(epgCache: nextCache));
  }

  Future<void> _hydrateActiveSnapshot(Playlist playlist) async {
    await _liveCategoryBox.clear();
    await _liveChannelBox.clear();

    for (final category in playlist.liveCategories) {
      await _liveCategoryBox.put(category.id, category);
    }

    for (final channel in playlist.liveChannels) {
      await _liveChannelBox.put(channel.id, channel);
    }
  }
}
