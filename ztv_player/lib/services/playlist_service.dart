import 'package:ztv_player/models/playlist.dart';
import 'package:ztv_player/services/playlist_builder_service.dart';
import 'package:ztv_player/storage/playlist_repository.dart';

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
  final int liveCategoryCount;
  final int liveChannelCount;
  final int movieCategoryCount;
  final int movieCount;
  final int seriesCategoryCount;
  final int seriesCount;

  const PlaylistLoadResult({
    required this.playlist,
    required this.liveCategoryCount,
    required this.liveChannelCount,
    required this.movieCategoryCount,
    required this.movieCount,
    required this.seriesCategoryCount,
    required this.seriesCount,
  });
}

class PlaylistLoadProgress {
  final String status;
  final double value;

  const PlaylistLoadProgress({
    required this.status,
    required this.value,
  });
}

class PlaylistService {
  PlaylistService({
    PlaylistBuilderService? builderService,
    PlaylistRepository? repository,
  }) : _builderService = builderService ?? PlaylistBuilderService(),
       _repository = repository ?? PlaylistRepository();

  final PlaylistBuilderService _builderService;
  final PlaylistRepository _repository;

  Future<PlaylistLoadResult> createAndSavePlaylist(
    PlaylistLoadRequest request, {
    void Function(PlaylistLoadProgress progress)? onProgress,
    void Function(String status)? onStatusChanged,
  }) async {
    final playlist = await _buildPlaylist(
      request,
      onProgress: onProgress,
      onStatusChanged: onStatusChanged,
    );
    await _repository.savePlaylist(playlist, setAsActive: true);
    _emitCompleted(onProgress, onStatusChanged);
    return _toResult(playlist);
  }

  Future<PlaylistLoadResult> reloadPlaylist(
    Playlist playlist, {
    void Function(PlaylistLoadProgress progress)? onProgress,
    void Function(String status)? onStatusChanged,
  }) async {
    final rebuilt = await _buildPlaylist(
      PlaylistLoadRequest(
        name: playlist.name,
        server: playlist.server,
        username: playlist.username,
        password: playlist.password,
      ),
      onProgress: onProgress,
      onStatusChanged: onStatusChanged,
    );

    final updated = rebuilt.copyWith(id: playlist.id, createdAt: playlist.createdAt);
    await _repository.updatePlaylist(updated);
    _emitCompleted(onProgress, onStatusChanged);
    return _toResult(updated);
  }

  Future<PlaylistLoadResult> editPlaylist(
    Playlist playlist, {
    required PlaylistLoadRequest request,
    void Function(PlaylistLoadProgress progress)? onProgress,
    void Function(String status)? onStatusChanged,
  }) async {
    final rebuilt = await _buildPlaylist(
      request,
      onProgress: onProgress,
      onStatusChanged: onStatusChanged,
    );

    final updated = rebuilt.copyWith(id: playlist.id, createdAt: playlist.createdAt);
    await _repository.updatePlaylist(updated);
    _emitCompleted(onProgress, onStatusChanged);
    return _toResult(updated);
  }

  Future<Playlist> _buildPlaylist(
    PlaylistLoadRequest request, {
    void Function(PlaylistLoadProgress progress)? onProgress,
    void Function(String status)? onStatusChanged,
  }) {
    return _builderService.build(
      PlaylistBuilderRequest(
        name: request.name,
        server: request.server,
        username: request.username,
        password: request.password,
      ),
      onProgress: (progress) {
        onStatusChanged?.call(progress.message);
        onProgress?.call(
          PlaylistLoadProgress(status: progress.message, value: progress.value),
        );
      },
    );
  }

  void _emitCompleted(
    void Function(PlaylistLoadProgress progress)? onProgress,
    void Function(String status)? onStatusChanged,
  ) {
    onStatusChanged?.call('Playlist successfully loaded!');
    onProgress?.call(
      const PlaylistLoadProgress(
        status: 'Playlist successfully loaded!',
        value: 1,
      ),
    );
  }

  PlaylistLoadResult _toResult(Playlist playlist) {
    return PlaylistLoadResult(
      playlist: playlist,
      liveCategoryCount: playlist.liveCategories.length,
      liveChannelCount: playlist.liveChannels.length,
      movieCategoryCount: playlist.vodCategories.length,
      movieCount: playlist.vodMovies.length,
      seriesCategoryCount: playlist.seriesCategories.length,
      seriesCount: playlist.series.length,
    );
  }
}
