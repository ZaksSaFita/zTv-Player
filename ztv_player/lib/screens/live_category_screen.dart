import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/helpers/theme.dart';
import 'package:ztv_player/models/live_tv_channel.dart';
import 'package:ztv_player/models/live_tv_category.dart';
import 'package:ztv_player/screens/live_channel_player_screen.dart';
import 'package:ztv_player/services/live_tv_service.dart';
import 'package:ztv_player/widgets/app_search_field.dart';
import 'package:ztv_player/widgets/app_sort_button.dart';
import 'package:ztv_player/widgets/app_view_mode_buttons.dart';
import 'package:ztv_player/widgets/content_cards.dart';
import 'package:ztv_player/widgets/empty_state.dart';

class LiveCategoryScreen extends StatefulWidget {
  final LiveTvCategory category;

  const LiveCategoryScreen({super.key, required this.category});

  @override
  State<LiveCategoryScreen> createState() => _LiveCategoryScreenState();
}

class _LiveCategoryScreenState extends State<LiveCategoryScreen> {
  bool _isSearchOpen = false;

  @override
  Widget build(BuildContext context) {
    final controller = AppSort.liveCategoryController;
    const channelService = LiveTvService();

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
                        hintText: 'Search channels',
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
        body: ValueListenableBuilder<Box<LiveTvChannel>>(
          valueListenable: channelService.listenable(),
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
                        final channels = channelService.getVisibleChannels(
                          categoryId: widget.category.id,
                          sortType: sortType,
                          query: query,
                        );

                        if (channels.isEmpty) {
                          return const EmptyState(
                            title: 'No channels found in this category.',
                            icon: Icons.tv,
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
                            itemCount: channels.length,
                            itemBuilder: (context, index) {
                              final channel = channels[index];
                              return AppPosterGridCard(
                                title: channel.name,
                                imageUrl: channel.logoUrl,
                                fallbackIcon: Icons.tv,
                                accentColor: Colors.blue,
                                imageFit: BoxFit.contain,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => LiveChannelPlayerScreen(
                                        channel: channel,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: channels.length,
                          itemBuilder: (context, index) {
                            final channel = channels[index];

                            return AppPosterListCard(
                              title: channel.name,
                              imageUrl: channel.logoUrl,
                             // badge: _channelBadge(channel),
                              fallbackIcon: Icons.tv,
                              accentColor: Colors.blue,
                              imageFit: BoxFit.contain,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => LiveChannelPlayerScreen(
                                      channel: channel,
                                    ),
                                  ),
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
          },
        ),
      ),
    );
  }

  
}
