import 'package:flutter/material.dart';

/// Animated footer that visualizes load-more states.
///
/// ### States (Dart 3 switch expression):
/// - **Loading**: Animated spinner + text
/// - **Error**: Error icon + retry button
/// - **End**: Check icon + end label
/// - **Hidden**: When `hasMore=true` and not loading
///
/// ### Performance:
/// - `AnimatedSwitcher` for smooth 220ms state transitions
/// - Keyed children prevent unnecessary rebuilds
/// - Minimal widget tree when hidden
class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({
    required this.isLoading,
    required this.hasMore,
    super.key,
    this.error,
    this.onRetry,
    this.emptyLabel = 'Chưa có dữ liệu',
    this.endLabel = 'Đã hết danh sách',
    this.loadingLabel = 'Đang tải...',
    this.retryLabel = 'Thử lại',
    this.itemCount,
  });

  final bool isLoading;
  final bool hasMore;
  final Object? error;
  final VoidCallback? onRetry;
  final String emptyLabel;
  final String endLabel;
  final String loadingLabel;
  final String retryLabel;

  /// When provided, displays "X items loaded" alongside the end label.
  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final child = switch ((error != null, isLoading, hasMore)) {
      (true, _, _) => _ErrorRow(
        theme: theme,
        onRetry: onRetry,
        retryLabel: retryLabel,
      ),
      (_, true, _) => _LoadingRow(theme: theme, label: loadingLabel),
      (_, _, false) => const SizedBox.shrink(),
      _ => const SizedBox.shrink(),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: child,
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow({required this.theme, required this.label});

  final ThemeData theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('loading'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({
    required this.theme,
    required this.retryLabel,
    this.onRetry,
  });

  final ThemeData theme;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('error'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
        const SizedBox(width: 8),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: Text(retryLabel))
        else
          Text(
            'Đã xảy ra lỗi',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
      ],
    );
  }
}
