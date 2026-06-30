import 'package:base_flutter/core/base/error/exceptions.dart';
import 'package:base_flutter/core/base/services/passkey_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/availability.dart';
import 'package:passkeys/exceptions.dart' as pk_exceptions;
import 'package:passkeys/types.dart' hide TimeoutException;

class MockPasskeyAuthenticator extends Mock implements PasskeyAuthenticator {}

class MockGetAvailability extends Mock implements GetAvailability {}

class FakeRegisterRequestType extends Fake implements RegisterRequestType {}

class FakeAuthenticateRequestType extends Fake
    implements AuthenticateRequestType {}

void main() {
  late MockPasskeyAuthenticator mockAuthenticator;
  late MockGetAvailability mockAvailability;
  late PasskeyService passkeyService;

  setUpAll(() {
    registerFallbackValue(FakeRegisterRequestType());
    registerFallbackValue(FakeAuthenticateRequestType());
  });

  setUp(() {
    mockAuthenticator = MockPasskeyAuthenticator();
    mockAvailability = MockGetAvailability();
    passkeyService = PasskeyService(mockAuthenticator);

    when(
      () => mockAuthenticator.getAvailability(),
    ).thenReturn(mockAvailability);
  });

  group('PasskeyService - cancelCurrentOperation', () {
    test(
      'nên gọi cancelCurrentAuthenticatorOperation từ authenticator',
      () async {
        when(
          () => mockAuthenticator.cancelCurrentAuthenticatorOperation(),
        ).thenAnswer((_) async {});

        await passkeyService.cancelCurrentOperation();

        verify(
          () => mockAuthenticator.cancelCurrentAuthenticatorOperation(),
        ).called(1);
      },
    );
  });

  group('PasskeyService - registerPasskey', () {
    const creationOptions = '''
    {
      "challenge": "dGVzdC1jaGFsbGVuZ2U",
      "rp": {
        "name": "Base App",
        "id": "baseapp.com"
      },
      "user": {
        "id": "dXNlci1pZA",
        "name": "testuser",
        "displayName": "Test User"
      },
      "pubKeyCredParams": [
        {
          "type": "public-key",
          "alg": -7
        }
      ],
      "excludeCredentials": []
    }
    ''';

    const mockResponseJson = <String, dynamic>{
      'id': 'credential-id',
      'rawId': 'credential-id',
      'type': 'public-key',
      'response': {
        'clientDataJSON': 'client-data-json',
        'attestationObject': 'attestation-object',
      },
      'clientExtensionResults': <String, dynamic>{},
    };

    test('nên trả về JSON string khi đăng ký thành công', () async {
      final mockResponse = RegisterResponseType.fromJson(mockResponseJson);

      when(
        () => mockAuthenticator.register(any()),
      ).thenAnswer((_) async => mockResponse);

      final result = await passkeyService.registerPasskey(creationOptions);

      expect(result, isNotEmpty);
      expect(result, contains('credential-id'));
      verify(() => mockAuthenticator.register(any())).called(1);
    });

    test(
      'nên ném AuthException khi người dùng huỷ quá trình đăng ký',
      () async {
        when(
          () => mockAuthenticator.register(any()),
        ).thenThrow(pk_exceptions.PasskeyAuthCancelledException());

        expect(
          () => passkeyService.registerPasskey(creationOptions),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains('bị hủy bởi người dùng'),
            ),
          ),
        );
      },
    );

    test(
      'nên ném TimeoutException khi quá trình đăng ký bị quá thời gian',
      () async {
        when(
          () => mockAuthenticator.register(any()),
        ).thenThrow(pk_exceptions.TimeoutException('Timeout occurred'));

        expect(
          () => passkeyService.registerPasskey(creationOptions),
          throwsA(
            isA<TimeoutException>().having(
              (e) => e.message,
              'message',
              contains('Quá thời gian xác thực Passkey'),
            ),
          ),
        );
      },
    );

    test('nên ném AppException khi có lỗi không xác định xảy ra', () async {
      when(
        () => mockAuthenticator.register(any()),
      ).thenThrow(Exception('Unknown error'));

      expect(
        () => passkeyService.registerPasskey(creationOptions),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            contains('Có lỗi không xác định xảy ra khi đăng ký Passkey'),
          ),
        ),
      );
    });
  });

  group('PasskeyService - authenticatePasskey', () {
    const requestOptions = '''
    {
      "challenge": "dGVzdC1jaGFsbGVuZ2U",
      "rpId": "baseapp.com",
      "allowCredentials": []
    }
    ''';

    const mockResponseJson = <String, dynamic>{
      'id': 'credential-id',
      'rawId': 'credential-id',
      'type': 'public-key',
      'response': {
        'clientDataJSON': 'client-data-json',
        'authenticatorData': 'authenticator-data',
        'signature': 'signature',
        'userHandle': 'user-handle',
      },
      'clientExtensionResults': <String, dynamic>{},
    };

    test('nên trả về JSON string khi xác thực thành công', () async {
      final mockResponse = AuthenticateResponseType.fromJson(mockResponseJson);

      when(
        () => mockAuthenticator.authenticate(any()),
      ).thenAnswer((_) async => mockResponse);

      final result = await passkeyService.authenticatePasskey(requestOptions);

      expect(result, isNotEmpty);
      expect(result, contains('credential-id'));
      expect(result, contains('signature'));
      verify(() => mockAuthenticator.authenticate(any())).called(1);
    });

    test(
      'nên ném AuthException khi thiết bị không tìm thấy credentials phù hợp',
      () async {
        when(
          () => mockAuthenticator.authenticate(any()),
        ).thenThrow(pk_exceptions.NoCredentialsAvailableException());

        expect(
          () => passkeyService.authenticatePasskey(requestOptions),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains('Không tìm thấy thông tin đăng ký Passkey'),
            ),
          ),
        );
      },
    );
  });
}
