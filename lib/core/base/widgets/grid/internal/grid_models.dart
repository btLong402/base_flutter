import 'package:flutter/rendering.dart';

/// Context information for the grid layout session.
class GridLayoutContext {
  GridLayoutContext({
    required this.constraints,
    required this.textDirection,
    required this.axisDirection,
    required this.growthDirection,
  }) : crossAxisExtent = constraints.crossAxisExtent,
       isAxisVertical =
           axisDirection == AxisDirection.down ||
           axisDirection == AxisDirection.up;

  final SliverConstraints constraints;
  final TextDirection textDirection;
  final AxisDirection axisDirection;
  final GrowthDirection growthDirection;
  final double crossAxisExtent;
  final bool isAxisVertical;
}

/// Placement data for a single child in the grid.
class GridChildPlacement {
  const GridChildPlacement({
    required this.index,
    required this.layoutOffset,
    required this.mainAxisExtent,
    required this.crossAxisOffset,
    required this.crossAxisExtent,
    required this.alignment,
    required this.columnStart,
    required this.columnSpan,
  });

  final int index;
  final double layoutOffset;
  final double mainAxisExtent;
  final double crossAxisOffset;
  final double crossAxisExtent;
  final AlignmentGeometry alignment;
  final int columnStart;
  final int columnSpan;

  double get trailingOffset => layoutOffset + mainAxisExtent;
}

/// Placement result for internal column calculations.
class ColumnPlacementResult {
  const ColumnPlacementResult(this.columnIndex, this.mainAxisOffset);
  final int columnIndex;
  final double mainAxisOffset;
}
