import 'package:flutter/material.dart';

import 'package:base_flutter/core/base/theme/app_colors.dart';
import 'package:base_flutter/core/base/theme/app_text_styles.dart';

/// Enum for FAB size variants
enum AppFabSize { standard, small, extended }

/// Reusable Floating Action Button (FAB) Widget
///
/// Follows Project Rules:
/// - Rule 04: Consistent design tokens (AppColors, AppInset)
/// - Rule 07: Performance optimized (StatelessWidget)
/// - WOW Aesthetics: Premium shadows and smooth shapes
class AppFab extends StatelessWidget {
  const AppFab({
    required this.onPressed,
    super.key,
    this.icon = Icons.add,
    this.label,
    this.size = AppFabSize.standard,
    this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.heroTag,
    this.tooltip,
  }) : assert(
         size != AppFabSize.extended || label != null,
         'Extended FAB requires a label',
       );

  /// Standard variant factory
  factory AppFab.standard({
    required VoidCallback onPressed,
    Key? key,
    IconData icon = Icons.add,
    Color? backgroundColor,
    Object? heroTag,
    String? tooltip,
  }) {
    return AppFab(
      key: key,
      onPressed: onPressed,
      icon: icon,
      backgroundColor: backgroundColor,
      heroTag: heroTag,
      tooltip: tooltip,
    );
  }

  /// Small variant factory
  factory AppFab.small({
    required VoidCallback onPressed,
    Key? key,
    IconData icon = Icons.add,
    Color? backgroundColor,
    Object? heroTag,
    String? tooltip,
  }) {
    return AppFab(
      onPressed: onPressed,
      key: key,
      icon: icon,
      size: AppFabSize.small,
      backgroundColor: backgroundColor,
      heroTag: heroTag,
      tooltip: tooltip,
    );
  }

  /// Extended variant factory (Icon + Label)
  factory AppFab.extended({
    required VoidCallback onPressed,
    required String label,
    Key? key,
    IconData icon = Icons.add,
    Color? backgroundColor,
    Object? heroTag,
    String? tooltip,
  }) {
    return AppFab(
      onPressed: onPressed,
      label: label,
      key: key,
      icon: icon,
      size: AppFabSize.extended,
      backgroundColor: backgroundColor,
      heroTag: heroTag,
      tooltip: tooltip,
    );
  }

  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final AppFabSize size;
  final Color? backgroundColor;
  final Color foregroundColor;
  final Object? heroTag;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final shape = size == AppFabSize.extended
        ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
        : const CircleBorder();

    switch (size) {
      case AppFabSize.small:
        return FloatingActionButton.small(
          onPressed: onPressed,
          backgroundColor: bgColor,
          foregroundColor: foregroundColor,
          heroTag: heroTag,
          tooltip: tooltip,
          shape: shape,
          child: Icon(icon),
        );
      case AppFabSize.extended:
        return FloatingActionButton.extended(
          onPressed: onPressed,
          backgroundColor: bgColor,
          foregroundColor: foregroundColor,
          heroTag: heroTag,
          tooltip: tooltip,
          shape: shape,
          icon: Icon(icon),
          label: Text(
            label!,
            style: AppTextStyles.labelLarge.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case AppFabSize.standard:
        return FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: bgColor,
          foregroundColor: foregroundColor,
          heroTag: heroTag,
          tooltip: tooltip,
          shape: shape,
          child: Icon(icon),
        );
    }
  }
}
