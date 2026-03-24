import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/series_category.dart';
import 'package:ztv_player/services/series_service.dart';
import 'package:ztv_player/widgets/content_cards.dart';
import 'package:ztv_player/widgets/empty_state.dart';

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppSort.controller(ScreenSection.series);
    const seriesService = SeriesService();

    return ValueListenableBuilder<Box<SeriesCategory>>(
      valueListenable: seriesService.listenable(),
      builder: (context, box, _) {
        return ValueListenableBuilder<SortType>(
          valueListenable: controller.sortNotifier,
          builder: (context, sortType, _) {
            return ValueListenableBuilder<String>(
              valueListenable: controller.searchController.notifier,
              builder: (context, query, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: controller.isGridNotifier,
                  builder: (context, isGrid, _) {
                    final categories = seriesService.getVisibleCategories(
                      sortType: sortType,
                      query: query,
                    );

                    if (categories.isEmpty) {
                      return const EmptyState(
                        title: 'No series categories found.',
                        subtitle: 'Please load series data first.',
                        icon: Icons.tv_outlined,
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
      },
    );
  }
}
