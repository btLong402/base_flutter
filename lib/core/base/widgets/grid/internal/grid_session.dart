import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import 'package:base_flutter/core/base/widgets/grid/internal/grid_models.dart';
import 'package:base_flutter/core/base/widgets/grid/internal/masonry_mixins.dart';
import 'package:base_flutter/core/base/widgets/grid/layout/grid_layout_config.dart';

export 'package:base_flutter/core/base/widgets/grid/internal/grid_models.dart';

/// Abstract base for grid layout sessions.
abstract class GridLayoutSession {
  GridLayoutSession(this.context);

  GridLayoutContext context;

  void ensureForLayout(GridLayoutContext nextContext);
  BoxConstraints resolveConstraintsForIndex(int index);
  GridChildPlacement recordChildLayout(int index, Size childSize);
  int estimateMinIndexForScrollOffset(double scrollOffset);
  double estimateMaxScrollOffset(int? itemCount);
  void dropCache(int leadingIndex, int trailingIndex);
  void reset();
  void updateItemCount(int? itemCount);
  double get maxColumnExtent;
  Iterable<GridChildPlacement> get cachedPlacements;
}

/// A grid layout session that organizes items in columns (e.g., Masonry).
class ColumnarGridSession extends GridLayoutSession with MasonryPlacementMixin {
  ColumnarGridSession({
    required GridLayoutContext context,
    required this.columnCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.spanResolver,
    required this.reverseCrossAxis,
    required this.expandToFit,
    this.fixedColumnWidth,
  }) : columnHeights = List<double>.filled(columnCount, 0),
       columnOffsets = List<double>.filled(columnCount, 0),
       super(context);

  @override
  final int columnCount;
  @override
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final GridSpanResolver spanResolver;
  final bool reverseCrossAxis;
  final bool expandToFit;
  final double? fixedColumnWidth;

  late double _columnWidth;
  double _crossAxisInset = 0;
  @override
  final List<double> columnHeights;
  final List<double> columnOffsets;
  final SplayTreeMap<int, GridChildPlacement> _placements =
      SplayTreeMap<int, GridChildPlacement>();
  final Map<int, GridSpanConfiguration> _spanCache =
      <int, GridSpanConfiguration>{};

  int _maxCachedIndex = -1;
  static const int _maxCachedPlacements = 500;
  int? _lastKnownItemCount;

  @override
  void ensureForLayout(GridLayoutContext nextContext) {
    final hasCrossExtentChanged =
        context.crossAxisExtent != nextContext.crossAxisExtent;
    if (!identical(context.constraints, nextContext.constraints) ||
        hasCrossExtentChanged ||
        nextContext.constraints.crossAxisExtent <= 0) {
      reset();
    }
    context = nextContext;

    if (fixedColumnWidth != null) {
      _columnWidth = fixedColumnWidth!;
    } else {
      final usableExtent = math.max(
        0,
        nextContext.crossAxisExtent -
            crossAxisSpacing * math.max(columnCount - 1, 0),
      );
      final rawWidth = usableExtent / columnCount;
      _columnWidth = rawWidth.isFinite ? rawWidth : 0;
    }

    if (!expandToFit) {
      final totalWidth = _crossAxisExtentForSpan(columnCount);
      _crossAxisInset = math.max(
        0,
        (nextContext.crossAxisExtent - totalWidth) / 2,
      );
    } else {
      _crossAxisInset = 0;
    }

    for (var i = 0; i < columnCount; i++) {
      columnOffsets[i] = _crossAxisOffsetForColumn(i);
    }
  }

  @override
  BoxConstraints resolveConstraintsForIndex(int index) {
    final span = _resolveSpan(index);
    final crossExtent = _crossAxisExtentForSpan(span.columnSpan);
    final mainExtent =
        span.mainAxisExtent ??
        (span.aspectRatio != null && span.aspectRatio! > 0
            ? crossExtent / span.aspectRatio!
            : null);
    return BoxConstraints(
      minWidth: crossExtent,
      maxWidth: crossExtent,
      minHeight: mainExtent ?? 0,
      maxHeight: mainExtent ?? double.infinity,
    );
  }

  @override
  GridChildPlacement recordChildLayout(int index, Size childSize) {
    final span = _resolveSpan(index);
    final placement = span.columnSpan > 1
        ? predictivePlacement(span.columnSpan)
        : resolveColumnPlacement(span.columnSpan);

    final crossExtent = _crossAxisExtentForSpan(span.columnSpan);
    final mainExtent = span.mainAxisExtent ?? childSize.height;
    final layoutOffset = placement.mainAxisOffset;
    final consumedExtent = mainExtent + mainAxisSpacing;

    for (var i = 0; i < span.columnSpan; i++) {
      final colIdx = placement.columnIndex + i;
      if (colIdx < columnCount) {
        columnHeights[colIdx] = layoutOffset + consumedExtent;
      }
    }

    final result = GridChildPlacement(
      index: index,
      layoutOffset: layoutOffset,
      mainAxisExtent: mainExtent,
      crossAxisOffset: columnOffsets[placement.columnIndex],
      crossAxisExtent: crossExtent,
      alignment: span.alignment,
      columnStart: placement.columnIndex,
      columnSpan: span.columnSpan,
    );

    _placements[index] = result;
    _maxCachedIndex = math.max(_maxCachedIndex, index);

    if (_placements.length > _maxCachedPlacements) {
      _pruneOldPlacements();
    }

    return result;
  }

  void _pruneOldPlacements() {
    final threshold = _maxCachedIndex - (_maxCachedPlacements ~/ 2);
    _placements.removeWhere((key, _) => key < threshold);
    _spanCache.removeWhere((key, _) => key < threshold);
  }

  @override
  int estimateMinIndexForScrollOffset(double scrollOffset) {
    if (_placements.isEmpty) return 0;
    var candidate = _placements.firstKey()!;
    for (final entry in _placements.entries) {
      if (entry.value.trailingOffset <= scrollOffset) {
        candidate = entry.key;
      } else {
        break;
      }
    }
    return candidate;
  }

  @override
  double estimateMaxScrollOffset(int? itemCount) {
    if (columnHeights.isEmpty) return 0;
    return math.max(0, columnHeights.reduce(math.max) - mainAxisSpacing);
  }

  @override
  void dropCache(int leadingIndex, int trailingIndex) {
    _placements.removeWhere((key, _) => key >= leadingIndex && key <= trailingIndex);
    _spanCache.removeWhere((key, _) => key >= leadingIndex && key <= trailingIndex);
  }

  @override
  void reset() {
    for (var i = 0; i < columnCount; i++) {
      columnHeights[i] = 0;
      columnOffsets[i] = _crossAxisOffsetForColumn(i);
    }
    _placements.clear();
    _spanCache.clear();
    _maxCachedIndex = -1;
    _lastKnownItemCount = null;
  }

  @override
  void updateItemCount(int? itemCount) {
    if (itemCount == null || _lastKnownItemCount == itemCount) return;
    _lastKnownItemCount = itemCount;

    final hasRemoved = _placements.keys.any((k) => k >= itemCount);
    if (hasRemoved) {
      _placements.removeWhere((key, _) => key >= itemCount);
      _spanCache.removeWhere((key, _) => key >= itemCount);
      _recalculateColumnHeights();
      if (_maxCachedIndex >= itemCount) {
        _maxCachedIndex = _placements.isEmpty ? -1 : _placements.lastKey()!;
      }
    }
  }

  void _recalculateColumnHeights() {
    for (var i = 0; i < columnCount; i++) {
      columnHeights[i] = 0;
    }
    for (final placement in _placements.values) {
      final endOffset = placement.trailingOffset + mainAxisSpacing;
      for (var i = 0; i < placement.columnSpan; i++) {
        final col = placement.columnStart + i;
        if (col < columnCount) {
          columnHeights[col] = math.max(columnHeights[col], endOffset);
        }
      }
    }
    _checkAndFlagImbalance();
  }

  void _checkAndFlagImbalance() {
    if (columnCount < 2 || columnHeights.isEmpty) return;
    final imbalance = columnHeights.reduce(math.max) - columnHeights.reduce(math.min);
    if (imbalance > 500.0 && _placements.isNotEmpty) {
      final oldestKeys = _placements.keys.take(_placements.length ~/ 4).toList();
      for (final key in oldestKeys) {
        _placements.remove(key);
        _spanCache.remove(key);
      }
    }
  }

  @override
  double get maxColumnExtent => columnHeights.reduce(math.max);

  @override
  Iterable<GridChildPlacement> get cachedPlacements => _placements.values;

  GridSpanConfiguration _resolveSpan(int index) {
    return _spanCache.putIfAbsent(
      index,
      () => spanResolver(index) ?? const GridSpanConfiguration(),
    );
  }

  double _crossAxisOffsetForColumn(int column) {
    final baseOffset = column * (_columnWidth + crossAxisSpacing);
    if (!reverseCrossAxis) return baseOffset + _crossAxisInset;
    return context.crossAxisExtent - _crossAxisExtentForSpan(1) - baseOffset - _crossAxisInset;
  }

  double _crossAxisExtentForSpan(int span) {
    final effective = math.min(span, columnCount);
    final gaps = math.max(effective - 1, 0) * crossAxisSpacing;
    return _columnWidth * effective + gaps;
  }
}
