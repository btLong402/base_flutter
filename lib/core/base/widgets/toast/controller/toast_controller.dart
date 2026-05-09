import 'package:base_flutter/core/base/widgets/toast/models/toast_config.dart';
import 'package:base_flutter/core/base/widgets/toast/widgets/toast_widget.dart';
import 'package:flutter/material.dart';

/// High-performance toast controller with overlay management
///
/// **Performance Features:**
/// - Single overlay entry reuse
/// - Automatic cleanup
/// - Queue management for multiple toasts
/// - Memory-efficient state tracking
class ToastController {
  ToastController._();

  static final ToastController _instance = ToastController._();
  static ToastController get instance => _instance;

  /// Global navigator key to find context when not provided
  GlobalKey<NavigatorState>? navigatorKey;

  OverlayEntry? _currentEntry;
  final List<ToastConfig> _queue = [];
  bool _isShowing = false;

  /// Show a toast notification
  void show(ToastConfig config, {BuildContext? context}) {
    final effectiveContext = context ?? navigatorKey?.currentContext;
    if (effectiveContext == null) {
      debugPrint('ToastController: Cannot show toast without a valid context.');
      return;
    }

    // Add to queue if currently showing
    if (_isShowing) {
      _queue.add(config);
      return;
    }

    _showToast(effectiveContext, config);
  }

  /// Show success toast (convenience method)
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

  /// Show error toast (convenience method)
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

  /// Show warning toast (convenience method)
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

  /// Show info toast (convenience method)
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

  void _showToast(BuildContext context, ToastConfig config) {
    _isShowing = true;

    // PERFORMANCE: Reuse overlay entry when possible
    _currentEntry = OverlayEntry(
      builder: (context) =>
          ToastWidget(config: config, onDismiss: _dismissCurrent),
    );

    // Insert into overlay
    OverlayState? overlay;

    try {
      overlay = Overlay.of(context);
    } on Object catch (_) {
      // Fallback to navigatorKey if context-based search fails
      overlay = navigatorKey?.currentState?.overlay;
    }

    if (overlay == null) {
      debugPrint(
        'ToastController: No Overlay found in context or navigatorKey.',
      );
      _isShowing = false;
      return;
    }

    overlay.insert(_currentEntry!);
  }

  void _dismissCurrent() {
    _currentEntry?.remove();
    _currentEntry = null;
    _isShowing = false;

    // Show next in queue if available
    _queue.clear();
  }

  /// Dismiss current toast immediately
  void dismiss() {
    _dismissCurrent();
  }

  /// Clear all queued toasts
  void clearQueue() {
    _queue.clear();
  }

  /// Check if toast is currently showing
  bool get isShowing => _isShowing;

  /// Get queue length
  int get queueLength => _queue.length;
}
