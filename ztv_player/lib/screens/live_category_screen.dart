import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/live_tv_channel.dart';
import 'package:ztv_player/models/live_tv_category.dart';
import 'package:ztv_player/screens/live_channel_player_screen.dart';
import 'package:ztv_player/services/live_channel_service.dart';
import 'package:ztv_player/widgets/app_search_field.dart';
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
    const channelService = LiveChannelService();

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
          ),
          actions: [
            IconButton(
              onPressed: () {
                final shouldOpen = !_isSearchOpen;
                setState(() => _isSearchOpen = shouldOpen);
                if (!shouldOpen) {
                  controller.updateSearch('');
                }
              },
              icon: Icon(_isSearchOpen ? Icons.close : Icons.search),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: controller.isGridNotifier,
              builder: (context, isGrid, _) {
                return IconButton(
                  onPressed: controller.toggleView,
                  icon: Icon(controller.viewIcon()),
                );
              },
            ),
            ValueListenableBuilder<SortType>(
              valueListenable: controller.sortNotifier,
              builder: (context, sortType, _) {
                return IconButton(
                  onPressed: controller.changeSort,
                  icon: Icon(controller.sortIcon()),
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
                    return ValueListenableBuilder<bool>(
                      valueListenable: controller.isGridNotifier,
                      builder: (context, isGrid, _) {
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

                        if (isGrid) {
                          return GridView.builder(
                            padding: AppView.contentPadding,
                            gridDelegate: AppView.gridDelegate,
                            itemCount: channels.length,
                            itemBuilder: (context, index) {
                              final channel = channels[index];
                              return AppGridCard(
                                title: channel.name,
                                subtitle: channel.num != null
                                    ? 'Channel ${channel.num}'
                                    : null,
                                imageUrl: channel.logoUrl,
                                fallbackIcon: Icons.tv,
                                accentColor: Colors.blue,
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

                            return AppListCard(
                              title: channel.name,
                              subtitle: channel.num != null
                                  ? 'Channel ${channel.num}'
                                  : null,
                              imageUrl: channel.logoUrl,
                              fallbackIcon: Icons.tv,
                              trailingIcon: Icons.play_circle_fill_rounded,
                              trailingIconColor: Colors.blueAccent,
                              accentColor: Colors.blue,
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
