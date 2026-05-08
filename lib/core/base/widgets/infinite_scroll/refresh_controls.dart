import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// ## Refresh Control Wrappers
///
/// Provides platform-appropriate pull-to-refresh implementations:
/// - **Material**: RefreshIndicator for Android/Web/Desktop
/// - **Cupertino**: CupertinoSliverRefreshControl for iOS (sliver-based)
///
/// ### Usage Patterns:
///
/// **Material (ListView/GridView):**
/// ```dart
/// MaterialRefreshWrapper(
///   onRefresh: controller.refresh,
///   child: ListView(...),
/// )
/// ```
///
/// **Cupertino (CustomScrollView):**
/// ```dart
/// CustomScrollView(
///   slivers: [
///     CupertinoSliverRefreshWrapper(onRefresh: controller.refresh),
///     SliverList(...),
///   ],
/// )
/// ```

import 'package:base_flutter/core/base/theme/app_colors.dart';

/// Material-style refresh control used for non-sliver lists.
///
/// Wraps [RefreshIndicator] with consistent styling and semantics.
class MaterialRefreshWrapper extends StatelessWidget {
  const MaterialRefreshWrapper({
    required this.onRefresh,
    required this.child,
    super.key,
    this.color,
    this.backgroundColor,
    this.displacement,
    this.strokeWidth,
    this.semanticsLabel,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;
  final double? displacement;
  final double? strokeWidth;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: color ?? AppColors.primary,
      backgroundColor: backgroundColor ?? Colors.white,
      displacement: displacement ?? 20,
      strokeWidth: strokeWidth ?? 2.5,
      semanticsLabel: semanticsLabel,
      onRefresh: onRefresh,
      child: child,
    );
  }
}

/// Cupertino-style pull-to-refresh control for sliver usage.
class CupertinoSliverRefreshWrapper extends StatelessWidget {
  const CupertinoSliverRefreshWrapper({required this.onRefresh, super.key});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(onRefresh: onRefresh);
  }
}

/// Platform-adaptive refresh wrapper.
///
/// Uses [RefreshIndicator.adaptive] which automatically switches between:
/// - **iOS/macOS**: Cupertino-style spinner.
/// - **Android/Web/Desktop**: Material-style spinner with brand colors.
///
/// Set [edgeOffset] to push the spinner below a pinned SliverAppBar.
class AdaptiveRefreshWrapper extends StatelessWidget {
  const AdaptiveRefreshWrapper({
    required this.onRefresh,
    required this.slivers,
    super.key,
    this.scrollController,
    this.physics,
    this.semanticsLabel,
    this.edgeOffset = 0,
  });

  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final String? semanticsLabel;

  /// Offset where the refresh indicator starts to appear.
  /// Set this to the height of your pinned SliverAppBar.
  final double edgeOffset;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isApple =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    final effectivePhysics =
        physics ??
        (isApple
            ? const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              )
            : const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ));

    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      edgeOffset: edgeOffset,
      semanticsLabel: semanticsLabel,
      child: CustomScrollView(
        controller: scrollController,
        physics: effectivePhysics,
        slivers: slivers,
      ),
    );
  }
}
