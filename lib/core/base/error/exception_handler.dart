import 'dart:io';

import 'package:base_flutter/core/base/error/error_translator.dart';
import 'package:base_flutter/core/base/error/exceptions.dart';
import 'package:base_flutter/core/l10n/generated/l10n.dart';
import 'package:dio/dio.dart';

/// Exception handler to map Dio errors to custom exceptions
class ExceptionHandler {
  /// Map DioException to custom AppException
  static AppException handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: S.current.error_timeout,
          code: error.response?.statusCode,
          data: error.response?.data,
        );

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response!);

      case DioExceptionType.cancel:
        return AppException(
          message: S.current.error_request_cancelled,
          code: error.response?.statusCode,
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException(
            message: S.current.error_network,
            code: error.response?.statusCode,
          );
        }
        return NetworkException(
          message: S.current.error_network,
          code: error.response?.statusCode,
          data: error.response?.data,
        );

      case DioExceptionType.badCertificate:
        return AppException(
          message: S.current.error_unknown,
          code: error.response?.statusCode,
          data: error.response?.data,
        );
    }
  }

  /// Handle HTTP status codes
  static AppException _handleStatusCode(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    final rawMessage = _extractErrorMessage(data) ?? S.current.error_unknown;
    final errors = _extractErrors(data);

    // Automatically translate the message using ErrorTranslator
    final message = ErrorTranslator.translate(
      fallback: rawMessage,
      errors: errors,
    );

    if (statusCode >= 500) {
      return ServerException(
        message: message,
        code: statusCode,
        data: data,
        errors: errors,
      );
    } else if (statusCode == 401) {
      return UnauthorizedException(
        message: message,
        code: statusCode,
        data: data,
        errors: errors,
      );
    } else if (statusCode == 403) {
      return AuthException(
        message: message,
        code: statusCode,
        data: data,
        errors: errors,
      );
    } else if (statusCode >= 400) {
      return ClientException(
        message: message,
        code: statusCode,
        data: data,
        errors: errors,
      );
    }

    return AppException(
      message: message,
      code: statusCode,
      data: data,
      errors: errors,
    );
  }

  /// Extract error message from response data
  static String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // Try common error message keys
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['errorMessage']?.toString() ??
          data['msg']?.toString();
    }

    if (data is String) {
      return data;
    }

    return null;
  }

  /// Extract detailed errors list from response data
  static List<Map<String, dynamic>>? _extractErrors(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;

    final errors = data['errors'];
    if (errors is List) {
      return errors.whereType<Map<String, dynamic>>().toList();
    }

    return null;
  }

  /// Handle general exceptions
  static AppException handleException(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is SocketException) {
      return NetworkException(message: S.current.error_network);
    }

    return AppException(message: error.toString());
  }
}
