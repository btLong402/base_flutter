import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_state.freezed.dart';

/// A general-purpose UI State wrapper utilizing [Freezed] for typical API request lifecycles.
///
/// Contains four states: `initial`, `loading`, `success`, and `error`.
///
/// ### Unified Architecture Example (Part 4/5: UI State)
///
/// Under this pattern:
/// - **Part 1: Params (`ProductParams`)** defines the parameters for the UseCase.
/// - **Part 2: Repository (`ProductRepository`)** defines data fetching.
/// - **Part 3: UseCase (`GetProductDetailUseCase`)** executes the business logic.
/// - **Part 4: UI State (`ProductDetailState`)** models the loading lifecycle.
/// - **Part 5: Notifier (`ProductNotifier`)** coordinates the state update.
///
/// **1. Use [BaseState] in your Riverpod Notifier:**
/// ```dart
/// class ProductDetailNotifier extends Notifier<BaseState<Product>> {
///   @override
///   BaseState<Product> build() => const BaseState.initial();
///
///   Future<void> loadProduct(String productId) async {
///     state = const BaseState.loading();
///     final result = await ref.read(getProductDetailUseCaseProvider).call(ProductParams(productId: productId));
///     state = result.fold(
///       (failure) => BaseState.error(failure.message),
///       (product) => BaseState.success(product),
///     );
///   }
/// }
/// ```
///
/// **2. Consume [BaseState] in your Flutter widget:**
/// ```dart
/// class ProductDetailWidget extends ConsumerWidget {
///   const ProductDetailWidget({super.key});
///
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final productState = ref.watch(productDetailProvider);
///
///     return productState.when(
///       initial: () => const Text('Vui lòng tải thông tin sản phẩm'),
///       loading: () => const CircularProgressIndicator(),
///       success: (product) => Text('Sản phẩm: ${product.name}!'),
///       error: (message) => Text('Có lỗi xảy ra: $message'),
///     );
///   }
/// }
/// ```
@freezed
class BaseState<T> with _$BaseState<T> {
  const factory BaseState.initial() = _Initial;
  const factory BaseState.loading() = _Loading;
  const factory BaseState.success(T data) = _Success;
  const factory BaseState.error(String message) = _Error;
}
