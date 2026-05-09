import 'dart:convert';
import 'package:base_flutter/core/base/constants/app_constants.dart';
import 'package:base_flutter/core/base/network/crypto/crypto_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class CryptographyInterceptor extends Interceptor {
  CryptographyInterceptor(this._cryptoService);

  final CryptoService _cryptoService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isSecure = (options.extra[AppConstants.secureExtraKey] as bool?) ?? false;

    if (isSecure && options.data != null) {
      try {
        final jsonStr = json.encode(options.data);
        
        // Use compute to perform encryption in an isolate to keep UI smooth
        final encrypted = await compute(_encryptTask, _CryptoTaskData(_cryptoService, jsonStr));
        
        options.data = {'payload': encrypted};
        options.headers[HttpHeaders.xEncrypted] = 'true';
      } on Object catch (e) {
        // Handle encryption error - tuân thủ Rule 05 (Error Handling)
        return handler.reject(
          DioException(
            requestOptions: options,
            error: 'Encryption failed: $e',
          ),
        );
      }
    }
    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final isEncrypted = response.headers.value(HttpHeaders.xEncrypted) == 'true';

    if (isEncrypted && response.data != null && response.data is Map) {
      try {
        final dataMap = response.data as Map<String, dynamic>;
        final encryptedData = dataMap['payload'] as String?;
        if (encryptedData != null) {
          final decrypted = await compute(_decryptTask, _CryptoTaskData(_cryptoService, encryptedData));
          response.data = json.decode(decrypted);
        }
      } on Object catch (e) {
        return handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: 'Decryption failed: $e',
          ),
        );
      }
    }
    return handler.next(response);
  }
}

// Top-level functions for compute
Future<String> _encryptTask(_CryptoTaskData data) async {
  return data.service.encrypt(data.text);
}

Future<String> _decryptTask(_CryptoTaskData data) async {
  return data.service.decrypt(data.text);
}

class _CryptoTaskData {
  _CryptoTaskData(this.service, this.text);

  final CryptoService service;
  final String text;
}
