import 'package:base_flutter/core/base/constants/app_constants.dart';
import 'package:base_flutter/core/base/network/crypto/crypto_service.dart';
import 'package:base_flutter/core/base/widgets/toast/services/toast_service.dart';
import 'package:dio/dio.dart';

/// Error interceptor to handle errors globally
class ErrorInterceptor extends Interceptor {
  ErrorInterceptor(this._cryptoService, this._dio);
  final CryptoService _cryptoService;
  final Dio _dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 1. Check for retry conditions (Network issues or Server 5xx)
    final isRetryable = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);

    if (isRetryable) {
      final extra = err.requestOptions.extra;
      final retryCount = extra['retry_count'] as int? ?? 0;
      if (retryCount < 3) {
        final nextRetry = retryCount + 1;
        extra['retry_count'] = nextRetry;

        // Exponential backoff: 1s, 2s, 4s
        final delay = Duration(seconds: nextRetry * nextRetry);
        await Future<void>.delayed(delay);

        try {
          final response = await _retry(err.requestOptions);
          return handler.resolve(response);
        } on Object catch (_) {
          // If retry fails, continue to global error handling
        }
      }
    }

    // 2. Map error message
    var message = 'Đã có lỗi xảy ra, vui lòng thử lại sau.';

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      message = 'Kết nối quá hạn, vui lòng kiểm tra mạng.';
    } else if (err.response?.statusCode != null) {
      final code = err.response!.statusCode!;
      if (code == 401) {
        message = 'Phiên đăng nhập đã hết hạn.';
        // Optional: Trigger logout flow here
      } else if (code == AppConstants.expiredKeyStatus) {
        // FORCE ROTATION LOGIC
        try {
          await _cryptoService.rotateKey();

          // Retry the request with the new key
          final response = await _retry(err.requestOptions);
          return handler.resolve(response);
        } on Object catch (e) {
          message = 'Không thể làm mới khóa bảo mật: $e';
        }
      } else if (code >= 500) {
        message = 'Lỗi máy chủ (Code: $code).';
      } else if (err.response?.data is Map) {
        // Try to get message from response body
        message = (err.response?.data as Map)['message']?.toString() ?? message;
      }
    }

    // 3. Show global toast
    ToastService.error(message);

    // Pass the error to the next handler
    handler.next(err);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  /// Helper to retry request
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) {
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        extra: requestOptions.extra,
      ),
    );
  }
}
