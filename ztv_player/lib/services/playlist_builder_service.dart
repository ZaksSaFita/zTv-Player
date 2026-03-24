import 'package:ztv_player/models/playlist.dart';
import 'package:ztv_player/services/xtream_api_service.dart';

class PlaylistBuildProgress {
  final String message;
  final double value;

  const PlaylistBuildProgress({
    required this.message,
    required this.value,
  });
}

class PlaylistBuilderRequest {
  final String name;
  final String server;
  final String username;
  final String password;
  final bool prefetchShortEpg;

  const PlaylistBuilderRequest({
    required this.name,
    required this.server,
    required this.username,
    required this.password,
    this.prefetchShortEpg = false,
  });
}

class PlaylistBuilderService {
  PlaylistBuilderService({XtreamApiService? apiService})
      : _apiService = apiService ?? XtreamApiService();

  final XtreamApiService _apiService;

  Future<Playlist> build(
    PlaylistBuilderRequest request, {
    void Function(PlaylistBuildProgress progress)? onProgress,
  }) async {
    _emit(onProgress, 'Testing connection...', 0.1);
    await _apiService.testConnection(
      server: request.server,
      username: request.username,
      password: request.password,
    );

    _emit(onProgress, 'Fetching categories...', 0.35);
    final categories = await _apiService.fetchLiveCategories(
      server: request.server,
      username: request.username,
      password: request.password,
    );

    _emit(onProgress, 'Fetching channels...', 0.65);
    final channels = await _apiService.fetchLiveChannels(
      server: request.server,
      username: request.username,
      password: request.password,
    );

    final channelCounts = <String, int>{};
    for (final channel in channels) {
      channelCounts[channel.categoryId] =
          (channelCounts[channel.categoryId] ?? 0) + 1;
    }

    for (final category in categories) {
      category.channelCount = channelCounts[category.id] ?? 0;
    }

    _emit(onProgress, 'Finalizing playlist...', 0.95);
    return Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: request.name.trim().isEmpty ? 'My Playlist' : request.name.trim(),
      server: request.server.trim(),
      username: request.username.trim(),
      password: request.password.trim(),
      isValid: true,
      createdAt: DateTime.now(),
      liveCategories: categories,
      liveChannels: channels,
      epgCache: const {},
    );
  }

  void _emit(
    void Function(PlaylistBuildProgress progress)? onProgress,
    String message,
    double value,
  ) {
    onProgress?.call(PlaylistBuildProgress(message: message, value: value));
  }
}
