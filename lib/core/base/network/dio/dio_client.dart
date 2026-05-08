import 'package:base_flutter/core/base/constants/app_constants.dart';
import 'package:base_flutter/core/base/network/cookies/app_cookie_manager.dart';
import 'package:base_flutter/core/base/network/interceptor/error_interceptor.dart';
import 'package:base_flutter/core/base/storage/token_storage.dart';
import 'package:base_flutter/core/base/storage/user_preferences.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:base_flutter/core/base/config/environment.dart';

/// Dio client factory
class DioClient {
  DioClient({
    required AppEnvironment environment,
    required this.cookieManager,
    required this.tokenStorage,
    required this.userPreferences,
    this.connectTimeout = AppConstants.connectTimeout,
    this.receiveTimeout = AppConstants.receiveTimeout,
    this.sendTimeout = AppConstants.sendTimeout,
  }) : baseUrl = environment.baseUrl,
       enableLogging = environment.enableLogging,
       enableCaching = environment.enableCaching {
    _dio = Dio(
      BaseOptions(
        baseUrl: environment.baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        contentType: Headers.jsonContentType,
        headers: {'Accept': 'application/json'},
      ),
    );
    _setupInterceptors();
  }
  late final Dio _dio;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableLogging;
  final bool enableCaching;
  final AppCookieManager cookieManager;
  final TokenStorage tokenStorage;
  final UserPreferences userPreferences;

  /// Callback triggered when a 401 Unauthorized response is received,
  /// indicating both access and refresh tokens have expired.
  /// Set this after app initialization to connect to AuthNotifier.forceLogout()
  void Function()? onUnauthorized;

  /// Get Dio instance
  Dio get dio => _dio;

  /// Setup interceptors
  void _setupInterceptors() {
    // Cookie interceptor must be first to ensure cookies are synced
    _dio.interceptors.add(cookieManager.dioInterceptor);

    // Cache interceptor
    if (enableCaching) {
      _dio.interceptors.add(_getCacheInterceptor());
    }

    // Logger interceptor (should be after cache to log actual requests)
    if (enableLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(requestHeader: true, requestBody: true),
      );
    }

    // Error interceptor (must be last to catch all errors)
    _dio.interceptors.add(ErrorInterceptor());
  }

  /// Get cache interceptor with Hive store
  DioCacheInterceptor _getCacheInterceptor() {
    final cacheOptions = CacheOptions(
      store: HiveCacheStore(null), // Will be initialized in main
      hitCacheOnErrorCodes: [401, 403],
      maxStale: const Duration(days: AppConstants.cacheMaxStale),
    );

    return DioCacheInterceptor(options: cacheOptions);
  }

  /// Add custom interceptor
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Remove interceptor
  void removeInterceptor(Interceptor interceptor) {
    _dio.interceptors.remove(interceptor);
  }

  /// Clear all interceptors
  void clearInterceptors() {
    _dio.interceptors.clear();
  }

  /// Build a Retrofit service using the configured Dio instance.
  T createService<T>(T Function(Dio dio) builder) {
    return builder(_dio);
  }
}
