import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/vod_category.dart';

class MovieService {
  const MovieService();

  ValueListenable<Box<VodCategory>> listenable() {
    return Hive.box<VodCategory>('vod_categories').listenable();
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
}
