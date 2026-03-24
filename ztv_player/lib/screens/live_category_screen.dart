import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/live_category.dart';
import 'package:ztv_player/models/live_channel.dart';
import 'package:ztv_player/screens/live_channel_player_screen.dart';
import 'package:ztv_player/services/live_channel_service.dart';
import 'package:ztv_player/widgets/app_search_field.dart';
import 'package:ztv_player/widgets/content_cards.dart';
import 'package:ztv_player/widgets/empty_state.dart';

class LiveCategoryScreen extends StatelessWidget {
  final LiveCategory category;

  const LiveCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final searchController = AppSort.liveCategorySearch;
    const channelService = LiveChannelService();

    return PopScope(
      onPopInvokedWithResult: (_, _) => searchController.update(''),
      child: Scaffold(
        appBar: AppBar(
          title: Text(category.name),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: ValueListenableBuilder<String>(
              valueListenable: searchController.notifier,
              builder: (context, query, _) {
                return AppSearchField(
                  value: query,
                  hintText: 'Search channels',
                  onChanged: searchController.update,
                );
              },
            ),
          ),
          leading: IconButton(
            onPressed: () {
              searchController.update('');
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_rounded),
          ),
        ),
        body: ValueListenableBuilder<Box<LiveChannel>>(
          valueListenable: channelService.listenable(),
          builder: (context, box, _) {
            return ValueListenableBuilder<String>(
              valueListenable: searchController.notifier,
              builder: (context, query, _) {
                final channels = channelService.getVisibleChannels(
                  categoryId: category.id,
                  query: query,
                );

                if (channels.isEmpty) {
                  return const EmptyState(
                    title: 'No channels found in this category.',
                    icon: Icons.tv,
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
                            builder: (_) =>
                                LiveChannelPlayerScreen(channel: channel),
                          ),
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
