import 'package:equatable/equatable.dart';

/// Base class for use case parameters.
/// Extend this to create type-safe, equatable parameters for your use cases.
///
/// ### Unified Architecture Example (Part 1/5: Params)
///
/// Under this pattern:
/// - **Part 1: Params (`ProductParams`)** defines the parameters for the UseCase.
/// - **Part 2: Repository (`ProductRepository`)** defines data fetching.
/// - **Part 3: UseCase (`GetProductDetailUseCase`)** executes the business logic.
/// - **Part 4: UI State (`ProductDetailState`)** models the loading lifecycle.
/// - **Part 5: Notifier (`ProductNotifier`)** coordinates the state update.
///
/// ```dart
/// // Defining parameters for fetching product details
/// class ProductParams extends Params {
///   final String productId;
///
///   const ProductParams({required this.productId});
///
///   @override
///   List<Object?> get props => [productId];
/// }
/// ```
///
/// Other examples:
/// ```dart
/// class PaginationParams extends Params {
///   final int page;
///   final int limit;
///   final String? query;
///
///   const PaginationParams({
///     required this.page,
///     required this.limit,
///     this.query,
///   });
///
///   @override
///   List<Object?> get props => [page, limit, query];
/// }
/// ```
abstract class Params extends Equatable {
  const Params();

  @override
  List<Object?> get props => [];
}
