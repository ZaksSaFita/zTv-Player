import 'package:flutter/material.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/series_category.dart';
import 'package:ztv_player/screens/series_category_screen.dart';
import 'package:ztv_player/services/series_service.dart';
import 'package:ztv_player/widgets/content_section_view.dart';

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final seriesService = SeriesService();

    return ContentSectionView<SeriesCategory, SeriesCategory>(
      section: ScreenSection.series,
      listenable: seriesService.categoriesListenable(),
      itemsBuilder: (sortType, query) => seriesService.getVisibleCategories(
        sortType: sortType,
        query: query,
      ),
      emptyTitle: 'No series categories found.',
      emptySubtitle: 'Please load series data first.',
      emptyIcon: Icons.tv_outlined,
      fallbackIcon: Icons.tv_outlined,
      accentColor: Colors.tealAccent,
      titleOf: (category) => category.name,
      subtitleOf: (category, viewColumns) =>
          viewColumns == 2 ? null : '${category.seriesCount ?? 0} series',
      onTap: _openCategory,
    );
  }
}

void _openCategory(BuildContext context, SeriesCategory category) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => SeriesCategoryScreen(category: category)),
  );
}
