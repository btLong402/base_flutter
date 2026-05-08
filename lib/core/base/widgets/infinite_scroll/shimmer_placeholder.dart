import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Configurable shimmer loading placeholder for infinite scroll lists.
///
/// Shows animated "skeleton" placeholders while data is loading,
/// providing smoother UX than a single spinner.
///
/// ### Usage:
/// ```dart
/// InfiniteScrollView<Post>(
///   controller: controller,
///   loadingBuilder: (_) => const ShimmerPlaceholder(
///     itemCount: 6,
///     itemHeight: 80,
///   ),
///   ...
/// )
/// ```
class ShimmerPlaceholder extends StatelessWidget {
  const ShimmerPlaceholder({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 72.0,
    this.itemSpacing = 12.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.baseColor,
    this.highlightColor,
    this.itemBuilder,
  });

  /// Number of skeleton placeholders to display.
  final int itemCount;

  /// Height of each placeholder item.
  final double itemHeight;

  /// Vertical spacing between items.
  final double itemSpacing;

  /// Border radius of placeholder items.
  final double borderRadius;

  /// Outer padding for the placeholder list.
  final EdgeInsetsGeometry padding;

  /// Base shimmer color. Defaults to grey[300].
  final Color? baseColor;

  /// Highlight shimmer color. Defaults to grey[100].
  final Color? highlightColor;

  /// Custom builder for each skeleton item. When provided,
  /// [itemHeight] and [borderRadius] are ignored.
  final Widget Function(BuildContext context, int index)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final base = baseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlight =
        highlightColor ?? (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return Padding(
      padding: padding,
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: List.generate(itemCount, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < itemCount - 1 ? itemSpacing : 0,
                ),
                child:
                    itemBuilder?.call(context, index) ??
                    _DefaultSkeletonItem(
                      height: itemHeight,
                      borderRadius: borderRadius,
                    ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Default skeleton item with title + subtitle layout.
class _DefaultSkeletonItem extends StatelessWidget {
  const _DefaultSkeletonItem({
    required this.height,
    required this.borderRadius,
  });

  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: height - 24,
            height: height - 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius * 0.6),
            ),
          ),
          const SizedBox(width: 12),
          // Text lines placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.6,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid-variant shimmer placeholder for grid layouts.
///
/// ```dart
/// InfiniteScrollView<Photo>(
///   controller: controller,
///   layout: InfiniteScrollLayout.grid,
///   loadingBuilder: (_) => const ShimmerGridPlaceholder(
///     crossAxisCount: 2,
///     itemCount: 6,
///   ),
///   ...
/// )
/// ```
class ShimmerGridPlaceholder extends StatelessWidget {
  const ShimmerGridPlaceholder({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.childAspectRatio = 1.0,
    this.spacing = 12.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
    this.baseColor,
    this.highlightColor,
  });

  final int crossAxisCount;
  final int itemCount;
  final double childAspectRatio;
  final double spacing;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final base = baseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlight =
        highlightColor ?? (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return Padding(
      padding: padding,
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            );
          },
        ),
      ),
    );
  }
}
