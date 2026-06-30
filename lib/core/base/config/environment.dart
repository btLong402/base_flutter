import 'dart:developer' as developer;

import 'package:base_flutter/core/base/config/env/env_dev.dart';
import 'package:base_flutter/core/base/config/env/env_prod.dart';
import 'package:base_flutter/core/base/config/env/env_staging.dart';
import 'package:base_flutter/core/base/constants/app_constants.dart';

enum AppFlavor { development, staging, production }

/// Represents a resolved environment configuration loaded from Envied configurations.
class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.name,
    required this.baseUrl,
    required this.webUrl,
    required this.enableLogging,
    required this.enableCaching,
    required this.rsaPublicKey,
  });

  /// Active flavor.
  final AppFlavor flavor;

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

  /// RSA Public Key for hybrid encryption
  final String rsaPublicKey;

  /// Parsed [Uri] representation of [baseUrl].
  Uri get baseUri => Uri.parse(baseUrl);

  /// Helper getters
  bool get isDevelopment => flavor == AppFlavor.development;
  bool get isStaging => flavor == AppFlavor.staging;
  bool get isProduction => flavor == AppFlavor.production;
}

/// Loads and exposes environment configuration for the application.
class EnvironmentConfig {
  const EnvironmentConfig._(this.environment);

  /// Currently active environment.
  final AppEnvironment environment;

  static const String _envKey = 'APP_ENV';
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

  /// Loads environment variables from the specified [flavor] or compile-time config.
  static Future<void> load({AppFlavor? flavor, String? fileName}) async {
    final resolvedFlavor =
        flavor ??
        AppFlavor.values.firstWhere(
          (e) => e.name == const String.fromEnvironment(_envKey),
          orElse: () => AppFlavor.development,
        );

    final String environmentName;
    final String baseUrl;
    final String webUrl;
    final bool enableLogging;
    final bool enableCaching;
    final String rsaPublicKey;

    switch (resolvedFlavor) {
      case AppFlavor.development:
        environmentName = EnvDev.appEnv;
        baseUrl = EnvDev.apiBaseUrl;
        webUrl = EnvDev.webBaseUrl;
        enableLogging = _parseBool(EnvDev.enableLogging) ?? true;
        enableCaching = _parseBool(EnvDev.enableCaching) ?? true;
        rsaPublicKey = EnvDev.rsaPublicKey ?? AppConstants.serverRsaPublicKey;
      case AppFlavor.staging:
        environmentName = EnvStaging.appEnv;
        baseUrl = EnvStaging.apiBaseUrl;
        webUrl = EnvStaging.webBaseUrl;
        enableLogging = _parseBool(EnvStaging.enableLogging) ?? true;
        enableCaching = _parseBool(EnvStaging.enableCaching) ?? true;
        rsaPublicKey =
            EnvStaging.rsaPublicKey ?? AppConstants.serverRsaPublicKey;
      case AppFlavor.production:
        environmentName = EnvProd.appEnv;
        baseUrl = EnvProd.apiBaseUrl;
        webUrl = EnvProd.webBaseUrl;
        enableLogging = _parseBool(EnvProd.enableLogging) ?? false;
        enableCaching = _parseBool(EnvProd.enableCaching) ?? true;
        rsaPublicKey = EnvProd.rsaPublicKey ?? AppConstants.serverRsaPublicKey;
    }

    _instance = EnvironmentConfig._(
      AppEnvironment(
        flavor: resolvedFlavor,
        name: environmentName,
        baseUrl: baseUrl,
        webUrl: webUrl,
        enableLogging: enableLogging,
        enableCaching: enableCaching,
        rsaPublicKey: rsaPublicKey,
      ),
    );

    developer.log(
      '┌─── EnvironmentConfig (Envied) loaded ───\n'
      '│ flavor:   $resolvedFlavor\n'
      '│ env:      $environmentName\n'
      '│ baseUrl:  $baseUrl\n'
      '│ webUrl:   $webUrl\n'
      '│ logging:  $enableLogging\n'
      '│ caching:  $enableCaching\n'
      '└────────────────────────────────────────',
      name: 'ENV',
    );
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
