// Pinterest-style Grid Performance Optimizations
//
// This file exports all Pinterest-optimized components for easy access.
//
// Usage:
// import 'package:base_flutter/core/widgets/grid/pinterest.dart';

// Pinterest-style animations
export 'animation/grid_animation_config.dart';
export 'animation/grid_transition_coordinator.dart';
export 'animation/pinterest_animation.dart';
// Core grid widgets
export 'grid.dart';
// Layout configurations
export 'layout/grid_layout_config.dart';
// Performance optimizations
export 'performance/adaptive_cache_strategy.dart';
export 'performance/pinterest_scroll_physics.dart';

/// Quick start example:
///
/// ```dart
/// import 'package:base_flutter/core/widgets/grid/pinterest.dart';
///
/// // Basic Pinterest-style grid
/// AdvancedGridView.builder(
///   physics: const PinterestScrollPhysics(),
///   layout: MasonryGridLayout(
///     columnCount: 2,
///     mainAxisSpacing: 8,
///     crossAxisSpacing: 8,
///   ),
///   animation: GridAnimationConfig.pinterest(),
///   itemCount: 100,
///   itemBuilder: (context, index) => MyCard(index),
/// )
///
/// // With adaptive caching
/// final cacheStrategy = AdaptiveCacheStrategy();
///
/// AdvancedGridView.builder(
///   controller: scrollController,
///   physics: const PinterestScrollPhysics(),
///   cacheExtent: cacheStrategy.calculateCacheExtent(
///     metrics: scrollController.position,
///     viewportHeight: screenHeight,
///   ),
///   layout: MasonryGridLayout(columnCount: 2),
///   animation: GridAnimationConfig.pinterest(),
///   itemCount: items.length,
///   itemBuilder: (context, index) => ItemCard(items[index]),
/// )
/// ```
