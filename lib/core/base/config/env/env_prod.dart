import 'package:envied/envied.dart';

part 'env_prod.g.dart';

@Envied(path: 'assets/env/.env.production')
abstract class EnvProd {
  @EnviedField(varName: 'APP_ENV')
  static const String appEnv = _EnvProd.appEnv;

  @EnviedField(varName: 'API_BASE_URL', obfuscate: true)
  static final String apiBaseUrl = _EnvProd.apiBaseUrl;

  @EnviedField(varName: 'WEB_BASE_URL', obfuscate: true)
  static final String webBaseUrl = _EnvProd.webBaseUrl;

  @EnviedField(varName: 'ENABLE_LOGGING')
  static const String enableLogging = _EnvProd.enableLogging;

  @EnviedField(varName: 'ENABLE_CACHING')
  static const String enableCaching = _EnvProd.enableCaching;

  @EnviedField(varName: 'RSA_PUBLIC_KEY', optional: true, obfuscate: true)
  static final String? rsaPublicKey = _EnvProd.rsaPublicKey;
}
