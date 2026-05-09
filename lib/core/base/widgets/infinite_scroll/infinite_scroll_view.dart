import 'package:base_flutter/core/base/widgets/grid/pinterest.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/entrance_animation.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/internal/box_infinite_view.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/internal/infinite_scroll_config.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/internal/sliver_infinite_view.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/load_more_footer.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/pagination_controller.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/performance_utils.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/scroll_state_widgets.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/separator_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

export 'package:base_flutter/core/base/widgets/infinite_scroll/internal/infinite_scroll_config.dart';

/// Performance-optimized infinite scrolling widget.
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

  ScrollPhysics _resolveScrollPhysics() {
    if (widget.physics != null) return widget.physics!;

    const basePhysics = AlwaysScrollableScrollPhysics();

    if (widget.usePinterestPhysics) {
      return const PinterestScrollPhysics(parent: basePhysics);
    }

    return const BouncingScrollPhysics(parent: basePhysics);
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
    final currentItemCount = controller.itemCount;
    if (currentItemCount < _lastItemCount) {
      _animatedIndices.clear();
    }
    _lastItemCount = currentItemCount;

    final scheduler = SchedulerBinding.instance;
    final phase = scheduler.schedulerPhase;

    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      setState(() {});
      return;
    }

    if (_hasPendingControllerUpdate) return;

    _hasPendingControllerUpdate = true;
    scheduler.addPostFrameCallback((_) {
      if (!mounted) return;
      _hasPendingControllerUpdate = false;
      setState(() {});
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      controller.handleScrollMetrics(notification.metrics);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: widget.useSlivers ? _buildSliverView() : _buildBoxView(),
    );
  }

  Widget _buildBoxView() {
    final screenSize = MediaQuery.of(context).size;
    final cacheExtent = resolveCacheExtent(
      widget.cacheExtent,
      screenSize.height,
    );
    final physics = _resolveScrollPhysics();
    final separators = SeparatorManager(builder: widget.separatorBuilder);
    final hasFooter = controller.itemCount > 0;
    final bodyCount = separators.childCount(controller.itemCount);
    final totalCount = bodyCount + (hasFooter ? 1 : 0);

    return BoxInfiniteView<T>(
      controller: controller,
      effectiveController: _effectiveController,
      physics: physics,
      cacheExtent: cacheExtent,
      separators: separators,
      hasFooter: hasFooter,
      totalCount: totalCount,
      layout: widget.layout,
      padding: widget.padding,
      itemExtent: widget.itemExtent,
      gridConfig: widget.gridConfig,
      gridDelegate: widget.gridDelegate,
      refreshSemanticsLabel: widget.refreshSemanticsLabel,
      gridCacheExtent: widget.gridConfig != null
          ? resolveCacheExtent(widget.cacheExtent, screenSize.height)
          : null,
      buildItem: _buildItem,
      buildFooter: _buildFooter,
      buildContentWrapper: _buildContentWrapper,
    );
  }

  Widget _buildSliverView() {
    final separators = SeparatorManager(builder: widget.separatorBuilder);
    final physics = _resolveScrollPhysics();

    return SliverInfiniteView<T>(
      controller: controller,
      effectiveController: _effectiveController,
      physics: physics,
      separators: separators,
      layout: widget.layout,
      padding: widget.padding,
      gridConfig: widget.gridConfig,
      gridDelegate: widget.gridDelegate,
      sliverAppBar: widget.sliverAppBar,
      loadingBuilder: widget.loadingBuilder,
      shimmerBuilder: widget.shimmerBuilder,
      shimmerCount: widget.shimmerCount,
      emptyBuilder: widget.emptyBuilder,
      errorBuilder: widget.errorBuilder,
      buildItem: _buildItem,
      buildFooter: _buildFooter,
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

  Widget _buildItem(
    BuildContext context,
    int index,
    T item, {
    bool animate = true,
  }) {
    final semanticsLabel = widget.semanticsLabelBuilder?.call(item, index);
    final itemKey =
        widget.itemKeyBuilder?.call(item, index) ?? ValueKey<int>(index);

    var child = widget.itemBuilder(context, index, item);

    if (widget.enableImplicitEntranceAnimation && animate) {
      if (_animatedIndices.add(index)) {
        child = EntranceAnimation(child: child);
      }
    }

    if (widget.enableItemRepaintBoundary) {
      child = RepaintBoundary(child: child);
    }

    child = KeyedSubtree(key: itemKey, child: child);

    if (semanticsLabel != null) {
      return Semantics(label: semanticsLabel, child: child);
    }
    return child;
  }

  Widget _buildFooter(BuildContext context) {
    if (controller.itemCount == 0) return const SizedBox.shrink();
    if (widget.footerBuilder != null) return widget.footerBuilder!(context);
    return LoadMoreFooter(
      isLoading: controller.isLoadingMore,
      hasMore: controller.hasMore,
      error: controller.error,
      onRetry: controller.retry,
      endLabel: 'Hết dữ liệu',
    );
  }
}
