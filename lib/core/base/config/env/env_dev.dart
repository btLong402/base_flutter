import 'package:envied/envied.dart';

part 'env_dev.g.dart';

@Envied(path: 'assets/env/.env.development')
abstract class EnvDev {
  @EnviedField(varName: 'APP_ENV')
  static const String appEnv = _EnvDev.appEnv;

  @EnviedField(varName: 'API_BASE_URL', obfuscate: true)
  static final String apiBaseUrl = _EnvDev.apiBaseUrl;

  @EnviedField(varName: 'WEB_BASE_URL', obfuscate: true)
  static final String webBaseUrl = _EnvDev.webBaseUrl;

  @EnviedField(varName: 'ENABLE_LOGGING')
  static const String enableLogging = _EnvDev.enableLogging;

  @EnviedField(varName: 'ENABLE_CACHING')
  static const String enableCaching = _EnvDev.enableCaching;

  @EnviedField(varName: 'RSA_PUBLIC_KEY', optional: true, obfuscate: true)
  static final String? rsaPublicKey = _EnvDev.rsaPublicKey;
}
