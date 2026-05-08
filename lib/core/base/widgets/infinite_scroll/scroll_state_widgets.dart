import 'package:base_flutter/core/base/widgets/empty/app_empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/infinite_scroll.dart'
    show InfiniteScrollView;
import 'package:base_flutter/core/base/widgets/infinite_scroll/infinite_scroll_view.dart'
    show InfiniteScrollView;

/// Reusable state display widgets for [InfiniteScrollView].
///
/// Extracted to follow Single Responsibility Principle. Each widget
/// handles one visual state: loading, empty, or error.

/// Default loading indicator shown during initial data fetch.
///
/// Displays a centered spinner with "Loading…" text.
/// Override via `InfiniteScrollView.loadingBuilder`.
class InfiniteScrollLoadingState extends StatelessWidget {
  const InfiniteScrollLoadingState({
    super.key,
    this.builder,
    this.shimmerBuilder,
    this.shimmerCount = 6,
  });

  /// Custom builder. Falls back to default spinner when null.
  final WidgetBuilder? builder;

  /// Shimmer item builder. Recommended for smooth loading experience.
  final Widget Function(BuildContext context, int index)? shimmerBuilder;

  /// Number of shimmer items to show.
  final int shimmerCount;

  @override
  Widget build(BuildContext context) {
    if (builder != null) return builder!(context);

    if (shimmerBuilder != null) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: List.generate(
              shimmerCount,
              (index) => shimmerBuilder!(context, index),
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Đang tải...', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Default empty state shown when data is loaded but list is empty.
///
/// Displays an inbox icon with descriptive text.
/// Override via `InfiniteScrollView.emptyBuilder`.
class InfiniteScrollEmptyState extends StatelessWidget {
  const InfiniteScrollEmptyState({super.key, this.builder});

  /// Custom builder. Falls back to default empty view when null.
  final WidgetBuilder? builder;

  @override
  Widget build(BuildContext context) {
    if (builder != null) return builder!(context);

    return const AppEmptyWidget(
      icon: Icons.inventory_2_outlined,
      title: 'Chưa có dữ liệu',
      message: 'Vuốt để làm mới hoặc quay lại sau',
    );
  }
}

/// Default error state shown when data fetching fails.
///
/// Displays an error icon, message, and retry button.
/// Override via `InfiniteScrollView.errorBuilder`.
class InfiniteScrollErrorState extends StatelessWidget {
  const InfiniteScrollErrorState({
    required this.error,
    required this.onRetry,
    super.key,
    this.builder,
  });

  final Object error;
  final VoidCallback onRetry;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)?
  builder;

  @override
  Widget build(BuildContext context) {
    if (builder != null) return builder!(context, error, onRetry);

    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cloud_off_outlined,
          size: 48,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 12),
        Text(
          'Lỗi kết nối',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Nhấn để thử lại.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    );
  }
}

/// Wraps scroll content with appropriate state display.
///
/// Shows loading, empty, or error state based on controller values.
/// When data is available, renders the [child] directly.
class InfiniteScrollContentWrapper extends StatelessWidget {
  const InfiniteScrollContentWrapper({
    required this.isInitialized,
    required this.isRefreshing,
    required this.itemCount,
    required this.error,
    required this.onRetry,
    required this.child,
    super.key,
    this.loadingBuilder,
    this.shimmerBuilder,
    this.shimmerCount = 6,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final bool isInitialized;
  final bool isRefreshing;
  final int itemCount;
  final Object? error;
  final VoidCallback onRetry;
  final Widget child;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext context, int index)? shimmerBuilder;
  final int shimmerCount;
  final WidgetBuilder? emptyBuilder;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)?
  errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (!isInitialized && isRefreshing) {
      return InfiniteScrollLoadingState(
        builder: loadingBuilder,
        shimmerBuilder: shimmerBuilder,
        shimmerCount: shimmerCount,
      );
    }

    if (itemCount == 0 && isInitialized && error == null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(child: InfiniteScrollEmptyState(builder: emptyBuilder)),
        ),
      );
    }

    if (itemCount == 0 && error != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: InfiniteScrollErrorState(
              error: error!,
              onRetry: onRetry,
              builder: errorBuilder,
            ),
          ),
        ),
      );
    }

    return child;
  }
}
