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

  const PlaylistLoadResult({
    required this.playlist,
    required this.liveCategoryCount,
    required this.liveChannelCount,
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
    final playlist = await _builderService.build(
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

    await _repository.savePlaylist(playlist, setAsActive: true);
    onStatusChanged?.call('Playlist successfully loaded!');
    onProgress?.call(
      const PlaylistLoadProgress(
        status: 'Playlist successfully loaded!',
        value: 1,
      ),
    );

    return PlaylistLoadResult(
      playlist: playlist,
      liveCategoryCount: playlist.liveCategories.length,
      liveChannelCount: playlist.liveChannels.length,
    );
  }
}
