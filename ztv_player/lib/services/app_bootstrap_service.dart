import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/theme.dart';
import 'package:ztv_player/models/episode.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/models/live_category.dart';
import 'package:ztv_player/models/live_channel.dart';
import 'package:ztv_player/models/playlist.dart';
import 'package:ztv_player/models/season.dart';
import 'package:ztv_player/models/series.dart';
import 'package:ztv_player/models/series_category.dart';
import 'package:ztv_player/models/vod_category.dart';
import 'package:ztv_player/models/vod_movie.dart';

class AppBootstrapService {
  const AppBootstrapService();

  Future<void> initialize() async {
    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();
    _loadSavedTheme();
  }

  void _registerAdapters() {
    Hive.registerAdapter(PlaylistAdapter());
    Hive.registerAdapter(EpgListingAdapter());
    Hive.registerAdapter(LiveCategoryAdapter());
    Hive.registerAdapter(LiveChannelAdapter());
    Hive.registerAdapter(VodCategoryAdapter());
    Hive.registerAdapter(VodMovieAdapter());
    Hive.registerAdapter(SeriesCategoryAdapter());
    Hive.registerAdapter(SeriesAdapter());
    Hive.registerAdapter(SeasonAdapter());
    Hive.registerAdapter(EpisodeAdapter());
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<Playlist>('playlists');
    await Hive.openBox<LiveCategory>('live_categories');
    await Hive.openBox<LiveChannel>('live_channels');
    await Hive.openBox<VodCategory>('vod_categories');
    await Hive.openBox<VodMovie>('vod_movies');
    await Hive.openBox<SeriesCategory>('series_categories');
    await Hive.openBox<Series>('series');
    await Hive.openBox<Season>('seasons');
    await Hive.openBox<Episode>('episodes');
    await Hive.openBox('settings');
  }

  void _loadSavedTheme() {
    final settings = Hive.box('settings');
    final savedThemeIndex =
        settings.get('theme', defaultValue: AppThemeType.dark.index) as int;
    AppTheme.notifier.value = AppThemeType.values[savedThemeIndex];
  }
}
