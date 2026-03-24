import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/models/live_tv_channel.dart';

class LiveTvService {
  const LiveTvService();

  static const _hiddenPrefixes = ['❱》'];

  ValueListenable<Box<LiveTvChannel>> listenable() {
    return Hive.box<LiveTvChannel>('live_channels').listenable();
  }

  List<LiveTvChannel> getChannelsByCategory(String categoryId) {
    final channels =
        Hive.box<LiveTvChannel>('live_channels').values
            .where(
              (channel) =>
                  channel.categoryId == categoryId &&
                  !_shouldHideChannel(channel.name),
            )
            .toList()
          ..sort((a, b) => (a.num ?? 0).compareTo(b.num ?? 0));

    return channels;
  }

  bool _shouldHideChannel(String name) {
    final normalizedName = name.trimLeft();
    return _hiddenPrefixes.any(normalizedName.startsWith);
  }

  List<LiveTvChannel> getVisibleChannels({
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
