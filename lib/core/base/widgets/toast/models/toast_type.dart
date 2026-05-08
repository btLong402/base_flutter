import 'package:flutter/material.dart';

/// Toast notification types with pre-configured styling
enum ToastType { success, error, warning, info }

/// Extension to provide colors and icons for each toast type
extension ToastTypeExtension on ToastType {
  /// Primary color for the toast type
  Color get color {
    switch (this) {
      case ToastType.success:
        return const Color(0xFF10B981); // Green
      case ToastType.error:
        return const Color(0xFFEF4444); // Red
      case ToastType.warning:
        return const Color(0xFFF59E0B); // Amber
      case ToastType.info:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  /// Background color for the toast (lighter variant)
  Color get backgroundColor {
    switch (this) {
      case ToastType.success:
        return const Color(0xFFD1FAE5); // Light green
      case ToastType.error:
        return const Color(0xFFFEE2E2); // Light red
      case ToastType.warning:
        return const Color(0xFFFEF3C7); // Light amber
      case ToastType.info:
        return const Color(0xFFDBEAFE); // Light blue
    }
  }

  /// Icon for the toast type
  IconData get icon {
    switch (this) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }

  /// Semantic label for accessibility
  String get semanticLabel {
    switch (this) {
      case ToastType.success:
        return 'Thành công';
      case ToastType.error:
        return 'Lỗi';
      case ToastType.warning:
        return 'Cảnh báo';
      case ToastType.info:
        return 'Thông tin';
    }
  }
}
