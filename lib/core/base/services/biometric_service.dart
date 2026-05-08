import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

/// Service quản lý xác thực sinh trắc học (Face ID / Fingerprint)
/// và lưu trữ credentials an toàn trong Keychain/Keystore.
@lazySingleton
class BiometricService {
  BiometricService(this._secureStorage, this._localAuth);

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  // Keys cho secure storage
  static const _keyUsername = 'base_username';
  static const _keyToken = 'base_token';
  static const _keyUser = 'base_user';
  static const _keyEnabled = 'base_enabled';

  /// Kiểm tra thiết bị có hỗ trợ biometrics (Face ID / Fingerprint)
  Future<bool> isDeviceSupported() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } on Object catch (_) {
      return false;
    }
  }

  /// Lấy danh sách loại biometrics khả dụng
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on Object catch (_) {
      return [];
    }
  }

  /// Kiểm tra biometric đã được kích hoạt (có credentials đã lưu)
  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _keyEnabled);
      return enabled == 'true';
    } on Object catch (_) {
      return false;
    }
  }

  /// Kiểm tra có credentials đã lưu hay không (token + username)
  Future<bool> hasSavedCredentials() async {
    try {
      final username = await _secureStorage.read(key: _keyUsername);
      final token = await _secureStorage.read(key: _keyToken);
      final enabled = await _secureStorage.read(key: _keyEnabled);
      return username != null &&
          username.isNotEmpty &&
          token != null &&
          token.isNotEmpty &&
          enabled == 'true';
    } on Object catch (_) {
      return false;
    }
  }

  /// Lấy username đã lưu (để kiểm tra thay đổi tài khoản)
  Future<String?> getSavedUsername() async {
    try {
      return await _secureStorage.read(key: _keyUsername);
    } on Object catch (_) {
      return null;
    }
  }

  /// Lấy token đã lưu
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _keyToken);
    } on Object catch (_) {
      return null;
    }
  }

  /// Lấy raw user JSON đã lưu
  Future<Map<String, dynamic>?> getUserJson() async {
    try {
      final raw = await _secureStorage.read(key: _keyUser);
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } on Object catch (_) {
      return null;
    }
  }

  /// Xác thực bằng biometrics (Face ID / Fingerprint)
  /// Trả về `true` nếu xác thực thành công.
  Future<bool> authenticate({String reason = 'Xác thực để đăng nhập'}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );
    } on Object catch (_) {
      return false;
    }
  }

  /// Lưu thông tin phiên sau khi Face ID xác nhận thành công.
  /// Lưu token + user JSON + username vào Keychain (iOS) / Keystore (Android).
  Future<void> saveSession({
    required String username,
    required String token,
    required Map<String, dynamic> userJson,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _keyUsername, value: username),
      _secureStorage.write(key: _keyToken, value: token),
      _secureStorage.write(key: _keyUser, value: jsonEncode(userJson)),
      _secureStorage.write(key: _keyEnabled, value: 'true'),
    ]);
  }

  /// Xóa tất cả biometric credentials.
  /// Gọi khi đổi mật khẩu, tắt biometric, hoặc đăng nhập tài khoản khác.
  Future<void> clearCredentials() async {
    await Future.wait([
      _secureStorage.delete(key: _keyUsername),
      _secureStorage.delete(key: _keyToken),
      _secureStorage.delete(key: _keyUser),
      _secureStorage.delete(key: _keyEnabled),
    ]);
  }
}
