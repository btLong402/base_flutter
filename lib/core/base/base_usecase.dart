// ignore_for_file: one_member_abstracts // Clean Architecture UseCases are designed with a single 'call' method to enforce single responsibility.
import 'package:base_flutter/core/base/error/failures.dart';
import 'package:dartz/dartz.dart';

typedef FutureResult<T> = Future<Either<Failure, T>>;
typedef StreamResult<T> = Stream<Either<Failure, T>>;

abstract class UseCase<T, Params> {
  FutureResult<T> call(Params params);
}

abstract class UseCaseNoParams<T> {
  FutureResult<T> call();
}

abstract class StreamUseCase<T, Params> {
  StreamResult<T> call(Params params);
}

abstract class StreamUseCaseNoParams<T> {
  StreamResult<T> call();
}

class NoParams {
  const NoParams();
}
