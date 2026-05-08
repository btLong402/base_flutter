import 'package:base_flutter/core/base/widgets/grid/grid.dart'
    show AdvancedGridView;
import 'package:base_flutter/core/base/widgets/grid/pinterest.dart'
    show AdvancedGridView;
import 'package:base_flutter/core/base/widgets/grid/widgets/advanced_grid_view.dart'
    show AdvancedGridView;
import 'package:flutter/material.dart';

/// Builder signature that mirrors [SliverChildBuilderDelegate] consumers.
typedef GridItemBuilder = Widget Function(BuildContext context, int index);

/// Provides semantic information about how a grid item should be laid out.
///
/// The library consumes this shape to derive cross-axis span, main-axis sizing,
/// and alignment behavior during layout.
class GridSpanConfiguration {
  const GridSpanConfiguration({
    this.columnSpan = 1,
    this.mainAxisExtent,
    this.aspectRatio,
    this.alignment = AlignmentDirectional.topStart,
  }) : assert(columnSpan > 0, 'columnSpan must be > 0');

  /// Number of columns the tile should span.
  final int columnSpan;

  /// Fixed main axis extent for the child. If null the child determines its
  /// own size, optionally constrained by [aspectRatio].
  final double? mainAxisExtent;

  /// If provided, height is derived from width using the ratio. Ignored when
  /// [mainAxisExtent] is supplied.
  final double? aspectRatio;

  /// Alignment applied inside the allocated tile bounds when the child does
  /// not fully occupy them (e.g. explicit height smaller than computed span).
  final AlignmentGeometry alignment;
}

/// Provides span configuration for a given grid index. Returning null lets the
/// layout strategy fall back to defaults for that layout type.
typedef GridSpanResolver = GridSpanConfiguration? Function(int index);

/// Base class for layout configuration consumed by [AdvancedGridView].
abstract class GridLayoutConfig {
  const GridLayoutConfig({
    this.padding,
    this.cacheExtent,
    this.prefetchExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  });

  /// Optional padding applied around the grid when building scrollables.
  final EdgeInsetsGeometry? padding;

  /// Overrides default cache extent for sliver-based grids.
  final double? cacheExtent;

  /// Provides a hint for prefetch extent (passed to [ScrollView]).
  final double? prefetchExtent;

  /// Mirrors [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Mirrors [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Mirrors [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;
}

class FixedGridLayout extends GridLayoutConfig {
  const FixedGridLayout({
    required this.crossAxisCount,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
    super.padding,
    super.cacheExtent,
    super.prefetchExtent,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
  }) : assert(crossAxisCount > 0, 'crossAxisCount must be > 0');

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final double? mainAxisExtent;
}

class ResponsiveGridBreakpoint {
  const ResponsiveGridBreakpoint({
    required this.breakpoint,
    required this.crossAxisCount,
    this.childAspectRatio,
    this.mainAxisExtent,
  }) : assert(crossAxisCount > 0, 'crossAxisCount must be > 0');

  final double breakpoint;
  final int crossAxisCount;
  final double? childAspectRatio;
  final double? mainAxisExtent;
}

class ResponsiveGridLayout extends GridLayoutConfig {
  const ResponsiveGridLayout({
    required this.breakpoints,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.minCrossAxisCount = 1,
    this.maxCrossAxisCount,
    this.expandToFit = true,
    super.padding,
    super.cacheExtent,
    super.prefetchExtent,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
  }) : assert(breakpoints.length > 0, 'Provide at least one breakpoint');

  final List<ResponsiveGridBreakpoint> breakpoints;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final int minCrossAxisCount;
  final int? maxCrossAxisCount;
  final bool expandToFit;
}

class MasonryGridLayout extends GridLayoutConfig {
  const MasonryGridLayout({
    this.columnCount,
    this.columnWidth,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.spanResolver,
    this.stickyColumnHeights = true,
    this.reverseCrossAxis = false,
    super.padding,
    super.cacheExtent,
    super.prefetchExtent,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
  }) : assert(
         columnCount != null || columnWidth != null,
         'Provide either columnCount or columnWidth',
       );

  final int? columnCount;
  final double? columnWidth;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final GridSpanResolver? spanResolver;
  final bool stickyColumnHeights;
  final bool reverseCrossAxis;
}

class RatioGridLayout extends GridLayoutConfig {
  const RatioGridLayout({
    required this.columnCount,
    required this.aspectRatio,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    super.padding,
    super.cacheExtent,
    super.prefetchExtent,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
  }) : assert(columnCount > 0, 'columnCount must be > 0');

  final int columnCount;
  final double aspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
}

class NestedGridLayout extends GridLayoutConfig {
  const NestedGridLayout({
    required this.innerLayout,
    this.primary = false,
    this.scrollPhysics,
    super.padding,
    super.cacheExtent,
    super.prefetchExtent,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
  });

  final GridLayoutConfig innerLayout;
  final bool primary;
  final ScrollPhysics? scrollPhysics;
}

class AsymmetricGridLayout extends GridLayoutConfig {
  const AsymmetricGridLayout({
    required this.columnCount,
    required this.spanResolver,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.reverseCrossAxis = false,
    super.padding,
    super.cacheExtent,
    super.prefetchExtent,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
  }) : assert(columnCount > 0, 'columnCount must be > 0');

  final int columnCount;
  final GridSpanResolver spanResolver;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final bool reverseCrossAxis;
}

class AutoPlacementRule {
  const AutoPlacementRule({required this.spanResolver, this.maxSpan})
    : assert(maxSpan == null || maxSpan > 0, 'maxSpan must be > 0');

  final GridSpanResolver spanResolver;
  final int? maxSpan;
}

class AutoPlacementGridLayout extends GridLayoutConfig {
  const AutoPlacementGridLayout({
    required this.columnCount,
    required this.rule,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.crossAxisAlignment = AlignmentDirectional.topStart,
    this.reverseCrossAxis = false,
    super.padding,
    super.cacheExtent,
    super.prefetchExtent,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
  }) : assert(columnCount > 0, 'columnCount must be > 0');

  final int columnCount;
  final AutoPlacementRule rule;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final AlignmentGeometry crossAxisAlignment;
  final bool reverseCrossAxis;
}
