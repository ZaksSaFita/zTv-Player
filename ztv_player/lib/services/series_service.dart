import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/series.dart';
import 'package:ztv_player/models/series_category.dart';
import 'package:ztv_player/models/series_details.dart';
import 'package:ztv_player/services/settings_service.dart';
import 'package:ztv_player/services/xtream_api_service.dart';

class SeriesService {
  SeriesService({
    SettingsService? settingsService,
    XtreamApiService? apiService,
  }) : _settingsService = settingsService ?? const SettingsService(),
       _apiService = apiService ?? XtreamApiService();

  final SettingsService _settingsService;
  final XtreamApiService _apiService;

  ValueListenable<Box<SeriesCategory>> categoriesListenable() {
    return Hive.box<SeriesCategory>('series_categories').listenable();
  }

  ValueListenable<Box<Series>> seriesListenable() {
    return Hive.box<Series>('series').listenable();
  }

  List<SeriesCategory> getSortedCategories(SortType sortType) {
    final categories = Hive.box<SeriesCategory>('series_categories').values.toList();

    AppSort.applyNamedSort(
      items: categories,
      sortType: sortType,
      idOf: (category) => category.id,
      nameOf: (category) => category.name,
      customValueOf: (category) => category.seriesCount ?? 0,
      customDescending: true,
    );

    return categories;
  }

  List<SeriesCategory> getVisibleCategories({
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

  List<Series> getSeriesByCategory(String categoryId) {
    final series =
        Hive.box<Series>('series').values
            .where((item) => item.categoryId == categoryId)
            .toList()
          ..sort((a, b) => (a.num ?? 0).compareTo(b.num ?? 0));

    return series;
  }

  List<Series> getVisibleSeries({
    required String categoryId,
    required SortType sortType,
    required String query,
  }) {
    final series = getSeriesByCategory(categoryId);
    AppSort.applyNamedSort(
      items: series,
      sortType: sortType,
      idOf: (item) => item.id,
      nameOf: (item) => item.name,
      customValueOf: (item) => item.num ?? 0,
    );

    return AppSort.applySearchFilter(
      items: series,
      query: query,
      nameOf: (item) => item.name,
    );
  }

  Future<SeriesDetails> getSeriesDetails(String seriesId) async {
    final playlist = _settingsService.getCurrentPlaylist();
    if (playlist == null) {
      throw Exception('No active playlist.');
    }

    return _apiService.fetchSeriesDetails(
      server: playlist.server,
      username: playlist.username,
      password: playlist.password,
      seriesId: seriesId,
    );
  }
}
