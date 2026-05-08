import 'dart:math' as math;

import 'package:base_flutter/core/base/widgets/grid/layout/grid_layout_config.dart';
import 'package:base_flutter/core/base/widgets/grid/layout/layout_strategies.dart';
import 'package:flutter/rendering.dart';

class AdvancedGridBoxParentData extends ContainerBoxParentData<RenderBox> {
  int index = 0;
  int columnSpan = 1;
  AlignmentGeometry alignment = AlignmentDirectional.topStart;
  double crossAxisExtent = 0;
}

class RenderAdvancedGridBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, AdvancedGridBoxParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, AdvancedGridBoxParentData> {
  RenderAdvancedGridBox({
    required GridLayoutConfig layout,
    required TextDirection textDirection,
  }) : _layout = layout,
       _textDirection = textDirection;

  GridLayoutConfig _layout;
  TextDirection _textDirection;

  GridLayoutConfig get layoutConfig => _layout;

  set layoutConfig(GridLayoutConfig value) {
    if (identical(value, _layout)) {
      return;
    }
    _layout = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;

  set textDirection(TextDirection value) {
    if (value == _textDirection) {
      return;
    }
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! AdvancedGridBoxParentData) {
      child.parentData = AdvancedGridBoxParentData();
    }
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    final maxWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.constrainWidth();
    assert(
      maxWidth.isFinite && maxWidth > 0,
      'AdvancedGridPanel requires bounded width.',
    );

    final resolvedPadding =
        _layout.padding?.resolve(_textDirection) ?? EdgeInsets.zero;
    final double innerWidth = math.max(
      0,
      maxWidth - resolvedPadding.horizontal,
    );

    final strategy = createLayoutStrategy(
      _layout,
      _textDirection,
    );
    final descriptor = strategy.describeBoxLayout(
      innerWidth,
    );
    final engine = _BoxColumnEngine(
      descriptor: descriptor,
      crossAxisExtent: innerWidth,
      textDirection: _textDirection,
    );

    var child = firstChild;
    var index = 0;
    while (child != null) {
      final childParentData = child.parentData! as AdvancedGridBoxParentData;
      final span =
          descriptor.spanResolver(index) ?? const GridSpanConfiguration();
      final crossExtent = engine.crossAxisExtentForSpan(span.columnSpan);
      final mainExtent =
          span.mainAxisExtent ??
          (span.aspectRatio != null && span.aspectRatio! > 0
              ? crossExtent / span.aspectRatio!
              : null);
      final childConstraints = BoxConstraints(
        minWidth: crossExtent,
        maxWidth: crossExtent,
        minHeight: mainExtent ?? 0,
        maxHeight: mainExtent ?? double.infinity,
      );
      child.layout(childConstraints, parentUsesSize: true);
      final placement = engine.placeChild(
        index,
        child.size,
        span,
      );

      final resolvedAlignment = span.alignment.resolve(
        _textDirection,
      );
      final alignmentOffset = resolvedAlignment.alongSize(
        Size(
          placement.crossAxisExtent - child.size.width,
          placement.mainAxisExtent - child.size.height,
        ),
      );
      final crossOffset =
          resolvedPadding.left + placement.crossAxisOffset + alignmentOffset.dx;
      final mainOffset =
          resolvedPadding.top + placement.layoutOffset + alignmentOffset.dy;

      childParentData
        ..index = index
        ..columnSpan = placement.columnSpan
        ..crossAxisExtent = placement.crossAxisExtent
        ..alignment = span.alignment
        ..offset = Offset(crossOffset, mainOffset);

      child = childParentData.nextSibling;
      index++;
    }

    final contentHeight = resolvedPadding.vertical + engine.maxColumnExtent;
    size = constraints.constrain(Size(maxWidth, contentHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as AdvancedGridBoxParentData;
      context.paintChild(child, offset + parentData.offset);
      child = parentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = lastChild;
    while (child != null) {
      final parentData = child.parentData! as AdvancedGridBoxParentData;
      final target = child;
      final isHit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (result, transformed) {
          return target.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = parentData.previousSibling;
    }
    return false;
  }
}

class _BoxColumnEngine {
  _BoxColumnEngine({
    required this.descriptor,
    required this.crossAxisExtent,
    required this.textDirection,
  }) : columnHeights = List<double>.filled(
         descriptor.columnCount,
         0,
       ) {
    _configure();
  }

  final BoxGridLayoutDescriptor descriptor;
  final double crossAxisExtent;
  final TextDirection textDirection;
  final List<double> columnHeights;
  late double _columnWidth;
  double _crossAxisInset = 0;

  void _configure() {
    if (descriptor.fixedColumnWidth != null) {
      _columnWidth = descriptor.fixedColumnWidth!;
      final totalWidth = _crossAxisExtentForSpan(descriptor.columnCount);
      _crossAxisInset = descriptor.expandToFit
          ? 0
          : math.max(0, (crossAxisExtent - totalWidth) / 2);
    } else {
      final gaps =
          descriptor.crossAxisSpacing * math.max(descriptor.columnCount - 1, 0);
      final double available = math.max(0, crossAxisExtent - gaps);
      _columnWidth = descriptor.columnCount > 0
          ? available / descriptor.columnCount
          : 0;
      _crossAxisInset = descriptor.expandToFit
          ? 0
          : math.max(0, (crossAxisExtent - available - gaps) / 2);
    }
  }

  _BoxChildPlacement placeChild(
    int index,
    Size childSize,
    GridSpanConfiguration span,
  ) {
    final int effectiveSpan = math.min(span.columnSpan, descriptor.columnCount);
    final placement = _resolveColumnPlacement(effectiveSpan);
    final crossExtent = _crossAxisExtentForSpan(effectiveSpan);
    final mainExtent = span.mainAxisExtent ?? childSize.height;
    final crossOffset = _crossAxisOffsetForColumn(placement.columnIndex);
    final layoutOffset = placement.mainAxisOffset;
    for (var i = 0; i < effectiveSpan; i++) {
      columnHeights[placement.columnIndex + i] =
          layoutOffset + mainExtent + descriptor.mainAxisSpacing;
    }
    return _BoxChildPlacement(
      layoutOffset: layoutOffset,
      crossAxisOffset: crossOffset,
      mainAxisExtent: mainExtent,
      crossAxisExtent: crossExtent,
      columnSpan: effectiveSpan,
    );
  }

  double get maxColumnExtent {
    if (columnHeights.isEmpty) {
      return 0;
    }
    final maxExtent = columnHeights.reduce(math.max);
    return math.max(0, maxExtent - descriptor.mainAxisSpacing);
  }

  double _crossAxisExtentForSpan(int span) {
    final int effective = math.min(span, descriptor.columnCount);
    final gaps = descriptor.crossAxisSpacing * math.max(effective - 1, 0);
    return _columnWidth * effective + gaps;
  }

  double _crossAxisOffsetForColumn(int column) {
    final base = column * (_columnWidth + descriptor.crossAxisSpacing);
    final offset = base + _crossAxisInset;
    if (!descriptor.reverseCrossAxis) {
      return offset;
    }
    return crossAxisExtent - _crossAxisExtentForSpan(1) - offset;
  }

  _ColumnSlot _resolveColumnPlacement(int span) {
    var bestScore = double.infinity;
    var bestColumn = 0;

    // MASONRY OPTIMIZATION: Enhanced balancing for gap-free layouts
    for (var column = 0; column <= descriptor.columnCount - span; column++) {
      final candidate = _windowMaxHeight(column, span);
      final score = _calculatePlacementScore(column, span, candidate);

      if (score < bestScore) {
        bestScore = score;
        bestColumn = column;
      }
    }

    final actualOffset = _windowMaxHeight(bestColumn, span);
    return _ColumnSlot(bestColumn, actualOffset.isFinite ? actualOffset : 0);
  }

  /// MASONRY OPTIMIZATION: Calculate placement score for balanced distribution
  double _calculatePlacementScore(int start, int span, double windowMaxHeight) {
    var score = windowMaxHeight;

    // Penalize variance within the window
    final variance = _calculateColumnVariance(start, span);
    score += variance * 2.0;

    // Penalize deviation from average column height
    final avgHeight =
        columnHeights.reduce((a, b) => a + b) / columnHeights.length;
    final deviation = (windowMaxHeight - avgHeight).abs();
    score += deviation * 0.5;

    // Penalize gap potential with neighbors
    final gapPotential = _calculateGapPotential(start, span, windowMaxHeight);
    score += gapPotential * 1.5;

    // Slight preference for left columns
    score += start * 0.01;

    return score;
  }

  /// Calculate variance in column heights for a window
  double _calculateColumnVariance(int start, int span) {
    if (span == 1) return 0;

    final heights = <double>[];
    for (var i = 0; i < span; i++) {
      heights.add(columnHeights[start + i]);
    }

    final avg = heights.reduce((a, b) => a + b) / heights.length;
    final variance =
        heights.fold<double>(0, (sum, h) => sum + math.pow(h - avg, 2)) /
        heights.length;

    return math.sqrt(variance);
  }

  /// Calculate potential gaps with neighboring columns
  double _calculateGapPotential(int start, int span, double windowMax) {
    if (span >= descriptor.columnCount) return 0;

    var maxGap = 0.0;

    // Check left neighbor
    if (start > 0) {
      final leftHeight = columnHeights[start - 1];
      maxGap = math.max(maxGap, (windowMax - leftHeight).abs());
    }

    // Check right neighbor
    if (start + span < descriptor.columnCount) {
      final rightHeight = columnHeights[start + span];
      maxGap = math.max(maxGap, (windowMax - rightHeight).abs());
    }

    return maxGap;
  }

  double _windowMaxHeight(int start, int span) {
    double height = 0;
    for (var offset = 0; offset < span; offset++) {
      height = math.max(height, columnHeights[start + offset]);
    }
    return height;
  }

  double crossAxisExtentForSpan(int span) => _crossAxisExtentForSpan(span);
}

class _BoxChildPlacement {
  const _BoxChildPlacement({
    required this.layoutOffset,
    required this.crossAxisOffset,
    required this.mainAxisExtent,
    required this.crossAxisExtent,
    required this.columnSpan,
  });

  final double layoutOffset;
  final double crossAxisOffset;
  final double mainAxisExtent;
  final double crossAxisExtent;
  final int columnSpan;

  double get trailingOffset => layoutOffset + mainAxisExtent;
}

class _ColumnSlot {
  const _ColumnSlot(this.columnIndex, this.mainAxisOffset);
  final int columnIndex;
  final double mainAxisOffset;
}
