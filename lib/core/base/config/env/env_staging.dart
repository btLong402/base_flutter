import 'package:envied/envied.dart';

part 'env_staging.g.dart';

@Envied(path: 'assets/env/.env.staging')
abstract class EnvStaging {
  @EnviedField(varName: 'APP_ENV')
  static const String appEnv = _EnvStaging.appEnv;

  @EnviedField(varName: 'API_BASE_URL', obfuscate: true)
  static final String apiBaseUrl = _EnvStaging.apiBaseUrl;

  @EnviedField(varName: 'WEB_BASE_URL', obfuscate: true)
  static final String webBaseUrl = _EnvStaging.webBaseUrl;

  @EnviedField(varName: 'ENABLE_LOGGING')
  static const String enableLogging = _EnvStaging.enableLogging;

  @EnviedField(varName: 'ENABLE_CACHING')
  static const String enableCaching = _EnvStaging.enableCaching;

  @EnviedField(varName: 'RSA_PUBLIC_KEY', optional: true, obfuscate: true)
  static final String? rsaPublicKey = _EnvStaging.rsaPublicKey;
}
