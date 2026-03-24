import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/vod_category.dart';
import 'package:ztv_player/widgets/content_cards.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppSort.controller(ScreenSection.movies);

    return ValueListenableBuilder<SortType>(
      valueListenable: controller.sortNotifier,
      builder: (context, sortType, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: controller.isGridNotifier,
          builder: (context, isGrid, _) {
            return ValueListenableBuilder(
              valueListenable: Hive.box<VodCategory>('vod_categories')
                  .listenable(),
              builder: (context, Box<VodCategory> box, _) {
                final categories = box.values.toList();

                AppSort.applyNamedSort(
                  items: categories,
                  sortType: sortType,
                  idOf: (category) => category.id,
                  nameOf: (category) => category.name,
                  customValueOf: (category) => category.movieCount ?? 0,
                  customDescending: true,
                );

                if (categories.isEmpty) {
                  return const Center(
                    child: Text(
                      'No movie categories found.\nPlease load movie data first.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  );
                }

                if (isGrid) {
                  return GridView.builder(
                    padding: AppView.contentPadding,
                    gridDelegate: AppView.gridDelegate,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return AppGridCard(
                        title: category.name,
                        subtitle: '${category.movieCount ?? 0} movies',
                        fallbackIcon: Icons.movie_creation_outlined,
                        accentColor: Colors.red,
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
