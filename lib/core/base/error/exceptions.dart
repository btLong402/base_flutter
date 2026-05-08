/// Base exception class for all custom exceptions
class AppException implements Exception {
  AppException({required this.message, this.code, this.data, this.errors});

  final String message;
  final int? code;
  final dynamic data;
  final List<Map<String, dynamic>>? errors;

  @override
  String toString() =>
      'AppException(message: $message, code: $code, errors: $errors)';
}

/// Server exceptions (5xx)
class ServerException extends AppException {
  ServerException({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}

/// Client exceptions (4xx)
class ClientException extends AppException {
  ClientException({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}

/// Network connection exceptions
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}

/// Cache exceptions
class CacheException extends AppException {
  CacheException({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}

/// Authentication exceptions
class AuthException extends AppException {
  AuthException({required super.message, super.code, super.data, super.errors});
}

/// Timeout exceptions
class TimeoutException extends AppException {
  TimeoutException({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}

/// Unauthorized exceptions
class UnauthorizedException extends AppException {
  UnauthorizedException({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}

/// Validation exceptions
class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}

/// Permission exceptions
class PermissionException extends AppException {
  PermissionException({
    required super.message,
    super.code,
    super.data,
    super.errors,
  });
}
