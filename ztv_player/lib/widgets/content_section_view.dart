import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/widgets/content_cards.dart';
import 'package:ztv_player/widgets/empty_state.dart';

typedef ContentItemTitle<T> = String Function(T item);
typedef ContentItemSubtitle<T> = String? Function(T item, int viewColumns);
typedef ContentItemTap<T> = void Function(BuildContext context, T item);

class ContentSectionView<T, B> extends StatelessWidget {
  const ContentSectionView({
    super.key,
    required this.section,
    required this.listenable,
    required this.itemsBuilder,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
    required this.fallbackIcon,
    required this.accentColor,
    required this.titleOf,
    required this.subtitleOf,
    required this.onTap,
  });

  final ScreenSection section;
  final ValueListenable<Box<B>> listenable;
  final List<T> Function(SortType sortType, String query) itemsBuilder;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final IconData fallbackIcon;
  final Color accentColor;
  final ContentItemTitle<T> titleOf;
  final ContentItemSubtitle<T> subtitleOf;
  final ContentItemTap<T> onTap;

  @override
  Widget build(BuildContext context) {
    final controller = AppSort.controller(section);

    return ValueListenableBuilder<Box<B>>(
      valueListenable: listenable,
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
                    final items = itemsBuilder(sortType, query);

                    if (items.isEmpty) {
                      return EmptyState(
                        title: emptyTitle,
                        subtitle: emptySubtitle,
                        icon: emptyIcon,
                      );
                    }

                    if (viewColumns > 1) {
                      return GridView.builder(
                        padding: AppView.contentPadding,
                        gridDelegate: AppView.delegateFor(
                          viewColumns,
                          denseTextGrid: true,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return AppGridCard(
                            title: titleOf(item),
                            subtitle: subtitleOf(item, viewColumns),
                            fallbackIcon: fallbackIcon,
                            accentColor: accentColor,
                            horizontalLayout: viewColumns == 2,
                            onTap: () => onTap(context, item),
                          );
                        },
                      );
                    }

                    return ListView.builder(
                      padding: AppView.contentPadding,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return AppListCard(
                          title: titleOf(item),
                          subtitle: subtitleOf(item, viewColumns),
                          fallbackIcon: fallbackIcon,
                          trailingIcon: Icons.arrow_forward_ios_rounded,
                          accentColor: accentColor,
                          onTap: () => onTap(context, item),
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
