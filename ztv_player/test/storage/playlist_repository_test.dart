import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/models/live_tv_category.dart';
import 'package:ztv_player/models/live_tv_channel.dart';
import 'package:ztv_player/models/playlist.dart';
import 'package:ztv_player/models/series.dart';
import 'package:ztv_player/models/series_category.dart';
import 'package:ztv_player/models/vod_category.dart';
import 'package:ztv_player/models/vod_movie.dart';
import 'package:ztv_player/storage/playlist_repository.dart';

void main() {
  late Directory hiveDirectory;
  const repository = PlaylistRepository();

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp(
      'ztv_player_repository_test_',
    );
    Hive.init(hiveDirectory.path);
    _registerAdapters();
  });

  tearDown(() async {
    await _closeIfOpen<Playlist>('playlists');
    await _closeIfOpen('settings');
    await _closeIfOpen<LiveTvCategory>('live_categories');
    await _closeIfOpen<LiveTvChannel>('live_channels');
    await _closeIfOpen<VodCategory>('vod_categories');
    await _closeIfOpen<VodMovie>('vod_movies');
    await _closeIfOpen<SeriesCategory>('series_categories');
    await _closeIfOpen<Series>('series');

    await Hive.deleteBoxFromDisk('playlists');
    await Hive.deleteBoxFromDisk('settings');
    await Hive.deleteBoxFromDisk('live_categories');
    await Hive.deleteBoxFromDisk('live_channels');
    await Hive.deleteBoxFromDisk('vod_categories');
    await Hive.deleteBoxFromDisk('vod_movies');
    await Hive.deleteBoxFromDisk('series_categories');
    await Hive.deleteBoxFromDisk('series');
  });

  tearDownAll(() async {
    await Hive.close();
    if (await hiveDirectory.exists()) {
      await hiveDirectory.delete(recursive: true);
    }
  });

  group('PlaylistRepository', () {
    test('setActivePlaylist hydrates all content snapshot boxes', () async {
      await _openRequiredBoxes();

      final playlist = _playlist(
        id: 'playlist-1',
        createdAt: DateTime(2026, 4, 6, 12),
      );
      await repository.savePlaylist(playlist);

      expect(repository.getActivePlaylistId(), 'playlist-1');
      expect(Hive.box<LiveTvCategory>('live_categories').values.length, 1);
      expect(Hive.box<LiveTvChannel>('live_channels').values.length, 1);
      expect(Hive.box<VodCategory>('vod_categories').values.length, 1);
      expect(Hive.box<VodMovie>('vod_movies').values.length, 1);
      expect(Hive.box<SeriesCategory>('series_categories').values.length, 1);
      expect(Hive.box<Series>('series').values.length, 1);
    });

    test('deletePlaylist promotes next newest playlist when active is removed',
        () async {
      await _openRequiredBoxes();

      final older = _playlist(
        id: 'older',
        createdAt: DateTime(2026, 4, 6, 10),
        liveCategoryName: 'Older Live',
      );
      final newer = _playlist(
        id: 'newer',
        createdAt: DateTime(2026, 4, 6, 12),
        liveCategoryName: 'Newer Live',
      );

      await repository.savePlaylist(older, setAsActive: false);
      await repository.savePlaylist(newer, setAsActive: true);
      await repository.deletePlaylist('newer');

      expect(repository.getActivePlaylistId(), 'older');
      expect(
        Hive.box<LiveTvCategory>('live_categories').values.single.name,
        'Older Live',
      );
    });

    test('cacheEpg stores listings on the playlist model', () async {
      await _openRequiredBoxes();

      final playlist = _playlist(
        id: 'playlist-epg',
        createdAt: DateTime(2026, 4, 6, 13),
      );
      await repository.savePlaylist(playlist);

      final listings = [
        EpgListing(
          id: '1',
          epgId: 'epg-1',
          title: 'News',
          description: 'Daily bulletin',
          lang: 'en',
          start: DateTime(2026, 4, 6, 18),
          end: DateTime(2026, 4, 6, 19),
          channelId: '101',
          nowPlaying: false,
          hasArchive: true,
        ),
      ];

      await repository.cacheEpg(
        playlistId: playlist.id,
        streamId: '101',
        listings: listings,
      );

      final updated = Hive.box<Playlist>('playlists').get('playlist-epg');
      expect(updated, isNotNull);
      expect(updated!.epgCache['101'], isNotNull);
      expect(updated.epgCache['101']!.single.title, 'News');
    });
  });
}

Future<void> _openRequiredBoxes() async {
  await Hive.openBox<Playlist>('playlists');
  await Hive.openBox('settings');
  await Hive.openBox<LiveTvCategory>('live_categories');
  await Hive.openBox<LiveTvChannel>('live_channels');
  await Hive.openBox<VodCategory>('vod_categories');
  await Hive.openBox<VodMovie>('vod_movies');
  await Hive.openBox<SeriesCategory>('series_categories');
  await Hive.openBox<Series>('series');
}

Future<void> _closeIfOpen<E>(String name) async {
  if (Hive.isBoxOpen(name)) {
    await Hive.box<E>(name).close();
  }
}

void _registerAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PlaylistAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(LiveTvCategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(LiveTvChannelAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(VodCategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(VodMovieAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(SeriesCategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(SeriesAdapter());
  }
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(EpgListingAdapter());
  }
}

Playlist _playlist({
  required String id,
  required DateTime createdAt,
  String liveCategoryName = 'Live Category',
}) {
  return Playlist(
    id: id,
    name: 'Playlist $id',
    server: 'http://example.com:8080',
    username: 'user',
    password: 'secret',
    isValid: true,
    createdAt: createdAt,
    liveCategories: [
      LiveTvCategory(id: '1', name: liveCategoryName, channelCount: 1),
    ],
    liveChannels: [
      LiveTvChannel(id: '101', name: 'Live 101', categoryId: '1'),
    ],
    vodCategories: [
      VodCategory(id: '2', name: 'Movies', movieCount: 1),
    ],
    vodMovies: [
      VodMovie(id: '201', name: 'Movie 201', categoryId: '2'),
    ],
    seriesCategories: [
      SeriesCategory(id: '3', name: 'Series', seriesCount: 1),
    ],
    series: [
      Series(id: '301', name: 'Series 301', categoryId: '3'),
    ],
  );
}
