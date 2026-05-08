import 'package:flutter/widgets.dart';

/// Coordinates lifecycle animations for grid items (appear, update, disappear).
///
/// **Purpose:**
/// - Manages staggered animations across multiple items
/// - Ensures proper sequencing and cleanup
/// - Prevents animation conflicts
/// - Provides consistent timing across the grid
///
/// **Performance Optimizations:**
/// - Automatic cleanup of completed animations
/// - Bounded animation tracking to prevent memory leaks
/// - Configurable max concurrent animations
/// - Efficient state lookup with Map
///
/// **Usage:**
/// ```dart
/// final coordinator = GridTransitionCoordinator();
///
/// // When item appears
/// coordinator.registerItemAppearance(index);
///
/// // When item disappears
/// coordinator.registerItemDisappearance(index, onComplete: () {
///   // Remove from list
/// });
/// ```
class GridTransitionCoordinator {
  GridTransitionCoordinator({
    this.staggerDelay = const Duration(milliseconds: 25),
    this.maxConcurrentAnimations = 20,
    this.maxTrackedAnimations = 100,
  });

  final Duration staggerDelay;
  final int maxConcurrentAnimations;

  /// Maximum number of animations to track (prevents memory leaks)
  final int maxTrackedAnimations;

  final Map<int, GridItemAnimationState> _activeAnimations = {};
  int _animationSequence = 0;

  /// Registers an item appearance and returns its animation delay
  Duration registerItemAppearance(int index) {
    // PERFORMANCE: Clean up old animations before adding new ones
    _cleanupOldAnimations();

    final state = GridItemAnimationState(
      index: index,
      type: GridItemAnimationType.appear,
      sequence: _animationSequence++,
    );

    _activeAnimations[index] = state;

    // Calculate stagger delay based on position in sequence
    final delay = staggerDelay * (state.sequence % maxConcurrentAnimations);

    return delay;
  }

  /// Registers an item disappearance
  void registerItemDisappearance(int index, {VoidCallback? onComplete}) {
    final state = GridItemAnimationState(
      index: index,
      type: GridItemAnimationType.disappear,
      sequence: _animationSequence++,
      onComplete: onComplete,
    );

    _activeAnimations[index] = state;

    // Schedule cleanup
    Future.delayed(const Duration(milliseconds: 300), () {
      _activeAnimations.remove(index);
      onComplete?.call();
    });
  }

  /// Registers an item update (e.g., size change)
  void registerItemUpdate(int index) {
    final state = GridItemAnimationState(
      index: index,
      type: GridItemAnimationType.update,
      sequence: _animationSequence++,
    );

    _activeAnimations[index] = state;

    // Cleanup after animation
    Future.delayed(const Duration(milliseconds: 250), () {
      _activeAnimations.remove(index);
    });
  }

  /// PERFORMANCE: Cleanup old completed animations to prevent memory leaks
  void _cleanupOldAnimations() {
    if (_activeAnimations.length <= maxTrackedAnimations) {
      return;
    }

    // Remove oldest animations that have likely completed
    final sortedKeys = _activeAnimations.keys.toList()..sort();
    final removeCount = _activeAnimations.length - (maxTrackedAnimations ~/ 2);

    for (var i = 0; i < removeCount && i < sortedKeys.length; i++) {
      _activeAnimations.remove(sortedKeys[i]);
    }
  }

  /// Checks if item is currently animating
  bool isAnimating(int index) {
    return _activeAnimations.containsKey(index);
  }

  /// Gets current animation state for item
  GridItemAnimationState? getAnimationState(int index) {
    return _activeAnimations[index];
  }

  /// Clears all animation states
  void reset() {
    _activeAnimations.clear();
    _animationSequence = 0;
  }

  /// Clears animation state for specific item
  void clearItemState(int index) {
    _activeAnimations.remove(index);
  }

  /// Gets count of currently active animations
  int get activeAnimationCount => _activeAnimations.length;
}

/// State of an item's animation
class GridItemAnimationState {
  const GridItemAnimationState({
    required this.index,
    required this.type,
    required this.sequence,
    this.onComplete,
  });

  final int index;
  final GridItemAnimationType type;
  final int sequence;
  final VoidCallback? onComplete;
}

enum GridItemAnimationType { appear, disappear, update }

/// Widget that integrates with GridTransitionCoordinator for managed animations
///
/// **Performance Optimizations:**
/// - Single AnimationController per item
/// - Child parameter in animations to prevent rebuilds
/// - Automatic disposal and cleanup
/// - Configurable animation layers
class CoordinatedGridItem extends StatefulWidget {
  const CoordinatedGridItem({
    required this.index,
    required this.coordinator,
    required this.child,
    super.key,
    this.appearDuration = const Duration(milliseconds: 280),
    this.appearCurve = Curves.easeOutCubic,
    this.enableFade = true,
    this.enableScale = true,
    this.enableSlide = true,
  });

  final int index;
  final GridTransitionCoordinator coordinator;
  final Widget child;
  final Duration appearDuration;
  final Curve appearCurve;
  final bool enableFade;
  final bool enableScale;
  final bool enableSlide;

  @override
  State<CoordinatedGridItem> createState() => _CoordinatedGridItemState();
}

class _CoordinatedGridItemState extends State<CoordinatedGridItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _hasRegistered = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.appearDuration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.appearCurve,
    );

    // Register with coordinator and get delay
    final delay = widget.coordinator.registerItemAppearance(widget.index);
    _hasRegistered = true;

    // Start animation after delay
    // PERFORMANCE: Use post-frame callback to avoid layout conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(delay, () async {
        if (mounted) {
          await _controller.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    if (_hasRegistered) {
      widget.coordinator.clearItemState(widget.index);
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PERFORMANCE: Build widget tree once, use child parameter in transitions
    var result = widget.child;

    // Apply transformations based on configuration
    // PERFORMANCE: Only create transition widgets that are enabled
    if (widget.enableSlide) {
      result = SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(_animation),
        child: result,
      );
    }

    if (widget.enableScale) {
      result = ScaleTransition(
        scale: Tween<double>(begin: 0.94, end: 1).animate(_animation),
        child: result,
      );
    }

    if (widget.enableFade) {
      result = FadeTransition(opacity: _animation, child: result);
    }

    return result;
  }
}
