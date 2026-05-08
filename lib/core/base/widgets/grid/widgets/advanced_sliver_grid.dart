import 'package:base_flutter/core/base/widgets/grid/animation/grid_animation_config.dart';
import 'package:base_flutter/core/base/widgets/grid/layout/grid_layout_config.dart';
import 'package:base_flutter/core/base/widgets/grid/render/advanced_sliver_render.dart';
import 'package:flutter/widgets.dart';

class AdvancedSliverGrid extends SliverMultiBoxAdaptorWidget {
  const AdvancedSliverGrid({
    required GridLayoutConfig layout,
    required super.delegate,
    super.key,
  }) : _layout = layout;

  final GridLayoutConfig _layout;

  GridLayoutConfig get layout => _layout;

  @override
  RenderSliverAdvancedGrid createRenderObject(BuildContext context) {
    final textDirection = Directionality.of(context);
    final element = context as SliverMultiBoxAdaptorElement;
    return RenderSliverAdvancedGrid(
      layout: _layout,
      childManager: element,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderSliverAdvancedGrid renderObject,
  ) {
    renderObject
      ..layoutConfig = _layout
      ..textDirection = Directionality.of(context);
  }
}

class AdvancedSliverGridList extends AdvancedSliverGrid {
  AdvancedSliverGridList({
    required super.layout,
    required IndexedWidgetBuilder itemBuilder,
    super.key,
    int? itemCount,
    GridAnimationConfig? animation,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    int semanticIndexOffset = 0,
    SemanticIndexCallback semanticIndexCallback = _defaultSemanticIndexCallback,
    ChildIndexGetter? findChildIndexCallback,
  }) : super(
         delegate: SliverChildBuilderDelegate(
           animation == null
               ? itemBuilder
               : (context, index) => animation.wrap(
                   context,
                   index,
                   itemBuilder(context, index),
                 ),
           childCount: itemCount,
           addAutomaticKeepAlives: addAutomaticKeepAlives,
           addRepaintBoundaries: addRepaintBoundaries,
           addSemanticIndexes: addSemanticIndexes,
           semanticIndexCallback: semanticIndexCallback,
           semanticIndexOffset: semanticIndexOffset,
           // CRITICAL OPTIMIZATION: Enable efficient item identification
           // This prevents unnecessary rebuilds when items are appended
           // to the list
           findChildIndexCallback: findChildIndexCallback,
         ),
       );

  static int? _defaultSemanticIndexCallback(Widget _, int index) => index;
}
