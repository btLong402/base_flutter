import 'dart:math' as math;

import 'package:base_flutter/core/base/widgets/grid/layout/layout_strategies.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/infinite_scroll_view.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/performance_utils.dart';
import 'package:flutter/widgets.dart';

/// Helpers for computing cache extents & tile dimensions in grid layouts.
///
/// Extracted from [InfiniteScrollView] state to keep the main widget
/// file under the 500-line limit.
class GridCacheHelper {
  GridCacheHelper._();

  /// Computes optimal cache extent for an [InfiniteGridConfig].
  ///
  /// Strategy: prefetch ~3 rows worth of tiles to keep the scroll frame
  /// budget healthy. Falls back to [GridLayoutConfig.prefetchExtent]
  /// when tile dimensions cannot be estimated.
  static double? cacheExtentFor({
    required BuildContext context,
    required InfiniteGridConfig config,
    required EdgeInsetsGeometry? widgetPadding,
    required double? explicitCacheExtent,
  }) {
    final explicit = explicitCacheExtent ?? config.layout.cacheExtent;
    if (explicit != null) return explicit;

    final crossAxisExtent = _resolvedCrossAxisExtent(
      context,
      config,
      widgetPadding,
    );
    if (!crossAxisExtent.isFinite || crossAxisExtent <= 0) {
      return config.layout.prefetchExtent;
    }

    final descriptor = describeGridLayout(
      config.layout,
      crossAxisExtent,
      Directionality.of(context),
    );
    final mainAxisExtent = _estimateMainAxisExtent(descriptor, crossAxisExtent);

    if (mainAxisExtent != null &&
        mainAxisExtent.isFinite &&
        mainAxisExtent > 0) {
      return mainAxisExtent * InfiniteScrollDefaults.gridCacheExtentMultiplier;
    }

    return config.layout.prefetchExtent;
  }

  static double _resolvedCrossAxisExtent(
    BuildContext context,
    InfiniteGridConfig config,
    EdgeInsetsGeometry? widgetPadding,
  ) {
    final padding = widgetPadding ?? config.layout.padding ?? EdgeInsets.zero;
    final resolved = padding.resolve(Directionality.of(context));
    final width = MediaQuery.of(context).size.width;
    return math.max(width - resolved.horizontal, 0);
  }

  static double? _estimateMainAxisExtent(
    BoxGridLayoutDescriptor descriptor,
    double crossAxisExtent,
  ) {
    final span = descriptor.spanResolver(0);
    if (span == null) return null;

    if (span.mainAxisExtent != null && span.mainAxisExtent! > 0) {
      return span.mainAxisExtent;
    }

    final columnWidth =
        descriptor.fixedColumnWidth ??
        _computeFlexibleColumnWidth(descriptor, crossAxisExtent);
    if (columnWidth <= 0) return null;

    final spanColumns = span.columnSpan.clamp(1, descriptor.columnCount);
    final totalWidth =
        columnWidth * spanColumns +
        descriptor.crossAxisSpacing * (spanColumns - 1);

    if (span.aspectRatio != null && span.aspectRatio! > 0) {
      return totalWidth / span.aspectRatio!;
    }

    return null;
  }

  static double _computeFlexibleColumnWidth(
    BoxGridLayoutDescriptor descriptor,
    double crossAxisExtent,
  ) {
    if (descriptor.columnCount <= 0) return 0;
    if (descriptor.fixedColumnWidth != null) {
      return descriptor.fixedColumnWidth!;
    }

    final spacing =
        descriptor.crossAxisSpacing * math.max(descriptor.columnCount - 1, 0);
    final usable = math.max(0, crossAxisExtent - spacing);
    return usable / descriptor.columnCount;
  }
}
