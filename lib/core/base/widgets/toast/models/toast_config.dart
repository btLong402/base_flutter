import 'package:base_flutter/core/base/widgets/toast/models/toast_type.dart';
import 'package:flutter/material.dart';

/// Configuration for a toast notification
///
/// **Performance Features:**
/// - Immutable for efficient rebuild detection
/// - Const constructors where possible
/// - Minimal memory footprint
class ToastConfig {
  const ToastConfig({
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.title,
    this.action,
    this.actionLabel,
    this.dismissible = true,
    this.showProgressBar = true,
    this.position = ToastPosition.top,
    this.maxWidth = 600.0,
    this.horizontalPadding = 16.0,
    this.verticalOffset = 50.0,
  });

  /// Factory: Success toast
  factory ToastConfig.success(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? action,
    String? actionLabel,
  }) {
    return ToastConfig(
      message: message,
      title: title,
      type: ToastType.success,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
    );
  }

  /// Factory: Error toast
  factory ToastConfig.error(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? action,
    String? actionLabel,
  }) {
    return ToastConfig(
      message: message,
      title: title,
      type: ToastType.error,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
    );
  }

  /// Factory: Warning toast
  factory ToastConfig.warning(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? action,
    String? actionLabel,
  }) {
    return ToastConfig(
      message: message,
      title: title,
      type: ToastType.warning,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
    );
  }

  /// Factory: Info toast
  factory ToastConfig.info(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? action,
    String? actionLabel,
  }) {
    return ToastConfig(
      message: message,
      title: title,
      type: ToastType.info,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
    );
  }

  /// Primary message text
  final String message;

  /// Optional title (displayed above message)
  final String? title;

  /// Toast type (success, error, warning, info)
  final ToastType type;

  /// Display duration (default: 3 seconds)
  final Duration duration;

  /// Optional action callback
  final VoidCallback? action;

  /// Label for action button
  final String? actionLabel;

  /// Whether user can dismiss by swiping/tapping
  final bool dismissible;

  /// Show animated progress bar
  final bool showProgressBar;

  /// Toast position on screen
  final ToastPosition position;

  /// Maximum width of toast (responsive)
  final double maxWidth;

  /// Horizontal padding from screen edges
  final double horizontalPadding;

  /// Vertical offset from top/bottom
  final double verticalOffset;

  /// Creates a copy with modified properties
  ToastConfig copyWith({
    String? message,
    String? title,
    ToastType? type,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
    bool? dismissible,
    bool? showProgressBar,
    ToastPosition? position,
    double? maxWidth,
    double? horizontalPadding,
    double? verticalOffset,
  }) {
    return ToastConfig(
      message: message ?? this.message,
      title: title ?? this.title,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      action: action ?? this.action,
      actionLabel: actionLabel ?? this.actionLabel,
      dismissible: dismissible ?? this.dismissible,
      showProgressBar: showProgressBar ?? this.showProgressBar,
      position: position ?? this.position,
      maxWidth: maxWidth ?? this.maxWidth,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      verticalOffset: verticalOffset ?? this.verticalOffset,
    );
  }
}

/// Toast position on screen
enum ToastPosition { top, center, bottom }

extension ToastPositionExtension on ToastPosition {
  /// Convert to alignment for positioning
  Alignment get alignment {
    switch (this) {
      case ToastPosition.top:
        return Alignment.topCenter;
      case ToastPosition.center:
        return Alignment.center;
      case ToastPosition.bottom:
        return Alignment.bottomCenter;
    }
  }

  /// Edge insets based on position
  EdgeInsets edgeInsets(double verticalOffset, double horizontalPadding) {
    switch (this) {
      case ToastPosition.top:
        return EdgeInsets.only(
          top: verticalOffset,
          left: horizontalPadding,
          right: horizontalPadding,
        );
      case ToastPosition.center:
        return EdgeInsets.symmetric(horizontal: horizontalPadding);
      case ToastPosition.bottom:
        return EdgeInsets.only(
          bottom: verticalOffset,
          left: horizontalPadding,
          right: horizontalPadding,
        );
    }
  }
}
