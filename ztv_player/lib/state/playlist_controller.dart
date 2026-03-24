import 'package:flutter/foundation.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/models/playlist.dart';
import 'package:ztv_player/services/playlist_builder_service.dart';
import 'package:ztv_player/services/xtream_api_service.dart';
import 'package:ztv_player/storage/playlist_repository.dart';

class PlaylistController extends ChangeNotifier {
  PlaylistController({
    PlaylistRepository? repository,
    PlaylistBuilderService? builderService,
    XtreamApiService? apiService,
  }) : _repository = repository ?? PlaylistRepository(),
       _builderService = builderService ?? PlaylistBuilderService(),
       _apiService = apiService ?? XtreamApiService();

  final PlaylistRepository _repository;
  final PlaylistBuilderService _builderService;
  final XtreamApiService _apiService;

  List<Playlist> _playlists = const [];
  Playlist? _activePlaylist;
  bool _isLoading = false;
  String _statusMessage = '';
  double _progressValue = 0;

  List<Playlist> get playlists => _playlists;
  Playlist? get activePlaylist => _activePlaylist;
  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;
  double get progressValue => _progressValue;
  bool get canCreatePlaylist =>
      _playlists.length < PlaylistRepository.maxPlaylists;

  Future<void> initialize() async {
    await _repository.initialize();
    _refreshState();
  }

  Future<Playlist> createPlaylist({
    required String name,
    required String server,
    required String username,
    required String password,
  }) async {
    if (!canCreatePlaylist) {
      throw Exception('Maximum of 5 playlists reached.');
    }

    _setLoading(
      isLoading: true,
      statusMessage: 'Preparing playlist...',
      progressValue: 0,
    );

    try {
      final playlist = await _builderService.build(
        PlaylistBuilderRequest(
          name: name,
          server: server,
          username: username,
          password: password,
        ),
        onProgress: (progress) {
          _setLoading(
            isLoading: true,
            statusMessage: progress.message,
            progressValue: progress.value,
          );
        },
      );

      await _repository.savePlaylist(playlist, setAsActive: true);
      _refreshState();
      _setLoading(
        isLoading: false,
        statusMessage: 'Playlist ready.',
        progressValue: 1,
      );
      return playlist;
    } catch (_) {
      _setLoading(isLoading: false);
      rethrow;
    }
  }

  Future<void> switchPlaylist(String? playlistId) async {
    await _repository.setActivePlaylist(playlistId);
    _refreshState();
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _repository.deletePlaylist(playlistId);
    _refreshState();
  }

  Future<List<EpgListing>> loadShortEpg(
    String streamId, {
    int? limit,
    bool forceRefresh = false,
  }) async {
    final playlist = _activePlaylist;
    if (playlist == null) {
      return const <EpgListing>[];
    }

    if (!forceRefresh && playlist.epgCache.containsKey(streamId)) {
      return playlist.epgCache[streamId] ?? const <EpgListing>[];
    }

    final listings = await _apiService.fetchShortEpg(
      server: playlist.server,
      username: playlist.username,
      password: playlist.password,
      streamId: streamId,
      limit: limit,
    );

    await _repository.cacheEpg(
      playlistId: playlist.id,
      streamId: streamId,
      listings: listings,
    );
    _refreshState();
    return listings;
  }

  Future<List<EpgListing>> loadArchiveEpg(
    String streamId, {
    int? limit,
  }) async {
    final playlist = _activePlaylist;
    if (playlist == null) {
      return const <EpgListing>[];
    }

    return _apiService.fetchSimpleDataTable(
      server: playlist.server,
      username: playlist.username,
      password: playlist.password,
      streamId: streamId,
      limit: limit,
    );
  }

  void _refreshState() {
    _playlists = _repository.getAllPlaylists();
    _activePlaylist = _repository.getActivePlaylist();
    notifyListeners();
  }

  void _setLoading({
    required bool isLoading,
    String? statusMessage,
    double? progressValue,
  }) {
    _isLoading = isLoading;
    if (statusMessage != null) {
      _statusMessage = statusMessage;
    }
    if (progressValue != null) {
      _progressValue = progressValue;
    }
    notifyListeners();
  }
}
