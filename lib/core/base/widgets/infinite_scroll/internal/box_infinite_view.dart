import 'package:base_flutter/core/base/widgets/grid/pinterest.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/internal/infinite_scroll_config.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/pagination_controller.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/refresh_controls.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/separator_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BoxInfiniteView<T> extends StatelessWidget {
  const BoxInfiniteView({
    required this.controller,
    required this.effectiveController,
    required this.physics,
    required this.cacheExtent,
    required this.separators,
    required this.hasFooter,
    required this.totalCount,
    required this.layout,
    required this.buildItem,
    required this.buildFooter,
    super.key,
    this.padding,
    this.itemExtent,
    this.gridConfig,
    this.gridDelegate,
    this.refreshSemanticsLabel,
    this.gridCacheExtent,
    this.buildContentWrapper,
  });

  final PaginationController<T> controller;
  final ScrollController effectiveController;
  final ScrollPhysics physics;
  final double cacheExtent;
  final SeparatorManager separators;
  final bool hasFooter;
  final int totalCount;
  final InfiniteScrollLayout layout;
  final Widget Function(BuildContext context, int index, T item) buildItem;
  final Widget Function(BuildContext context) buildFooter;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final InfiniteGridConfig? gridConfig;
  final SliverGridDelegate? gridDelegate;
  final String? refreshSemanticsLabel;
  final double? gridCacheExtent;
  final Widget Function(Widget child)? buildContentWrapper;

  @override
  Widget build(BuildContext context) {
    Widget list;
    if (layout == InfiniteScrollLayout.list) {
      list = ListView.builder(
        controller: effectiveController,
        physics: physics,
        padding: padding,
        scrollCacheExtent: ScrollCacheExtent.pixels(cacheExtent),
        itemExtent: separators.builder == null ? itemExtent : null,
        itemBuilder: (context, index) {
          if (hasFooter && index == totalCount - 1) {
            return buildFooter(context);
          }
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
        itemCount: totalCount,
      );
    } else {
      if (gridConfig != null) {
        list = AdvancedGridView.builder(
          key: ValueKey<int>(gridConfig!.layout.hashCode),
          controller: effectiveController,
          physics: physics,
          padding: padding,
          scrollCacheExtent: gridCacheExtent,
          layout: gridConfig!.layout,
          animation: gridConfig!.animation,
          itemCount: totalCount,
          itemBuilder: (context, index) {
            if (hasFooter && index == totalCount - 1) {
              return Center(child: buildFooter(context));
            }
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
        );
      } else {
        list = GridView.builder(
          controller: effectiveController,
          physics: physics,
          padding: padding,
          scrollCacheExtent: ScrollCacheExtent.pixels(cacheExtent),
          gridDelegate: gridDelegate!,
          itemBuilder: (context, index) {
            if (hasFooter && index == totalCount - 1) {
              return Center(child: buildFooter(context));
            }
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
          itemCount: totalCount,
        );
      }
    }

    return MaterialRefreshWrapper(
      onRefresh: controller.refresh,
      semanticsLabel: refreshSemanticsLabel ?? 'Kéo để làm mới',
      child: buildContentWrapper?.call(list) ?? list,
    );
  }
}
