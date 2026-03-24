import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/live_category.dart';

class LiveService {
  const LiveService();

  ValueListenable<Box<LiveCategory>> listenable() {
    return Hive.box<LiveCategory>('live_categories').listenable();
  }

  List<LiveCategory> getSortedCategories(SortType sortType) {
    final categories = Hive.box<LiveCategory>('live_categories').values.toList();

    AppSort.applyNamedSort(
      items: categories,
      sortType: sortType,
      idOf: (category) => category.id,
      nameOf: (category) => category.name,
    );

    return categories;
  }

  List<LiveCategory> getVisibleCategories({
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
