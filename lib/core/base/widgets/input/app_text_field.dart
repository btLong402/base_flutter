import 'package:base_flutter/core/base/theme/app_colors.dart';
import 'package:base_flutter/core/base/theme/app_dimensions.dart';
import 'package:base_flutter/core/base/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Standardized TextField widget for the ChatOps Design System
///
/// Provides consistent styling across the entire app.
/// Use the appropriate factory constructor for your context:
/// - `AppTextField.standard` - Default with visible border (reference style)
/// - `AppTextField.compact` - For bottom sheets and dialogs (filled, no border)
/// - `AppTextField.outlined` - For multiline/notes with visible border
class AppTextField extends StatelessWidget {
  const AppTextField._({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.autofocus = false,
    this.focusNode,
    this.fillColor,
    this.showBorder = false,
    this.onChanged,
    this.inputFormatters,
    this.suffixText,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.onTap,
    this.textAlign = TextAlign.start,
  });

  factory AppTextField.standard({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool autofocus = false,
    FocusNode? focusNode,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
    String? suffixText,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
    bool enabled = true,
    bool readOnly = false,
    bool obscureText = false,
    VoidCallback? onTap,
    TextAlign textAlign = TextAlign.start,
  }) {
    return AppTextField._(
      key: key,
      controller: controller,
      initialValue: initialValue,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      keyboardType: keyboardType,
      autofocus: autofocus,
      focusNode: focusNode,
      maxLines: maxLines,
      showBorder: true,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      suffixText: suffixText,
      onSubmitted: onSubmitted,
      validator: validator,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      onTap: onTap,
      textAlign: textAlign,
    );
  }

  /// Currency input variant - auto-formats with dot separators + ` đ` suffix
  /// Visible border, number keyboard, currency formatter built-in
  factory AppTextField.currency({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    String? hintText,
    IconData? prefixIcon,
    bool autofocus = false,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
    bool enabled = true,
    bool readOnly = false,
    VoidCallback? onTap,
    bool obscureText = false,
  }) {
    return AppTextField._(
      key: key,
      controller: controller,
      initialValue: initialValue,
      hintText: hintText ?? 'Nhập số tiền',
      prefixIcon: prefixIcon,
      keyboardType: TextInputType.number,
      autofocus: autofocus,
      focusNode: focusNode,
      showBorder: true,
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyInputFormatter(),
      ],
      suffixText: 'đ',
      onSubmitted: onSubmitted,
      validator: validator,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      obscureText: obscureText,
    );
  }

  /// Compact variant for bottom sheets and dialogs
  /// Filled background, no visible border
  factory AppTextField.compact({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool autofocus = false,
    FocusNode? focusNode,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
    String? suffixText,
    Color? fillColor,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
    bool enabled = true,
    bool readOnly = false,
    VoidCallback? onTap,
    bool obscureText = false,
  }) {
    return AppTextField._(
      key: key,
      controller: controller,
      initialValue: initialValue,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      keyboardType: keyboardType,
      autofocus: autofocus,
      focusNode: focusNode,
      maxLines: maxLines,
      fillColor: fillColor ?? AppColors.inputFillLight.withValues(alpha: 0.3),
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      suffixText: suffixText,
      onSubmitted: onSubmitted,
      validator: validator,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      obscureText: obscureText,
    );
  }

  /// Outlined variant for multiline inputs like notes
  /// Filled background with visible border
  factory AppTextField.outlined({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    String? hintText,
    FocusNode? focusNode,
    int maxLines = 3,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
    bool enabled = true,
    bool readOnly = false,
    VoidCallback? onTap,
    bool obscureText = false,
  }) {
    return AppTextField._(
      key: key,
      controller: controller,
      initialValue: initialValue,
      hintText: hintText,
      focusNode: focusNode,
      maxLines: maxLines,
      fillColor: AppColors.inputFillLight.withValues(alpha: 0.3),
      showBorder: true,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      obscureText: obscureText,
    );
  }

  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool autofocus;
  final FocusNode? focusNode;
  final Color? fillColor;
  final bool showBorder;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final VoidCallback? onTap;
  final TextAlign textAlign;

  // Design Tokens - Reference Style
  static double get _borderRadius => AppDimensions.rsm;
  static double get _fontSize => 14.sp;
  static double get _iconSize => AppDimensions.iconSm;
  static EdgeInsets get _contentPadding => EdgeInsets.symmetric(
    horizontal: AppDimensions.md,
    vertical: AppDimensions.vsm + 4,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      autofocus: autofocus,
      focusNode: focusNode,
      onChanged: onChanged,
      textAlign: textAlign,
      onFieldSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: validator != null
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      onTap: onTap,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: _fontSize,
        fontWeight: FontWeight.w500,
        color: enabled ? theme.colorScheme.onSurface : theme.disabledColor,
      ),
      decoration: buildDecoration(
        theme: theme,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        fillColor: fillColor,
        showBorder: showBorder,
        enabled: enabled,
      ),
    );
  }

  /// Exposed for DropdownButtonFormField or other fields that need
  /// matching style
  static InputDecoration buildDecoration({
    required ThemeData theme,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? suffixText,
    Color? fillColor,
    bool showBorder = true,
    bool enabled = true,
  }) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      hintText: hintText,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: isDark
            ? AppColors.textDisabledDark
            : AppColors.textDisabledLight,
        fontWeight: FontWeight.normal,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              size: _iconSize,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            )
          : null,
      suffixIcon: suffixIcon,
      suffixText: suffixText,
      suffixStyle: theme.textTheme.bodyMedium?.copyWith(
        color: enabled ? colorScheme.onSurface : theme.disabledColor,
        fontWeight: FontWeight.w600,
      ),
      fillColor: enabled
          ? (fillColor ??
                (isDark ? AppColors.inputFillDark : AppColors.inputFillLight)
                    .withValues(alpha: 0.3))
          : (isDark ? AppColors.inputFillDark : AppColors.inputFillLight)
                .withValues(alpha: 0.6),
      filled: true,
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: showBorder
            ? BorderSide(color: theme.dividerColor)
            : BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: showBorder
            ? BorderSide(color: theme.dividerColor)
            : BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      contentPadding: _contentPadding,
    );
  }
}
