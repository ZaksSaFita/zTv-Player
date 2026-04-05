import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ztv_player/services/xtream_api_service.dart';

void main() {
  group('XtreamApiService', () {
    test('testConnection accepts sanitized wrapped JSON payloads', () async {
      final service = XtreamApiService(
        dio: Dio()..httpClientAdapter = _FakeAdapter((options) {
          return _jsonBytes(
            '\ufeffprefix {"user_info":{"username":"demo",},"server_info":{"url":"example.com",},} suffix',
          );
        }),
      );

      final result = await service.testConnection(
        server: 'http://example.com:8080/',
        username: 'demo',
        password: 'secret',
      );

      expect(result['user_info']['username'], 'demo');
      expect(result['server_info']['url'], 'example.com');
    });

    test('fetchLiveChannels extracts wrapped lists and skips malformed items',
        () async {
      final service = XtreamApiService(
        dio: Dio()..httpClientAdapter = _FakeAdapter((options) {
          expect(options.queryParameters['action'], 'get_live_streams');
          return _jsonBytes(jsonEncode({
            'live_streams': [
              {
                'stream_id': '101',
                'name': 'News HD',
                'category_id': '5',
              },
              {
                'stream_id': '',
                'name': 'Broken',
                'category_id': '5',
              },
              'invalid'
            ],
          }));
        }),
      );

      final channels = await service.fetchLiveChannels(
        server: 'http://example.com:8080/player_api.php',
        username: 'demo',
        password: 'secret',
      );

      expect(channels, hasLength(1));
      expect(channels.single.id, '101');
      expect(channels.single.name, 'News HD');
    });

    test('fetchShortEpg returns items sorted by start time', () async {
      final service = XtreamApiService(
        dio: Dio()..httpClientAdapter = _FakeAdapter((options) {
          expect(options.queryParameters['action'], 'get_short_epg');
          expect(options.queryParameters['stream_id'], '101');
          return _jsonBytes(jsonEncode({
            'epg_listings': [
              {
                'id': '2',
                'epg_id': '2',
                'title': base64.encode(utf8.encode('Late Show')),
                'description': base64.encode(utf8.encode('Later program')),
                'lang': 'en',
                'start': '2026-04-06T21:00:00.000',
                'end': '2026-04-06T22:00:00.000',
                'channel_id': '101',
                'now_playing': 0,
                'has_archive': 1,
              },
              {
                'id': '1',
                'epg_id': '1',
                'title': base64.encode(utf8.encode('Morning Show')),
                'description': base64.encode(utf8.encode('Early program')),
                'lang': 'en',
                'start': '2026-04-06T08:00:00.000',
                'end': '2026-04-06T09:00:00.000',
                'channel_id': '101',
                'now_playing': 0,
                'has_archive': 0,
              }
            ],
          }));
        }),
      );

      final listings = await service.fetchShortEpg(
        server: 'http://example.com:8080',
        username: 'demo',
        password: 'secret',
        streamId: '101',
      );

      expect(listings, hasLength(2));
      expect(listings.first.title, 'Morning Show');
      expect(listings.last.title, 'Late Show');
    });
  });
}

List<int> _jsonBytes(String body) => utf8.encode(body);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final List<int> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromBytes(
      _handler(options),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}
