import 'package:hive_flutter/hive_flutter.dart';

enum FavoriteContentType { liveTv, movie, series }

class FavoritesService {
  const FavoritesService();

  Box get _settingsBox => Hive.box('settings');

  bool isFavorite(FavoriteContentType type, String id) {
    return _favoritesFor(type).contains(id);
  }

  bool toggleFavorite(FavoriteContentType type, String id) {
    final favorites = _favoritesFor(type);
    final updated = {...favorites};
    final isFavorite = updated.contains(id);

    if (isFavorite) {
      updated.remove(id);
    } else {
      updated.add(id);
    }

    _settingsBox.put(_keyFor(type), updated.toList()..sort());
    return !isFavorite;
  }

  Set<String> _favoritesFor(FavoriteContentType type) {
    final stored = _settingsBox.get(_keyFor(type));
    if (stored is List) {
      return stored.map((item) => item.toString()).toSet();
    }
    return <String>{};
  }

  String _keyFor(FavoriteContentType type) {
    switch (type) {
      case FavoriteContentType.liveTv:
        return 'favorite_live_channels';
      case FavoriteContentType.movie:
        return 'favorite_movies';
      case FavoriteContentType.series:
        return 'favorite_series';
    }
  }
}
