import 'package:flutter/widgets.dart';

typedef InfiniteSeparatorBuilder =
    Widget Function(BuildContext context, int index);

/// Utility that maps logical list indices to physical children when separators
/// are present, similar to how [ListView.separated] works.
///
/// ### Purpose:
/// Enables separator support across list, grid, and sliver layouts with
/// consistent index mapping logic.
///
/// ### How it works:
/// - Interleaves separators between items: [item0, sep0, item1, sep1, item2]
/// - Maps physical index to logical item index: physical 4 → logical item 2
/// - Calculates total child count: itemCount * 2 - 1
///
/// ### Performance:
/// - Constant-time index calculations (O(1))
/// - No list allocations, just index arithmetic
/// - Compatible with lazy builders (no upfront work)
///
/// ### Usage:
/// ```dart
/// final separators = SeparatorManager(
///   builder: (context, index) => Divider(),
/// );
///
/// ListView.builder(
///   itemCount: separators.childCount(items.length),
///   itemBuilder: (context, index) {
///     return separators.buildChild(
///       context: context,
///       index: index,
///       itemCount: items.length,
///       itemBuilder: (ctx, itemIndex) => ItemTile(items[itemIndex]),
///     );
///   },
/// );
/// ```
class SeparatorManager {
  const SeparatorManager({this.builder});

  final InfiniteSeparatorBuilder? builder;

  /// Whether separators are enabled
  bool get hasSeparators => builder != null;

  /// Returns the total number of children once separators are interleaved.
  /// Formula: itemCount <= 1 ? itemCount : itemCount * 2 - 1
  int childCount(int itemCount) {
    return (!hasSeparators || itemCount <= 1) ? itemCount : itemCount * 2 - 1;
  }

  /// Whether the given index corresponds to a separator.
  /// All odd indices are separators when enabled.
  bool isSeparatorIndex(int index, int itemCount) {
    return hasSeparators && itemCount > 1 && index.isOdd;
  }

  /// Builds either an item or separator for the provided index.
  Widget buildChild({
    required BuildContext context,
    required int index,
    required int itemCount,
    required Widget Function(BuildContext context, int itemIndex) itemBuilder,
  }) {
    if (isSeparatorIndex(index, itemCount)) {
      final separatorIndex = index ~/ 2;
      return builder!(context, separatorIndex);
    }
    final itemIndex = itemIndexFor(index);
    return itemBuilder(context, itemIndex);
  }

  /// Maps a physical index back to the logical item index.
  /// Formula: hasSeparators ? index ~/ 2 : index
  int itemIndexFor(int index) => hasSeparators ? index ~/ 2 : index;
}
