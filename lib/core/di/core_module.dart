import 'package:base_flutter/core/base/config/environment.dart';
import 'package:base_flutter/core/base/network/cookies/app_cookie_manager.dart';
import 'package:base_flutter/core/base/network/crypto/crypto_service.dart';
import 'package:base_flutter/core/base/network/dio/dio_client.dart';
import 'package:base_flutter/core/base/network/interceptor/cryptography_interceptor.dart';
import 'package:base_flutter/core/base/storage/secure_storage.dart';
import 'package:base_flutter/core/base/storage/token_storage.dart';
import 'package:base_flutter/core/base/storage/user_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:passkeys/authenticator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Core module - registers core dependencies
@module
abstract class CoreModule {
  /// Provide AppEnvironment instance
  @lazySingleton
  AppEnvironment get environment => EnvironmentConfig.current;

  /// Provide AppCookieManager instance
  @preResolve
  Future<AppCookieManager> cookieManager(SecureStorage secureStorage) async {
    return AppCookieManager.create(
      baseUri: EnvironmentConfig.current.baseUri,
      secureStorage: secureStorage,
    );
  }

  /// Provide SharedPreferences instance
  @preResolve
  Future<SharedPreferences> get sharedPreferences async {
    return SharedPreferences.getInstance();
  }

  /// Provide FlutterSecureStorage instance
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Provide LocalAuthentication instance for biometric auth
  @lazySingleton
  LocalAuthentication get localAuthentication => LocalAuthentication();

  /// Provide PasskeyAuthenticator instance for passkey auth
  @lazySingleton
  PasskeyAuthenticator get passkeyAuthenticator => PasskeyAuthenticator();

  /// Provide strongly-typed preferences wrapper
  @lazySingleton
  UserPreferences userPreferences(SharedPreferences preferences) =>
      UserPreferences(preferences);

  /// Provide TokenStorage instance
  @lazySingleton
  TokenStorage tokenStorage(AppCookieManager cookieManager) =>
      TokenStorage(cookieManager);

  /// Provide DioClient instance
  @lazySingleton
  DioClient dioClient(
    AppEnvironment environment,
    AppCookieManager cookieManager,
    TokenStorage tokenStorage,
    UserPreferences userPreferences,
    CryptoService cryptoService,
    CryptographyInterceptor cryptoInterceptor,
  ) => DioClient(
    environment: environment,
    cookieManager: cookieManager,
    tokenStorage: tokenStorage,
    userPreferences: userPreferences,
    cryptoService: cryptoService,
    cryptoInterceptor: cryptoInterceptor,
  );

  /// Provide Dio instance from DioClient
  @lazySingleton
  Dio dio(DioClient dioClient) => dioClient.dio;
}
