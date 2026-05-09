import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/performance_utils.dart';

/// Mixin providing local CRUD operations for pagination controllers.
///
/// Extracted to separate item manipulation logic from network fetching logic.
mixin PaginationCRUDMixin<T> on ChangeNotifier, SafeNotifierMixin {
  final LinkedHashMap<int, List<T>> _pages = LinkedHashMap<int, List<T>>();

  /// Internal state accessors for the controller
  LinkedHashMap<int, List<T>> get pagesState => _pages;

  int _nextPage = 1;
  int get nextPage => _nextPage;
  set nextPage(int value) => _nextPage = value;

  bool _hasMore = true;
  bool get hasMore => _hasMore;
  set hasMore(bool value) => _hasMore = value;

  bool _initialized = false;
  bool get initialized => _initialized;
  set initialized(bool value) => _initialized = value;

  Object? _error;
  Object? get errorState => _error;
  set errorState(Object? value) => _error = value;

  int get itemCount =>
      _pages.values.fold<int>(0, (total, items) => total + items.length);

  /// Resolves whether there are more items to load.
  bool resolveHasMore(List<T> newItems, int pageSize,
      bool Function(List<T> newItems)? hasMoreResolver) {
    if (hasMoreResolver != null) {
      return hasMoreResolver(newItems);
    }
    return newItems.length >= pageSize;
  }

  /// Replaces the current items with [newItems] without making a network call.
  void performReplaceItems(
    List<T> newItems, {
    required int initialPage,
    required int pageSize,
    bool Function(List<T> newItems)? hasMoreResolver,
  }) {
    _pages
      ..clear()
      ..[initialPage] = List<T>.unmodifiable(newItems);
    _nextPage = initialPage + 1;
    _hasMore = resolveHasMore(newItems, pageSize, hasMoreResolver);
    _initialized = true;
    _error = null;
    safeNotifyListeners();
  }

  /// Updates an existing item identified by [test].
  bool performUpdateItemWhere(bool Function(T item) test, T Function(T item) updater) {
    for (final entry in _pages.entries) {
      final page = entry.value;
      for (var i = 0; i < page.length; i++) {
        if (test(page[i])) {
          final mutable = List<T>.of(page);
          mutable[i] = updater(page[i]);
          _pages[entry.key] = List<T>.unmodifiable(mutable);
          safeNotifyListeners();
          return true;
        }
      }
    }
    return false;
  }

  /// Removes all items matching [test].
  int performRemoveItemsWhere(bool Function(T item) test) {
    var removed = 0;
    for (final entry in _pages.entries.toList()) {
      final before = entry.value.length;
      final filtered = entry.value.where((e) => !test(e)).toList();
      if (filtered.length < before) {
        _pages[entry.key] = List<T>.unmodifiable(filtered);
        removed += before - filtered.length;
      }
    }
    if (removed > 0) safeNotifyListeners();
    return removed;
  }

  /// Inserts [item] at position [index] within the flattened list.
  void performInsertItem(int index, T item, {required int initialPage}) {
    var offset = 0;
    for (final entry in _pages.entries) {
      final page = entry.value;
      if (index <= offset + page.length) {
        final mutable = List<T>.of(page)..insert(index - offset, item);
        _pages[entry.key] = List<T>.unmodifiable(mutable);
        safeNotifyListeners();
        return;
      }
      offset += page.length;
    }
    if (_pages.isNotEmpty) {
      final lastKey = _pages.keys.last;
      final mutable = List<T>.of(_pages[lastKey]!)..add(item);
      _pages[lastKey] = List<T>.unmodifiable(mutable);
      safeNotifyListeners();
    } else {
      _pages[initialPage] = List<T>.unmodifiable([item]);
      _hasMore = false;
      safeNotifyListeners();
    }
  }

  /// Clears all data and resets to uninitialized state.
  void performClear({required int initialPage}) {
    _pages.clear();
    _nextPage = initialPage;
    _hasMore = true;
    _initialized = false;
    _error = null;
    safeNotifyListeners();
  }
}
