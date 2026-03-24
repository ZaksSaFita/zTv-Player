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
    final connectionData = await _apiService.testConnection(
      server: request.server,
      username: request.username,
      password: request.password,
    );
    final expiresAt = _readExpirationDate(connectionData);

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

    _emit(onProgress, 'Fetching movie categories...', 0.78);
    final vodCategories = await _apiService.fetchVodCategories(
      server: request.server,
      username: request.username,
      password: request.password,
    );

    _emit(onProgress, 'Fetching movies...', 0.9);
    final vodMovies = await _apiService.fetchVodMovies(
      server: request.server,
      username: request.username,
      password: request.password,
    );

    _emit(onProgress, 'Fetching series categories...', 0.94);
    final seriesCategories = await _apiService.fetchSeriesCategories(
      server: request.server,
      username: request.username,
      password: request.password,
    );

    _emit(onProgress, 'Fetching series...', 0.97);
    final series = await _apiService.fetchSeries(
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

    final movieCounts = <String, int>{};
    for (final movie in vodMovies) {
      movieCounts[movie.categoryId] = (movieCounts[movie.categoryId] ?? 0) + 1;
    }

    final normalizedVodCategories = vodCategories
        .map(
          (category) => category.copyWith(
            movieCount: movieCounts[category.id] ?? 0,
          ),
        )
        .toList();

    final seriesCounts = <String, int>{};
    for (final item in series) {
      seriesCounts[item.categoryId] = (seriesCounts[item.categoryId] ?? 0) + 1;
    }

    final normalizedSeriesCategories = seriesCategories
        .map(
          (category) => category.copyWith(
            seriesCount: seriesCounts[category.id] ?? 0,
          ),
        )
        .toList();

    _emit(onProgress, 'Finalizing playlist...', 0.95);
    return Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: request.name.trim().isEmpty ? 'My Playlist' : request.name.trim(),
      server: request.server.trim(),
      username: request.username.trim(),
      password: request.password.trim(),
      isValid: true,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      liveCategories: categories,
      liveChannels: channels,
      epgCache: const {},
      vodCategories: normalizedVodCategories,
      vodMovies: vodMovies,
      seriesCategories: normalizedSeriesCategories,
      series: series,
    );
  }

  void _emit(
    void Function(PlaylistBuildProgress progress)? onProgress,
    String message,
    double value,
  ) {
    onProgress?.call(PlaylistBuildProgress(message: message, value: value));
  }

  DateTime? _readExpirationDate(Map<String, dynamic> connectionData) {
    final userInfo = connectionData['user_info'];
    if (userInfo is! Map) {
      return null;
    }

    final expDate = userInfo['exp_date'];
    if (expDate == null) {
      return null;
    }

    final seconds = int.tryParse(expDate.toString());
    if (seconds == null || seconds <= 0) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      isUtc: true,
    ).toLocal();
  }
}
