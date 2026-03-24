import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/vod_category.dart';
import 'package:ztv_player/screens/movie_category_screen.dart';
import 'package:ztv_player/services/movie_service.dart';
import 'package:ztv_player/widgets/content_cards.dart';
import 'package:ztv_player/widgets/empty_state.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppSort.controller(ScreenSection.movies);
    final movieService = MovieService();

    return ValueListenableBuilder<Box<VodCategory>>(
      valueListenable: movieService.categoriesListenable(),
      builder: (context, box, _) {
        return ValueListenableBuilder<SortType>(
          valueListenable: controller.sortNotifier,
          builder: (context, sortType, _) {
            return ValueListenableBuilder<String>(
              valueListenable: controller.searchController.notifier,
              builder: (context, query, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: controller.viewColumnsNotifier,
                  builder: (context, viewColumns, _) {
                    final categories = movieService.getVisibleCategories(
                      sortType: sortType,
                      query: query,
                    );

                    if (categories.isEmpty) {
                      return const EmptyState(
                        title: 'No movie categories found.',
                        subtitle: 'Please load movie data first.',
                        icon: Icons.movie_creation_outlined,
                      );
                    }

                    if (viewColumns > 1) {
                      return GridView.builder(
                        padding: AppView.contentPadding,
                        gridDelegate: AppView.delegateFor(viewColumns),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return AppGridCard(
                            title: category.name,
                            subtitle: '${category.movieCount ?? 0} movies',
                            fallbackIcon: Icons.movie_creation_outlined,
                            accentColor: Colors.red,
                            onTap: () => _openCategory(context, category),
                          );
                        },
                      );
                    }

                    return ListView.builder(
                      padding: AppView.contentPadding,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return AppListCard(
                          title: category.name,
                          subtitle: '${category.movieCount ?? 0} movies',
                          fallbackIcon: Icons.movie_creation_outlined,
                          accentColor: Colors.red,
                          trailingIcon: Icons.arrow_forward_ios_rounded,
                          onTap: () => _openCategory(context, category),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

void _openCategory(BuildContext context, VodCategory category) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => MovieCategoryScreen(category: category)),
  );
}
