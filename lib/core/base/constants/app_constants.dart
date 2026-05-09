/// Application-wide constants
class AppConstants {
  AppConstants._();

  static const String baseUrl = 'https://api.example.com';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String userKey = 'user_data';
  static const String storeKey = 'app_store_code';
  static const String cryptoAesKey = 'crypto_aes_key';
  static const String cryptoAesIv = 'crypto_aes_iv';
  static const String cryptoKeyCreatedAt = 'crypto_key_created_at';
  static const String serverRsaPublicKey = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA75N...[Thay bằng Key thật]...
-----END PUBLIC KEY-----''';

  // Network Extra Keys
  static const String secureExtraKey = 'secure';

  // Cookie Keys
  static const String accessTokenCookieName = 'accessToken';
  static const String refreshTokenCookieName = 'refreshToken';
  static const String cookiePath = '/';

  // Cache
  static const Duration cacheMaxAge = Duration(hours: 1);
  static const int cacheMaxStale = 7;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Error Codes
  static const int expiredKeyStatus = 498;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration buttonThrottle = Duration(milliseconds: 300);
}

/// HTTP Headers
class AppHttpHeaders {
  AppHttpHeaders._();
  static const String authorization = 'Authorization';
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String acceptLanguage = 'Accept-Language';
  static const String xEncrypted = 'X-Encrypted';
  static const String xKey = 'X-Key';
}
