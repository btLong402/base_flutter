/// Base class for all failures in the domain layer
/// This provides a consistent way to handle errors across the app
abstract class Failure {
  const Failure({required this.message, this.code, this.data, this.errors});

  final String message;
  final int? code;
  final dynamic data;
  final List<Map<String, dynamic>>? errors;

  @override
  String toString() =>
      'Failure(message: $message, code: $code, errors: $errors)';
}

/// Server-related failures (5xx errors)
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}

/// Client-related failures (4xx errors)
class ClientFailure extends Failure {
  const ClientFailure({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}

/// Network connection failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}

/// Generic/Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}
