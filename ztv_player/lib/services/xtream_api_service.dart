import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:ztv_player/helpers/network_url.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/models/epg_response.dart';
import 'package:ztv_player/models/live_tv_category.dart';
import 'package:ztv_player/models/live_tv_channel.dart';
import 'package:ztv_player/models/series.dart';
import 'package:ztv_player/models/series_category.dart';
import 'package:ztv_player/models/series_details.dart';
import 'package:ztv_player/models/vod_category.dart';
import 'package:ztv_player/models/vod_details.dart';
import 'package:ztv_player/models/vod_movie.dart';

class XtreamApiService {
  XtreamApiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<Map<String, dynamic>> testConnection({
    required String server,
    required String username,
    required String password,
  }) async {
    final data = await _getDecodedJson(
      server: server,
      username: username,
      password: password,
    );
    if (data == null) {
      throw Exception('Connection failed. Server returned no data.');
    }

    if (data is String && data.trim().toLowerCase() == 'null') {
      throw Exception('Connection failed. Invalid credentials.');
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('Connection failed. Unexpected player_api response.');
  }

  Future<List<LiveTvCategory>> fetchLiveCategories({
    required String server,
    required String username,
    required String password,
  }) async {
    final data = await _getList(
      server: server,
      username: username,
      password: password,
      action: 'get_live_categories',
    );

    return data
        .map((item) => LiveTvCategory.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<LiveTvChannel>> fetchLiveChannels({
    required String server,
    required String username,
    required String password,
  }) async {
    final data = await _getList(
      server: server,
      username: username,
      password: password,
      action: 'get_live_streams',
    );

    return _parseListItems(
      data,
      parser: (item) => LiveTvChannel.fromJson(item),
      itemLabel: 'live channel',
      isValid: (channel) => channel.id.trim().isNotEmpty,
      emptyErrorMessage: 'Server returned live channels, but none could be parsed.',
    );
  }

  Future<List<EpgListing>> fetchShortEpg({
    required String server,
    required String username,
    required String password,
    required String streamId,
    int? limit,
  }) {
    return _fetchEpg(
      server: server,
      username: username,
      password: password,
      action: 'get_short_epg',
      streamId: streamId,
      limit: limit,
    );
  }

  Future<List<EpgListing>> fetchSimpleDataTable({
    required String server,
    required String username,
    required String password,
    required String streamId,
    int? limit,
  }) {
    return _fetchEpg(
      server: server,
      username: username,
      password: password,
      action: 'get_simple_data_table',
      streamId: streamId,
      limit: limit,
    );
  }

  Future<List<VodCategory>> fetchVodCategories({
    required String server,
    required String username,
    required String password,
  }) async {
    final data = await _getList(
      server: server,
      username: username,
      password: password,
      action: 'get_vod_categories',
    );

    return data
        .map((item) => VodCategory.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<VodMovie>> fetchVodMovies({
    required String server,
    required String username,
    required String password,
  }) async {
    final data = await _getList(
      server: server,
      username: username,
      password: password,
      action: 'get_vod_streams',
    );

    return _parseListItems(
      data,
      parser: (item) => VodMovie.fromJson(item),
      itemLabel: 'movie',
      isValid: (movie) => movie.id.trim().isNotEmpty,
      emptyErrorMessage: 'Server returned movies, but none could be parsed.',
    );
  }

  Future<VodDetails> fetchVodDetails({
    required String server,
    required String username,
    required String password,
    required String vodId,
  }) async {
    final data = await _getDecodedJson(
      server: server,
      username: username,
      password: password,
      action: 'get_vod_info',
      vodId: vodId,
    );

    if (data is! Map) {
      throw Exception('Invalid response for get_vod_info.');
    }

    return VodDetails.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<SeriesCategory>> fetchSeriesCategories({
    required String server,
    required String username,
    required String password,
  }) async {
    final data = await _getList(
      server: server,
      username: username,
      password: password,
      action: 'get_series_categories',
    );

    return data
        .map((item) => SeriesCategory.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<Series>> fetchSeries({
    required String server,
    required String username,
    required String password,
  }) async {
    final data = await _getList(
      server: server,
      username: username,
      password: password,
      action: 'get_series',
    );

    return _parseListItems(
      data,
      parser: (item) => Series.fromJson(item),
      itemLabel: 'series item',
      isValid: (series) => series.id.trim().isNotEmpty,
      emptyErrorMessage: 'Server returned series, but none could be parsed.',
    );
  }

  Future<SeriesDetails> fetchSeriesDetails({
    required String server,
    required String username,
    required String password,
    required String seriesId,
  }) async {
    final data = await _getDecodedJson(
      server: server,
      username: username,
      password: password,
      action: 'get_series_info',
      seriesId: seriesId,
    );

    if (data is! Map) {
      throw Exception('Invalid response for get_series_info.');
    }

    return SeriesDetails.fromJson(Map<String, dynamic>.from(data), seriesId);
  }

  Future<List<dynamic>> _getList({
    required String server,
    required String username,
    required String password,
    required String action,
  }) async {
    final data = await _getDecodedJson(
      server: server,
      username: username,
      password: password,
      action: action,
    );
    final normalized = _extractListPayload(data);
    if (normalized == null) {
      throw Exception('Invalid response for $action.');
    }

    return normalized;
  }

  List<dynamic>? _extractListPayload(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is! Map) {
      return null;
    }

    const candidateKeys = <String>[
      'data',
      'results',
      'items',
      'channels',
      'live_streams',
      'available_channels',
      'movies',
      'series',
      'categories',
    ];

    for (final key in candidateKeys) {
      final value = data[key];
      if (value is List) {
        return value;
      }
    }

    return null;
  }

  List<T> _parseListItems<T>(
    List<dynamic> data, {
    required T Function(Map<String, dynamic> item) parser,
    required String itemLabel,
    required bool Function(T item) isValid,
    required String emptyErrorMessage,
  }) {
    final parsedItems = <T>[];
    var skippedItems = 0;

    for (final item in data) {
      if (item is! Map) {
        skippedItems++;
        continue;
      }

      try {
        final parsed = parser(Map<String, dynamic>.from(item));
        if (isValid(parsed)) {
          parsedItems.add(parsed);
        } else {
          skippedItems++;
        }
      } catch (error, stackTrace) {
        skippedItems++;
        developer.log(
          'Skipping malformed $itemLabel item.',
          name: 'XtreamApiService',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (parsedItems.isEmpty && data.isNotEmpty) {
      throw Exception(emptyErrorMessage);
    }

    if (skippedItems > 0) {
      developer.log(
        'Skipped $skippedItems malformed $itemLabel item(s).',
        name: 'XtreamApiService',
      );
    }

    return parsedItems;
  }

  Future<List<EpgListing>> _fetchEpg({
    required String server,
    required String username,
    required String password,
    required String action,
    required String streamId,
    int? limit,
  }) async {
    final data = await _getDecodedJson(
      server: server,
      username: username,
      password: password,
      action: action,
      extraQueryParameters: limit != null ? {'limit': limit} : null,
      streamId: streamId,
    );
    if (data is! Map) {
      return const <EpgListing>[];
    }

    final epg = EpgResponse.fromJson(Map<String, dynamic>.from(data));
    return epg.epgListings.toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  String _apiUrl(String server) {
    final normalized = normalizeServerUrlForDevice(server);
    return '$normalized/player_api.php';
  }

  Future<dynamic> _getDecodedJson({
    required String server,
    required String username,
    required String password,
    String? action,
    String? streamId,
    String? vodId,
    String? seriesId,
    Map<String, dynamic>? extraQueryParameters,
  }) async {
    final queryParameters = <String, dynamic>{
      'username': username,
      'password': password,
    };

    if (action != null) {
      queryParameters['action'] = action;
    }

    if (streamId != null) {
      queryParameters['stream_id'] = streamId;
    }

    if (vodId != null) {
      queryParameters['vod_id'] = vodId;
    }

    if (seriesId != null) {
      queryParameters['series_id'] = seriesId;
    }

    if (extraQueryParameters != null) {
      queryParameters.addAll(extraQueryParameters);
    }

    try {
      final response = await _dio.get<List<int>>(
        _apiUrl(server),
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (status) => status != null && status >= 200 && status < 300,
        ),
      );

      return _decodeResponsePayload(response.data);
    } on DioException catch (error) {
      throw Exception(_friendlyDioMessage(error));
    } on FormatException catch (error) {
      final label = action ?? 'player_api.php';
      throw Exception('Malformed JSON from $label: ${error.message}');
    }
  }

  dynamic _decodeResponsePayload(List<int>? bytes) {
    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    final raw = utf8.decode(bytes, allowMalformed: true).trim();
    if (raw.isEmpty || raw.toLowerCase() == 'null') {
      return null;
    }

    final extracted = _extractJsonPayload(raw);
    final sanitized = _sanitizeJson(extracted);
    return jsonDecode(sanitized);
  }

  String _extractJsonPayload(String raw) {
    final objectIndex = raw.indexOf('{');
    final listIndex = raw.indexOf('[');
    final starts = [objectIndex, listIndex].where((index) => index >= 0).toList()
      ..sort();

    if (starts.isEmpty) {
      return raw;
    }

    final start = starts.first;
    final extracted = _extractBalancedJson(raw, start);
    return extracted ?? raw.substring(start);
  }

  String? _extractBalancedJson(String raw, int start) {
    final opening = raw[start];
    final closing = opening == '{' ? '}' : ']';
    var depth = 0;
    var inString = false;
    var escaping = false;

    for (var index = start; index < raw.length; index++) {
      final char = raw[index];

      if (escaping) {
        escaping = false;
        continue;
      }

      if (char == r'\') {
        escaping = true;
        continue;
      }

      if (char == '"') {
        inString = !inString;
        continue;
      }

      if (inString) {
        continue;
      }

      if (char == opening) {
        depth++;
        continue;
      }

      if (char == closing) {
        depth--;
        if (depth == 0) {
          return raw.substring(start, index + 1);
        }
      }
    }

    return null;
  }

  String _sanitizeJson(String raw) {
    return raw
        .replaceFirst('\ufeff', '')
        .replaceAll(RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F]'), ' ')
        .replaceAll(RegExp(r',\s*([}\]])'), r'$1');
  }

  String _friendlyDioMessage(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Server timeout. Please try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Check the URL and network.';
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      return 'Server returned HTTP $statusCode.';
    }

    return error.message ?? 'Unknown network error.';
  }
}
