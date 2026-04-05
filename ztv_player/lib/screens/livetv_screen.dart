import 'package:flutter/material.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/live_tv_category.dart';
import 'package:ztv_player/services/live_service.dart';
import 'package:ztv_player/widgets/content_section_view.dart';
import 'live_category_screen.dart';

class LiveTvScreen extends StatelessWidget {
  const LiveTvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const liveService = LiveService();

    return ContentSectionView<LiveTvCategory, LiveTvCategory>(
      section: ScreenSection.live,
      listenable: liveService.listenable(),
      itemsBuilder: (sortType, query) => liveService.getVisibleCategories(
        sortType: sortType,
        query: query,
      ),
      emptyTitle: 'No live categories found.',
      emptySubtitle: 'Please load a playlist first.',
      emptyIcon: Icons.live_tv_rounded,
      fallbackIcon: Icons.live_tv_rounded,
      accentColor: Colors.blue,
      titleOf: (category) => category.name,
      subtitleOf: (category, viewColumns) => viewColumns == 2
          ? null
          : '${category.channelCount} channels',
      onTap: _openCategory,
    );
  }
}

void _openCategory(BuildContext context, LiveTvCategory category) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => LiveCategoryScreen(category: category)),
  );
}
