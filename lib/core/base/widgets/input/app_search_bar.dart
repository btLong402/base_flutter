import 'package:flutter/material.dart';
import 'package:base_flutter/core/base/theme/app_colors.dart';
import 'package:base_flutter/core/base/widgets/input/app_text_field.dart';

/// Standardized Search Bar for lists
///
/// Uses [AppTextField] internally with specific styling for search.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    required this.controller,
    super.key,
    this.hintText = 'Tìm kiếm...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final hasText = value.text.isNotEmpty;
        return AppTextField.compact(
          controller: controller,
          hintText: hintText,
          prefixIcon: Icons.search,
          autofocus: autofocus,
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.textSecondaryLight,
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                    onClear?.call();
                  },
                )
              : null,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          fillColor: Colors.white,
        );
      },
    );
  }
}
