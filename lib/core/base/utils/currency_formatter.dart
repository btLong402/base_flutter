import 'package:flutter/services.dart';

/// Centralized currency formatting utility for Vietnamese Đồng (VNĐ).
///
/// **Standard format:** `1.000.000 đ` (dot separator, suffix ` đ`)
///
/// Provides consistent formatting for:
/// - Display: [format], [formatCompact], [formatNoSymbol]
/// - Input: [CurrencyInputFormatter]
/// - Parsing: [parse]
///
/// Usage:
/// ```dart
/// CurrencyFormatter.format(1500000);        // '1.500.000 đ'
/// CurrencyFormatter.formatCompact(1500000); // '1.5tr'
/// CurrencyFormatter.formatNoSymbol(1500000);// '1.500.000'
/// CurrencyFormatter.parse('1.500.000');     // 1500000.0
/// ```
abstract final class CurrencyFormatter {
  /// Vietnamese currency symbol
  static const String symbol = 'đ';

  /// Thousands separator (Vietnamese standard = dot)
  static const String _separator = '.';

  // ─── DISPLAY FORMATTERS ─────────────────────────────

  /// Full format with currency symbol.
  ///
  /// `1500000` → `1.500.000 đ`
  /// `-500000` → `-500.000 đ`
  static String format(num amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatted = _addSeparators(absAmount.toStringAsFixed(0));
    return '${isNegative ? '-' : ''}$formatted $symbol';
  }

  /// Format without currency symbol (for badges, inline values).
  ///
  /// `1500000` → `1.500.000`
  static String formatNoSymbol(num amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatted = _addSeparators(absAmount.toStringAsFixed(0));
    return '${isNegative ? '-' : ''}$formatted';
  }

  /// Compact abbreviated format for space-constrained areas.
  ///
  /// `1500000` → `1.5tr`
  /// `550000`  → `550k`
  /// `5000`    → `5k`
  /// `500`     → `500`
  static String formatCompact(num amount) {
    final absAmount = amount.abs();
    final prefix = amount < 0 ? '-' : '';
    if (absAmount >= 1000000000) {
      final value = absAmount / 1000000000;
      return '$prefix${_trimTrailingZeros(value.toStringAsFixed(1))}tỷ';
    }
    if (absAmount >= 1000000) {
      final value = absAmount / 1000000;
      return '$prefix${_trimTrailingZeros(value.toStringAsFixed(1))}tr';
    }
    if (absAmount >= 1000) {
      final value = absAmount / 1000;
      return '$prefix${_trimTrailingZeros(value.toStringAsFixed(0))}k';
    }
    return '$prefix${absAmount.toStringAsFixed(0)}';
  }

  /// Compact format using "M" for millions (Mockup style).
  ///
  /// `1500000` → `1.5M`
  static String formatCompactM(num amount) {
    final absAmount = amount.abs();
    final prefix = amount < 0 ? '-' : '';
    if (absAmount >= 1000000) {
      final value = absAmount / 1000000;
      return '$prefix${_trimTrailingZeros(value.toStringAsFixed(1))}M';
    }
    return formatNoSymbol(amount);
  }

  // ─── PARSING ────────────────────────────────────────

  /// Parse a formatted currency string back to [double].
  ///
  /// Handles all separator styles: `1.000.000`, `1,000,000`, `1000000`
  /// Also strips currency symbols: `đ`, `VNĐ`, `VND`
  static double parse(String text) {
    final cleaned = text
        .replaceAll(_separator, '')
        .replaceAll(',', '')
        .replaceAll(symbol, '')
        .replaceAll('VNĐ', '')
        .replaceAll('VND', '')
        .trim();
    return double.tryParse(cleaned) ?? 0;
  }

  // ─── HELPERS ────────────────────────────────────────

  /// Add dot separators to a numeric string.
  ///
  /// `1000000` → `1.000.000`
  static String _addSeparators(String numberStr) {
    return numberStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}$_separator',
    );
  }

  /// Remove trailing `.0` from compact numbers.
  static String _trimTrailingZeros(String value) {
    if (value.endsWith('.0')) return value.substring(0, value.length - 2);
    return value;
  }
}

/// [TextInputFormatter] that formats numeric input as Vietnamese currency.
///
/// Automatically adds dot separators as the user types:
/// - User types: `1500000`
/// - Displays as: `1.500.000`
///
/// Optionally shows a `đ` suffix.
///
/// Usage:
/// ```dart
/// TextField(
///   inputFormatters: [CurrencyInputFormatter()],
///   keyboardType: TextInputType.number,
/// )
/// ```
class CurrencyInputFormatter extends TextInputFormatter {
  CurrencyInputFormatter({this.showSymbol = false});

  /// Whether to append ` đ` suffix during typing.
  final bool showSymbol;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty
    if (newValue.text.isEmpty) return newValue;

    // Strip everything non-digit
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return TextEditingValue.empty;

    // Remove leading zeros (but keep at least one zero)
    final normalized = digitsOnly.length > 1
        ? digitsOnly.replaceFirst(RegExp('^0+'), '')
        : digitsOnly;
    final clean = normalized.isEmpty ? '0' : normalized;

    // Format with separators
    var formatted = clean.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    if (showSymbol) formatted = '$formatted đ';

    // Calculate cursor position
    final cursorOffset = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}
