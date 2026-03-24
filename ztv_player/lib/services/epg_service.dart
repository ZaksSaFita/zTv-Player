import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/services/settings_service.dart';
import 'package:ztv_player/services/xtream_api_service.dart';

class EpgService {
  EpgService({
    this.settingsService = const SettingsService(),
    XtreamApiService? apiService,
  }) : _apiService = apiService ?? XtreamApiService();

  final SettingsService settingsService;
  final XtreamApiService _apiService;

  Future<List<EpgListing>> getShortEpg({
    required String streamId,
    int? limit,
  }) async {
    return _fetchEpgListings(
      action: 'get_short_epg',
      streamId: streamId,
      limit: limit,
    );
  }

  Future<List<EpgListing>> getArchiveEpg({
    required String streamId,
    int? limit,
  }) async {
    return _fetchEpgListings(
      action: 'get_simple_data_table',
      streamId: streamId,
      limit: limit,
    );
  }

  Future<List<EpgListing>> _fetchEpgListings({
    required String action,
    required String streamId,
    int? limit,
  }) async {
    final playlist = settingsService.getCurrentPlaylist();
    if (playlist == null) {
      return const <EpgListing>[];
    }

    if (action == 'get_simple_data_table') {
      return _apiService.fetchSimpleDataTable(
        server: playlist.server,
        username: playlist.username,
        password: playlist.password,
        streamId: streamId,
        limit: limit,
      );
    }

    return _apiService.fetchShortEpg(
      server: playlist.server,
      username: playlist.username,
      password: playlist.password,
      streamId: streamId,
      limit: limit,
    );
  }
}
