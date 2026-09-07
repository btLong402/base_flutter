import 'dart:async';

import 'package:flutter/material.dart';

/// High-performance native Shimmer widget built with Flutter's [ShaderMask].
///
/// Features:
/// - **Zero External Dependencies**: 100% native Flutter framework.
/// - **Hardware Accelerated**: Shader runs directly on GPU (Impeller / Skia).
/// - **Natural Diagonal Sweep**: Sweeps smoothly at a gentle 15-degree angle.
/// - **Theme Adaptive**: Automatic light/dark palette matching.
/// - **Repaint Isolated**: Wrapped in [RepaintBoundary] to protect parent trees.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    required this.child,
    super.key,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeInOutSine,
    this.enabled = true,
  });

  /// Factory constructor matching `package:shimmer` API for drop-in replacement.
  const AppShimmer.fromColors({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    super.key,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeInOutSine,
    this.enabled = true,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final Curve curve;
  final bool enabled;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.enabled) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void didUpdateWidget(covariant AppShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        unawaited(_controller.repeat());
      } else {
        _controller
          ..stop()
          ..reset();
      }
    }
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final base = widget.baseColor ??
        (isDark ? const Color(0xFF24262B) : const Color(0xFFE8EAEF));
    final highlight = widget.highlightColor ??
        (isDark ? const Color(0xFF383C44) : const Color(0xFFF7F8FA));

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final curvedProgress = widget.curve.transform(_controller.value);

          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: const Alignment(-1, -0.3),
                end: const Alignment(1, 0.3),
                colors: [base, highlight, base],
                stops: const [0, 0.5, 1],
                transform: _SlidingGradientTransform(slidePercent: curvedProgress),
              ).createShader(bounds);
            },
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final translationX = bounds.width * (slidePercent * 3 - 1.5);
    return Matrix4.translationValues(translationX, 0, 0);
  }
}
