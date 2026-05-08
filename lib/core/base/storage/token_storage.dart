import 'package:base_flutter/core/base/constants/app_constants.dart';
import 'package:base_flutter/core/base/network/cookies/app_cookie_manager.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Token storage that sources authentication tokens from cookies.
class TokenStorage {
  TokenStorage(this._cookieManager);

  final AppCookieManager _cookieManager;

  /// Get access token from cookies.
  Future<String?> getToken({Uri? uri}) {
    return _cookieManager.getCookieValue(
      AppConstants.accessTokenCookieName,
      uri: uri,
    );
  }

  /// Save access token into cookie jar (useful for mocks or manual overrides).
  Future<bool> saveToken(String token, {Uri? uri}) async {
    await _cookieManager.saveCookie(
      AppConstants.accessTokenCookieName,
      token,
      uri: uri,
    );
    return true;
  }

  /// Get refresh token from cookies.
  Future<String?> getRefreshToken({Uri? uri}) {
    return _cookieManager.getCookieValue(
      AppConstants.refreshTokenCookieName,
      uri: uri,
    );
  }

  /// Save refresh token into cookie jar.
  Future<bool> saveRefreshToken(String token, {Uri? uri}) async {
    await _cookieManager.saveCookie(
      AppConstants.refreshTokenCookieName,
      token,
      uri: uri,
    );
    return true;
  }

  /// Save both tokens in a single operation.
  Future<bool> saveTokens(
    String accessToken,
    String refreshToken, {
    Uri? uri,
  }) async {
    await Future.wait([
      saveToken(accessToken, uri: uri),
      saveRefreshToken(refreshToken, uri: uri),
    ]);
    return true;
  }

  /// Clear authentication tokens from cookies.
  Future<bool> clearTokens({Uri? uri}) async {
    await Future.wait([
      _cookieManager.deleteCookie(AppConstants.accessTokenCookieName, uri: uri),
      _cookieManager.deleteCookie(
        AppConstants.refreshTokenCookieName,
        uri: uri,
      ),
    ]);
    return true;
  }

  /// Check if user has a valid refresh token.
  Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.isNotEmpty && !isTokenExpired(token);
  }

  /// Check if a JWT token is expired.
  bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } on Object catch (_) {
      // If not a valid JWT or error decoding, assume expired/invalid
      return true;
    }
  }

  /// Check if a token is valid (not empty and not expired).
  bool isTokenValid(String? token) {
    return token != null && token.isNotEmpty && !isTokenExpired(token);
  }

  /// Check if user is authenticated.
  ///
  /// Returns true if either access token or refresh token exists and is valid.
  /// When only refresh token exists, the app should attempt a token refresh.
  Future<bool> isAuthenticated() async {
    final results = await Future.wait([getToken(), getRefreshToken()]);

    return isTokenValid(results[0]) || isTokenValid(results[1]);
  }
}
