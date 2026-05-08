/// Core base classes for Clean Architecture with Dartz
///
/// Export all base classes and utilities for working with Either pattern
library;

export 'base_notifier.dart';
export 'base_params.dart';
export 'base_repository.dart';
export 'base_usecase.dart';

/// Example usage:
/// ```dart
/// import 'package:code_base/core/base/base.dart';
///
/// // Now you can use all base classes
/// class MyUseCase extends UseCase<Result, MyParams> {
///   @override
///   Future<Either<Failure, Result>> call(MyParams params) async {
///     // Implementation
///   }
/// }
///
/// class MyRepository extends BaseRepository implements IMyRepository {
///   @override
///   Future<Either<Failure, Data>> getData() async {
///     return execute(() async {
///       // API call
///     });
///   }
/// }
/// ```
