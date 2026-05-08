import 'dart:math' as math;

import 'package:base_flutter/core/base/widgets/grid/internal/grid_session.dart';
import 'package:base_flutter/core/base/widgets/grid/layout/grid_layout_config.dart';
import 'package:flutter/widgets.dart';

/// Factory function to create the appropriate layout strategy for a
/// given configuration.
GridLayoutStrategy createLayoutStrategy(
  GridLayoutConfig config,
  TextDirection direction,
) {
  if (config is FixedGridLayout) {
    return _FixedGridStrategy(config, direction);
  }
  if (config is ResponsiveGridLayout) {
    return _ResponsiveGridStrategy(config, direction);
  }
  if (config is MasonryGridLayout) {
    return _MasonryGridStrategy(config, direction);
  }
  if (config is RatioGridLayout) {
    return _RatioGridStrategy(config, direction);
  }
  if (config is AsymmetricGridLayout) {
    return _AsymmetricGridStrategy(config, direction);
  }
  if (config is AutoPlacementGridLayout) {
    return _AutoPlacementGridStrategy(config, direction);
  }
  if (config is NestedGridLayout) {
    return createLayoutStrategy(config.innerLayout, direction);
  }
  throw UnsupportedError(
    'Unsupported grid configuration ${config.runtimeType}',
  );
}

/// Base interface for grid layout strategies.
abstract class GridLayoutStrategy {
  const GridLayoutStrategy();

  /// Creates a new layout session for the given context.
  GridLayoutSession startSession(GridLayoutContext context);

  /// Describes the box layout without performing a full layout pass.
  /// Useful for prefetch heuristics and estimations.
  BoxGridLayoutDescriptor describeBoxLayout(double crossAxisExtent);
}

/// Lightweight helper that exposes layout metadata without triggering a full
/// layout pass. Consumers (e.g. infinite scrollers) can use the returned
/// descriptor to estimate item heights, column widths, and spacing for
/// prefetch heuristics.
BoxGridLayoutDescriptor describeGridLayout(
  GridLayoutConfig config,
  double crossAxisExtent,
  TextDirection direction,
) {
  final strategy = createLayoutStrategy(config, direction);
  return strategy.describeBoxLayout(crossAxisExtent);
}

/// Descriptor containing layout metadata for box grids.
class BoxGridLayoutDescriptor {
  const BoxGridLayoutDescriptor({
    required this.columnCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.spanResolver,
    required this.reverseCrossAxis,
    required this.expandToFit,
    required this.fixedColumnWidth,
  });

  final int columnCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final GridSpanResolver spanResolver;
  final bool reverseCrossAxis;
  final bool expandToFit;
  final double? fixedColumnWidth;
}

/// Base class for column-based grid strategies.
/// Consolidates common logic for all columnar layouts to reduce duplication.
abstract class _BaseColumnStrategy extends GridLayoutStrategy {
  _BaseColumnStrategy(this.direction);

  final TextDirection direction;

  // Abstract methods that subclasses must implement
  GridSpanResolver spanResolverForIndex();
  double mainAxisSpacing();
  double crossAxisSpacing();
  bool reverseCrossAxis();
  bool expandToFit();
  double? fixedColumnWidth();
  int resolveColumnCountForExtent(double crossAxisExtent);

  @override
  GridLayoutSession startSession(GridLayoutContext context) {
    final columnCount = math.max(
      1,
      resolveColumnCountForExtent(context.crossAxisExtent),
    );
    return ColumnarGridSession(
      context: context,
      columnCount: columnCount,
      mainAxisSpacing: mainAxisSpacing(),
      crossAxisSpacing: crossAxisSpacing(),
      spanResolver: spanResolverForIndex(),
      reverseCrossAxis: reverseCrossAxis(),
      expandToFit: expandToFit(),
      fixedColumnWidth: fixedColumnWidth(),
    );
  }

  @override
  BoxGridLayoutDescriptor describeBoxLayout(double crossAxisExtent) {
    final columnCount = math.max(
      1,
      resolveColumnCountForExtent(crossAxisExtent),
    );
    return BoxGridLayoutDescriptor(
      columnCount: columnCount,
      mainAxisSpacing: mainAxisSpacing(),
      crossAxisSpacing: crossAxisSpacing(),
      spanResolver: spanResolverForIndex(),
      reverseCrossAxis: reverseCrossAxis(),
      expandToFit: expandToFit(),
      fixedColumnWidth: fixedColumnWidth(),
    );
  }
}

/// Fixed grid strategy - uniform columns with consistent sizing.
class _FixedGridStrategy extends _BaseColumnStrategy {
  _FixedGridStrategy(this.layout, super.direction);

  final FixedGridLayout layout;

  @override
  GridSpanResolver spanResolverForIndex() {
    return (int _) => GridSpanConfiguration(
      mainAxisExtent: layout.mainAxisExtent,
      aspectRatio: layout.mainAxisExtent == null
          ? layout.childAspectRatio
          : null,
    );
  }

  @override
  double mainAxisSpacing() => layout.mainAxisSpacing;

  @override
  double crossAxisSpacing() => layout.crossAxisSpacing;

  @override
  bool reverseCrossAxis() => direction == TextDirection.rtl;

  @override
  bool expandToFit() => true;

  @override
  double? fixedColumnWidth() => null;

  @override
  int resolveColumnCountForExtent(double crossAxisExtent) =>
      layout.crossAxisCount;
}

/// Responsive grid strategy - adapts column count based on viewport width.
class _ResponsiveGridStrategy extends _BaseColumnStrategy {
  _ResponsiveGridStrategy(this.layout, super.direction);

  final ResponsiveGridLayout layout;
  ResponsiveGridBreakpoint? _activeBreakpoint;

  @override
  GridSpanResolver spanResolverForIndex() {
    return (int index) {
      final breakpoint = _activeBreakpoint ?? layout.breakpoints.first;
      return GridSpanConfiguration(
        mainAxisExtent: breakpoint.mainAxisExtent,
        aspectRatio: breakpoint.mainAxisExtent == null
            ? breakpoint.childAspectRatio
            : null,
      );
    };
  }

  int _resolveColumns(double extent) {
    final sorted = layout.breakpoints.toList()
      ..sort((a, b) => a.breakpoint.compareTo(b.breakpoint));
    var candidate = sorted.first;
    for (final breakpoint in sorted) {
      if (extent <= breakpoint.breakpoint) {
        candidate = breakpoint;
        break;
      }
      candidate = breakpoint;
    }
    _activeBreakpoint = candidate;
    final count = candidate.crossAxisCount;
    final minCount = layout.minCrossAxisCount;
    final maxCount = layout.maxCrossAxisCount ?? count;
    return count.clamp(minCount, maxCount);
  }

  @override
  double mainAxisSpacing() => layout.mainAxisSpacing;

  @override
  double crossAxisSpacing() => layout.crossAxisSpacing;

  @override
  bool reverseCrossAxis() => direction == TextDirection.rtl;

  @override
  bool expandToFit() => layout.expandToFit;

  @override
  double? fixedColumnWidth() => null;

  @override
  int resolveColumnCountForExtent(double crossAxisExtent) =>
      math.max(_resolveColumns(crossAxisExtent), layout.minCrossAxisCount);
}

/// Masonry grid strategy - waterfall layout with variable item heights.
class _MasonryGridStrategy extends _BaseColumnStrategy {
  _MasonryGridStrategy(this.layout, super.direction);

  final MasonryGridLayout layout;

  @override
  GridSpanResolver spanResolverForIndex() {
    if (layout.spanResolver != null) {
      return layout.spanResolver!;
    }
    return (int _) => const GridSpanConfiguration();
  }

  @override
  double mainAxisSpacing() => layout.mainAxisSpacing;

  @override
  double crossAxisSpacing() => layout.crossAxisSpacing;

  @override
  bool reverseCrossAxis() =>
      layout.reverseCrossAxis || direction == TextDirection.rtl;

  @override
  bool expandToFit() => layout.columnWidth == null;

  @override
  double? fixedColumnWidth() => layout.columnWidth;

  @override
  int resolveColumnCountForExtent(double crossAxisExtent) {
    if (layout.columnCount != null) {
      return layout.columnCount!;
    }
    final targetColumnWidth = layout.columnWidth ?? crossAxisExtent;

    // MASONRY OPTIMIZATION: Ensure minimum viable column count
    // At least 2 columns for proper masonry effect
    final available = math.max(
      2,
      ((crossAxisExtent + layout.crossAxisSpacing) /
              (targetColumnWidth + layout.crossAxisSpacing))
          .floor(),
    );
    return available;
  }
}

/// Ratio grid strategy - maintains aspect ratio for all items.
class _RatioGridStrategy extends _BaseColumnStrategy {
  _RatioGridStrategy(this.layout, super.direction);

  final RatioGridLayout layout;

  @override
  GridSpanResolver spanResolverForIndex() {
    return (int _) => GridSpanConfiguration(aspectRatio: layout.aspectRatio);
  }

  @override
  double mainAxisSpacing() => layout.mainAxisSpacing;

  @override
  double crossAxisSpacing() => layout.crossAxisSpacing;

  @override
  bool reverseCrossAxis() => direction == TextDirection.rtl;

  @override
  bool expandToFit() => true;

  @override
  double? fixedColumnWidth() => null;

  @override
  int resolveColumnCountForExtent(double crossAxisExtent) => layout.columnCount;
}

/// Asymmetric grid strategy - items can span multiple columns.
class _AsymmetricGridStrategy extends _BaseColumnStrategy {
  _AsymmetricGridStrategy(this.layout, super.direction);

  final AsymmetricGridLayout layout;

  @override
  GridSpanResolver spanResolverForIndex() => layout.spanResolver;

  @override
  double mainAxisSpacing() => layout.mainAxisSpacing;

  @override
  double crossAxisSpacing() => layout.crossAxisSpacing;

  @override
  bool reverseCrossAxis() =>
      layout.reverseCrossAxis || direction == TextDirection.rtl;

  @override
  bool expandToFit() => true;

  @override
  double? fixedColumnWidth() => null;

  @override
  int resolveColumnCountForExtent(double crossAxisExtent) => layout.columnCount;
}

/// Auto-placement grid strategy - automatically places items.
class _AutoPlacementGridStrategy extends _BaseColumnStrategy {
  _AutoPlacementGridStrategy(this.layout, super.direction);

  final AutoPlacementGridLayout layout;

  @override
  GridSpanResolver spanResolverForIndex() {
    return (int index) {
      final resolved =
          layout.rule.spanResolver(index) ?? const GridSpanConfiguration();
      final maxSpan = layout.rule.maxSpan ?? layout.columnCount;
      final clampedSpan = resolved.columnSpan.clamp(1, maxSpan);
      return GridSpanConfiguration(
        columnSpan: clampedSpan,
        aspectRatio: resolved.aspectRatio,
        mainAxisExtent: resolved.mainAxisExtent,
        alignment: resolved.alignment,
      );
    };
  }

  @override
  double mainAxisSpacing() => layout.mainAxisSpacing;

  @override
  double crossAxisSpacing() => layout.crossAxisSpacing;

  @override
  bool reverseCrossAxis() =>
      layout.reverseCrossAxis || direction == TextDirection.rtl;

  @override
  bool expandToFit() => true;

  @override
  double? fixedColumnWidth() => null;

  @override
  int resolveColumnCountForExtent(double crossAxisExtent) => layout.columnCount;
}
