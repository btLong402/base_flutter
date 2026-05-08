import 'package:base_flutter/core/base/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Reusable list tile for entity selection pages.
///
/// Shows title, optional subtitle, leading icon/widget,
/// and a check icon when selected.
class SelectionItemTile extends StatelessWidget {
  const SelectionItemTile({
    required this.title,
    super.key,
    this.subtitle,
    this.subtitleWidget,
    this.leading,
    this.leadingIcon,
    this.isSelected = false,
  });

  /// Primary text.
  final String title;

  /// Secondary text below [title].
  final String? subtitle;

  /// Custom subtitle widget (exclusive with [subtitle]).
  final Widget? subtitleWidget;

  /// Custom leading widget (takes priority over [leadingIcon]).
  final Widget? leading;

  /// Icon shown in a circle when [leading] is null.
  final IconData? leadingIcon;

  /// Whether this item is the current selection.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildLeading(),
          const SizedBox(width: 12),
          Expanded(child: _buildContent(theme)),
          if (isSelected)
            const Icon(Icons.check, size: 20, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildLeading() {
    if (leading != null) return leading!;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        leadingIcon ?? Icons.business,
        size: 20,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitleWidget != null) ...[
          const SizedBox(height: 2),
          subtitleWidget!,
        ] else if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
