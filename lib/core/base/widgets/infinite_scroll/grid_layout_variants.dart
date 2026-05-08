import 'package:base_flutter/core/base/widgets/infinite_scroll/infinite_scroll.dart'
    show InfiniteScrollView;
import 'package:base_flutter/core/base/widgets/infinite_scroll/infinite_scroll_view.dart'
    show InfiniteScrollView;

/// ## Grid Layout Variants for InfiniteScrollView
///
/// Enumerates the advanced grid layout strategies supported by
/// [InfiniteScrollView]. These variants integrate with the advanced grid
/// system to provide diverse layout patterns while maintaining consistent
/// pagination, caching, and scroll performance.
///
/// ### Layout Descriptions:
///
/// - **Fixed**: Equal-width columns with fixed aspect ratios
///   - Best for: Photo galleries, product grids
///   - Performance: Excellent (predictable layout)
///
/// - **Flexible**: Responsive columns that adapt to breakpoints
///   - Best for: Multi-device apps, adaptive UIs
///   - Performance: Good (layout recalc on resize)
///
/// - **Masonry**: Pinterest-style waterfall layout
///   - Best for: Variable-height content (images, cards)
///   - Performance: Good (height measurement required)
///
/// - **Ratio**: Custom aspect ratios per item
///   - Best for: Mixed media types
///   - Performance: Good (requires aspect ratio data)
///
/// - **Nested**: Grids within grids (complex layouts)
///   - Best for: Dashboard UIs, magazine layouts
///   - Performance: Moderate (nested layout passes)
///
/// - **Asymmetric**: Non-uniform tile sizes and spans
///   - Best for: Hero items, featured content
///   - Performance: Good (span resolver function)
///
/// - **Auto Placement**: Automatic tile positioning algorithm
///   - Best for: Dynamic content with variable sizes
///   - Performance: Moderate (auto-layout calculation)
///
/// ### Usage:
/// ```dart
/// InfiniteScrollView(
///   layout: InfiniteScrollLayout.grid,
///   gridConfig: InfiniteGridConfig(
///     layout: MasonryGridLayout(...), // Corresponds to GridLayoutVariant.masonry
///   ),
/// )
/// ```
enum GridLayoutVariant {
  fixed,
  flexible,
  masonry,
  ratio,
  nested,
  asymmetric,
  autoPlacement,
}

extension GridLayoutVariantLabel on GridLayoutVariant {
  String get displayLabel => switch (this) {
    GridLayoutVariant.fixed => 'Fixed',
    GridLayoutVariant.flexible => 'Flexible',
    GridLayoutVariant.masonry => 'Masonry',
    GridLayoutVariant.ratio => 'Ratio',
    GridLayoutVariant.nested => 'Nested',
    GridLayoutVariant.asymmetric => 'Asymmetric',
    GridLayoutVariant.autoPlacement => 'Auto Placement',
  };
}
