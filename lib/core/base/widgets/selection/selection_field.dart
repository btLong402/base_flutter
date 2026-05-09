import 'package:base_flutter/core/base/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A read-only form field that opens a selection page on tap.
///
/// Replaces inline [DropdownButton] with a tap-to-navigate pattern.
/// Shows the current selection or a hint, with a chevron icon.
///
/// ```dart
/// SelectionField(
///   label: 'Chi nhánh',
///   value: selectedBranchName,
///   hint: 'Chọn chi nhánh',
///   isRequired: true,
///   onTap: () => _openBranchSelection(),
/// )
/// ```
class SelectionField extends StatelessWidget {
  const SelectionField({
    required this.label,
    super.key,
    this.value,
    this.hint = 'Chọn',
    this.isRequired = false,
    this.onTap,
    this.errorText,
    this.enabled = true,
    this.prefixIcon,
  });

  /// Label displayed above the field.
  final String label;

  /// Current selection display text. Null shows [hint].
  final String? value;

  /// Placeholder when no value is selected.
  final String hint;

  /// Shows a red asterisk after the label.
  final bool isRequired;

  /// Called when the field is tapped.
  final VoidCallback? onTap;

  /// Error message displayed below the field.
  final String? errorText;

  /// Whether the field is interactive.
  final bool enabled;

  /// Optional icon before the value text.
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value != null && value!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(theme),
        const SizedBox(height: 8),
        _buildField(context, theme, hasValue),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          _buildError(theme),
        ],
      ],
    );
  }

  Widget _buildLabel(ThemeData theme) {
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
      ],
    );
  }

  Widget _buildField(BuildContext context, ThemeData theme, bool hasValue) {
    final borderColor = errorText != null
        ? AppColors.error
        : AppColors.dividerLight;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(24),
          color: enabled
              ? AppColors.inputFillLight.withValues(alpha: 0.3)
              : AppColors.backgroundLight,
        ),
        child: Row(
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, size: 18, color: AppColors.textPrimaryLight),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                hasValue ? value! : hint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: hasValue
                      ? AppColors.textPrimaryLight
                      : AppColors.textTertiaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: enabled
                  ? AppColors.textPrimaryLight
                  : AppColors.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Text(
      errorText!,
      style: theme.textTheme.labelSmall?.copyWith(color: AppColors.error),
    );
  }
}
