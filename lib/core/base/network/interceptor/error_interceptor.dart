import 'package:dio/dio.dart';
import 'package:base_flutter/core/base/widgets/toast/services/toast_service.dart';

/// Error interceptor to handle errors globally
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 1. Map error message
    var message = 'Đã có lỗi xảy ra, vui lòng thử lại sau.';

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      message = 'Kết nối quá hạn, vui lòng kiểm tra mạng.';
    } else if (err.response?.statusCode != null) {
      final code = err.response!.statusCode!;
      if (code == 401) {
        message = 'Phiên đăng nhập đã hết hạn.';
        // Optional: Trigger logout flow here
      } else if (code >= 500) {
        message = 'Lỗi máy chủ (Code: $code).';
      } else if (err.response?.data is Map) {
        // Try to get message from response body
        message = (err.response?.data as Map)['message']?.toString() ?? message;
      }
    }

    // 2. Show global toast
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
}
