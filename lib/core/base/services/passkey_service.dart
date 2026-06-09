import 'dart:developer' as developer;
import 'dart:io';
import 'package:base_flutter/core/base/error/exceptions.dart';
import 'package:injectable/injectable.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/exceptions.dart' as pk_exceptions;
import 'package:passkeys/types.dart' hide TimeoutException;

/// Dịch vụ quản lý xác thực bằng Passkey (FIDO2/WebAuthn).
/// Hỗ trợ đăng ký (Registration) và đăng nhập (Authentication) không mật khẩu.
@lazySingleton
class PasskeyService {
  PasskeyService(this._authenticator);

  final PasskeyAuthenticator _authenticator;

  /// Kiểm tra thiết bị hiện tại có hỗ trợ Passkey hay không.
  Future<bool> isDeviceSupported() async {
    try {
      if (Platform.isAndroid) {
        final availability = await _authenticator.getAvailability().android();
        return availability.hasPasskeySupport;
      } else if (Platform.isIOS) {
        final availability = await _authenticator.getAvailability().iOS();
        return availability.hasPasskeySupport;
      }
      return false;
    } on Object catch (e, s) {
      developer.log(
        'Lỗi kiểm tra tính khả dụng của Passkey',
        name: 'passkey.service',
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

  /// Kiểm tra xem thiết bị đã đăng ký mã xác thực sinh trắc học để dùng Passkey chưa.
  Future<bool> hasBiometricsEnrolled() async {
    try {
      if (Platform.isIOS) {
        final availability = await _authenticator.getAvailability().iOS();
        return availability.hasBiometrics;
      } else if (Platform.isAndroid) {
        final availability = await _authenticator.getAvailability().android();
        return availability.isUserVerifyingPlatformAuthenticatorAvailable ?? false;
      }
      return false;
    } on Object catch (e, s) {
      developer.log(
        'Lỗi kiểm tra tính khả dụng sinh trắc học cho Passkey',
        name: 'passkey.service',
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

  /// Huỷ tác vụ Passkey hiện tại nếu có.
  Future<void> cancelCurrentOperation() async {
    try {
      await _authenticator.cancelCurrentAuthenticatorOperation();
    } on Object catch (e, s) {
      developer.log(
        'Lỗi huỷ tác vụ Passkey',
        name: 'passkey.service',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Đăng ký (Tạo mới) Passkey từ JSON options gửi từ Relying Party Server (Backend).
  ///
  /// [optionsJsonString] là chuỗi cấu hình `publicKeyCredentialCreationOptions` của WebAuthn.
  /// Trả về chuỗi JSON chứa kết quả tạo khóa để gửi ngược lại Server xác thực.
  Future<String> registerPasskey(String optionsJsonString) async {
    try {
      developer.log('Bắt đầu quá trình đăng ký Passkey', name: 'passkey.service');
      final request = RegisterRequestType.fromJsonString(optionsJsonString);
      final response = await _authenticator.register(request);
      developer.log('Đăng ký Passkey thành công', name: 'passkey.service');
      return response.toJsonString();
    } on pk_exceptions.AuthenticatorException catch (e, s) {
      _handleAuthenticatorException('đăng ký', e, s);
    } on Object catch (e, s) {
      developer.log(
        'Lỗi không xác định khi đăng ký Passkey',
        name: 'passkey.service',
        error: e,
        stackTrace: s,
      );
      throw AppException(
        message: 'Có lỗi không xác định xảy ra khi đăng ký Passkey: $e',
      );
    }
  }

  /// Xác thực (Đăng nhập) bằng Passkey từ JSON options gửi từ Relying Party Server (Backend).
  ///
  /// [optionsJsonString] là chuỗi cấu hình `publicKeyCredentialRequestOptions` của WebAuthn.
  /// Trả về chuỗi JSON chứa thông tin chữ ký để gửi ngược lại Server xác thực.
  Future<String> authenticatePasskey(String optionsJsonString) async {
    try {
      developer.log('Bắt đầu quá trình xác thực Passkey', name: 'passkey.service');
      final request = AuthenticateRequestType.fromJsonString(optionsJsonString);
      final response = await _authenticator.authenticate(request);
      developer.log('Xác thực Passkey thành công', name: 'passkey.service');
      return response.toJsonString();
    } on pk_exceptions.AuthenticatorException catch (e, s) {
      _handleAuthenticatorException('xác thực', e, s);
    } on Object catch (e, s) {
      developer.log(
        'Lỗi không xác định khi xác thực Passkey',
        name: 'passkey.service',
        error: e,
        stackTrace: s,
      );
      throw AppException(
        message: 'Có lỗi không xác định xảy ra khi xác thực Passkey: $e',
      );
    }
  }

  /// Chuyển đổi ngoại lệ từ thư viện `passkeys` thành định dạng `AppException` chuẩn của ứng dụng.
  Never _handleAuthenticatorException(
    String flow,
    pk_exceptions.AuthenticatorException e,
    StackTrace s,
  ) {
    developer.log(
      'Tác vụ $flow thất bại',
      name: 'passkey.service',
      error: e,
      stackTrace: s,
    );

    if (e is pk_exceptions.PasskeyAuthCancelledException) {
      throw AuthException(message: 'Yêu cầu xác thực Passkey bị hủy bởi người dùng.');
    } else if (e is pk_exceptions.MissingGoogleSignInException) {
      throw AuthException(
        message: 'Cần đăng nhập tài khoản Google trên thiết bị này để sử dụng Passkey.',
      );
    } else if (e is pk_exceptions.SyncAccountNotAvailableException) {
      throw AuthException(
        message: 'Tài khoản đồng bộ đám mây (iCloud/Google) chưa sẵn sàng.',
      );
    } else if (e is pk_exceptions.NoCredentialsAvailableException) {
      throw AuthException(
        message: 'Không tìm thấy thông tin đăng ký Passkey phù hợp trên thiết bị.',
      );
    } else if (e is pk_exceptions.DeviceNotSupportedException) {
      throw AuthException(
        message: 'Thiết bị này không hỗ trợ xác thực bằng Passkey.',
      );
    } else if (e is pk_exceptions.DomainNotAssociatedException) {
      throw AuthException(
        message: 'Tên miền chưa được liên kết chính xác với ứng dụng: ${e.message}',
      );
    } else if (e is pk_exceptions.NoCreateOptionException) {
      throw AuthException(
        message: 'Không tìm thấy tùy chọn tạo khóa tương thích trên thiết bị.',
      );
    } else if (e is pk_exceptions.TimeoutException) {
      throw TimeoutException(
        message: 'Quá thời gian xác thực Passkey. Vui lòng thử lại.',
      );
    } else if (e is pk_exceptions.MalformedBase64Url) {
      throw ValidationException(
        message: 'Dữ liệu challenge hoặc thông tin người dùng từ máy chủ bị lỗi định dạng Base64URL.',
      );
    } else if (e is pk_exceptions.UnhandledAuthenticatorException) {
      throw AppException(
        message: 'Lỗi xác thực hệ thống chưa được hỗ trợ (code: ${e.code}): ${e.message}',
      );
    } else {
      throw AppException(
        message: 'Lỗi xác thực hệ thống không xác định: $e',
      );
    }
  }
}
