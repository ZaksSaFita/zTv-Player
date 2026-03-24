import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/series_category.dart';
import 'package:ztv_player/widgets/content_cards.dart';

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppSort.controller(ScreenSection.series);

    return ValueListenableBuilder<SortType>(
      valueListenable: controller.sortNotifier,
      builder: (context, sortType, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: controller.isGridNotifier,
          builder: (context, isGrid, _) {
            return ValueListenableBuilder(
              valueListenable: Hive.box<SeriesCategory>('series_categories')
                  .listenable(),
              builder: (context, Box<SeriesCategory> box, _) {
                final categories = box.values.toList();

                AppSort.applyNamedSort(
                  items: categories,
                  sortType: sortType,
                  idOf: (category) => category.id,
                  nameOf: (category) => category.name,
                );

                if (categories.isEmpty) {
                  return const Center(
                    child: Text(
                      'No series categories found.\nPlease load series data first.',
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
                        fallbackIcon: Icons.tv_outlined,
                        accentColor: Colors.tealAccent,
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
                      fallbackIcon: Icons.tv_outlined,
                      accentColor: Colors.tealAccent,
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
