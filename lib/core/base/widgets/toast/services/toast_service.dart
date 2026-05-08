import 'dart:async';

import 'package:base_flutter/core/base/utils/app_haptics.dart';
import 'package:base_flutter/core/base/widgets/toast/controller/toast_controller.dart';
import 'package:base_flutter/core/base/widgets/toast/models/toast_config.dart';
import 'package:flutter/material.dart';

/// Toast service providing static methods for easy access
///
/// **Usage:**
/// ```dart
/// // Show success toast
/// ToastService.success(context, 'File saved successfully!');
///
/// // Show error toast
/// ToastService.error(context, 'Failed to upload file');
///
/// // Custom toast
/// ToastService.show(
///   context,
///   ToastConfig(
///     message: 'Custom message',
///     type: ToastType.info,
///     duration: Duration(seconds: 5),
///   ),
/// );
/// ```
class ToastService {
  ToastService._();

  static final ToastController _controller = ToastController.instance;

  /// Show a custom toast
  static void show(ToastConfig config, {BuildContext? context}) {
    _controller.show(config, context: context);
  }

  /// Show success toast
  static void success(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
    bool haptic = true,
  }) {
    if (haptic) unawaited(AppHaptics.success());
    _controller.show(
      ToastConfig.success(
        message,
        title: title,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        actionLabel: actionLabel,
      ),
      context: context,
    );
  }

  /// Show error toast
  static void error(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
    bool haptic = true,
  }) {
    if (haptic) unawaited(AppHaptics.error());
    _controller.show(
      ToastConfig.error(
        message,
        title: title,
        duration: duration ?? const Duration(seconds: 4),
        action: action,
        actionLabel: actionLabel,
      ),
      context: context,
    );
  }

  /// Show warning toast
  static void warning(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
    bool haptic = true,
  }) {
    if (haptic) unawaited(AppHaptics.medium());
    _controller.show(
      ToastConfig.warning(
        message,
        title: title,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        actionLabel: actionLabel,
      ),
      context: context,
    );
  }

  /// Show info toast
  static void info(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
    bool haptic = true,
  }) {
    if (haptic) unawaited(AppHaptics.light());
    _controller.show(
      ToastConfig.info(
        message,
        title: title,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        actionLabel: actionLabel,
      ),
      context: context,
    );
  }

  /// Dismiss current toast
  static void dismiss() {
    _controller.dismiss();
  }

  /// Clear all queued toasts
  static void clearQueue() {
    _controller.clearQueue();
  }

  /// Check if toast is showing
  static bool get isShowing => _controller.isShowing;

  /// Get queue length
  static int get queueLength => _controller.queueLength;
}
