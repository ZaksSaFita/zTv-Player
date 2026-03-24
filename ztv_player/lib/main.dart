import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/models/episode.dart';
import 'package:ztv_player/models/live_category.dart';
import 'package:ztv_player/models/live_channel.dart';
import 'package:ztv_player/models/playlist.dart';
import 'package:ztv_player/models/season.dart';
import 'package:ztv_player/models/series.dart';
import 'package:ztv_player/models/series_category.dart';
import 'package:ztv_player/models/vod_category.dart';
import 'package:ztv_player/models/vod_movie.dart';
import 'package:ztv_player/screens/playlist_screen/create_playlist_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // === HIVE INIT ===
  await Hive.initFlutter(); // ovo je najvažnije
  // kasnije ćemo ovdje registrovati adaptere za modele

  // === REGISTRACIJA SVIH ADAPTERA ===
  Hive.registerAdapter(PlaylistAdapter());
  Hive.registerAdapter(LiveCategoryAdapter());
  Hive.registerAdapter(LiveChannelAdapter());
  Hive.registerAdapter(VodCategoryAdapter());
  Hive.registerAdapter(VodMovieAdapter());
  Hive.registerAdapter(SeriesCategoryAdapter());
  Hive.registerAdapter(SeriesAdapter());
  Hive.registerAdapter(SeasonAdapter());
  Hive.registerAdapter(EpisodeAdapter());

  // === OTVARANJE BOXOVA (baza podataka) ===
  await Hive.openBox<Playlist>('playlists');
  await Hive.openBox<LiveCategory>('live_categories');
  await Hive.openBox<LiveChannel>('live_channels');
  await Hive.openBox<VodCategory>('vod_categories');
  await Hive.openBox<VodMovie>('vod_movies');
  await Hive.openBox<SeriesCategory>('series_categories');
  await Hive.openBox<Series>('series');
  await Hive.openBox<Season>('seasons');
  await Hive.openBox<Episode>('episodes');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zTv - Player',
      theme: ThemeData(),
      home: const MyHomePage(),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: [
              Image.asset("assets/images/zTv_logo.png", fit: BoxFit.contain),
              Column(
                children: [
                  Text(
                    "Ready for the big screen",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Create a playlist, keep it saved, and browse Live TV, Movies, and Series by category.",
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
                      transitionDuration: const Duration(
                        milliseconds: 600,
                      ), // brzina animacije
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const CreatePlaylistScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            // Slide iz desna + Fade
                            const begin = Offset(
                              1.0,
                              0.0,
                            ); // počinje sa desne strane
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

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
                ),
                child: Text(
                  "Create your playlist",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
