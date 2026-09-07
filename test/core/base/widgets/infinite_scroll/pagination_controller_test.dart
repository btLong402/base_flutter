import 'dart:async';

import 'package:base_flutter/core/base/widgets/infinite_scroll/pagination_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PaginationController - Initialization & Lifecycle', () {
    test('should automatically fetch initial page when autoStart is true',
        () async {
      final fetchedPages = <int>[];
      final controller = PaginationController<String>(
        pageSize: 5,
        loadPage: ({required page, required pageSize}) async {
          fetchedPages.add(page);
          return List.generate(pageSize, (i) => 'Item $page-$i');
        },
      );

      // Wait for microtask
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(fetchedPages, equals([1]));
      expect(controller.isInitialized, isTrue);
      expect(controller.itemCount, equals(5));
      expect(controller.hasMore, isTrue);
      expect(controller.error, isNull);

      controller.dispose();
    });

    test('should not automatically fetch when autoStart is false', () async {
      final fetchedPages = <int>[];
      final controller = PaginationController<String>(
        autoStart: false,
        pageSize: 5,
        loadPage: ({required page, required pageSize}) async {
          fetchedPages.add(page);
          return ['Item 1'];
        },
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(fetchedPages, isEmpty);
      expect(controller.isInitialized, isFalse);
      expect(controller.itemCount, equals(0));

      controller.dispose();
    });
  });

  group('PaginationController - Pagination & Fetching', () {
    test('loadMore should fetch next page and append items', () async {
      final controller = PaginationController<int>(
        autoStart: false,
        pageSize: 3,
        loadPage: ({required page, required pageSize}) async {
          return List.generate(pageSize, (i) => (page - 1) * pageSize + i);
        },
      );

      await controller.refresh();
      expect(controller.items, equals([0, 1, 2]));
      expect(controller.nextPage, equals(2));

      await controller.loadMore();
      expect(controller.items, equals([0, 1, 2, 3, 4, 5]));
      expect(controller.nextPage, equals(3));
      expect(controller.itemAt(4), equals(4));

      controller.dispose();
    });

    test('should set hasMore to false when loaded items are less than pageSize',
        () async {
      final controller = PaginationController<int>(
        autoStart: false,
        pageSize: 5,
        loadPage: ({required page, required pageSize}) async {
          if (page == 1) return [1, 2, 3, 4, 5];
          return [6, 7]; // less than pageSize
        },
      );

      await controller.refresh();
      expect(controller.hasMore, isTrue);

      await controller.loadMore();
      expect(controller.hasMore, isFalse);

      controller.dispose();
    });

    test('deduplication: concurrent fetch for same page returns same future',
        () async {
      var callCount = 0;
      final completer = Completer<List<String>>();

      final controller = PaginationController<String>(
        autoStart: false,
        pageSize: 2,
        loadPage: ({required page, required pageSize}) {
          callCount++;
          return completer.future;
        },
      );

      // Trigger two refreshes concurrently
      final f1 = controller.refresh();
      final f2 = controller.refresh();

      completer.complete(['A', 'B']);
      await Future.wait([f1, f2]);

      expect(callCount, equals(1));
      expect(controller.items, equals(['A', 'B']));

      controller.dispose();
    });
  });

  group('PaginationController - Error Handling & Retry', () {
    test('should preserve previous items on refresh failure and store error',
        () async {
      var shouldFail = false;
      final controller = PaginationController<String>(
        autoStart: false,
        pageSize: 2,
        loadPage: ({required page, required pageSize}) async {
          if (shouldFail) {
            throw Exception('Network error');
          }
          return ['Alpha', 'Beta'];
        },
      );

      await controller.refresh();
      expect(controller.items, equals(['Alpha', 'Beta']));
      expect(controller.error, isNull);

      shouldFail = true;
      await controller.refresh();

      expect(controller.error, isA<Exception>());
      // Previous items must be preserved (not cleared) on failed refresh
      expect(controller.items, equals(['Alpha', 'Beta']));

      // Now retry with success
      shouldFail = false;
      await controller.retry();
      expect(controller.error, isNull);
      expect(controller.items, equals(['Alpha', 'Beta']));

      controller.dispose();
    });

    test('should handle error during loadMore and allow retry', () async {
      var shouldFailLoadMore = true;
      final controller = PaginationController<String>(
        autoStart: false,
        pageSize: 2,
        loadPage: ({required page, required pageSize}) async {
          if (page == 2 && shouldFailLoadMore) {
            throw Exception('Load more failed');
          }
          return page == 1 ? ['Item 1', 'Item 2'] : ['Item 3', 'Item 4'];
        },
      );

      await controller.refresh();
      expect(controller.itemCount, equals(2));

      await controller.loadMore();
      expect(controller.error, isNotNull);
      expect(controller.itemCount, equals(2)); // Didn't corrupt list

      shouldFailLoadMore = false;
      await controller.retry();
      expect(controller.error, isNull);
      expect(controller.itemCount, equals(4));

      controller.dispose();
    });
  });

  group('PaginationController - CRUD Operations', () {
    test('insertItem, updateItemWhere, removeItemsWhere, replaceItems, clear',
        () async {
      final controller = PaginationController<String>(
        autoStart: false,
        pageSize: 3,
        loadPage: ({required page, required pageSize}) async {
          return ['A', 'B', 'C'];
        },
      );

      await controller.refresh();
      expect(controller.items, equals(['A', 'B', 'C']));

      // 1. insertItem
      controller.insertItem(1, 'Inserted');
      expect(controller.items, equals(['A', 'Inserted', 'B', 'C']));

      // 2. updateItemWhere
      final updated = controller.updateItemWhere(
        (item) => item == 'B',
        (item) => 'Updated_B',
      );
      expect(updated, isTrue);
      expect(controller.items, equals(['A', 'Inserted', 'Updated_B', 'C']));

      // 3. removeItemsWhere
      final removedCount = controller.removeItemsWhere((item) => item == 'A');
      expect(removedCount, equals(1));
      expect(controller.items, equals(['Inserted', 'Updated_B', 'C']));

      // 4. replaceItems
      controller.replaceItems(['X', 'Y']);
      expect(controller.items, equals(['X', 'Y']));
      expect(controller.itemCount, equals(2));

      // 5. clear
      controller.clear();
      expect(controller.items, isEmpty);
      expect(controller.isInitialized, isFalse);

      controller.dispose();
    });
  });

  group('PaginationController - LRU Page Eviction', () {
    test('should evict oldest pages when exceeding keepPagesInMemory',
        () async {
      final controller = PaginationController<int>(
        autoStart: false,
        pageSize: 2,
        keepPagesInMemory: 2, // Only keep at most 2 pages
        loadPage: ({required page, required pageSize}) async {
          return [(page * 10) + 1, (page * 10) + 2];
        },
      );

      await controller.refresh(); // Page 1
      expect(controller.loadedPages, equals([1]));

      await controller.loadMore(bypassRateLimit: true); // Page 2
      expect(controller.loadedPages, equals([1, 2]));

      await controller.loadMore(bypassRateLimit: true); // Page 3 -> Should evict Page 1
      expect(controller.loadedPages, equals([2, 3]));
      expect(controller.items, equals([21, 22, 31, 32]));

      controller.dispose();
    });
  });
}
