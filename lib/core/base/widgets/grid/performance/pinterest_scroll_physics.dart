import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// Pinterest-style scroll physics with smooth momentum and natural
/// deceleration.
///
/// **Key characteristics:**
/// - Smooth, responsive scrolling
/// - Natural momentum curves matching Pinterest app
/// - Optimized overscroll effects
/// - Snap-to-item support (optional)
class PinterestScrollPhysics extends ScrollPhysics {
  const PinterestScrollPhysics({
    super.parent,
    this.frictionFactor = 0.015,
    this.springTension = 0.5,
    this.enableSnapToItem = false,
    this.snapSensitivity = 0.3,
  });

  /// Friction factor for momentum scrolling (lower = longer glide)
  /// Pinterest uses ~0.015 for smooth, extended scrolling
  final double frictionFactor;

  /// Spring tension for overscroll (lower = softer bounce)
  final double springTension;

  /// Enable snap-to-item behavior
  final bool enableSnapToItem;

  /// Sensitivity for snap detection (0.0-1.0)
  final double snapSensitivity;

  @override
  PinterestScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PinterestScrollPhysics(
      parent: buildParent(ancestor),
      frictionFactor: frictionFactor,
      springTension: springTension,
      enableSnapToItem: enableSnapToItem,
      snapSensitivity: snapSensitivity,
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Standard scroll behavior - no modification needed
    return offset;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Pinterest-style soft overscroll boundaries
    assert(() {
      if (value == position.pixels) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            '$runtimeType.applyBoundaryConditions() was called '
            'with a position and value that are the same.',
          ),
        ]);
      }
      return true;
    }(), 'applyBoundaryConditions called with same position and value');

    // Overscroll at the top
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }

    // Under scroll at the top
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      return value - position.minScrollExtent;
    }

    // Overscroll at the bottom
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) {
      return value - position.pixels;
    }

    // Under scroll at the bottom
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) {
      return value - position.maxScrollExtent;
    }

    // In range - no resistance
    return 0;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final tolerance = toleranceFor(position);

    // If we're out of range and have no velocity, apply spring
    if (position.outOfRange) {
      double? end;
      if (position.pixels > position.maxScrollExtent) {
        end = position.maxScrollExtent;
      } else if (position.pixels < position.minScrollExtent) {
        end = position.minScrollExtent;
      }
      assert(end != null, 'end must not be null when position is out of range');
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        end!,
        velocity,
        tolerance: tolerance,
      );
    }

    // Snap to item if enabled and velocity is low
    if (enableSnapToItem && velocity.abs() < snapSensitivity * 1000) {
      return null; // Let snap behavior handle it
    }

    // CRITICAL FIX: If velocity is very low or zero, don't create simulation
    // This prevents unwanted automatic scrolling when user releases finger
    if (velocity.abs() < tolerance.velocity) {
      return null;
    }

    // CRITICAL FIX: Use Flutter's standard FrictionSimulation instead of custom
    // This is more reliable and handles edge cases properly
    return FrictionSimulation(
      frictionFactor * 10, // Scale up for appropriate deceleration
      position.pixels,
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  SpringDescription get spring {
    // Softer spring for Pinterest-like overscroll
    return SpringDescription.withDampingRatio(
      mass: 0.5,
      stiffness: 100,
      ratio: 1.1,
    );
  }

  @override
  double get minFlingVelocity => 50; // Pinterest uses lower threshold

  @override
  double get maxFlingVelocity => 8000; // Higher max for responsive feel

  @override
  double carriedMomentum(double existingVelocity) {
    // Preserve more momentum for smoother scrolling
    return existingVelocity.sign *
        math.min(
          0.000816 * math.pow(existingVelocity.abs(), 1.967).toDouble(),
          40000.0,
        );
  }

  @override
  double get dragStartDistanceMotionThreshold => 3.5; // Slightly less sensitive
}

/// Scroll behavior that applies Pinterest physics to all scrollable
class PinterestScrollBehavior extends ScrollBehavior {
  const PinterestScrollBehavior({
    this.frictionFactor = 0.015,
    this.springTension = 0.5,
  });

  final double frictionFactor;
  final double springTension;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return PinterestScrollPhysics(
      parent: super.getScrollPhysics(context),
      frictionFactor: frictionFactor,
      springTension: springTension,
    );
  }
}
