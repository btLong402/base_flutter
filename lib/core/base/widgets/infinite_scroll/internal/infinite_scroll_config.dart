import 'package:base_flutter/core/base/widgets/grid/pinterest.dart';

enum InfiniteScrollLayout { list, grid }

/// Configuration for integrating the advanced grid system with
/// [InfiniteScrollView]. Supply a [GridLayoutConfig] alongside optional
/// animation parameters to enable fixed, responsive, masonry, asymmetric, or
/// auto-placement grids.
class InfiniteGridConfig {
  const InfiniteGridConfig({required this.layout, this.animation});

  final GridLayoutConfig layout;
  final GridAnimationConfig? animation;
}
