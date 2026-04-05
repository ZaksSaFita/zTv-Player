import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/media_format.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/helpers/theme.dart';
import 'package:ztv_player/models/series.dart';
import 'package:ztv_player/models/series_category.dart';
import 'package:ztv_player/screens/series_player_screen.dart';
import 'package:ztv_player/services/series_service.dart';
import 'package:ztv_player/widgets/app_search_field.dart';
import 'package:ztv_player/widgets/app_sort_button.dart';
import 'package:ztv_player/widgets/app_view_mode_buttons.dart';
import 'package:ztv_player/widgets/content_cards.dart';
import 'package:ztv_player/widgets/empty_state.dart';

class SeriesCategoryScreen extends StatefulWidget {
  const SeriesCategoryScreen({super.key, required this.category});

  final SeriesCategory category;

  @override
  State<SeriesCategoryScreen> createState() => _SeriesCategoryScreenState();
}

class _SeriesCategoryScreenState extends State<SeriesCategoryScreen> {
  bool _isSearchOpen = false;

  @override
  Widget build(BuildContext context) {
    final controller = AppSort.seriesCategoryController;
    final seriesService = SeriesService();

    return PopScope(
      onPopInvokedWithResult: (_, _) {
        controller.updateSearch('');
        setState(() => _isSearchOpen = false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.category.name),
          bottom: _isSearchOpen
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: ValueListenableBuilder<String>(
                    valueListenable: controller.searchController.notifier,
                    builder: (context, query, _) {
                      return AppSearchField(
                        value: query,
                        hintText: 'Search series',
                        onChanged: controller.updateSearch,
                      );
                    },
                  ),
                )
              : null,
          leading: IconButton(
            onPressed: () {
              controller.updateSearch('');
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: AppTheme.colorsNotifier.value.bottomNavIcon,
          ),
          actions: [
            ValueListenableBuilder(
              valueListenable: AppTheme.colorsNotifier,
              builder: (context, colors, _) {
                return IconButton(
                  onPressed: () {
                    final shouldOpen = !_isSearchOpen;
                    setState(() => _isSearchOpen = shouldOpen);
                    if (!shouldOpen) {
                      controller.updateSearch('');
                    }
                  },
                  icon: Icon(_isSearchOpen ? Icons.close : Icons.search),
                  color: _isSearchOpen
                      ? colors.bottomNavSelectedIcon
                      : colors.bottomNavIcon,
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: AppTheme.colorsNotifier,
              builder: (context, colors, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: controller.viewColumnsNotifier,
                  builder: (context, viewColumns, _) {
                    return AppViewModeButtons(
                      columns: viewColumns,
                      iconColor: colors.bottomNavIcon,
                      activeColor: colors.bottomNavSelectedIcon,
                      onPressed: controller.toggleView,
                    );
                  },
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: AppTheme.colorsNotifier,
              builder: (context, colors, _) {
                return ValueListenableBuilder<SortType>(
                  valueListenable: controller.sortNotifier,
                  builder: (context, sortType, _) {
                    return AppSortButton(
                      value: sortType,
                      iconColor: colors.bottomNavIcon,
                      onSelected: controller.setSort,
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: ValueListenableBuilder<Box<Series>>(
          valueListenable: seriesService.seriesListenable(),
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
                        final series = seriesService.getVisibleSeries(
                          categoryId: widget.category.id,
                          sortType: sortType,
                          query: query,
                        );

                        if (series.isEmpty) {
                          return const EmptyState(
                            title: 'No series found in this category.',
                            icon: Icons.tv_outlined,
                          );
                        }

                        if (viewColumns > 1) {
                          return GridView.builder(
                            padding: AppView.contentPadding,
                            gridDelegate: AppView.delegateFor(
                              viewColumns,
                              poster: true,
                              densePoster: true,
                            ),
                            itemCount: series.length,
                            itemBuilder: (context, index) {
                              final item = series[index];
                              return AppPosterGridCard(
                                title: item.name,
                                subtitle: viewColumns >= 3
                                    ? null
                                    : _seriesSubtitle(item),
                                compact: viewColumns >= 3,
                                imageUrl: item.logoUrl,
                                badge: _seriesBadge(item),
                                fallbackIcon: Icons.tv_outlined,
                                accentColor: Colors.tealAccent,
                                onTap: () => _openSeries(context, item),
                              );
                            },
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: series.length,
                          itemBuilder: (context, index) {
                            final item = series[index];
                            return AppPosterListCard(
                              title: item.name,
                              subtitle: _seriesSubtitle(item),
                              imageUrl: item.logoUrl,
                              badge: _seriesBadge(item),
                              fallbackIcon: Icons.tv_outlined,
                              accentColor: Colors.tealAccent,
                              onTap: () => _openSeries(context, item),
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
        ),
      ),
    );
  }

  String? _seriesSubtitle(Series series) {
    final parts = <String>[];
    if (series.genre != null && series.genre!.isNotEmpty) {
      parts.add(series.genre!);
    }
    return parts.isEmpty ? null : parts.join(' | ');
  }

  String? _seriesBadge(Series series) {
    final parts = <String>[];
    if (series.year != null && series.year!.isNotEmpty) {
      parts.add(series.year!);
    }
    if (series.rating != null && series.rating!.isNotEmpty) {
      parts.add(formatRating(series.rating));
    }
    return parts.isEmpty ? null : parts.join(' | ');
  }

  void _openSeries(BuildContext context, Series series) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SeriesPlayerScreen(series: series)),
    );
  }
}
