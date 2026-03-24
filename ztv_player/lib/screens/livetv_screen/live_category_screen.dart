import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/models/live_category.dart';
import 'package:ztv_player/models/live_channel.dart';
import 'package:ztv_player/widgets/content_cards.dart';

class LiveCategoryScreen extends StatelessWidget {
  final LiveCategory category;

  const LiveCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<LiveChannel>('live_channels').listenable(),
        builder: (context, Box<LiveChannel> box, _) {
          final channels = box.values
              .where((channel) => channel.categoryId == category.id)
              .toList()
            ..sort((a, b) => (a.num ?? 0).compareTo(b.num ?? 0));

          if (channels.isEmpty) {
            return const Center(
              child: Text(
                'No channels found in this category',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];

              return AppListCard(
                title: channel.name,
                subtitle: channel.num != null ? 'Channel ${channel.num}' : null,
                imageUrl: channel.logoUrl,
                fallbackIcon: Icons.tv,
                trailingIcon: Icons.play_circle_fill_rounded,
                trailingIconColor: Colors.blueAccent,
                accentColor: Colors.blue,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Playing: ${channel.name}'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
