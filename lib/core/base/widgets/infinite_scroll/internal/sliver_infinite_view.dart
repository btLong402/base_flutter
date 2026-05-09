import 'package:base_flutter/core/base/widgets/grid/pinterest.dart';
import 'package:flutter/material.dart';
import 'infinite_scroll_config.dart';
import '../pagination_controller.dart';
import '../separator_builder.dart';
import '../refresh_controls.dart';
import '../scroll_state_widgets.dart';

class SliverInfiniteView<T> extends StatelessWidget {
  const SliverInfiniteView({
    required this.controller,
    required this.effectiveController,
    required this.physics,
    required this.separators,
    required this.layout,
    required this.buildItem,
    required this.buildFooter,
    super.key,
    this.padding,
    this.gridConfig,
    this.gridDelegate,
    this.sliverAppBar,
    this.loadingBuilder,
    this.shimmerBuilder,
    this.shimmerCount = 6,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final PaginationController<T> controller;
  final ScrollController effectiveController;
  final ScrollPhysics physics;
  final SeparatorManager separators;
  final InfiniteScrollLayout layout;
  final Widget Function(BuildContext context, int index, T item, {bool animate})
  buildItem;
  final Widget Function(BuildContext context) buildFooter;
  final EdgeInsetsGeometry? padding;
  final InfiniteGridConfig? gridConfig;
  final SliverGridDelegate? gridDelegate;
  final SliverAppBar? sliverAppBar;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext context, int index)? shimmerBuilder;
  final int shimmerCount;
  final WidgetBuilder? emptyBuilder;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)?
  errorBuilder;

  @override
  Widget build(BuildContext context) {
    final appCell = sliverAppBar;
    final slivers = <Widget>[
      ?appCell,
      CupertinoSliverRefreshWrapper(onRefresh: controller.refresh),
      if (!controller.isInitialized && controller.isRefreshing)
        SliverToBoxAdapter(
          child: InfiniteScrollLoadingState(
            builder: loadingBuilder,
            shimmerBuilder: shimmerBuilder,
            shimmerCount: shimmerCount,
          ),
        )
      else if (controller.itemCount == 0 && controller.error == null)
        SliverToBoxAdapter(
          child: InfiniteScrollEmptyState(builder: emptyBuilder),
        )
      else if (controller.itemCount == 0 && controller.error != null)
        SliverToBoxAdapter(
          child: InfiniteScrollErrorState(
            error: controller.error!,
            onRetry: controller.retry,
            builder: errorBuilder,
          ),
        )
      else
        _buildSliverContent(),
      if (controller.itemCount > 0)
        SliverToBoxAdapter(child: buildFooter(context)),
    ];

    return CustomScrollView(
      controller: effectiveController,
      physics: physics,
      slivers: slivers,
    );
  }

  Widget _buildSliverContent() {
    final childCount = separators.childCount(controller.itemCount);

    if (layout == InfiniteScrollLayout.grid) {
      if (gridConfig != null) {
        Widget buildInternalChild(BuildContext context, int index) {
          return separators.buildChild(
            context: context,
            index: index,
            itemCount: controller.itemCount,
            itemBuilder: (ctx, itemIndex) {
              final item = controller.itemAt(itemIndex);
              return item == null
                  ? const SizedBox.shrink()
                  : buildItem(ctx, itemIndex, item,
                      animate: gridConfig!.animation == null);
            },
          );
        }

        final delegate = SliverChildBuilderDelegate(
          gridConfig!.animation == null
              ? buildInternalChild
              : (context, index) => gridConfig!.animation!.wrap(
                    context,
                    index,
                    buildInternalChild(context, index),
                  ),
          childCount: childCount,
          addAutomaticKeepAlives: gridConfig!.layout.addAutomaticKeepAlives,
          addRepaintBoundaries: gridConfig!.layout.addRepaintBoundaries,
          addSemanticIndexes: gridConfig!.layout.addSemanticIndexes,
        );

        final sliver = AdvancedSliverGrid(
          key: ValueKey<int>(gridConfig!.layout.hashCode),
          layout: gridConfig!.layout,
          delegate: delegate,
        );

        final gridPadding = padding ?? gridConfig!.layout.padding;
        if (gridPadding != null) {
          return SliverPadding(padding: gridPadding, sliver: sliver);
        }
        return sliver;
      }

      return SliverPadding(
        padding: padding ?? EdgeInsets.zero,
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return separators.buildChild(
                context: context,
                index: index,
                itemCount: controller.itemCount,
                itemBuilder: (ctx, itemIndex) {
                  final item = controller.itemAt(itemIndex);
                  return item == null
                      ? const SizedBox.shrink()
                      : buildItem(ctx, itemIndex, item);
                },
              );
            },
            childCount: childCount,
            addAutomaticKeepAlives: false,
          ),
          gridDelegate: gridDelegate!,
        ),
      );
    }

    return SliverPadding(
      padding: padding ?? EdgeInsets.zero,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return separators.buildChild(
              context: context,
              index: index,
              itemCount: controller.itemCount,
              itemBuilder: (ctx, itemIndex) {
                final item = controller.itemAt(itemIndex);
                return item == null
                    ? const SizedBox.shrink()
                    : buildItem(ctx, itemIndex, item);
              },
            );
          },
          childCount: childCount,
          addAutomaticKeepAlives: false,
        ),
      ),
    );
  }
}
