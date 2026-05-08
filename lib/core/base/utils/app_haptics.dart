import 'package:flutter/services.dart';

/// Service to handle haptic feedback throughout the app
class AppHaptics {
  AppHaptics._();

  /// Light impact for subtle interactions (e.g. checkbox toggle)
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact for standard actions (e.g. button press)
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact for important actions (e.g. delete, long press)
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection feedback for list/picker scrolling
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Success feedback for task completion
  static Future<void> success() async {
    // Multi-tap effect for success
    await HapticFeedback.lightImpact();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  /// Error feedback for validation failures
  static Future<void> error() async {
    await HapticFeedback.vibrate();
  }
}
