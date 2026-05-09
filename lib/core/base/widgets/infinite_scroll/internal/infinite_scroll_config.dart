import 'package:base_flutter/core/base/base.dart' show InfiniteScrollView;
import 'package:base_flutter/core/base/widgets/grid/pinterest.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/infinite_scroll.dart'
    show InfiniteScrollView;
import 'package:base_flutter/core/base/widgets/infinite_scroll/infinite_scroll_view.dart'
    show InfiniteScrollView;

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
