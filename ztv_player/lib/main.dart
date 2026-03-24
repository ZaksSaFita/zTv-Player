import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart' hide Playlist;
import 'package:ztv_player/helpers/theme.dart';
import 'package:ztv_player/models/live_tv_channel.dart';
import 'package:ztv_player/models/episode.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/models/live_tv_category.dart';
import 'package:ztv_player/models/playlist.dart';
import 'package:ztv_player/models/season.dart';
import 'package:ztv_player/models/series.dart';
import 'package:ztv_player/models/series_category.dart';
import 'package:ztv_player/models/vod_category.dart';
import 'package:ztv_player/models/vod_movie.dart';
import 'package:ztv_player/screens/create_playlist_screen.dart';
import 'package:ztv_player/screens/layout_screen/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(PlaylistAdapter());
  Hive.registerAdapter(EpgListingAdapter());
  Hive.registerAdapter(LiveTvCategoryAdapter());
  Hive.registerAdapter(LiveTvChannelAdapter());
  Hive.registerAdapter(VodCategoryAdapter());
  Hive.registerAdapter(VodMovieAdapter());
  Hive.registerAdapter(SeriesCategoryAdapter());
  Hive.registerAdapter(SeriesAdapter());
  Hive.registerAdapter(SeasonAdapter());
  Hive.registerAdapter(EpisodeAdapter());

  await Hive.openBox<Playlist>('playlists');
  await Hive.openBox<LiveTvCategory>('live_categories');
  await Hive.openBox<LiveTvChannel>('live_channels');
  await Hive.openBox<VodCategory>('vod_categories');
  await Hive.openBox<VodMovie>('vod_movies');
  await Hive.openBox<SeriesCategory>('series_categories');
  await Hive.openBox<Series>('series');
  await Hive.openBox<Season>('seasons');
  await Hive.openBox<Episode>('episodes');

  await Hive.openBox('settings');
  final settings = Hive.box('settings');
  final savedThemeIndex =
      settings.get('theme', defaultValue: AppThemeType.dark.index) as int;
  AppTheme.notifier.value = AppThemeType.values[savedThemeIndex];

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeType>(
      valueListenable: AppTheme.notifier,
      builder: (context, theme, _) {
        return MaterialApp(
          title: 'zTv - Player',
          theme: AppTheme.getTheme(theme),
          home: const MyHomePage(),
          routes: {'/main': (context) => const MainScreen()},
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _checkPlaylistAndNavigate();
  }

  Future<void> _checkPlaylistAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final playlistBox = Hive.box<Playlist>('playlists');

    if (playlistBox.isNotEmpty && mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/images/zTv_logo.png', fit: BoxFit.contain),
              Column(
                children: const [
                  Text(
                    'Ready for the big screen',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Create a playlist, keep it saved, and browse Live TV, Movies, and Series by category.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 600),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const CreatePlaylistScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            final tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            final offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  'Create your playlist',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
