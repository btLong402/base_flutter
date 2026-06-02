import 'package:base_flutter/core/base/error/exception_handler.dart';
import 'package:base_flutter/core/base/error/exceptions.dart';
import 'package:base_flutter/core/base/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

/// Base repository with common error handling logic.
/// All repository implementations can extend this to get consistent
/// error handling.
///
/// ### Unified Architecture Example (Part 2/5: Repository)
///
/// Under this pattern:
/// - **Part 1: Params (`ProductParams`)** defines the parameters for the UseCase.
/// - **Part 2: Repository (`ProductRepository`)** defines data fetching.
/// - **Part 3: UseCase (`GetProductDetailUseCase`)** executes the business logic.
/// - **Part 4: UI State (`ProductDetailState`)** models the loading lifecycle.
/// - **Part 5: Notifier (`ProductNotifier`)** coordinates the state update.
///
/// **1. Define the repository interface:**
/// ```dart
/// abstract class ProductRepository {
///   Future<Either<Failure, Product>> getProductDetail(String id);
/// }
/// ```
///
/// **2. Implement the repository by extending [BaseRepository]:**
/// ```dart
/// class ProductRepositoryImpl extends BaseRepository implements ProductRepository {
///   final ProductRemoteDataSource _remoteDataSource;
///
///   ProductRepositoryImpl(this._remoteDataSource);
///
///   @override
///   Future<Either<Failure, Product>> getProductDetail(String id) {
///     // The `execute` method handles Exceptions automatically
///     // and converts them to appropriate `Failure` types (ServerFailure, NetworkFailure, etc.)
///     return execute(() => _remoteDataSource.getProduct(id));
///   }
/// }
/// ```
abstract class BaseRepository {
  /// Execute an async operation with automatic error handling
  /// Converts exceptions to Failures using the Either pattern
  Future<Either<Failure, T>> execute<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Right(result);
    } on Object catch (e) {
      final exception = _handleException(e);
      return Left(_mapExceptionToFailure(exception));
    }
  }

  /// Execute a synchronous operation with automatic error handling
  Either<Failure, T> executeSync<T>(T Function() operation) {
    try {
      final result = operation();
      return Right(result);
    } on Object catch (e) {
      final exception = _handleException(e);
      return Left(_mapExceptionToFailure(exception));
    }
  }

  /// Helper to convert any error into an AppException
  AppException _handleException(Object e) {
    if (e is DioException) {
      return ExceptionHandler.handleDioException(e);
    }
    return ExceptionHandler.handleException(e);
  }

  /// Mapping from AppException to Failure
  Failure _mapExceptionToFailure(AppException e) {
    if (e is ServerException) {
      return ServerFailure(
        message: e.message,
        code: e.code,
        data: e.data,
        errors: e.errors,
      );
    } else if (e is ClientException) {
      return ClientFailure(
        message: e.message,
        code: e.code,
        data: e.data,
        errors: e.errors,
      );
    } else if (e is NetworkException) {
      return NetworkFailure(
        message: e.message,
        code: e.code,
        data: e.data,
        errors: e.errors,
      );
    } else if (e is CacheException) {
      return CacheFailure(
        message: e.message,
        code: e.code,
        data: e.data,
        errors: e.errors,
      );
    } else if (e is AuthException || e is UnauthorizedException) {
      return AuthFailure(
        message: e.message,
        code: e.code,
        data: e.data,
        errors: e.errors,
      );
    } else if (e is TimeoutException) {
      return NetworkFailure(
        message: e.message,
        code: e.code,
        data: e.data,
        errors: e.errors,
      );
    } else if (e is ValidationException) {
      return ValidationFailure(
        message: e.message,
        code: e.code,
        data: e.data,
        errors: e.errors,
      );
    } else if (e is PermissionException) {
      return PermissionFailure(
        message: e.message,
        code: e.code,
        data: e.data,
        errors: e.errors,
      );
    }
    return UnknownFailure(
      message: e.message,
      code: e.code,
      data: e.data,
      errors: e.errors,
    );
  }

  /// Execute with custom error mapping
  /// Use this when you need specific error handling logic
  ///
  /// Usage:
  /// ```dart
  /// @override
  /// Future<Either<Failure, Data>> getData() async {
  ///   return executeWithMapping(
  ///     () async => await apiService.getData(),
  ///     onError: (error) {
  ///       if (error is TimeoutException) {
  ///         return NetworkFailure(message: 'Request timeout');
  ///       }
  ///       return UnknownFailure(message: error.toString());
  ///     },
  ///   );
  /// }
  /// ```
  Future<Either<Failure, T>> executeWithMapping<T>(
    Future<T> Function() operation, {
    required Failure Function(Object error) onError,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } on Object catch (e) {
      return Left(onError(e));
    }
  }
}
