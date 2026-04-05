import 'package:flutter/material.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/vod_category.dart';
import 'package:ztv_player/screens/movie_category_screen.dart';
import 'package:ztv_player/services/movie_service.dart';
import 'package:ztv_player/widgets/content_section_view.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movieService = MovieService();

    return ContentSectionView<VodCategory, VodCategory>(
      section: ScreenSection.movies,
      listenable: movieService.categoriesListenable(),
      itemsBuilder: (sortType, query) => movieService.getVisibleCategories(
        sortType: sortType,
        query: query,
      ),
      emptyTitle: 'No movie categories found.',
      emptySubtitle: 'Please load movie data first.',
      emptyIcon: Icons.movie_creation_outlined,
      fallbackIcon: Icons.movie_creation_outlined,
      accentColor: Colors.red,
      titleOf: (category) => category.name,
      subtitleOf: (category, viewColumns) =>
          viewColumns == 2 ? null : '${category.movieCount ?? 0} movies',
      onTap: _openCategory,
    );
  }
}

void _openCategory(BuildContext context, VodCategory category) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => MovieCategoryScreen(category: category)),
  );
}
