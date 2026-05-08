import 'package:base_flutter/core/base/widgets/grid/animation/grid_animation_config.dart';
import 'package:base_flutter/core/base/widgets/grid/layout/grid_layout_config.dart';
import 'package:base_flutter/core/base/widgets/grid/widgets/advanced_sliver_grid.dart';
import 'package:flutter/widgets.dart';

/// A high-performance scrollable grid that supports multiple layout
/// strategies, lazy item building, cache tuning, and responsive breakpoints.
///
/// The view delegates all layout concerns to [GridLayoutConfig] while
/// consumers provide lightweight item widgets via [_itemBuilder].
///
/// **Performance Optimizations:**
/// - Automatic RepaintBoundary insertion for complex items
/// - Optimized cache extent based on scroll direction
/// - Efficient child key generation for stable identity
/// - Reduced widget rebuilds through const constructors
class AdvancedGridView extends BoxScrollView {
  AdvancedGridView.builder({
    required this.layout,
    required GridItemBuilder itemBuilder,
    super.key,
    this.itemCount,
    EdgeInsetsGeometry? padding,
    GridAnimationConfig? animation,
    Clip? clipBehavior,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    double? cacheExtent,
    super.restorationId,
    this.addRepaintBoundaries,
    this.findChildIndexCallback,
  }) : _itemBuilder = itemBuilder,
       _animationConfig = animation,
       super(
         padding: padding ?? layout.padding,
         cacheExtent:
             cacheExtent ?? layout.cacheExtent ?? layout.prefetchExtent,
         clipBehavior: clipBehavior ?? Clip.hardEdge,
       );

  final GridLayoutConfig layout;
  final GridItemBuilder _itemBuilder;
  final int? itemCount;
  final GridAnimationConfig? _animationConfig;

  /// Override for repaint boundaries (defaults to layout config)
  final bool? addRepaintBoundaries;

  /// Callback to find child index for efficient updates
  /// CRITICAL for performance with large lists
  final ChildIndexGetter? findChildIndexCallback;

  @override
  Widget buildChildLayout(BuildContext context) {
    final animation = _animationConfig;

    final IndexedWidgetBuilder builder;
    if (animation == null) {
      builder = _itemBuilder;
    } else {
      builder = (context, index) => animation.wrap(
        context,
        index,
        _itemBuilder(context, index),
      );
    }

    // PERFORMANCE: Use optimized delegate with proper callbacks
    final delegate = SliverChildBuilderDelegate(
      builder,
      childCount: itemCount,
      addAutomaticKeepAlives: layout.addAutomaticKeepAlives,
      // CRITICAL: Enable repaint boundaries for smooth scrolling
      addRepaintBoundaries: addRepaintBoundaries ?? layout.addRepaintBoundaries,
      addSemanticIndexes: layout.addSemanticIndexes,
      // CRITICAL: Enable efficient child finding for updates
      findChildIndexCallback: findChildIndexCallback,
    );

    return AdvancedSliverGrid(layout: layout, delegate: delegate);
  }

  @override
  int? get semanticChildCount => itemCount;
}
