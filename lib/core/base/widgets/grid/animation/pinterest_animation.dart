import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:base_flutter/core/base/widgets/grid/animation/grid_animation_config.dart';

/// Pinterest-style animation configuration (re-exported for convenience).
///
/// **Note:** This is now a type alias to the unified GridAnimationConfig.
/// All Pinterest animation functionality has been consolidated into
/// GridAnimationConfig for better maintainability and to eliminate code
/// duplication.
///
/// **Migration Guide:**
/// - `PinterestGridAnimationConfig.staggeredFade()` →
///    `GridAnimationConfig.pinterest()`
/// - `PinterestGridAnimationConfig.fadeOnly()` →
///    `GridAnimationConfig.fadeOnly()`
/// - `PinterestGridAnimationConfig.scaleOnly()` →
///    `GridAnimationConfig.scaleOnly()`
/// - `PinterestGridAnimationConfig.slideOnly()` →
///    `GridAnimationConfig.slideOnly()`
/// - `PinterestGridAnimationConfig.none()` →
///    `GridAnimationConfig.none()`
///
/// **Usage:**
/// ```dart
/// // Old way (still works but deprecated)
/// animation: PinterestGridAnimationConfig.staggeredFade()
///
/// // New way (recommended)
/// animation: GridAnimationConfig.pinterest()
/// ```
@Deprecated(
  'Use GridAnimationConfig instead. Will be removed in a future version.',
)
typedef PinterestGridAnimationConfig = GridAnimationConfig;

/// Disappearing animation for items being removed from the grid.
///
/// **Use case:** When items are deleted or filtered out.
/// Provides smooth exit animation instead of instant removal.
///
/// **Example:**
/// ```dart
/// PinterestItemDisappearAnimation(
///   onComplete: () => setState(() => items.removeAt(index)),
///   child: ItemWidget(),
/// )
/// ```
class PinterestItemDisappearAnimation extends StatefulWidget {
  const PinterestItemDisappearAnimation({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInCubic,
    this.onComplete,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onComplete;

  @override
  State<PinterestItemDisappearAnimation> createState() =>
      _PinterestItemDisappearAnimationState();
}

class _PinterestItemDisappearAnimationState
    extends State<PinterestItemDisappearAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    final curve = CurvedAnimation(parent: _controller, curve: widget.curve);

    _opacity = Tween<double>(begin: 1, end: 0).animate(curve);
    _scale = Tween<double>(begin: 1, end: 0.9).animate(curve);

    // Auto-start animation
    unawaited(
      _controller.forward().then((_) {
        if (mounted) {
          widget.onComplete?.call();
        }
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
