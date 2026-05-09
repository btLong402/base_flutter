import 'dart:math' as math;
import 'package:base_flutter/core/base/widgets/grid/internal/grid_models.dart';

/// Mixin providing advanced Masonry placement algorithms.
mixin MasonryPlacementMixin {
  int get columnCount;
  List<double> get columnHeights;
  double get mainAxisSpacing;

  /// Resolves the best column placement for a given span.
  ColumnPlacementResult resolveColumnPlacement(int span) {
    final effectiveSpan = math.min(span, columnCount);
    var bestScore = double.infinity;
    var bestColumn = 0;

    for (var i = 0; i <= columnCount - effectiveSpan; i++) {
      final windowMax = windowMaxHeight(i, effectiveSpan);
      final balanceScore = _calculatePlacementScore(
        i,
        effectiveSpan,
        windowMax,
      );

      if (balanceScore < bestScore) {
        bestScore = balanceScore;
        bestColumn = i;
      }
    }

    final actualOffset = windowMaxHeight(bestColumn, effectiveSpan);
    return ColumnPlacementResult(
      bestColumn,
      actualOffset.isFinite ? actualOffset : 0,
    );
  }

  /// Predictive placement for multi-column items.
  ColumnPlacementResult predictivePlacement(int span) {
    if (span <= 1) return resolveColumnPlacement(span);

    final effectiveSpan = math.min(span, columnCount);
    var bestScore = double.infinity;
    var bestColumn = 0;

    for (var i = 0; i <= columnCount - effectiveSpan; i++) {
      final windowMax = windowMaxHeight(i, effectiveSpan);

      // Simulate placement impact
      final tempHeights = List<double>.from(columnHeights);
      for (var j = 0; j < effectiveSpan; j++) {
        tempHeights[i + j] = windowMax;
      }

      // Calculate overall balance after this placement
      final avgHeight =
          tempHeights.reduce((a, b) => a + b) / tempHeights.length;
      final variance =
          tempHeights.fold<double>(
            0,
            (sum, h) => sum + math.pow(h - avgHeight, 2),
          ) /
          tempHeights.length;

      final score = windowMax + (math.sqrt(variance) * 3.0);

      if (score < bestScore) {
        bestScore = score;
        bestColumn = i;
      }
    }

    final actualOffset = windowMaxHeight(bestColumn, effectiveSpan);
    return ColumnPlacementResult(
      bestColumn,
      actualOffset.isFinite ? actualOffset : 0,
    );
  }

  /// Calculates the maximum height across a range of columns.
  double windowMaxHeight(int start, int span) {
    double maxHeight = 0;
    for (var i = 0; i < span; i++) {
      maxHeight = math.max(maxHeight, columnHeights[start + i]);
    }
    return maxHeight;
  }

  double _calculatePlacementScore(int start, int span, double windowMaxHeight) {
    var score = windowMaxHeight;

    // Variance factor
    final columnVariance = _calculateColumnVariance(start, span);
    score += columnVariance * 2.0;

    // Deviation from average
    final avgColumnHeight = columnHeights.reduce((a, b) => a + b) / columnCount;
    final heightDeviation = (windowMaxHeight - avgColumnHeight).abs();
    score += heightDeviation * 0.5;

    // Neighbor gap potential
    final gapPotential = _calculateGapPotential(start, span, windowMaxHeight);
    score += gapPotential * 1.5;

    // Prefer left
    score += start * 0.01;

    return score;
  }

  double _calculateColumnVariance(int start, int span) {
    if (span <= 1) return 0;

    final heights = <double>[];
    for (var i = 0; i < span; i++) {
      heights.add(columnHeights[start + i]);
    }

    final avg = heights.reduce((a, b) => a + b) / heights.length;
    final variance =
        heights.fold<double>(
          0,
          (sum, h) => sum + math.pow(h - avg, 2),
        ) /
        heights.length;

    return math.sqrt(variance);
  }

  double _calculateGapPotential(int start, int span, double windowMax) {
    if (span >= columnCount) return 0;
    var maxGap = 0.0;

    if (start > 0) {
      maxGap = math.max(maxGap, (windowMax - columnHeights[start - 1]).abs());
    }
    if (start + span < columnCount) {
      maxGap = math.max(
        maxGap,
        (windowMax - columnHeights[start + span]).abs(),
      );
    }
    return maxGap;
  }
}
