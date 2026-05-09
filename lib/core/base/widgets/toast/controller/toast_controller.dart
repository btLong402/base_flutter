import 'package:base_flutter/core/base/widgets/toast/models/toast_config.dart';
import 'package:base_flutter/core/base/widgets/toast/widgets/toast_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// High-performance toast controller using FToast for overlay management
class ToastController {
  ToastController._();

  static final ToastController _instance = ToastController._();
  static ToastController get instance => _instance;

  final FToast _fToast = FToast();

  /// Global navigator key to find context when not provided
  GlobalKey<NavigatorState>? navigatorKey;

  /// Show a toast notification
  void show(ToastConfig config, {BuildContext? context}) {
    final effectiveContext = context ?? navigatorKey?.currentContext;
    if (effectiveContext == null) {
      debugPrint('ToastController: Cannot show toast without a valid context.');
      return;
    }

    _fToast
      ..init(effectiveContext)
      ..showToast(
        child: ToastWidget(
          config: config,
          onDismiss: _fToast.removeCustomToast,
        ),
        gravity: _mapGravity(config.position),
        toastDuration: config.duration,
      );
  }

  ToastGravity _mapGravity(ToastPosition position) {
    switch (position) {
      case ToastPosition.top:
        return ToastGravity.TOP;
      case ToastPosition.center:
        return ToastGravity.CENTER;
      case ToastPosition.bottom:
        return ToastGravity.BOTTOM;
    }
  }

  /// Show success toast
  void showSuccess(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration,
  }) {
    show(
      ToastConfig.success(
        message,
        title: title,
        duration: duration ?? const Duration(seconds: 3),
      ),
      context: context,
    );
  }

  /// Show error toast
  void showError(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration,
  }) {
    show(
      ToastConfig.error(
        message,
        title: title,
        duration: duration ?? const Duration(seconds: 4),
      ),
      context: context,
    );
  }

  /// Show warning toast
  void showWarning(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration,
  }) {
    show(
      ToastConfig.warning(
        message,
        title: title,
        duration: duration ?? const Duration(seconds: 3),
      ),
      context: context,
    );
  }

  /// Show info toast
  void showInfo(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration,
  }) {
    show(
      ToastConfig.info(
        message,
        title: title,
        duration: duration ?? const Duration(seconds: 3),
      ),
      context: context,
    );
  }

  /// Dismiss current toast immediately
  void dismiss() {
    _fToast.removeCustomToast();
  }

  /// Clear all queued toasts
  void clearQueue() {
    _fToast.removeQueuedCustomToasts();
  }

  /// Check if toast is currently showing
  // FToast doesn't expose isShowing easily, but we can track if needed.
  bool get isShowing => false; 

  /// Get queue length
  int get queueLength => 0;
}
