import 'package:dio/dio.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/models/epg_response.dart';
import 'package:ztv_player/services/settings_service.dart';

class EpgService {
  EpgService({
    this.settingsService = const SettingsService(),
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final SettingsService settingsService;
  final Dio _dio;

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

    final server = playlist.server.endsWith('/')
        ? playlist.server.substring(0, playlist.server.length - 1)
        : playlist.server;

    final queryParameters = <String, dynamic>{
      'username': playlist.username,
      'password': playlist.password,
      'action': action,
      'stream_id': streamId,
    };

    if (limit != null) {
      queryParameters['limit'] = limit;
    }

    final response = await _dio.get(
      '$server/player_api.php',
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data is! Map) {
      return const <EpgListing>[];
    }

    final epgResponse = EpgResponse.fromJson(Map<String, dynamic>.from(data));
    final listings = epgResponse.epgListings.toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return listings;
  }
}
