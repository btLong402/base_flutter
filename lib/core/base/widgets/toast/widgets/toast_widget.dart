import 'dart:async';
import 'package:base_flutter/core/base/widgets/toast/models/toast_config.dart';
import 'package:base_flutter/core/base/widgets/toast/widgets/toast_body.dart';
import 'package:flutter/material.dart';

/// High-performance toast widget with smooth animations and swipe-to-dismiss
///
/// **Performance Optimizations:**
/// - Uses AnimatedBuilder with child parameter to prevent rebuilds
/// - RepaintBoundary to isolate repaints
/// - Const constructors where possible
/// - Hardware-accelerated transforms (GPU-accelerated)
/// - Efficient gesture detection with GestureDetector
/// - Optimized animation curves for 60 FPS
/// - Multi-directional swipe-to-dismiss (horizontal and vertical)
/// - Smooth fade, slide, and scale animations
///
/// **Features:**
/// - Swipe horizontally or vertically to dismiss
/// - Tap anywhere on toast to dismiss
/// - Automatic resistance when dragging beyond threshold
/// - Direction-aware dismiss animations
/// - Progress bar showing remaining time
/// - Responsive across all screen sizes
class ToastWidget extends StatefulWidget {
  const ToastWidget({
    required this.config,
    required this.onDismiss,
    super.key,
    this.animationDuration = const Duration(milliseconds: 350),
  });

  final ToastConfig config;
  final VoidCallback onDismiss;
  final Duration animationDuration;

  @override
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  // Separate controller for rest animation to avoid ticker conflicts
  AnimationController? _restController;
  Animation<Offset>? _restAnimation;

  bool _isExiting = false;
  double _dragOffsetX = 0;
  double _dragOffsetY = 0;
  bool _isDragging = false;

  // Thresholds for swipe-to-dismiss
  static const double _dismissThresholdX = 100;
  static const double _dismissThresholdY = 80;
  static const double _maxDragExtent = 150;

  @override
  void initState() {
    super.initState();

    // Single controller for all animations
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // Slide animation with smooth easing
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Fade animation with faster curve
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
        reverseCurve: const Interval(0.4, 1, curve: Curves.easeIn),
      ),
    );

    // Scale animation for subtle zoom effect
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.8, curve: Curves.easeOutBack),
        reverseCurve: Curves.easeInCubic,
      ),
    );

    // Start entrance animation
    unawaited(_controller.forward());

    // Auto-dismiss after duration
    if (widget.config.duration != Duration.zero) {
      Future.delayed(
        widget.config.duration + widget.animationDuration,
        () async {
          if (mounted && !_isExiting) {
            await _dismiss();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _restController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_isExiting) return;

    setState(() => _isExiting = true);
    await _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  void _handlePanStart(DragStartDetails details) {
    if (!widget.config.dismissible || _isExiting) return;
    setState(() => _isDragging = true);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.config.dismissible || _isExiting) return;

    setState(() {
      // Allow both horizontal and vertical swipes
      _dragOffsetX += details.delta.dx;
      _dragOffsetY += details.delta.dy;

      // Clamp drag offsets to max extent with resistance
      _dragOffsetX = _applyResistance(_dragOffsetX, _maxDragExtent);
      _dragOffsetY = _applyResistance(_dragOffsetY, _maxDragExtent);
    });
  }

  Future<void> _handlePanEnd(DragEndDetails details) async {
    if (!widget.config.dismissible || _isExiting) return;

    final velocity = details.velocity.pixelsPerSecond;
    final shouldDismiss = _shouldDismissFromDrag(velocity);

    setState(() => _isDragging = false);

    if (shouldDismiss) {
      await _dismissWithDirection();
    } else {
      // Animate back to original position
      await _animateToRest();
    }
  }

  Future<void> _handlePanCancel() async {
    if (!widget.config.dismissible || _isExiting) return;
    setState(() => _isDragging = false);
    await _animateToRest();
  }

  /// Apply resistance to drag beyond threshold
  double _applyResistance(double offset, double maxExtent) {
    if (offset.abs() <= maxExtent) return offset;

    // Apply exponential resistance
    final excess = offset.abs() - maxExtent;
    final resistance = maxExtent + (excess * 0.3);
    return offset.sign * resistance;
  }

  /// Check if drag should trigger dismiss
  bool _shouldDismissFromDrag(Offset velocity) {
    // Check horizontal swipe
    if (_dragOffsetX.abs() >= _dismissThresholdX || velocity.dx.abs() > 500) {
      return true;
    }

    // Check vertical swipe
    if (_dragOffsetY.abs() >= _dismissThresholdY || velocity.dy.abs() > 500) {
      return true;
    }

    return false;
  }

  /// Dismiss with direction-based animation
  Future<void> _dismissWithDirection() async {
    if (_isExiting) return; // Prevent duplicate dismiss calls

    setState(() => _isExiting = true);

    // Determine dismiss direction
    final isHorizontal = _dragOffsetX.abs() > _dragOffsetY.abs();

    // Animate to off-screen
    final targetX = isHorizontal ? _dragOffsetX.sign * 500 : _dragOffsetX;
    final targetY = !isHorizontal ? _dragOffsetY.sign * 500 : _dragOffsetY;

    // Smooth transition to target
    final begin = Offset(_dragOffsetX, _dragOffsetY);
    final end = Offset(targetX, targetY);

    final offsetTween = Tween<Offset>(begin: begin, end: end);
    final animation = offsetTween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Listen to animation updates
    void listener() {
      if (mounted && !_controller.isDismissed) {
        setState(() {
          _dragOffsetX = animation.value.dx;
          _dragOffsetY = animation.value.dy;
        });
      }
    }

    animation.addListener(listener);

    // Ensure controller is in valid state before reversing
    if (_controller.status == AnimationStatus.completed ||
        _controller.status == AnimationStatus.forward) {
      await _controller.reverse().then((_) {
        animation.removeListener(listener);
        if (mounted) {
          widget.onDismiss();
        }
      });
    } else {
      // Controller not in valid state, dismiss immediately
      animation.removeListener(listener);
      if (mounted) {
        widget.onDismiss();
      }
    }
  }

  /// Animate back to rest position
  Future<void> _animateToRest() async {
    if (_isExiting) return; // Don't animate if already exiting

    // Clean up any existing rest animation
    _restController?.dispose();
    _restController = null;
    _restAnimation = null;

    final begin = Offset(_dragOffsetX, _dragOffsetY);
    const end = Offset.zero;

    final offsetTween = Tween<Offset>(begin: begin, end: end);
    _restController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _restAnimation = offsetTween.animate(
      CurvedAnimation(parent: _restController!, curve: Curves.easeOutCubic),
    );

    void listener() {
      if (mounted && !_isExiting && _restAnimation != null) {
        setState(() {
          _dragOffsetX = _restAnimation!.value.dx;
          _dragOffsetY = _restAnimation!.value.dy;
        });
      }
    }

    _restAnimation!.addListener(listener);

    await _restController!.forward().then((_) {
      if (mounted && !_isExiting) {
        _restAnimation?.removeListener(listener);
        _restController?.dispose();
        _restController = null;
        _restAnimation = null;

        setState(() {
          _dragOffsetX = 0.0;
          _dragOffsetY = 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    // PERFORMANCE: Calculate offset direction based on position
    final offsetDirection = config.position == ToastPosition.top ? -1.0 : 1.0;

    return Positioned.fill(
      child: Align(
        alignment: config.position.alignment,
        child: Padding(
          padding: config.position.edgeInsets(
            config.verticalOffset,
            config.horizontalPadding,
          ),
          child: GestureDetector(
            // PERFORMANCE: Enable swipe-to-dismiss with pan gestures
            onPanStart: widget.config.dismissible ? _handlePanStart : null,
            onPanUpdate: widget.config.dismissible ? _handlePanUpdate : null,
            onPanEnd: widget.config.dismissible ? _handlePanEnd : null,
            onPanCancel: widget.config.dismissible ? _handlePanCancel : null,
            // Tap to dismiss
            onTap: widget.config.dismissible
                ? () async {
                    if (!_isExiting) await _dismiss();
                  }
                : null,
            child: AnimatedBuilder(
              animation: _slideAnimation,
              // PERFORMANCE: Child parameter prevents rebuilding content
              child: ToastBody(
                config: config,
                onDismiss: widget.config.dismissible ? _dismiss : null,
                onAction: config.action,
              ),
              builder: (context, child) {
                // Calculate slide offset based on animation progress
                final slideValue = _slideAnimation.value;
                final fadeValue = _fadeAnimation.value;
                final scaleValue = _scaleAnimation.value;

                // Entrance/exit animation offset
                final animationYOffset =
                    (1 - slideValue) * 100 * offsetDirection;

                // Combined offset with drag
                final totalOffsetX = _dragOffsetX * slideValue;
                final totalOffsetY =
                    animationYOffset + (_dragOffsetY * slideValue);

                // Calculate rotation based on horizontal drag
                final rotation = (_dragOffsetX / 500) * 0.05;

                // Apply slight scale down when dragging for visual feedback
                final dragScale = _isDragging ? 0.98 : 1.0;
                final finalScale = scaleValue * dragScale;

                // Calculate opacity with clamping to prevent invalid values
                // As user drags, opacity reduces based on drag distance
                final dragOpacityFactor = (1 - (_dragOffsetX.abs() / 300))
                    .clamp(0.0, 1.0);
                final finalOpacity = (fadeValue * dragOpacityFactor).clamp(
                  0.0,
                  1.0,
                );

                // PERFORMANCE: Use Transform for GPU-accelerated animations
                return Transform.translate(
                  offset: Offset(totalOffsetX, totalOffsetY),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: finalScale,
                      child: Opacity(opacity: finalOpacity, child: child),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
