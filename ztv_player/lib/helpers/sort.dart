import 'package:flutter/material.dart';

enum SortType { defaultSort, asc, desc, custome }

enum ScreenSection { live, movies, series }

class SearchController {
  final ValueNotifier<String> notifier;

  SearchController({String initialValue = ''})
    : notifier = ValueNotifier(initialValue);

  void update(String query) {
    notifier.value = query;
  }
}

class ScreenUiController {
  final ValueNotifier<SortType> sortNotifier;
  final ValueNotifier<bool> isGridNotifier;
  final SearchController searchController;

  ScreenUiController({
    SortType initialSort = SortType.defaultSort,
    bool initialIsGrid = true,
    String initialSearch = '',
  }) : sortNotifier = ValueNotifier(initialSort),
       isGridNotifier = ValueNotifier(initialIsGrid),
       searchController = SearchController(initialValue: initialSearch);

  void changeSort() {
    sortNotifier.value = AppSort.nextSort(sortNotifier.value);
  }

  void toggleView() {
    isGridNotifier.value = !isGridNotifier.value;
  }

  void updateSearch(String query) {
    searchController.update(query);
  }

  IconData sortIcon() {
    return AppSort.iconFor(sortNotifier.value);
  }

  IconData viewIcon() {
    return AppView.iconFor(isGridNotifier.value);
  }
}

class AppSort {
  static final Map<ScreenSection, ScreenUiController> _controllers = {
    ScreenSection.live: ScreenUiController(),
    ScreenSection.movies: ScreenUiController(),
    ScreenSection.series: ScreenUiController(),
  };

  static final SearchController liveCategorySearch = SearchController();

  static ScreenUiController controller(ScreenSection section) {
    return _controllers[section]!;
  }

  static SortType nextSort(SortType current) {
    switch (current) {
      case SortType.defaultSort:
        return SortType.asc;
      case SortType.asc:
        return SortType.desc;
      case SortType.desc:
        return SortType.custome;
      case SortType.custome:
        return SortType.defaultSort;
    }
  }

  static IconData iconFor(SortType sortType) {
    switch (sortType) {
      case SortType.defaultSort:
        return Icons.sort;
      case SortType.asc:
        return Icons.arrow_upward;
      case SortType.desc:
        return Icons.arrow_downward;
      case SortType.custome:
        return Icons.settings;
    }
  }

  static int compareIds(String a, String b) {
    final aNumber = int.tryParse(a);
    final bNumber = int.tryParse(b);

    if (aNumber != null && bNumber != null) {
      return aNumber.compareTo(bNumber);
    }

    return a.compareTo(b);
  }

  static void applyNamedSort<T>({
    required List<T> items,
    required SortType sortType,
    required String Function(T item) idOf,
    required String Function(T item) nameOf,
    int Function(T item)? customValueOf,
    bool customDescending = false,
  }) {
    switch (sortType) {
      case SortType.asc:
        items.sort((a, b) => nameOf(a).compareTo(nameOf(b)));
        break;
      case SortType.desc:
        items.sort((a, b) => nameOf(b).compareTo(nameOf(a)));
        break;
      case SortType.custome:
        if (customValueOf != null) {
          items.sort((a, b) {
            final first = customValueOf(a);
            final second = customValueOf(b);
            return customDescending
                ? second.compareTo(first)
                : first.compareTo(second);
          });
        }
        break;
      case SortType.defaultSort:
        items.sort((a, b) => compareIds(idOf(a), idOf(b)));
        break;
    }
  }

  static List<T> applySearchFilter<T>({
    required List<T> items,
    required String query,
    required String Function(T item) nameOf,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return items;
    }

    return items
        .where((item) => nameOf(item).toLowerCase().contains(normalizedQuery))
        .toList();
  }
}

class AppView {
  static const EdgeInsets contentPadding = EdgeInsets.all(12);
  static const SliverGridDelegateWithFixedCrossAxisCount gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      );

  static IconData iconFor(bool isGrid) {
    return isGrid ? Icons.grid_view : Icons.view_list;
  }
}
