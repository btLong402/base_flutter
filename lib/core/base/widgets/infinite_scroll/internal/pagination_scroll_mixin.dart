import 'dart:async';

import 'package:base_flutter/core/base/widgets/infinite_scroll/performance_utils.dart';
import 'package:flutter/widgets.dart';

/// Mixin providing scroll metric processing, throttling, and debouncing
/// for pagination controllers.
///
/// Extracted to adhere to Single Responsibility Principle and Rule 02
/// (File length <= 300 lines).
mixin PaginationScrollMixin on ChangeNotifier {
  Timer? _debounceTimer;
  Timer? _throttleTimer;
  ScrollMetrics? _pendingMetrics;
  ScrollMetrics? _lastScrollMetrics;
  double? _lastTriggeredMaxExtent;
  bool _throttleActive = false;

  /// Contract getters and methods required from the host controller.
  bool get hasMore;
  bool get isLoadingMore;
  Duration get debounceDuration;
  double get preloadFraction;
  Future<void> loadMore({bool bypassRateLimit = false});

  /// Resets the max extent guard to allow triggering pagination again.
  void resetScrollExtentGuard() {
    _lastTriggeredMaxExtent = null;
  }

  /// Cancels in-flight scroll metrics timers and clears pending metrics.
  void cancelScrollTimers() {
    _debounceTimer?.cancel();
    _throttleTimer?.cancel();
    _throttleActive = false;
    _lastScrollMetrics = null;
    _pendingMetrics = null;
  }

  /// Handles incoming [ScrollMetrics] from a scroll notification listener.
  void handleScrollMetrics(ScrollMetrics metrics) {
    if (!hasMore || isLoadingMore) return;

    if (_throttleActive) {
      _pendingMetrics = metrics;
      return;
    }

    _processScrollMetrics(metrics);

    _throttleActive = true;
    _throttleTimer?.cancel();
    _throttleTimer = Timer(InfiniteScrollDefaults.throttleDuration, () {
      _throttleActive = false;
      if (_pendingMetrics != null) {
        final pending = _pendingMetrics;
        _pendingMetrics = null;
        _processScrollMetrics(pending!);
      }
    });
  }

  void _processScrollMetrics(ScrollMetrics metrics) {
    _lastScrollMetrics = metrics;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      final latestMetrics = _lastScrollMetrics;
      if (latestMetrics == null) return;

      final currentMaxExtent = latestMetrics.maxScrollExtent;
      if (_lastTriggeredMaxExtent != null) {
        final tolerance =
            _lastTriggeredMaxExtent! *
            InfiniteScrollDefaults.maxExtentTolerance;
        final diff = currentMaxExtent - _lastTriggeredMaxExtent!;

        if (diff < tolerance && diff >= 0) return;
        if (diff < -tolerance) _lastTriggeredMaxExtent = null;
      }

      if (shouldTriggerLoadMore(
        metrics: latestMetrics,
        preloadFraction: preloadFraction,
      )) {
        _lastTriggeredMaxExtent = currentMaxExtent;
        unawaited(loadMore());
      }
    });
  }

  /// Disposes scroll timers when the controller is disposed.
  void disposeScrollTimers() {
    _debounceTimer?.cancel();
    _throttleTimer?.cancel();
    _debounceTimer = null;
    _throttleTimer = null;
    _pendingMetrics = null;
    _lastScrollMetrics = null;
    _lastTriggeredMaxExtent = null;
  }
}
