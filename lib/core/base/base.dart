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
// Error Handling
export 'error/exceptions.dart';
export 'error/failures.dart';
// Theme System
export 'theme/app_colors.dart';
export 'theme/app_dimensions.dart';
export 'theme/app_text_styles.dart';
export 'theme/app_theme.dart';
export 'utils/currency_formatter.dart';
export 'utils/date_time_helper.dart';
// Utilities
export 'utils/localized_validators.dart';
export 'utils/logger.dart';
// Common Widgets
export 'widgets/avatar/app_avatar.dart';
export 'widgets/custom_image_widget/custom_image.dart';
export 'widgets/custom_image_widget/custom_image_widget.dart';
export 'widgets/empty/app_empty_widget.dart';
export 'widgets/infinite_scroll/infinite_scroll.dart';
export 'widgets/input/app_search_bar.dart';
export 'widgets/input/app_text_field.dart';
export 'widgets/input/form_picker_tile.dart';
export 'widgets/selection/selection.dart';
export 'widgets/shimmer/generic_shimmer.dart';
export 'widgets/toast/toast_notification.dart';

/// Example usage:
/// ```dart
/// import 'package:base_flutter/core/base/base.dart';
///
/// // Now you can use all base classes, themes, and common widgets
/// ```
///
/// ### Architecture Showcase:
/// 
/// Below is a complete guide showing how all Base classes tie together in a Clean Architecture flow:
/// 
/// **1. Data Layer (Repository Implementation)**
/// ```dart
/// class ProductRepositoryImpl extends BaseRepository implements ProductRepository {
///   final ProductRemoteDataSource remote;
///   ProductRepositoryImpl(this.remote);
/// 
///   @override
///   Future<Either<Failure, Product>> getProductDetail(String id) {
///     // `execute` automatically maps exceptions to appropriate Failures
///     return execute(() => remote.fetchProduct(id)); 
///   }
/// }
/// ```
/// 
/// **2. Domain Layer (UseCase & Params)**
/// ```dart
/// class ProductParams extends Params {
///   final String productId;
///   const ProductParams(this.productId);
/// 
///   @override
///   List<Object?> get props => [productId];
/// }
/// 
/// class GetProductDetailUseCase implements UseCase<Product, ProductParams> {
///   final ProductRepository repository;
///   GetProductDetailUseCase(this.repository);
/// 
///   @override
///   FutureResult<Product> call(ProductParams params) {
///     return repository.getProductDetail(params.productId);
///   }
/// }
/// ```
/// 
/// **3. Presentation Layer (State & Riverpod Notifier)**
/// ```dart
/// typedef ProductDetailState = BaseState<Product>;
/// 
/// class ProductDetailNotifier extends BaseNotifier<ProductDetailState> {
///   final GetProductDetailUseCase getProductDetail;
///   ProductDetailNotifier(this.getProductDetail) : super(const BaseState.initial());
/// 
///   Future<void> fetchProduct(String id) async {
///     await runTask<Product>(
///       task: getProductDetail(ProductParams(id)),
///       onLoading: () => state = const BaseState.loading(),
///       onSuccess: (product) => state = BaseState.success(product),
///       onError: (message) => state = BaseState.error(message),
///     );
///   }
/// }
/// ```
/// 
/// **4. Presentation Layer (UI Widget)**
/// ```dart
/// class ProductDetailPage extends ConsumerWidget {
///   final String productId;
///   const ProductDetailPage(this.productId, {super.key});
/// 
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final detailState = ref.watch(productDetailProvider(productId));
/// 
///     return Scaffold(
///       body: detailState.when(
///         initial: () => const Center(child: Text('Bắt đầu...')),
///         loading: () => const Center(child: CircularProgressIndicator()),
///         success: (product) => ProductDetailWidget(product),
///         error: (message) => Center(child: Text('Lỗi: $message')),
///       ),
///     );
///   }
/// }
/// ```
