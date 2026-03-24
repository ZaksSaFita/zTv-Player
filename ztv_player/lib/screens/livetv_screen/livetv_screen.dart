import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/live_tv_category.dart';
import 'package:ztv_player/widgets/content_cards.dart';
import 'live_category_screen.dart';

class LiveTvScreen extends StatelessWidget {
  const LiveTvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppSort.controller(ScreenSection.live);

    return ValueListenableBuilder<SortType>(
      valueListenable: controller.sortNotifier,
      builder: (context, sortType, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: controller.isGridNotifier,
          builder: (context, isGrid, _) {
            return ValueListenableBuilder(
              valueListenable: Hive.box<LiveTvCategory>(
                'live_categories',
              ).listenable(),
              builder: (context, Box<LiveTvCategory> box, _) {
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
                      'No live categories found.\nPlease load a playlist first.',
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
                        subtitle: '${category.channelCount} channels',
                        fallbackIcon: Icons.live_tv_rounded,
                        accentColor: Colors.blue,
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
                      subtitle: '${category.channelCount} channels',
                      fallbackIcon: Icons.live_tv_rounded,
                      trailingIcon: Icons.arrow_forward_ios_rounded,
                      accentColor: Colors.blue,
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
  }
}

void _openCategory(BuildContext context, LiveTvCategory category) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => LiveCategoryScreen(category: category)),
  );
}
