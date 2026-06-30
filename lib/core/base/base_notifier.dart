import 'package:base_flutter/core/base/base_usecase.dart';
import 'package:base_flutter/core/base/error/failures.dart';
import 'package:state_notifier/state_notifier.dart';

/// A base class for state management using [StateNotifier] that provides built-in utilities
/// for handling asynchronous tasks (like UseCases) and mapping failures to user-friendly messages.
///
/// ### Unified Architecture Example (Part 5/5: Notifier)
///
/// Under this pattern:
/// - **Part 1: Params (`ProductParams`)** defines the parameters for the UseCase.
/// - **Part 2: Repository (`ProductRepository`)** defines data fetching.
/// - **Part 3: UseCase (`GetProductDetailUseCase`)** executes the business logic.
/// - **Part 4: UI State (`ProductDetailState`)** models the loading lifecycle.
/// - **Part 5: Notifier (`ProductNotifier`)** coordinates the state update.
///
/// ```dart
/// // 1. Define your UI State (e.g. using BaseState<Product>)
/// typedef ProductState = BaseState<Product>;
///
/// // 2. Subclass BaseNotifier
/// class ProductNotifier extends BaseNotifier<ProductState> {
///   final GetProductDetailUseCase _getProductDetail;
///
///   ProductNotifier(this._getProductDetail) : super(const BaseState.initial());
///
///   Future<void> fetchProduct(String productId) async {
///     await runTask<Product>(
///       task: _getProductDetail(ProductParams(productId: productId)),
///       onLoading: () => state = const BaseState.loading(),
///       onSuccess: (product) => state = BaseState.success(product),
///       onError: (message) => state = BaseState.error(message),
///     );
///   }
/// }
/// ```
///
/// ### Complex Example Usage:
/// Handles custom failure mapping, union/sealed states, and sequential task chaining (submitting an order then processing payment):
/// ```dart
/// // 1. Define custom failures
/// class ValidationFailure extends Failure {
///   final Map<String, String> errors;
///   ValidationFailure(this.errors);
/// }
///
/// // 2. Define a union/sealed state for a feature
/// class CheckoutState {
///   const CheckoutState();
/// }
/// class CheckoutInitial extends CheckoutState {}
/// class CheckoutSubmitting extends CheckoutState {}
/// class CheckoutSuccess extends CheckoutState {
///   final Order order;
///   CheckoutSuccess(this.order);
/// }
/// class CheckoutValidationError extends CheckoutState {
///   final Map<String, String> fields;
///   CheckoutValidationError(this.fields);
/// }
/// class CheckoutError extends CheckoutState {
///   final String message;
///   CheckoutError(this.message);
/// }
///
/// // 3. Subclass BaseNotifier with overridden error mapper and complex task chaining
/// class CheckoutNotifier extends BaseNotifier<CheckoutState> {
///   final SubmitOrderUseCase _submitOrder;
///   final ProcessPaymentUseCase _processPayment;
///
///   CheckoutNotifier(
///     this._submitOrder,
///     this._processPayment,
///   ) : super(CheckoutInitial());
///
///   // Overriding error mapper to handle validation failures separately
///   @override
///   String mapFailureToMessage(Failure failure) {
///     if (failure is ValidationFailure) return 'Dữ liệu nhập vào không hợp lệ.';
///     return super.mapFailureToMessage(failure);
///   }
///
///   Future<void> checkout(OrderParams params) async {
///     // Run the first task: Submitting the order
///     final orderResult = await runTask<Order>(
///       task: _submitOrder(params),
///       onLoading: () => state = CheckoutSubmitting(),
///       onSuccess: (_) {}, // Handled in task chaining below
///       onError: (msg) => state = CheckoutError(msg),
///     );
///
///     // Chain the second task only if the first task succeeded
///     await orderResult.fold(
///       (failure) async {
///         if (failure is ValidationFailure) {
///           state = CheckoutValidationError(failure.errors);
///         }
///       },
///       (order) async {
///         // Run the second task: Processing payment for the created order
///         await runTask<PaymentReceipt>(
///           task: _processPayment(PaymentParams(orderId: order.id)),
///           onLoading: () => state = CheckoutSubmitting(),
///           onSuccess: (receipt) => state = CheckoutSuccess(order),
///           onError: (msg) => state = CheckoutError('Thanh toán thất bại: $msg'),
///         );
///       },
///     );
///   }
/// }
/// ```
abstract class BaseNotifier<S> extends StateNotifier<S> {
  BaseNotifier(super._state);

  /// Standard failure to message mapper
  String mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    return 'Đã có lỗi xảy ra, vui lòng thử lại sau.';
  }

  /// Helper to execute a [FutureResult] (such as a use case invocation) and handle state transitions.
  ///
  /// Calls [onLoading] before executing the task, and resolves the result:
  /// - On success, calls [onSuccess] with the loaded data.
  /// - On failure, maps the [Failure] using [mapFailureToMessage] and calls [onError].
  ///
  /// Returns the underlying [FutureResult] for further handling if needed.
  ///
  /// ### Example:
  /// ```dart
  /// await runTask<Product>(
  ///   task: _getProductUseCase(id),
  ///   onLoading: () => state = const ProductState.loading(),
  ///   onSuccess: (product) => state = ProductState.success(product),
  ///   onError: (error) => state = ProductState.error(error),
  /// );
  /// ```
  FutureResult<T> runTask<T>({
    required FutureResult<T> task,
    required void Function() onLoading,
    required void Function(T data) onSuccess,
    required void Function(String message) onError,
  }) async {
    onLoading();
    final result = await task;
    result.fold((failure) => onError(mapFailureToMessage(failure)), onSuccess);
    return result;
  }
}
