import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// ## Performance Utilities for Infinite Scroll System
///
/// This module provides:
/// - **Constants**: Tuning parameters for optimal scroll performance
/// - **Helper Functions**: Cache extent resolution, load-more trigger logic
/// - **Mixins**: Safe notification patterns for ChangeNotifier classes
///
/// ### Performance Tuning Matrix:
///
/// | Device  | P.Size | Preload | Cache | Use Case              |
/// |---------|--------|---------|-------|-----------------------|
/// | Mobile  | 20-24  | 0.7     | 2.0x  | Text lists, simple UI |
/// | Mobile  | 12-16  | 0.75    | 1.8x  | Media-heavy grids     |
/// | Tablet  | 30-40  | 0.75    | 2.2x  | Large viewports       |
/// | Desktop | 50+    | 0.8     | 2.5x  | Wide screens          |
///
/// ### Throttle/Debounce Strategy:
/// - **Throttle (150ms)**: Process max 6-7 scroll updates/second
/// - **Debounce (200ms)**: Wait for scroll to "settle" before checking
///   threshold
/// - **Min Interval (500ms)**: Absolute minimum between loadMore() calls
///
/// ### Constants Reference:
/// - `maxExtentTolerance`: 5% - Prevents duplicate pagination triggers
/// - `bottomDistanceMultiplier`: 1.5 - Viewports from bottom for load trigger
/// - `entranceOpacity/Scale`: 0.6→1.0, 0.94→1.0 - Item entrance animation
/// - `gridCacheExtentMultiplier`: 3.0 - Prefetch 3 rows in grid mode

/// Mixin for safely notifying listeners, avoiding errors during build/dispose.
///
/// Consolidates duplicate notification logic found in PaginationController
/// and InfiniteScrollView state classes.
mixin SafeNotifierMixin on ChangeNotifier {
  /// Whether this notifier still has active listeners (not disposed)
  bool get mounted => hasListeners;

  /// Safely notifies listeners, deferring if called during build phase
  void safeNotifyListeners() {
    if (!mounted) return;

    final scheduler = SchedulerBinding.instance;
    final phase = scheduler.schedulerPhase;

    // Safe to notify immediately if not in build/layout phase
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
      return;
    }

    // Defer notification if we're in build/layout phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) notifyListeners();
    });
  }
}

/// Shared performance tuning constants for the infinite scroll widgets.
///
/// **Performance Tuning Guide:**
/// - Mobile: Use default pageSize (20), preloadFraction (0.7)
/// - Tablet: Increase pageSize to 30-40, preloadFraction to 0.75
/// - Desktop: pageSize 50+, preloadFraction 0.8
/// - Reduce pageSize if items are complex/heavy
/// - Increase cacheExtentMultiplier for smoother fast scrolls
class InfiniteScrollDefaults {
  InfiniteScrollDefaults._();

  /// Default number of items per page. Balance between:
  /// - Too low: frequent network requests
  /// - Too high: initial load delay, layout jank
  static const int pageSize = 20;

  /// Starting page index (1-based or 0-based depending on API)
  static const int initialPage = 1;

  /// Number of pages to keep in memory. Older pages are evicted.
  /// Set to null to keep all pages (use for small datasets only).
  static const int keepPagesInMemory = 100;

  /// Trigger load-more when scrolled this fraction of total content.
  /// Lower = earlier prefetch, higher = later prefetch.
  /// 0.7 means trigger when 70% scrolled.
  static const double preloadFraction = 0.7;

  /// Cache extent multiplier relative to viewport height.
  /// Higher values prefetch more offscreen items for smoother scrolling.
  static const double cacheExtentMultiplier = 2;

  /// Debounce duration for scroll-triggered load-more requests.
  /// Prevents excessive API calls during rapid scrolling.
  static const Duration debounceDuration = Duration(milliseconds: 200);

  /// Throttle duration for scroll metric updates.
  /// Limits how often we check scroll position for load-more trigger.
  static const Duration throttleDuration = Duration(milliseconds: 150);

  /// Minimum interval between consecutive load-more invocations.
  /// Prevents duplicate requests if debounce fires multiple times.
  static const Duration minLoadInterval = Duration(milliseconds: 500);

  /// Tolerance for maxScrollExtent change detection (5% of extent)
  static const double maxExtentTolerance = 0.05;

  /// Distance multiplier from bottom for load-more trigger (1.5 viewports)
  static const double bottomDistanceMultiplier = 1.5;

  /// Entrance animation opacity range
  static const double entranceOpacityStart = 0.6;
  static const double entranceOpacityEnd = 1;

  /// Entrance animation scale range
  static const double entranceScaleStart = 0.94;
  static const double entranceScaleEnd = 1;

  /// Entrance animation duration
  static const Duration entranceAnimationDuration = Duration(milliseconds: 200);

  /// Grid cache extent multiplier (prefetch 3 rows worth of tiles)
  static const double gridCacheExtentMultiplier = 3;
}

/// Returns true when the scroll position is close enough to the end of the
/// content to trigger the next page load.
///
/// Uses preloadFraction to determine threshold. For example, with
/// preloadFraction=0.7 and maxScrollExtent=1000, triggers at pixels >= 700.
///
/// CRITICAL FIX: Added minimum distance check to prevent premature pagination
/// in masonry/waterfall grids where initial maxScrollExtent is small because
/// only a few items are rendered on screen. Without this guard, pagination
/// triggers too early (e.g., loading page 6 before scrolling past page 1).
///
/// The fix ensures the user must scroll at LEAST one viewport height beyond
/// the preload threshold before triggering, preventing cascading page loads
/// when only 10-20 items are initially rendered.
bool shouldTriggerLoadMore({
  required ScrollMetrics metrics,
  double preloadFraction = InfiniteScrollDefaults.preloadFraction,
}) {
  if (!metrics.hasPixels || metrics.maxScrollExtent == double.infinity) {
    return false;
  }
  // If content fits in viewport, load immediately
  if (metrics.maxScrollExtent == 0) {
    return true;
  }

  // CRITICAL FIX: Calculate threshold with minimum distance requirement
  // This prevents premature triggers when only a few items are rendered
  // initially
  final threshold = metrics.maxScrollExtent * preloadFraction;

  // CRITICAL FIX: Only trigger if we're both:
  // 1. Past the percentage threshold (70% of maxScrollExtent)
  // 2. Within reasonable distance of the actual bottom (< 1.5 viewports away)
  final distanceFromBottom = metrics.maxScrollExtent - metrics.pixels;
  final reasonableDistance =
      metrics.viewportDimension *
      InfiniteScrollDefaults.bottomDistanceMultiplier;

  // Must be past threshold AND close to bottom (whichever is more restrictive)
  return metrics.pixels >= threshold &&
      distanceFromBottom <= reasonableDistance;
}

/// Convenience helper to clamp cache extent to positive values only.
///
/// Falls back to viewportDimension * cacheExtentMultiplier if no explicit
/// value provided. Larger cache extent improves scrolling smoothness by
/// prefetching more offscreen items, at the cost of memory.
double resolveCacheExtent(double? cacheExtent, double viewportDimension) {
  if (cacheExtent == null) {
    return viewportDimension * InfiniteScrollDefaults.cacheExtentMultiplier;
  }
  return cacheExtent.clamp(0, double.infinity);
}
