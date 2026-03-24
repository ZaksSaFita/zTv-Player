import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/xtream_parser.dart';
import 'package:ztv_player/models/live_tv_channel.dart';
import 'package:ztv_player/models/live_tv_category.dart';
import 'package:ztv_player/models/playlist.dart';
import 'package:ztv_player/services/settings_service.dart';

class PlaylistLoadRequest {
  final String name;
  final String server;
  final String username;
  final String password;

  const PlaylistLoadRequest({
    required this.name,
    required this.server,
    required this.username,
    required this.password,
  });
}

class PlaylistLoadResult {
  final Playlist playlist;
  final int liveChannelCount;

  const PlaylistLoadResult({
    required this.playlist,
    required this.liveChannelCount,
  });
}

class PlaylistService {
  const PlaylistService({this.settingsService = const SettingsService()});

  final SettingsService settingsService;

  Future<PlaylistLoadResult> createAndSavePlaylist(
    PlaylistLoadRequest request, {
    void Function(String status)? onStatusChanged,
  }) async {
    final parser = XtreamParser(
      server: request.server,
      username: request.username,
      password: request.password,
    );

    onStatusChanged?.call('Testing connection...');
    await _validateConnection(request);

    onStatusChanged?.call('Connection OK. Saving playlist...');
    final playlist = await _savePlaylist(request);

    onStatusChanged?.call('Loading Live TV categories...');
    final liveCategories = await parser.getLiveCategories();
    await _saveLiveCategories(liveCategories);

    onStatusChanged?.call('Loading Live TV channels...');
    final liveChannels = await parser.getLiveChannels();
    await _saveLiveChannels(liveChannels);

    onStatusChanged?.call('Calculating channel counts...');
    await _updateCategoryChannelCounts(
      liveCategories: liveCategories,
      liveChannels: liveChannels,
    );

    onStatusChanged?.call('Playlist successfully loaded!');

    return PlaylistLoadResult(
      playlist: playlist,
      liveChannelCount: liveChannels.length,
    );
  }

  Future<void> _validateConnection(PlaylistLoadRequest request) async {
    final m3uUrl =
        '${request.server}/get.php?username=${request.username}&password=${request.password}&type=m3u_plus';
    final response = await Dio().get(m3uUrl);

    if (response.statusCode != 200 || response.data.toString().length < 500) {
      throw Exception('Invalid playlist from server');
    }
  }

  Future<Playlist> _savePlaylist(PlaylistLoadRequest request) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: request.name.isNotEmpty ? request.name : 'My Playlist',
      server: request.server,
      username: request.username,
      password: request.password,
    );

    final playlistBox = Hive.box<Playlist>('playlists');
    await playlistBox.put(playlist.id, playlist);
    settingsService.setCurrentPlaylist(playlist);
    return playlist;
  }

  Future<void> _saveLiveCategories(List<LiveTvCategory> categories) async {
    final liveCatBox = Hive.box<LiveTvCategory>('live_categories');
    await liveCatBox.clear();
    for (final category in categories) {
      await liveCatBox.put(category.id, category);
    }
  }

  Future<void> _saveLiveChannels(List<LiveTvChannel> channels) async {
    final liveChanBox = Hive.box<LiveTvChannel>('live_channels');
    await liveChanBox.clear();
    for (final channel in channels) {
      await liveChanBox.put(channel.id, channel);
    }
  }

  Future<void> _updateCategoryChannelCounts({
    required List<LiveTvCategory> liveCategories,
    required List<LiveTvChannel> liveChannels,
  }) async {
    final countMap = <String, int>{};
    for (final channel in liveChannels) {
      countMap[channel.categoryId] = (countMap[channel.categoryId] ?? 0) + 1;
    }

    for (final category in liveCategories) {
      category.channelCount = countMap[category.id] ?? 0;
      await category.save();
    }
  }
}
