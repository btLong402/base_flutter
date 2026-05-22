import 'package:base_flutter/core/base/constants/app_constants.dart';
import 'package:base_flutter/core/base/network/cookies/secure_cookie_storage.dart';
import 'package:base_flutter/core/base/storage/secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart' as dio_cookie;

/// Centralized cookie manager for handling session and token cookies.
class AppCookieManager {
  AppCookieManager._(this._cookieJar, this._baseUri);

  final PersistCookieJar _cookieJar;
  final Uri _baseUri;
  late final dio_cookie.CookieManager _dioInterceptor =
      dio_cookie.CookieManager(_cookieJar);

  /// Factory method to create and initialize a persistent cookie jar with secure storage.
  static Future<AppCookieManager> create({
    required Uri baseUri,
    required SecureStorage secureStorage,
  }) async {
    final jar = PersistCookieJar(storage: SecureCookieStorage(secureStorage));
    return AppCookieManager._(jar, baseUri);
  }

  /// Dio interceptor that syncs cookies between requests and responses.
  dio_cookie.CookieManager get dioInterceptor => _dioInterceptor;

  /// Returns the base URI associated with the cookie jar.
  Uri get baseUri => _baseUri;

  /// Loads cookies for the provided [uri] (or default base URI).
  Future<List<Cookie>> loadForRequest(Uri? uri) {
    return _cookieJar.loadForRequest(_effectiveUri(uri));
  }

  /// Retrieves a cookie by [name].
  Future<String?> getCookieValue(String name, {Uri? uri}) async {
    final targetUri = _effectiveUri(uri);
    final cookies = await _cookieJar.loadForRequest(targetUri);
    for (final cookie in cookies) {
      if (cookie.name == name) {
        return cookie.value;
      }
    }
    return null;
  }

  /// Saves a cookie value for subsequent requests.
  Future<void> saveCookie(
    String name,
    String value, {
    Uri? uri,
    String path = AppConstants.cookiePath,
    bool? secure,
    bool httpOnly = true,
    int? maxAge,
    DateTime? expires,
  }) async {
    final targetUri = _effectiveUri(uri);
    final cookie = Cookie(name, value)
      ..domain = targetUri.host
      ..path = path
      ..httpOnly = httpOnly
      ..secure = secure ?? targetUri.scheme == 'https';

    if (maxAge != null) {
      cookie.maxAge = maxAge;
    }

    if (expires != null) {
      cookie.expires = expires;
    }

    await _cookieJar.saveFromResponse(targetUri, [cookie]);
  }

  /// Deletes a cookie by setting its max age to zero.
  Future<void> deleteCookie(String name, {Uri? uri}) async {
    final targetUri = _effectiveUri(uri);
    final expiredCookie = Cookie(name, 'deleted')
      ..domain = targetUri.host
      ..path = AppConstants.cookiePath
      ..maxAge = 0
      ..expires = DateTime.fromMillisecondsSinceEpoch(0)
      ..secure = targetUri.scheme == 'https'
      ..httpOnly = true;

    await _cookieJar.saveFromResponse(targetUri, [expiredCookie]);
  }

  /// Clears all stored cookies.
  Future<void> clearAll() => _cookieJar.deleteAll();

  /// Returns the effective URI used to resolve cookie scopes.
  Uri _effectiveUri(Uri? uri) {
    if (uri == null || uri.host.isEmpty) {
      return _baseUri;
    }
    // Ensure the URI always has a scheme for correct cookie domain matching.
    if (uri.scheme.isEmpty) {
      return _baseUri.replace(path: uri.path, query: uri.query);
    }
    return uri;
  }
}
