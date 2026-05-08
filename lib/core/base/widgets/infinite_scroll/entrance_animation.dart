import 'dart:async';

import 'package:base_flutter/core/base/widgets/infinite_scroll/performance_utils.dart';
import 'package:flutter/material.dart';

/// Lightweight entrance animation for list/grid items.
///
/// Uses explicit `AnimationController` with fade + scale transition.
/// Animation runs once on mount, then controller is disposed.
///
/// ### Performance:
/// - Single-pass animation, no repeated rebuilds
/// - Constants-driven from [InfiniteScrollDefaults]
/// - Opacity: 0.6 → 1.0, Scale: 0.94 → 1.0
/// - Duration: 200ms with easeOut curve
class EntranceAnimation extends StatefulWidget {
  const EntranceAnimation({required this.child, super.key});

  final Widget child;

  @override
  State<EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<EntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: InfiniteScrollDefaults.entranceAnimationDuration,
    );

    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _opacity = Tween<double>(
      begin: InfiniteScrollDefaults.entranceOpacityStart,
      end: InfiniteScrollDefaults.entranceOpacityEnd,
    ).animate(curve);

    _scale = Tween<double>(
      begin: InfiniteScrollDefaults.entranceScaleStart,
      end: InfiniteScrollDefaults.entranceScaleEnd,
    ).animate(curve);

    unawaited(_controller.forward());
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
