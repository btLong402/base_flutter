import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Animation constants for consistent behavior across all grid animations
class GridAnimationConstants {
  GridAnimationConstants._();

  // Duration constants
  static const Duration defaultDuration = Duration(milliseconds: 280);
  static const Duration fastDuration = Duration(milliseconds: 220);
  static const Duration slowDuration = Duration(milliseconds: 320);

  // Stagger constants
  static const Duration staggerDelay = Duration(milliseconds: 25);
  static const Duration maxStagger = Duration(milliseconds: 200);
  static const int staggerModulo = 20;

  // Transform constants
  static const double defaultScaleFrom = 0.94;
  static const double subtleScaleFrom = 0.95;
  static const double dramaticScaleFrom = 0.85;
  static const double slideOffsetSmall = 24;
  static const double slideOffsetMedium = 32;

  // Curve constants
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve subtleCurve = Curves.easeOut;
  static const Curve bouncyCurve = Curves.easeOutBack;
}

typedef GridItemAnimationBuilder =
    Widget Function(BuildContext context, int index, Widget child);

/// Unified grid animation configuration supporting multiple animation styles.
///
/// **Supports:**
/// - Pinterest-style staggered fade/scale/slide
/// - Simple staggered animations
/// - Custom animation builders
/// - No animation mode
///
/// **Performance:**
/// - Uses efficient RenderLayer animations (FadeTransition, ScaleTransition)
/// - Automatic disposal via stateful widgets
/// - Keep-alive support for scroll performance
class GridAnimationConfig {
  /// No animation - items appear immediately.
  factory GridAnimationConfig.none() =>
      GridAnimationConfig._((_, _, child) => child);

  /// Pinterest-style staggered animation with fade, scale, and slide effects.
  ///
  /// This creates the signature Pinterest appearance animation with all
  /// three effects.
  ///
  /// **Parameters:**
  /// - [duration]: Animation duration per item
  /// - [curve]: Easing curve (default: easeOutCubic for natural deceleration)
  /// - [staggerDelay]: Base delay between items (default: 25ms)
  /// - [maxStagger]: Maximum stagger delay (default: 200ms)
  /// - [fadeFrom]: Initial opacity (0.0 = invisible, 1.0 = visible)
  /// - [scaleFrom]: Initial scale (< 1.0 = smaller)
  /// - [slideOffset]: Vertical slide distance in pixels
  factory GridAnimationConfig.pinterest({
    Duration duration = GridAnimationConstants.defaultDuration,
    Curve curve = GridAnimationConstants.defaultCurve,
    Duration staggerDelay = GridAnimationConstants.staggerDelay,
    Duration maxStagger = GridAnimationConstants.maxStagger,
    double fadeFrom = 0.0,
    double scaleFrom = GridAnimationConstants.defaultScaleFrom,
    double slideOffset = GridAnimationConstants.slideOffsetSmall,
  }) {
    return GridAnimationConfig._(
      (context, index, child) => _GridAnimator(
        duration: duration,
        curve: curve,
        delay: Duration(
          milliseconds: math.min(
            maxStagger.inMilliseconds,
            (index % GridAnimationConstants.staggerModulo) *
                staggerDelay.inMilliseconds,
          ),
        ),
        fadeFrom: fadeFrom,
        scaleFrom: scaleFrom,
        slideOffset: slideOffset,
        child: child,
      ),
    );
  }

  /// Fade-only animation (minimal CPU usage).
  factory GridAnimationConfig.fadeOnly({
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = GridAnimationConstants.subtleCurve,
    Duration staggerDelay = const Duration(milliseconds: 20),
    double fadeFrom = 0.0,
  }) {
    return GridAnimationConfig.pinterest(
      duration: duration,
      curve: curve,
      staggerDelay: staggerDelay,
      fadeFrom: fadeFrom,
      scaleFrom: 1,
      slideOffset: 0,
    );
  }

  /// Scale-only animation (subtle, modern feel).
  factory GridAnimationConfig.scaleOnly({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = GridAnimationConstants.bouncyCurve,
    Duration staggerDelay = const Duration(milliseconds: 30),
    double scaleFrom = GridAnimationConstants.dramaticScaleFrom,
  }) {
    return GridAnimationConfig.pinterest(
      duration: duration,
      curve: curve,
      staggerDelay: staggerDelay,
      fadeFrom: 1,
      scaleFrom: scaleFrom,
      slideOffset: 0,
    );
  }

  /// Slide-only animation (directional, spatial awareness).
  factory GridAnimationConfig.slideOnly({
    Duration duration = GridAnimationConstants.slowDuration,
    Curve curve = GridAnimationConstants.defaultCurve,
    Duration staggerDelay = GridAnimationConstants.staggerDelay,
    double slideOffset = GridAnimationConstants.slideOffsetMedium,
  }) {
    return GridAnimationConfig.pinterest(
      duration: duration,
      curve: curve,
      staggerDelay: staggerDelay,
      fadeFrom: 1,
      scaleFrom: 1,
      slideOffset: slideOffset,
    );
  }


  const GridAnimationConfig._(this._builder);

  final GridItemAnimationBuilder _builder;

  /// Wraps a child widget with the configured animation.
  Widget wrap(BuildContext context, int index, Widget child) =>
      _builder(context, index, child);
}

/// Unified grid item animator supporting fade, scale, and slide effects.
///
/// **Performance optimizations:**
/// - SingleTickerProviderStateMixin for single animation controller
/// - AutomaticKeepAliveClientMixin to preserve state during scrolling
/// - RenderLayer animations (FadeTransition, ScaleTransition, SlideTransition)
/// - Minimal widget rebuilds
/// - Proper disposal to prevent leaks
class _GridAnimator extends StatefulWidget {
  const _GridAnimator({
    required this.duration,
    required this.curve,
    required this.delay,
    required this.fadeFrom,
    required this.scaleFrom,
    required this.slideOffset,
    required this.child,
  });

  final Duration duration;
  final Curve curve;
  final Duration delay;
  final double fadeFrom;
  final double scaleFrom;
  final double slideOffset;
  final Widget child;

  @override
  State<_GridAnimator> createState() => _GridAnimatorState();
}

class _GridAnimatorState extends State<_GridAnimator>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  late final Animation<double>? _opacity;
  late final Animation<double>? _scale;
  late final Animation<Offset>? _slide;

  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curve = CurvedAnimation(parent: _controller, curve: widget.curve);

    // Create animations only if needed (performance optimization)
    _opacity = widget.fadeFrom < 1.0
        ? Tween<double>(begin: widget.fadeFrom, end: 1).animate(_curve)
        : null;

    _scale = widget.scaleFrom < 1.0
        ? Tween<double>(begin: widget.scaleFrom, end: 1).animate(_curve)
        : null;

    _slide = widget.slideOffset > 0
        ? Tween<Offset>(
            begin: Offset(0, widget.slideOffset / 100),
            end: Offset.zero,
          ).animate(_curve)
        : null;

    // Schedule animation start
    if (widget.delay.inMilliseconds > 0) {
      Future<void>.delayed(widget.delay, () async {
        if (mounted && !_hasStarted) {
          _hasStarted = true;
          await _controller.forward();
        }
      });
    } else {
      _hasStarted = true;
      unawaited(_controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    var result = widget.child;

    // Apply transformations in optimal order (inner to outer)
    // 1. Slide (affects position)
    final slide = _slide;
    if (slide != null) {
      result = SlideTransition(position: slide, child: result);
    }

    // 2. Scale (affects size)
    final scale = _scale;
    if (scale != null) {
      result = ScaleTransition(scale: scale, child: result);
    }

    // 3. Fade (affects visibility)
    final opacity = _opacity;
    if (opacity != null) {
      result = FadeTransition(opacity: opacity, child: result);
    }

    return result;
  }

  @override
  bool get wantKeepAlive => true;
}
