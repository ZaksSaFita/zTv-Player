import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/live_channel.dart';

class LiveChannelService {
  const LiveChannelService();

  ValueListenable<Box<LiveChannel>> listenable() {
    return Hive.box<LiveChannel>('live_channels').listenable();
  }

  List<LiveChannel> getChannelsByCategory(String categoryId) {
    final channels = Hive.box<LiveChannel>('live_channels').values
        .where(
          (channel) =>
              channel.categoryId == categoryId &&
              !channel.name.trimLeft().startsWith('❱》'),
        )
        .toList()
      ..sort((a, b) => (a.num ?? 0).compareTo(b.num ?? 0));

    return channels;
  }

  List<LiveChannel> getVisibleChannels({
    required String categoryId,
    required SortType sortType,
    required String query,
  }) {
    final channels = getChannelsByCategory(categoryId);
    AppSort.applyNamedSort(
      items: channels,
      sortType: sortType,
      idOf: (channel) => channel.id,
      nameOf: (channel) => channel.name,
      customValueOf: (channel) => channel.num ?? 0,
    );

    return AppSort.applySearchFilter(
      items: channels,
      query: query,
      nameOf: (channel) => channel.name,
    );
  }
}
