import 'dart:developer' as developer;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:base_flutter/core/base/constants/app_constants.dart';

enum EnvironmentName { development, staging, production }

/// Represents a resolved environment configuration loaded from .env files.
class AppEnvironment {
  const AppEnvironment({
    required this.name,
    required this.baseUrl,
    required this.webUrl,
    required this.enableLogging,
    required this.enableCaching,
  });

  /// Active environment name (e.g. development, staging, production).
  final String name;

  /// Base API URL loaded from the environment configuration.
  final String baseUrl;

  /// Base web URL for client-facing links (e.g. customer order link).
  final String webUrl;

  /// Flag controlling verbose logging for network calls.
  final bool enableLogging;

  /// Flag controlling client-side caching.
  final bool enableCaching;

  /// Parsed [Uri] representation of [baseUrl].
  Uri get baseUri => Uri.parse(baseUrl);
}

/// Loads and exposes environment configuration for the application.
class EnvironmentConfig {
  const EnvironmentConfig._(this.environment);

  /// Currently active environment.
  final AppEnvironment environment;

  static const String _envKey = 'APP_ENV';
  static const String _loggingKey = 'ENABLE_LOGGING';
  static const String _cachingKey = 'ENABLE_CACHING';
  static const String _baseUrlKey = 'API_BASE_URL';
  static const String _webUrlKey = 'WEB_BASE_URL';
  static const String _defaultWebUrl = 'https://thienbao.itomosoft.com';
  static const String _defaultEnv = 'development';
  static const String _filePrefix = 'assets/env/.env';
  static const String _defaultFile = 'assets/env/.env.development';

  static EnvironmentConfig? _instance;

  /// Returns the active environment configuration.
  static AppEnvironment get current {
    final instance = _instance;
    if (instance == null) {
      throw StateError(
        'EnvironmentConfig not initialized. '
        'Call EnvironmentConfig.load() first.',
      );
    }
    return instance.environment;
  }

  /// Active environment name.
  static String get name => current.name;

  /// Loads environment variables from the specified [env] or [fileName].
  ///
  /// If both are omitted the loader attempts to resolve the environment from
  /// the `APP_ENV` compile-time define. When resolution fails the development
  /// configuration is used as a fallback.
  static Future<void> load({String? env, String? fileName}) async {
    final resolvedEnv = (env?.trim().isNotEmpty ?? false)
        ? env!.trim()
        : const String.fromEnvironment(_envKey, defaultValue: _defaultEnv);

    final resolvedFileName = fileName ?? '$_filePrefix.$resolvedEnv';

    await _loadDotEnv(resolvedFileName);

    final baseUrl = dotenv.maybeGet(_baseUrlKey) ?? AppConstants.baseUrl;
    final webUrl = dotenv.maybeGet(_webUrlKey) ?? _defaultWebUrl;
    final enableLogging = _parseBool(dotenv.maybeGet(_loggingKey)) ?? true;
    final enableCaching = _parseBool(dotenv.maybeGet(_cachingKey)) ?? true;
    final environmentName = dotenv.maybeGet(_envKey) ?? resolvedEnv;

    _instance = EnvironmentConfig._(
      AppEnvironment(
        name: environmentName,
        baseUrl: baseUrl,
        webUrl: webUrl,
        enableLogging: enableLogging,
        enableCaching: enableCaching,
      ),
    );

    developer.log(
      '┌─── EnvironmentConfig loaded ───\n'
      '│ env:      $environmentName\n'
      '│ file:     $resolvedFileName\n'
      '│ baseUrl:  $baseUrl\n'
      '│ webUrl:   $webUrl\n'
      '│ logging:  $enableLogging\n'
      '│ caching:  $enableCaching\n'
      '└────────────────────────────────',
      name: 'ENV',
    );
  }

  static Future<void> _loadDotEnv(String fileName) async {
    try {
      await dotenv.load(fileName: fileName);
    } catch (_) {
      if (fileName == _defaultFile) rethrow;
      await dotenv.load(fileName: _defaultFile);
    }
  }

  static bool? _parseBool(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'y':
        return true;
      case 'false':
      case '0':
      case 'no':
      case 'n':
        return false;
      default:
        return null;
    }
  }
}
