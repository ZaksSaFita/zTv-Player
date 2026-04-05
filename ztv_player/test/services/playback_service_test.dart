import 'package:flutter_test/flutter_test.dart';
import 'package:ztv_player/models/episode.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/models/live_tv_channel.dart';
import 'package:ztv_player/models/playlist.dart';
import 'package:ztv_player/models/vod_movie.dart';
import 'package:ztv_player/services/playback_service.dart';
import 'package:ztv_player/services/settings_service.dart';

void main() {
  final playlist = Playlist(
    id: 'playlist-1',
    name: 'Demo',
    server: 'http://example.com:8080/',
    username: 'user',
    password: 'pass',
    isValid: true,
    createdAt: DateTime(2026, 4, 6, 12),
  );

  group('PlaybackService', () {
    test('prefers direct source for live streams', () {
      final service = PlaybackService(
        settingsService: _FakeSettingsService(playlist),
      );

      final channel = LiveTvChannel(
        id: '101',
        name: 'News',
        categoryId: '1',
        streamUrl: ' http://cdn.example.com/live/news.m3u8 ',
      );

      expect(
        service.resolveLiveStreamUrl(channel),
        'http://cdn.example.com/live/news.m3u8',
      );
    });

    test('builds live stream URL from active playlist', () {
      final service = PlaybackService(
        settingsService: _FakeSettingsService(playlist),
      );

      final channel = LiveTvChannel(
        id: '101',
        name: 'News',
        categoryId: '1',
      );

      expect(
        service.resolveLiveStreamUrl(channel),
        'http://example.com:8080/live/user/pass/101.ts',
      );
    });

    test('builds movie stream URL with custom extension', () {
      final service = PlaybackService(
        settingsService: _FakeSettingsService(playlist),
      );

      final movie = VodMovie(
        id: '201',
        name: 'Film',
        categoryId: '2',
      );

      expect(
        service.resolveMovieStreamUrl(movie, extension: 'mkv'),
        'http://example.com:8080/movie/user/pass/201.mkv',
      );
    });

    test('builds episode stream URL', () {
      final service = PlaybackService(
        settingsService: _FakeSettingsService(playlist),
      );

      final episode = Episode(
        id: '301',
        name: 'Episode 1',
        seasonNumber: 1,
        episodeNumber: 1,
      );

      expect(
        service.resolveEpisodeStreamUrl(episode),
        'http://example.com:8080/series/user/pass/301.mp4',
      );
    });

    test('returns null for archive when listing has no archive', () {
      final service = PlaybackService(
        settingsService: _FakeSettingsService(playlist),
      );

      final result = service.resolveArchiveStreamUrl(
        channel: LiveTvChannel(id: '101', name: 'News', categoryId: '1'),
        listing: EpgListing(
          id: '1',
          epgId: '1',
          title: 'Program',
          description: 'Desc',
          lang: 'en',
          start: DateTime(2026, 4, 6, 10, 0),
          end: DateTime(2026, 4, 6, 11, 0),
          channelId: '101',
          nowPlaying: false,
          hasArchive: false,
        ),
      );

      expect(result, isNull);
    });

    test('builds archive stream URL with formatted timeshift values', () {
      final service = PlaybackService(
        settingsService: _FakeSettingsService(playlist),
      );

      final result = service.resolveArchiveStreamUrl(
        channel: LiveTvChannel(id: '101', name: 'News', categoryId: '1'),
        listing: EpgListing(
          id: '1',
          epgId: '1',
          title: 'Program',
          description: 'Desc',
          lang: 'en',
          start: DateTime(2026, 4, 6, 10, 5),
          end: DateTime(2026, 4, 6, 11, 35),
          channelId: '101',
          nowPlaying: false,
          hasArchive: true,
        ),
      );

      expect(
        result,
        'http://example.com:8080/timeshift/user/pass/90/2026-04-06:10-05/101.ts',
      );
    });
  });
}

class _FakeSettingsService extends SettingsService {
  _FakeSettingsService(this._playlist);

  final Playlist? _playlist;

  @override
  Playlist? getCurrentPlaylist() => _playlist;
}
