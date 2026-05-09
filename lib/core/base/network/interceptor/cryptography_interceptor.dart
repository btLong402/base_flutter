import 'dart:convert';
import 'package:base_flutter/core/base/config/environment.dart';
import 'package:base_flutter/core/base/constants/app_constants.dart';
import 'package:base_flutter/core/base/network/crypto/crypto_service.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:flutter/foundation.dart' hide Key;
import 'package:injectable/injectable.dart';
import 'package:pointycastle/asymmetric/api.dart';

@injectable
class CryptographyInterceptor extends Interceptor {
  CryptographyInterceptor(this._cryptoService, this._environment);

  final CryptoService _cryptoService;
  final AppEnvironment _environment;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isSecure = (options.extra[AppConstants.secureExtraKey] as bool?) ?? false;

    if (isSecure && options.data != null) {
      try {
        final jsonStr = json.encode(options.data);
        
        // Use compute for Hybrid Encryption (RSA + AES)
        final result = await compute(
          _encryptHybridTask, 
          _CryptoTaskData(
            _cryptoService, 
            jsonStr, 
            rsaPublicKey: _environment.rsaPublicKey,
          ),
        );
        
        options.data = {'payload': result.payload};
        options.headers[AppHttpHeaders.xEncrypted] = 'true';
        options.headers[AppHttpHeaders.xKey] = result.encryptedKey;
        
        // Store session key/iv in extra to decrypt response later
        options.extra['session_crypto'] = result.sessionCrypto;
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
    final isEncrypted = response.headers.value(AppHttpHeaders.xEncrypted) == 'true';

    if (isEncrypted && response.data != null && response.data is Map) {
      try {
        final dataMap = response.data as Map<String, dynamic>;
        final encryptedData = dataMap['payload'] as String?;
        if (encryptedData != null) {
          // Check if we have a session key from the request
          final sessionCrypto = response.requestOptions.extra['session_crypto'] as ({encrypt_pkg.Key key, encrypt_pkg.IV iv})?;
          
          final decrypted = await compute(
            _decryptTask, 
            _CryptoTaskData(
              _cryptoService, 
              encryptedData, 
              key: sessionCrypto?.key,
              iv: sessionCrypto?.iv,
            ),
          );
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
Future<({String payload, String encryptedKey, ({encrypt_pkg.Key key, encrypt_pkg.IV iv}) sessionCrypto})> _encryptHybridTask(_CryptoTaskData data) async {
  final aesKey = encrypt_pkg.Key.fromSecureRandom(32);
  final aesIv = encrypt_pkg.IV.fromSecureRandom(16);
  
  final payload = await data.service.encrypt(data.text, key: aesKey, iv: aesIv);
  
  // Encrypt Key Package
  final keyPackage = '${aesKey.base64}:${aesIv.base64}';
  final rsaEncrypter = encrypt_pkg.Encrypter(encrypt_pkg.RSA(publicKey: encrypt_pkg.RSAKeyParser().parse(data.rsaPublicKey!) as RSAPublicKey));
  final encryptedKey = rsaEncrypter.encrypt(keyPackage).base64;

  return (
    payload: payload, 
    encryptedKey: encryptedKey,
    sessionCrypto: (key: aesKey, iv: aesIv),
  );
}

Future<String> _decryptTask(_CryptoTaskData data) async {
  return data.service.decrypt(data.text, key: data.key, iv: data.iv);
}

class _CryptoTaskData {
  _CryptoTaskData(this.service, this.text, {this.key, this.iv, this.rsaPublicKey});

  final CryptoService service;
  final String text;
  final encrypt_pkg.Key? key;
  final encrypt_pkg.IV? iv;
  final String? rsaPublicKey;
}
