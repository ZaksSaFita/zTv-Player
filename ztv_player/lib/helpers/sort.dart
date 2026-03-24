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
  final ValueNotifier<int> viewColumnsNotifier;
  final SearchController searchController;

  ScreenUiController({
    SortType initialSort = SortType.defaultSort,
    int initialViewColumns = 2,
    String initialSearch = '',
  }) : sortNotifier = ValueNotifier(initialSort),
       viewColumnsNotifier = ValueNotifier(initialViewColumns),
       searchController = SearchController(initialValue: initialSearch);

  void changeSort() {
    sortNotifier.value = AppSort.nextSort(sortNotifier.value);
  }

  void setSort(SortType sortType) {
    sortNotifier.value = sortType;
  }

  void toggleView() {
    switch (viewColumnsNotifier.value) {
      case 1:
        viewColumnsNotifier.value = 2;
        break;
      case 2:
        viewColumnsNotifier.value = 3;
        break;
      default:
        viewColumnsNotifier.value = 1;
        break;
    }
  }

  void setViewColumns(int columns) {
    viewColumnsNotifier.value = columns.clamp(1, 3);
  }

  void setListView() {
    viewColumnsNotifier.value = 1;
  }

  void cycleGridView() {
    viewColumnsNotifier.value = viewColumnsNotifier.value == 2 ? 3 : 2;
  }

  void updateSearch(String query) {
    searchController.update(query);
  }

  IconData sortIcon() {
    return AppSort.iconFor(sortNotifier.value);
  }

  IconData viewIcon() {
    return AppView.iconFor(viewColumnsNotifier.value);
  }
}

class AppSort {
  static final Map<ScreenSection, ScreenUiController> _controllers = {
    ScreenSection.live: ScreenUiController(),
    ScreenSection.movies: ScreenUiController(),
    ScreenSection.series: ScreenUiController(),
  };

  static final ScreenUiController liveCategoryController = ScreenUiController(
    initialViewColumns: 1,
  );
  static final ScreenUiController movieCategoryController = ScreenUiController(
    initialViewColumns: 1,
  );
  static final ScreenUiController seriesCategoryController = ScreenUiController(
    initialViewColumns: 1,
  );

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

  static String labelFor(SortType sortType) {
    switch (sortType) {
      case SortType.defaultSort:
        return 'Default';
      case SortType.asc:
        return 'A-Z';
      case SortType.desc:
        return 'Z-A';
      case SortType.custome:
        return 'Custom';
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
  static SliverGridDelegateWithFixedCrossAxisCount delegateFor(
    int columns, {
    bool poster = false,
    bool densePoster = false,
    bool denseTextGrid = false,
  }) {
    final resolvedColumns = columns < 2 ? 2 : columns;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: resolvedColumns,
      crossAxisSpacing: 12,
      mainAxisSpacing: poster ? 14 : 12,
      childAspectRatio: poster
          ? densePoster
                ? (resolvedColumns == 2 ? 0.82 : 0.74)
                : (resolvedColumns == 2 ? 0.72 : 0.62)
          : denseTextGrid
          ? (resolvedColumns == 2 ? 1.08 : 0.82)
          : (resolvedColumns == 2 ? 1.2 : 0.96),
    );
  }

  static IconData iconFor(int columns) {
    switch (columns) {
      case 1:
        return Icons.view_agenda_outlined;
      case 2:
        return Icons.grid_view_rounded;
      default:
        return Icons.grid_on_rounded;
    }
  }
}
