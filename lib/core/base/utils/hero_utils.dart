import 'package:flutter/material.dart';

/// Utilities for consistent Hero/shared-element transitions.
class HeroUtils {
  const HeroUtils._();

  static String tag(String namespace, Object id) => '$namespace-$id';

  static HeroController createHeroController() => HeroController();

  static Widget hero({
    required String tag,
    required Widget child,
    HeroFlightShuttleBuilder? shuttleBuilder,
    HeroPlaceholderBuilder? placeholderBuilder,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
    Clip clipBehavior = Clip.antiAlias,
  }) {
    final wrappedChild = borderRadius == BorderRadius.zero
        ? child
        : ClipRRect(
            borderRadius: borderRadius,
            clipBehavior: clipBehavior,
            child: child,
          );
    return Hero(
      tag: tag,
      flightShuttleBuilder: shuttleBuilder ?? _fadeShuttle,
      placeholderBuilder: placeholderBuilder ?? _placeholder,
      transitionOnUserGestures: true,
      child: wrappedChild,
    );
  }

  static Widget _placeholder(
    BuildContext context,
    Size heroSize,
    Widget child,
  ) {
    return _HeroPlaceholder(size: heroSize, child: child);
  }

  static Widget _fadeShuttle(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final toHero = toHeroContext.widget as Hero;
    return FadeTransition(opacity: animation, child: toHero.child);
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.size, required this.child});

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: child,
        ),
      ),
    );
  }
}

/// Prefetches an image to avoid flashes during Hero flights.
Future<void> precacheHeroImage(ImageProvider provider, BuildContext context) {
  return precacheImage(provider, context);
}
