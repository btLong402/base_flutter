import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Direction of scroll movement
enum PinterestScrollDirection { idle, forward, reverse }

/// Pinterest-style adaptive cache strategy that adjusts based on scroll
/// velocity, device capabilities, and content complexity.
///
/// **Key features:**
/// - Dynamic cache extent based on scroll speed
/// - Predictive preloading in scroll direction
/// - Memory-aware cache limits
/// - Device capability detection
class AdaptiveCacheStrategy {
  AdaptiveCacheStrategy({
    this.minCacheExtent = 500.0,
    this.maxCacheExtent = 3000.0,
    this.baseMultiplier = 2.0,
    this.velocityThreshold = 300.0,
    this.enablePredictiveLoading = true,
  });

  /// Minimum cache extent (used when scrolling is slow/stopped)
  final double minCacheExtent;

  /// Maximum cache extent (used during fast scrolling)
  final double maxCacheExtent;

  /// Base cache multiplier relative to viewport height
  final double baseMultiplier;

  /// Velocity threshold (pixels/second) to trigger adaptive caching
  final double velocityThreshold;

  /// Enable predictive loading in scroll direction
  final bool enablePredictiveLoading;

  double _lastScrollPosition = 0;
  double _currentVelocity = 0;
  PinterestScrollDirection _scrollDirection = PinterestScrollDirection.idle;
  int _frameCount = 0;

  /// Calculates optimal cache extent based on current scroll metrics.
  ///
  /// **Algorithm:**
  /// 1. Measure scroll velocity
  /// 2. Adjust cache extent proportionally
  /// 3. Bias cache in scroll direction
  /// 4. Respect device memory constraints
  double calculateCacheExtent({
    required ScrollMetrics metrics,
    required double viewportHeight,
  }) {
    _updateScrollMetrics(metrics);

    // Base cache extent
    final baseCacheExtent = viewportHeight * baseMultiplier;

    // Velocity-based adjustment
    final velocityFactor = _calculateVelocityFactor();
    final adaptiveCacheExtent = baseCacheExtent * (1.0 + velocityFactor);

    // Clamp to min/max bounds
    final clampedExtent = adaptiveCacheExtent.clamp(
      minCacheExtent,
      maxCacheExtent,
    );

    return clampedExtent;
  }

  /// Calculates cache bias for directional preloading.
  ///
  /// Returns a value between -1.0 (bias backward) and 1.0 (bias forward).
  /// 0.0 means equal caching in both directions.
  double calculateCacheBias() {
    if (!enablePredictiveLoading) {
      return 0; // Equal distribution
    }

    switch (_scrollDirection) {
      case PinterestScrollDirection.forward:
        // Cache more items ahead
        return 0.6;
      case PinterestScrollDirection.reverse:
        // Cache more items behind
        return -0.6;
      case PinterestScrollDirection.idle:
        return 0;
    }
  }

  void _updateScrollMetrics(ScrollMetrics metrics) {
    _frameCount++;

    final currentPosition = metrics.pixels;
    final delta = currentPosition - _lastScrollPosition;

    // Update scroll direction
    if (delta > 0.5) {
      _scrollDirection = PinterestScrollDirection.forward;
    } else if (delta < -0.5) {
      _scrollDirection = PinterestScrollDirection.reverse;
    } else if (_frameCount > 10) {
      // Reset to idle after several frames with no movement
      _scrollDirection = PinterestScrollDirection.idle;
      _frameCount = 0;
    }

    // Estimate velocity (simplified)
    _currentVelocity = delta.abs() * 60.0; // Approximate fps multiplication

    _lastScrollPosition = currentPosition;
  }

  double _calculateVelocityFactor() {
    if (_currentVelocity < velocityThreshold) {
      return 0; // No extra caching
    }

    // Linear scaling: 0.0 at threshold, 1.0 at 2x threshold
    final factor = ((_currentVelocity - velocityThreshold) / velocityThreshold)
        .clamp(0.0, 1.0);

    return factor;
  }

  /// Resets internal state (useful when scroll controller changes)
  void reset() {
    _lastScrollPosition = 0.0;
    _currentVelocity = 0.0;
    _scrollDirection = PinterestScrollDirection.idle;
    _frameCount = 0;
  }
}

/// Device capability detector for optimal cache sizing
class DeviceCapabilityDetector {
  DeviceCapabilityDetector._();

  static DeviceCapabilityLevel detect() {
    // In a real implementation, you would:
    // 1. Check device memory
    // 2. Measure actual rendering performance
    // 3. Detect device type (phone, tablet, desktop)

    if (kIsWeb) {
      return DeviceCapabilityLevel.medium;
    }

    // For now, use platform heuristics
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      // Mobile devices - conservative caching
      return DeviceCapabilityLevel.medium;
    }

    // Desktop/other - more aggressive caching
    return DeviceCapabilityLevel.high;
  }

  /// Returns recommended cache multiplier based on device capability
  static double getRecommendedCacheMultiplier(DeviceCapabilityLevel level) {
    switch (level) {
      case DeviceCapabilityLevel.low:
        return 1.5;
      case DeviceCapabilityLevel.medium:
        return 2;
      case DeviceCapabilityLevel.high:
        return 3;
    }
  }

  /// Returns recommended max cache extent based on device capability
  static double getRecommendedMaxCacheExtent(DeviceCapabilityLevel level) {
    switch (level) {
      case DeviceCapabilityLevel.low:
        return 2000;
      case DeviceCapabilityLevel.medium:
        return 3000;
      case DeviceCapabilityLevel.high:
        return 5000;
    }
  }
}

enum DeviceCapabilityLevel { low, medium, high }

/// Scroll metrics wrapper for easier testing and mocking
class ScrollMetricsSnapshot {
  const ScrollMetricsSnapshot({
    required this.pixels,
    required this.minScrollExtent,
    required this.maxScrollExtent,
    required this.viewportDimension,
    required this.axisDirection,
  });

  factory ScrollMetricsSnapshot.fromMetrics(ScrollMetrics metrics) {
    return ScrollMetricsSnapshot(
      pixels: metrics.pixels,
      minScrollExtent: metrics.minScrollExtent,
      maxScrollExtent: metrics.maxScrollExtent,
      viewportDimension: metrics.viewportDimension,
      axisDirection: metrics.axisDirection,
    );
  }

  final double pixels;
  final double minScrollExtent;
  final double maxScrollExtent;
  final double viewportDimension;
  final AxisDirection axisDirection;
}

/// Predictive preloader that loads content ahead of scroll position
class PredictivePreloader {
  PredictivePreloader({
    this.lookaheadFactor = 1.5,
    this.minLookahead = 5,
    this.maxLookahead = 20,
  });

  /// How many viewport heights to look ahead
  final double lookaheadFactor;

  /// Minimum number of items to preload
  final int minLookahead;

  /// Maximum number of items to preload
  final int maxLookahead;

  /// Calculates how many items to preload based on current state
  int calculatePreloadCount({
    required double velocity,
    required int itemsPerViewport,
    required PinterestScrollDirection direction,
  }) {
    if (direction == PinterestScrollDirection.idle) {
      return minLookahead;
    }

    // Scale preload count based on velocity
    final velocityScale = (velocity / 1000.0).clamp(0.0, 1.0);
    final baseCount = itemsPerViewport * lookaheadFactor;
    final scaledCount = (baseCount * (1.0 + velocityScale)).round();

    return scaledCount.clamp(minLookahead, maxLookahead);
  }
}
