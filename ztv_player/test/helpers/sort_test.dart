import 'package:flutter_test/flutter_test.dart';
import 'package:ztv_player/helpers/sort.dart';

class _NamedItem {
  const _NamedItem({
    required this.id,
    required this.name,
    required this.weight,
  });

  final String id;
  final String name;
  final int weight;
}

void main() {
  group('AppSort.compareIds', () {
    test('sorts numeric ids numerically when possible', () {
      expect(AppSort.compareIds('2', '10'), lessThan(0));
      expect(AppSort.compareIds('10', '2'), greaterThan(0));
    });

    test('falls back to string comparison for non numeric ids', () {
      expect(AppSort.compareIds('beta', 'alpha'), greaterThan(0));
    });
  });

  group('AppSort.applyNamedSort', () {
    const items = <_NamedItem>[
      _NamedItem(id: '10', name: 'Zulu', weight: 2),
      _NamedItem(id: '2', name: 'Alpha', weight: 3),
      _NamedItem(id: '3', name: 'Echo', weight: 1),
    ];

    test('applies default id ordering', () {
      final sorted = [...items];

      AppSort.applyNamedSort(
        items: sorted,
        sortType: SortType.defaultSort,
        idOf: (item) => item.id,
        nameOf: (item) => item.name,
      );

      expect(sorted.map((item) => item.id), ['2', '3', '10']);
    });

    test('applies ascending name ordering', () {
      final sorted = [...items];

      AppSort.applyNamedSort(
        items: sorted,
        sortType: SortType.asc,
        idOf: (item) => item.id,
        nameOf: (item) => item.name,
      );

      expect(sorted.map((item) => item.name), ['Alpha', 'Echo', 'Zulu']);
    });

    test('applies descending name ordering', () {
      final sorted = [...items];

      AppSort.applyNamedSort(
        items: sorted,
        sortType: SortType.desc,
        idOf: (item) => item.id,
        nameOf: (item) => item.name,
      );

      expect(sorted.map((item) => item.name), ['Zulu', 'Echo', 'Alpha']);
    });

    test('applies custom numeric ordering', () {
      final sorted = [...items];

      AppSort.applyNamedSort(
        items: sorted,
        sortType: SortType.custome,
        idOf: (item) => item.id,
        nameOf: (item) => item.name,
        customValueOf: (item) => item.weight,
        customDescending: true,
      );

      expect(sorted.map((item) => item.weight), [3, 2, 1]);
    });
  });

  group('AppSort.applySearchFilter', () {
    const items = <_NamedItem>[
      _NamedItem(id: '1', name: 'Live Sports', weight: 0),
      _NamedItem(id: '2', name: 'Movie Night', weight: 0),
      _NamedItem(id: '3', name: 'Series Hub', weight: 0),
    ];

    test('returns all items for blank queries', () {
      final result = AppSort.applySearchFilter(
        items: items,
        query: '   ',
        nameOf: (item) => item.name,
      );

      expect(result, hasLength(3));
    });

    test('filters case insensitively', () {
      final result = AppSort.applySearchFilter(
        items: items,
        query: 'movie',
        nameOf: (item) => item.name,
      );

      expect(result.map((item) => item.name), ['Movie Night']);
    });
  });

  group('ScreenUiController', () {
    test('toggleView cycles through 1, 2 and 3 columns', () {
      final controller = ScreenUiController(initialViewColumns: 1);

      controller.toggleView();
      expect(controller.viewColumnsNotifier.value, 2);

      controller.toggleView();
      expect(controller.viewColumnsNotifier.value, 3);

      controller.toggleView();
      expect(controller.viewColumnsNotifier.value, 1);
    });

    test('setViewColumns clamps values to supported range', () {
      final controller = ScreenUiController(initialViewColumns: 2);

      controller.setViewColumns(0);
      expect(controller.viewColumnsNotifier.value, 1);

      controller.setViewColumns(99);
      expect(controller.viewColumnsNotifier.value, 3);
    });

    test('changeSort advances through the configured sort order', () {
      final controller = ScreenUiController();

      controller.changeSort();
      expect(controller.sortNotifier.value, SortType.asc);

      controller.changeSort();
      expect(controller.sortNotifier.value, SortType.desc);

      controller.changeSort();
      expect(controller.sortNotifier.value, SortType.custome);

      controller.changeSort();
      expect(controller.sortNotifier.value, SortType.defaultSort);
    });
  });
}
