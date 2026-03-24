import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/series_category.dart';

class SeriesService {
  const SeriesService();

  ValueListenable<Box<SeriesCategory>> listenable() {
    return Hive.box<SeriesCategory>('series_categories').listenable();
  }

  List<SeriesCategory> getSortedCategories(SortType sortType) {
    final categories = Hive.box<SeriesCategory>('series_categories').values.toList();

    AppSort.applyNamedSort(
      items: categories,
      sortType: sortType,
      idOf: (category) => category.id,
      nameOf: (category) => category.name,
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
}
