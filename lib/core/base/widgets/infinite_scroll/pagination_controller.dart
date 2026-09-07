import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;

import 'package:base_flutter/core/base/widgets/infinite_scroll/internal/pagination_mixins.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/internal/pagination_scroll_mixin.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/performance_utils.dart';
import 'package:flutter/widgets.dart';

typedef LoadPageCallback<T> =
    Future<List<T>> Function({required int page, required int pageSize});

/// ## PaginationController - Intelligent Page-Based Data Fetching
///
/// Encapsulates page-based fetching logic with built-in debouncing,
/// deduplication, refresh, LRU caching, and retry helpers.
class PaginationController<T> extends ChangeNotifier
    with SafeNotifierMixin, PaginationCRUDMixin<T>, PaginationScrollMixin {
  PaginationController({
    required this.loadPage,
    this.pageSize = InfiniteScrollDefaults.pageSize,
    this.initialPage = InfiniteScrollDefaults.initialPage,
    this.debounceDuration = InfiniteScrollDefaults.debounceDuration,
    this.preloadFraction = InfiniteScrollDefaults.preloadFraction,
    this.keepPagesInMemory = InfiniteScrollDefaults.keepPagesInMemory,
    this.onPageLoaded,
    this.hasMoreResolver,
    this.autoStart = true,
  }) : assert(pageSize > 0, 'pageSize must be greater than zero'),
       assert(
         preloadFraction > 0 && preloadFraction <= 1,
         'preloadFraction must be between 0 (exclusive) and 1 (inclusive)',
       ),
       assert(
         keepPagesInMemory == null || keepPagesInMemory > 0,
         'keepPagesInMemory must be greater than zero when provided',
       ) {
    nextPage = initialPage;
    if (autoStart) {
      scheduleMicrotask(refresh);
    }
  }

  final LoadPageCallback<T> loadPage;
  final int pageSize;
  final int initialPage;
  @override
  final Duration debounceDuration;
  @override
  final double preloadFraction;
  final int? keepPagesInMemory;
  final ValueChanged<List<T>>? onPageLoaded;
  final bool Function(List<T> newItems)? hasMoreResolver;
  final bool autoStart;

  final Map<int, Future<List<T>>> _inFlightRequests = {};

  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  int? _lastRequestedPage;
  DateTime? _lastLoadInvocation;
  Map<String, dynamic>? _summary;
  int _totalRecords = 0;

  bool get isRefreshing => _isRefreshing;
  @override
  bool get isLoadingMore => _isLoadingMore;
  bool get isInitialized => initialized;
  Map<String, dynamic>? get summary => _summary;
  int get totalRecords => _totalRecords;

  void updateMetadata({Map<String, dynamic>? summary, int? totalRecords}) {
    _summary = summary;
    if (totalRecords != null) {
      _totalRecords = totalRecords;
    }
    safeNotifyListeners();
  }

  List<T> get items =>
      pagesState.values.expand((page) => page).toList(growable: false);

  T? itemAt(int index) {
    if (index < 0 || index >= itemCount) {
      return null;
    }
    var offset = 0;
    for (final page in pagesState.values) {
      if (index < offset + page.length) {
        return page[index - offset];
      }
      offset += page.length;
    }
    return null;
  }

  Iterable<int> get loadedPages => pagesState.keys;

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    errorState = null;
    resetScrollExtentGuard();
    safeNotifyListeners();

    final previousPages = LinkedHashMap<int, List<T>>.from(pagesState);
    try {
      final newItems = await _fetchPage(initialPage);
      _replaceWithInitialPage(newItems);
      _isRefreshing = false;
      initialized = true;
      safeNotifyListeners();
    } on Object catch (error, stackTrace) {
      developer.log(
        'refresh failed',
        name: 'infinite_scroll.controller',
        error: error,
        stackTrace: stackTrace,
      );
      _isRefreshing = false;
      errorState = error;
      pagesState
        ..clear()
        ..addAll(previousPages);
      safeNotifyListeners();
    }
  }

  @override
  Future<void> loadMore({bool bypassRateLimit = false}) async {
    if (!hasMore || _isLoadingMore) return;

    if (!bypassRateLimit &&
        _lastLoadInvocation != null &&
        DateTime.now().difference(_lastLoadInvocation!) <
            InfiniteScrollDefaults.minLoadInterval) {
      return;
    }

    cancelScrollTimers();

    _lastLoadInvocation = DateTime.now();
    _isLoadingMore = true;
    errorState = null;
    safeNotifyListeners();

    final targetPage = nextPage;

    try {
      final items = await _fetchPage(targetPage);
      _appendPage(targetPage, items);
      _isLoadingMore = false;
      resetScrollExtentGuard();
      safeNotifyListeners();
    } on Object catch (error, stackTrace) {
      developer.log(
        'loadMore failed (page $targetPage)',
        name: 'infinite_scroll.controller',
        error: error,
        stackTrace: stackTrace,
      );
      _isLoadingMore = false;
      errorState = error;
      safeNotifyListeners();
    }
  }

  Future<void> retry() async {
    if (_lastRequestedPage == null) return;
    if (!initialized) {
      await refresh();
      return;
    }
    if (_lastRequestedPage == initialPage) {
      await refresh();
    } else {
      await loadMore(bypassRateLimit: true);
    }
  }

  Future<List<T>> _fetchPage(int page) {
    _lastRequestedPage = page;
    final existing = _inFlightRequests[page];
    if (existing != null) return existing;

    final future = loadPage(
      page: page,
      pageSize: pageSize,
    ).then(List<T>.unmodifiable);
    _inFlightRequests[page] = future;

    return future.whenComplete(() async {
      await _inFlightRequests.remove(page);
    });
  }

  void _replaceWithInitialPage(List<T> newItems) {
    pagesState
      ..clear()
      ..[initialPage] = newItems;
    nextPage = initialPage + 1;
    hasMore = resolveHasMore(newItems, pageSize, hasMoreResolver);
    onPageLoaded?.call(newItems);
  }

  void _appendPage(int page, List<T> newItems) {
    if (newItems.isEmpty) {
      hasMore = false;
      return;
    }
    pagesState[page] = newItems;
    if (keepPagesInMemory != null && pagesState.length > keepPagesInMemory!) {
      final oldestKey = pagesState.keys.first;
      pagesState.remove(oldestKey);
    }
    nextPage = page + 1;
    hasMore = resolveHasMore(newItems, pageSize, hasMoreResolver);
    onPageLoaded?.call(newItems);
  }

  bool get hasItems => itemCount > 0;
  Object? get error => errorState;

  void replaceItems(List<T> newItems) {
    performReplaceItems(
      newItems,
      initialPage: initialPage,
      pageSize: pageSize,
      hasMoreResolver: hasMoreResolver,
    );
  }

  bool updateItemWhere(bool Function(T item) test, T Function(T item) updater) {
    return performUpdateItemWhere(test, updater);
  }

  int removeItemsWhere(bool Function(T item) test) {
    return performRemoveItemsWhere(test);
  }

  void insertItem(int index, T item) {
    performInsertItem(index, item, initialPage: initialPage);
  }

  void clear() {
    performClear(initialPage: initialPage);
    resetScrollExtentGuard();
  }

  @override
  void dispose() {
    disposeScrollTimers();
    for (final future in _inFlightRequests.values) {
      future.ignore();
    }
    _inFlightRequests.clear();
    super.dispose();
  }
}
