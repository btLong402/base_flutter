import 'package:base_flutter/core/base/widgets/grid/animation/grid_animation_config.dart';
import 'package:base_flutter/core/base/widgets/grid/layout/grid_layout_config.dart';
import 'package:base_flutter/core/base/widgets/grid/render/advanced_box_render.dart';
import 'package:flutter/widgets.dart';

class AdvancedGridPanel extends MultiChildRenderObjectWidget {
  AdvancedGridPanel.builder({
    required this.layout,
    required GridItemBuilder itemBuilder,
    required int itemCount,
    super.key,
    GridAnimationConfig? animation,
  }) : super(
         children: List<Widget>.generate(
           itemCount,
           (index) => _GridPanelChild(
             itemBuilder: itemBuilder,
             index: index,
             animation: animation,
           ),
           growable: false,
         ),
       );

  final GridLayoutConfig layout;

  @override
  RenderAdvancedGridBox createRenderObject(BuildContext context) {
    return RenderAdvancedGridBox(
      layout: layout,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderAdvancedGridBox renderObject,
  ) {
    renderObject
      ..layoutConfig = layout
      ..textDirection = Directionality.of(context);
  }
}

class _GridPanelChild extends StatelessWidget {
  const _GridPanelChild({
    required this.itemBuilder,
    required this.index,
    this.animation,
  });

  final GridItemBuilder itemBuilder;
  final int index;
  final GridAnimationConfig? animation;

  @override
  Widget build(BuildContext context) {
    final child = itemBuilder(context, index);
    if (animation == null) {
      return child;
    }
    return animation!.wrap(context, index, child);
  }
}
