// ignore_for_file: one_member_abstracts // Clean Architecture UseCases are designed with a single 'call' method to enforce single responsibility.
import 'package:base_flutter/core/base/error/failures.dart';
import 'package:dartz/dartz.dart';

typedef FutureResult<T> = Future<Either<Failure, T>>;
typedef StreamResult<T> = Stream<Either<Failure, T>>;

/// Base class for UseCases with parameters.
///
/// ### Unified Architecture Example (Part 3/5: UseCase)
///
/// Under this pattern:
/// - **Part 1: Params (`ProductParams`)** defines the parameters for the UseCase.
/// - **Part 2: Repository (`ProductRepository`)** defines data fetching.
/// - **Part 3: UseCase (`GetProductDetailUseCase`)** executes the business logic.
/// - **Part 4: UI State (`ProductDetailState`)** models the loading lifecycle.
/// - **Part 5: Notifier (`ProductNotifier`)** coordinates the state update.
///
/// ```dart
/// class GetProductDetailUseCase implements UseCase<Product, ProductParams> {
///   final ProductRepository _repository;
///
///   GetProductDetailUseCase(this._repository);
///
///   @override
///   FutureResult<Product> call(ProductParams params) {
///     return _repository.getProductDetail(params.productId);
///   }
/// }
/// ```
abstract class UseCase<T, Params> {
  FutureResult<T> call(Params params);
}

/// Base class for UseCases without parameters.
///
/// ### Example Usage:
/// ```dart
/// class LogoutUseCase implements UseCaseNoParams<void> {
///   final AuthRepository _repository;
///
///   LogoutUseCase(this._repository);
///
///   @override
///   FutureResult<void> call() {
///     return _repository.logout();
///   }
/// }
/// ```
abstract class UseCaseNoParams<T> {
  FutureResult<T> call();
}

/// Base class for Stream-based UseCases with parameters.
abstract class StreamUseCase<T, Params> {
  StreamResult<T> call(Params params);
}

/// Base class for Stream-based UseCases without parameters.
abstract class StreamUseCaseNoParams<T> {
  StreamResult<T> call();
}

/// A placeholder class to represent "no parameters" for use cases.
///
/// Use this if you want to explicitly declare a use case has no parameters but still
/// conforms to the standard [UseCase] signature instead of [UseCaseNoParams].
///
/// ### Example Usage:
/// ```dart
/// class GetAppConfigUseCase implements UseCase<AppConfig, NoParams> {
///   @override
///   FutureResult<AppConfig> call(NoParams params) {
///     ...
///   }
/// }
/// ```
class NoParams {
  const NoParams();
}
