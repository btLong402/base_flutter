/// Core base classes for Clean Architecture with Dartz
///
/// Export all base classes and utilities for working with Either pattern
library;

// Base Architecture
export 'base_notifier.dart';
export 'base_params.dart';
export 'base_repository.dart';
export 'base_state.dart';
export 'base_usecase.dart';

// Theme System
export 'theme/app_colors.dart';
export 'theme/app_dimensions.dart';
export 'theme/app_text_styles.dart';
export 'theme/app_theme.dart';

// Error Handling
export 'error/exceptions.dart';
export 'error/failures.dart';

// Utilities
export 'utils/localized_validators.dart';
export 'utils/logger.dart';
export 'utils/currency_formatter.dart';
export 'utils/date_time_helper.dart';

// Common Widgets
export 'widgets/avatar/app_avatar.dart';
export 'widgets/input/app_text_field.dart';
export 'widgets/input/app_search_bar.dart';
export 'widgets/input/form_picker_tile.dart';
export 'widgets/selection/selection.dart';
export 'widgets/infinite_scroll/infinite_scroll.dart';
export 'widgets/shimmer/generic_shimmer.dart';
export 'widgets/toast/toast_notification.dart';
export 'widgets/empty/app_empty_widget.dart';
export 'widgets/custom_image_widget/custom_image_widget.dart';
export 'widgets/custom_image_widget/custom_image.dart';

/// Example usage:
/// ```dart
/// import 'package:base_flutter/core/base/base.dart';
///
/// // Now you can use all base classes, themes, and common widgets
/// ```
