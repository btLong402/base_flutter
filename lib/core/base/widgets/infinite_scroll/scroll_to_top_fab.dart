import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Floating action button that appears when user scrolls down,
/// providing a one-tap scroll-to-top action.
///
/// ### Features:
/// - Auto-shows/hides based on scroll offset threshold.
/// - Smooth animated visibility transition.
/// - Uses [ScrollController] listener for efficient tracking.
/// - Customizable icon, position, and appearance.
///
/// ### Usage:
/// ```dart
/// Stack(
///   children: [
///     InfiniteScrollView<Post>(..., scrollController: _scrollCtrl),
///     ScrollToTopFab(controller: _scrollCtrl),
///   ],
/// )
/// ```
class ScrollToTopFab extends StatefulWidget {
  const ScrollToTopFab({
    required this.controller,
    super.key,
    this.showAfterOffset = 400.0,
    this.scrollDuration = const Duration(milliseconds: 400),
    this.alignment = Alignment.bottomRight,
    this.padding = const EdgeInsets.all(16),
    this.mini = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
  });

  /// Scroll controller to monitor and scroll.
  final ScrollController controller;

  /// Minimum scroll offset before the FAB appears.
  final double showAfterOffset;

  /// Duration of the scroll-to-top animation.
  final Duration scrollDuration;

  /// Position within the parent [Stack].
  final Alignment alignment;

  /// Padding from edges.
  final EdgeInsetsGeometry padding;

  /// Whether to use [FloatingActionButton.small].
  final bool mini;

  /// Custom icon. Defaults to [Icons.keyboard_arrow_up].
  final Widget? icon;

  /// FAB background color. Defaults to theme surface variant.
  final Color? backgroundColor;

  /// FAB icon color. Defaults to theme on-surface.
  final Color? foregroundColor;

  /// Hero tag to avoid hero animation conflicts with other FABs.
  final Object? heroTag;

  @override
  State<ScrollToTopFab> createState() => _ScrollToTopFabState();
}

class _ScrollToTopFabState extends State<ScrollToTopFab> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ScrollToTopFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.controller.hasClients) return;

    final position = widget.controller.position;
    final offset = position.pixels;
    final direction = position.userScrollDirection;

    // Show FAB when scrolled past threshold and scrolling up
    final shouldShow =
        offset > widget.showAfterOffset && direction == ScrollDirection.forward;

    // Hide when scrolling down or near top
    final shouldHide =
        offset <= widget.showAfterOffset ||
        direction == ScrollDirection.reverse;

    if (shouldShow && !_visible) {
      setState(() => _visible = true);
    } else if (shouldHide && _visible) {
      setState(() => _visible = false);
    }
  }

  Future<void> _scrollToTop() async {
    developer.log(
      'Scroll to top triggered',
      name: 'infinite_scroll.scroll_to_top',
    );
    await widget.controller.animateTo(
      0,
      duration: widget.scrollDuration,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        widget.backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final fgColor = widget.foregroundColor ?? theme.colorScheme.onSurface;

    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: widget.padding,
        child: AnimatedScale(
          scale: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: FloatingActionButton.small(
              heroTag: widget.heroTag,
              onPressed: _scrollToTop,
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              elevation: 2,
              child:
                  widget.icon ?? const Icon(Icons.keyboard_arrow_up, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
