import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/vod_category.dart';
import 'package:ztv_player/models/vod_details.dart';
import 'package:ztv_player/models/vod_movie.dart';
import 'package:ztv_player/services/settings_service.dart';
import 'package:ztv_player/services/xtream_api_service.dart';

class MovieService {
  MovieService({
    SettingsService? settingsService,
    XtreamApiService? apiService,
  }) : _settingsService = settingsService ?? const SettingsService(),
       _apiService = apiService ?? XtreamApiService();

  final SettingsService _settingsService;
  final XtreamApiService _apiService;

  ValueListenable<Box<VodCategory>> categoriesListenable() {
    return Hive.box<VodCategory>('vod_categories').listenable();
  }

  ValueListenable<Box<VodMovie>> moviesListenable() {
    return Hive.box<VodMovie>('vod_movies').listenable();
  }

  List<VodCategory> getSortedCategories(SortType sortType) {
    final categories = Hive.box<VodCategory>('vod_categories').values.toList();

    AppSort.applyNamedSort(
      items: categories,
      sortType: sortType,
      idOf: (category) => category.id,
      nameOf: (category) => category.name,
      customValueOf: (category) => category.movieCount ?? 0,
      customDescending: true,
    );

    return categories;
  }

  List<VodCategory> getVisibleCategories({
    required SortType sortType,
    required String query,
  }) {
    final categories = getSortedCategories(sortType);
    return AppSort.applySearchFilter(
      items: categories,
      query: query,
      nameOf: (category) => category.name,
    );
  }

  List<VodMovie> getMoviesByCategory(String categoryId) {
    final movies =
        Hive.box<VodMovie>('vod_movies').values
            .where((movie) => movie.categoryId == categoryId)
            .toList()
          ..sort((a, b) => (a.num ?? 0).compareTo(b.num ?? 0));

    return movies;
  }

  List<VodMovie> getVisibleMovies({
    required String categoryId,
    required SortType sortType,
    required String query,
  }) {
    final movies = getMoviesByCategory(categoryId);
    AppSort.applyNamedSort(
      items: movies,
      sortType: sortType,
      idOf: (movie) => movie.id,
      nameOf: (movie) => movie.name,
      customValueOf: (movie) => movie.num ?? 0,
    );

    return AppSort.applySearchFilter(
      items: movies,
      query: query,
      nameOf: (movie) => movie.name,
    );
  }

  Future<VodDetails> getMovieDetails(String movieId) async {
    final playlist = _settingsService.getCurrentPlaylist();
    if (playlist == null) {
      throw Exception('No active playlist.');
    }

    return _apiService.fetchVodDetails(
      server: playlist.server,
      username: playlist.username,
      password: playlist.password,
      vodId: movieId,
    );
  }
}
