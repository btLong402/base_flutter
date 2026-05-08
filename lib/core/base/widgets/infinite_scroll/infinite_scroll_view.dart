import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:base_flutter/core/base/widgets/grid/pinterest.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/entrance_animation.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/grid_cache_helper.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/load_more_footer.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/pagination_controller.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/performance_utils.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/refresh_controls.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/scroll_state_widgets.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/separator_builder.dart';

/// Performance-optimized infinite scrolling widget.
///
/// Supports list & grid layouts, pull-to-refresh, load-more, entrance
/// animations, and advanced grid configurations (masonry, asymmetric,
/// auto-placement).
///
/// ```dart
/// InfiniteScrollView<Post>(
///   controller: paginationController,
///   layout: InfiniteScrollLayout.list,
///   itemBuilder: (context, index, post) => PostTile(post),
///   separatorBuilder: (context, index) => Divider(),
/// )
/// ```

enum InfiniteScrollLayout { list, grid }

/// Configuration for integrating the advanced grid system with
/// [InfiniteScrollView]. Supply a [GridLayoutConfig] alongside optional
/// animation parameters to enable fixed, responsive, masonry, asymmetric, or
/// auto-placement grids.
class InfiniteGridConfig {
  const InfiniteGridConfig({required this.layout, this.animation});

  final GridLayoutConfig layout;
  final GridAnimationConfig? animation;
}

/// High-level view that renders an infinite scrolling list or grid with
/// built-in pull-to-refresh and load-more behaviour. Supports both
/// CustomScrollView (Sliver) and ListView/GridView (material) variants.
class InfiniteScrollView<T> extends StatefulWidget {
  const InfiniteScrollView({
    required this.controller,
    required this.itemBuilder,
    super.key,
    this.layout = InfiniteScrollLayout.list,
    this.useSlivers = false,
    this.scrollController,
    this.physics,
    this.padding,
    this.gridConfig,
    this.gridDelegate,
    this.itemExtent,
    this.cacheExtent,
    this.separatorBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.shimmerBuilder,
    this.shimmerCount = 6,
    this.footerBuilder,
    this.sliverAppBar,
    this.semanticsLabelBuilder,
    this.refreshSemanticsLabel,
    this.itemKeyBuilder,
    this.enableItemRepaintBoundary = true,
    this.enableImplicitEntranceAnimation = true,
    this.usePinterestPhysics = false,
  }) : assert(
         layout != InfiniteScrollLayout.grid ||
             gridDelegate != null ||
             gridConfig != null,
         'Provide gridConfig or gridDelegate when using grid layout',
       ),
       assert(
         layout != InfiniteScrollLayout.grid ||
             gridDelegate == null ||
             gridConfig == null,
         'gridDelegate and gridConfig are mutually exclusive',
       );

  final PaginationController<T> controller;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final InfiniteScrollLayout layout;
  final bool useSlivers;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final InfiniteGridConfig? gridConfig;
  final SliverGridDelegate? gridDelegate;
  final double? itemExtent;
  final double? cacheExtent;
  final InfiniteSeparatorBuilder? separatorBuilder;
  final WidgetBuilder? emptyBuilder;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)?
  errorBuilder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext context, int index)? shimmerBuilder;
  final int shimmerCount;
  final WidgetBuilder? footerBuilder;
  final SliverAppBar? sliverAppBar;
  final String Function(T item, int index)? semanticsLabelBuilder;
  final String? refreshSemanticsLabel;
  final Key Function(T item, int index)? itemKeyBuilder;
  final bool enableItemRepaintBoundary;
  final bool enableImplicitEntranceAnimation;

  /// Enable Pinterest-style scroll physics for smooth, natural scrolling
  final bool usePinterestPhysics;

  @override
  State<InfiniteScrollView<T>> createState() => _InfiniteScrollViewState<T>();
}

class _InfiniteScrollViewState<T> extends State<InfiniteScrollView<T>> {
  ScrollController? _internalController;
  bool _hasPendingControllerUpdate = false;
  final Set<int> _animatedIndices = {};
  int _lastItemCount = 0;

  PaginationController<T> get controller => widget.controller;

  ScrollController get _effectiveController =>
      widget.scrollController ?? (_internalController ??= ScrollController());

  /// Resolves and caches scroll physics to avoid repeated conditionals
  ScrollPhysics _resolveScrollPhysics() {
    if (widget.physics != null) return widget.physics!;

    // CRITICAL: Always use AlwaysScrollableScrollPhysics as parent for
    // pull-to-refresh
    const basePhysics = AlwaysScrollableScrollPhysics();

    if (widget.usePinterestPhysics) {
      return const PinterestScrollPhysics(parent: basePhysics);
    }

    return const BouncingScrollPhysics(parent: basePhysics);
  }

  /// Resolves cache extent with viewport dimension
  double _resolveCacheExtent(double viewportDimension) {
    return resolveCacheExtent(widget.cacheExtent, viewportDimension);
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerUpdated);
  }

  @override
  void didUpdateWidget(covariant InfiniteScrollView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.removeListener(_onControllerUpdated);
      widget.controller.addListener(_onControllerUpdated);
      // Clear animation tracking when controller changes
      _animatedIndices.clear();
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerUpdated);
    _internalController?.dispose();
    super.dispose();
  }

  void _onControllerUpdated() {
    if (!mounted) return;

    // Clear animation tracking when item count decreases significantly
    // This indicates a refresh has occurred with new data
    final currentItemCount = controller.itemCount;
    if (currentItemCount < _lastItemCount) {
      _animatedIndices.clear();
      developer.log(
        'Refresh detected: itemCount '
        '$_lastItemCount → $currentItemCount, '
        'clearing animation state',
        name: 'infinite_scroll.view',
      );
    }
    _lastItemCount = currentItemCount;

    // PERFORMANCE: Avoid setState during build or layout phase.
    // Schedule update for post-frame to prevent "setState during build" errors
    // and layout thrashing during rapid scroll events.
    final scheduler = SchedulerBinding.instance;
    final phase = scheduler.schedulerPhase;

    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      // Safe to update immediately
      setState(() {});
      return;
    }

    // Already have a pending update scheduled
    if (_hasPendingControllerUpdate) {
      return;
    }

    _hasPendingControllerUpdate = true;
    scheduler.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _hasPendingControllerUpdate = false;
      setState(() {});
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // PERFORMANCE FIX: Only process ScrollUpdateNotification to prevent
    // duplicate handling. OverscrollNotification is a subclass of
    // ScrollNotification but doesn't provide meaningful position changes for
    // pagination triggers. Processing both causes duplicate loadMore() calls
    // especially after page 10.
    if (notification is ScrollUpdateNotification) {
      controller.handleScrollMetrics(notification.metrics);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: widget.useSlivers
          ? _buildSliverView(context)
          : _buildListView(context),
    );
  }

  Widget _buildListView(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cacheExtent = _resolveCacheExtent(screenSize.height);
    final physics = _resolveScrollPhysics();
    final separators = SeparatorManager(builder: widget.separatorBuilder);
    final hasFooter = controller.itemCount > 0;
    final bodyCount = separators.childCount(controller.itemCount);
    final totalCount = bodyCount + (hasFooter ? 1 : 0);

    developer.log(
      'Building ${widget.layout.name}: '
      'items=${controller.itemCount}, total=$totalCount',
      name: 'infinite_scroll.view',
    );

    Widget list;
    if (widget.layout == InfiniteScrollLayout.list) {
      list = ListView.builder(
        controller: _effectiveController,
        physics: physics,
        padding: widget.padding,
        cacheExtent: cacheExtent,
        itemExtent: widget.separatorBuilder == null ? widget.itemExtent : null,
        itemBuilder: (context, index) {
          if (hasFooter && index == totalCount - 1) {
            return _buildFooter(context);
          }
          return separators.buildChild(
            context: context,
            index: index,
            itemCount: controller.itemCount,
            itemBuilder: (ctx, itemIndex) {
              final item = controller.itemAt(itemIndex);
              if (item == null) {
                return const SizedBox.shrink();
              }
              return _buildItem(ctx, itemIndex, item);
            },
          );
        },
        itemCount: totalCount,
      );
    } else {
      final gridConfig = widget.gridConfig;
      if (gridConfig != null) {
        final animateItems = gridConfig.animation == null;
        // PERFORMANCE FIX: Use stable key based on layout config only.
        // Let element tree handle incremental updates when items change.
        final Key gridKey = ValueKey<int>(gridConfig.layout.hashCode);
        final gridCacheExtent = _gridCacheExtentFor(context, gridConfig);
        list = AdvancedGridView.builder(
          key: gridKey,
          controller: _effectiveController,
          physics: physics,
          padding: widget.padding,
          cacheExtent: gridCacheExtent,
          layout: gridConfig.layout,
          animation: gridConfig.animation,
          itemCount: totalCount,
          itemBuilder: (context, index) {
            return _buildGridTile(
              context,
              index: index,
              totalCount: totalCount,
              hasFooter: hasFooter,
              separators: separators,
              animateItems: animateItems,
            );
          },
        );
      } else {
        list = GridView.builder(
          controller: _effectiveController,
          physics: physics,
          padding: widget.padding,
          cacheExtent: cacheExtent,
          gridDelegate: widget.gridDelegate!,
          itemBuilder: (context, index) {
            return _buildGridTile(
              context,
              index: index,
              totalCount: totalCount,
              hasFooter: hasFooter,
              separators: separators,
              animateItems: true,
            );
          },
          itemCount: totalCount,
        );
      }
    }

    return MaterialRefreshWrapper(
      onRefresh: controller.refresh,
      semanticsLabel: widget.refreshSemanticsLabel ?? 'Kéo để làm mới',
      child: _buildContentWrapper(list),
    );
  }

  Widget _buildSliverView(BuildContext context) {
    final physics = _resolveScrollPhysics();
    final slivers = <Widget>[
      if (widget.sliverAppBar != null) widget.sliverAppBar!,
      CupertinoSliverRefreshWrapper(onRefresh: controller.refresh),
      if (!controller.isInitialized && controller.isRefreshing)
        SliverToBoxAdapter(
          child: InfiniteScrollLoadingState(
            builder: widget.loadingBuilder,
            shimmerBuilder: widget.shimmerBuilder,
            shimmerCount: widget.shimmerCount,
          ),
        )
      else if (controller.itemCount == 0 && controller.error == null)
        SliverToBoxAdapter(
          child: InfiniteScrollEmptyState(builder: widget.emptyBuilder),
        )
      else if (controller.itemCount == 0 && controller.error != null)
        SliverToBoxAdapter(
          child: InfiniteScrollErrorState(
            error: controller.error!,
            onRetry: controller.retry,
            builder: widget.errorBuilder,
          ),
        )
      else
        _buildSliverContent(),
      if (controller.itemCount > 0)
        SliverToBoxAdapter(child: _buildFooter(context)),
    ];

    return CustomScrollView(
      controller: _effectiveController,
      physics: physics,
      slivers: slivers,
    );
  }

  Widget _buildSliverContent() {
    final separators = SeparatorManager(builder: widget.separatorBuilder);
    final childCount = separators.childCount(controller.itemCount);

    if (widget.layout == InfiniteScrollLayout.grid) {
      final gridConfig = widget.gridConfig;
      if (gridConfig != null) {
        Widget buildChild(BuildContext context, int index) {
          return separators.buildChild(
            context: context,
            index: index,
            itemCount: controller.itemCount,
            itemBuilder: (ctx, itemIndex) {
              final item = controller.itemAt(itemIndex);
              if (item == null) {
                return const SizedBox.shrink();
              }
              return _buildItem(
                ctx,
                itemIndex,
                item,
                animate: gridConfig.animation == null,
              );
            },
          );
        }

        final delegate = SliverChildBuilderDelegate(
          gridConfig.animation == null
              ? buildChild
              : (context, index) => gridConfig.animation!.wrap(
                  context,
                  index,
                  buildChild(context, index),
                ),
          childCount: childCount,
          addAutomaticKeepAlives: gridConfig.layout.addAutomaticKeepAlives,
          addRepaintBoundaries: gridConfig.layout.addRepaintBoundaries,
          addSemanticIndexes: gridConfig.layout.addSemanticIndexes,
        );

        // PERFORMANCE FIX: Use stable key based on layout config only.
        // Let element tree handle incremental updates when items change.
        final sliver = AdvancedSliverGrid(
          key: ValueKey<int>(gridConfig.layout.hashCode),
          layout: gridConfig.layout,
          delegate: delegate,
        );

        final padding = widget.padding ?? gridConfig.layout.padding;
        if (padding != null) {
          return SliverPadding(padding: padding, sliver: sliver);
        }
        return sliver;
      }

      return SliverPadding(
        padding: widget.padding ?? EdgeInsets.zero,
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return separators.buildChild(
                context: context,
                index: index,
                itemCount: controller.itemCount,
                itemBuilder: (ctx, itemIndex) {
                  final item = controller.itemAt(itemIndex);
                  if (item == null) {
                    return const SizedBox.shrink();
                  }
                  return _buildItem(ctx, itemIndex, item);
                },
              );
            },
            childCount: childCount,
            addAutomaticKeepAlives: false,
          ),
          gridDelegate: widget.gridDelegate!,
        ),
      );
    }

    return SliverPadding(
      padding: widget.padding ?? EdgeInsets.zero,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return separators.buildChild(
              context: context,
              index: index,
              itemCount: controller.itemCount,
              itemBuilder: (ctx, itemIndex) {
                final item = controller.itemAt(itemIndex);
                if (item == null) {
                  return const SizedBox.shrink();
                }
                return _buildItem(ctx, itemIndex, item);
              },
            );
          },
          childCount: childCount,
          addAutomaticKeepAlives: false,
        ),
      ),
    );
  }

  Widget _buildContentWrapper(Widget child) {
    return InfiniteScrollContentWrapper(
      isInitialized: controller.isInitialized,
      isRefreshing: controller.isRefreshing,
      itemCount: controller.itemCount,
      error: controller.error,
      onRetry: controller.retry,
      loadingBuilder: widget.loadingBuilder,
      shimmerBuilder: widget.shimmerBuilder,
      shimmerCount: widget.shimmerCount,
      emptyBuilder: widget.emptyBuilder,
      errorBuilder: widget.errorBuilder,
      child: child,
    );
  }

  double? _gridCacheExtentFor(BuildContext context, InfiniteGridConfig config) {
    return GridCacheHelper.cacheExtentFor(
      context: context,
      config: config,
      widgetPadding: widget.padding,
      explicitCacheExtent: widget.cacheExtent,
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    T item, {
    bool animate = true,
  }) {
    final semanticsLabel = widget.semanticsLabelBuilder?.call(item, index);

    // PERFORMANCE: Stable keys prevent unnecessary rebuilds during scroll.
    // Using ValueKey with index as fallback if no custom key provided.
    final itemKey =
        widget.itemKeyBuilder?.call(item, index) ?? ValueKey<int>(index);

    var child = widget.itemBuilder(context, index, item);

    // PERFORMANCE: Lightweight entrance animation using AnimatedOpacity.
    // Only animate items that haven't been animated before to prevent
    // re-animation on rebuild when new pages are loaded.
    if (widget.enableImplicitEntranceAnimation && animate) {
      final shouldAnimate = _animatedIndices.add(index);
      if (shouldAnimate) {
        child = EntranceAnimation(child: child);
      }
    }

    // PERFORMANCE: RepaintBoundary isolates item repaints, preventing
    // unnecessary repaints of neighboring items during animations or updates.
    if (widget.enableItemRepaintBoundary) {
      child = RepaintBoundary(child: child);
    }

    // Wrap with stable key to maintain item identity during scroll
    child = KeyedSubtree(key: itemKey, child: child);

    if (semanticsLabel != null) {
      return Semantics(label: semanticsLabel, child: child);
    }
    return child;
  }

  Widget _buildGridTile(
    BuildContext context, {
    required int index,
    required int totalCount,
    required bool hasFooter,
    required SeparatorManager separators,
    required bool animateItems,
  }) {
    if (hasFooter && index == totalCount - 1) {
      return Center(child: _buildFooter(context));
    }
    return separators.buildChild(
      context: context,
      index: index,
      itemCount: controller.itemCount,
      itemBuilder: (ctx, itemIndex) {
        final item = controller.itemAt(itemIndex);
        if (item == null) {
          return const SizedBox.shrink();
        }
        return _buildItem(ctx, itemIndex, item, animate: animateItems);
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    if (controller.itemCount == 0) {
      return const SizedBox.shrink();
    }
    if (widget.footerBuilder != null) {
      return widget.footerBuilder!(context);
    }
    return LoadMoreFooter(
      isLoading: controller.isLoadingMore,
      hasMore: controller.hasMore,
      error: controller.error,
      onRetry: controller.retry,
      endLabel: 'Hết dữ liệu',
    );
  }
}
