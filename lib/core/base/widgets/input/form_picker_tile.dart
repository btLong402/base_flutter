import 'package:base_flutter/core/base/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Reusable picker tile for form fields (employee, date, time).
///
/// Displays an icon, text, and an optional chevron.
/// Used in bottom-sheet forms for consistent picker styling.
class FormPickerTile extends StatelessWidget {
  const FormPickerTile({
    required this.icon,
    required this.text,
    required this.onTap,
    super.key,
    this.isPlaceholder = false,
    this.disabled = false,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isPlaceholder;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: disabled
          ? AppColors.inputFillLight.withValues(alpha: 0.6)
          : AppColors.inputFillLight.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondaryLight),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: disabled || isPlaceholder
                        ? AppColors.textSecondaryLight
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              if (!disabled)
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textSecondaryLight,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
