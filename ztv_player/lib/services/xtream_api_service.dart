import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/models/epg_response.dart';
import 'package:ztv_player/models/live_tv_category.dart';
import 'package:ztv_player/models/live_tv_channel.dart';

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

    return data
        .map((item) => LiveTvChannel.fromJson(Map<String, dynamic>.from(item)))
        .where((channel) => channel.id.trim().isNotEmpty)
        .toList();
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
    if (data is! List) {
      throw Exception('Invalid response for $action.');
    }

    return data;
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
    var normalized = server.trim();
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    if (normalized.endsWith('/player_api.php')) {
      return normalized;
    }

    if (normalized.endsWith('/get.php')) {
      normalized = normalized.substring(0, normalized.length - '/get.php'.length);
    }

    return '$normalized/player_api.php';
  }

  Future<dynamic> _getDecodedJson({
    required String server,
    required String username,
    required String password,
    String? action,
    String? streamId,
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
    final firstChar = raw[start];
    final endChar = firstChar == '{' ? '}' : ']';
    final end = raw.lastIndexOf(endChar);

    if (end <= start) {
      return raw.substring(start);
    }

    return raw.substring(start, end + 1);
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
