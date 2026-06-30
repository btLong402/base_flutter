import 'package:base_flutter/core/base/services/fcm_service.dart';
import 'package:base_flutter/core/base/services/local_noti_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockLocalNotificationService extends Mock
    implements LocalNotificationService {}

void main() {
  late MockFirebaseMessaging mockFirebaseMessaging;
  late MockLocalNotificationService mockLocalNotificationService;
  late FcmService fcmService;

  setUp(() {
    mockFirebaseMessaging = MockFirebaseMessaging();
    mockLocalNotificationService = MockLocalNotificationService();
    fcmService = FcmService(
      mockFirebaseMessaging,
      mockLocalNotificationService,
    );
  });

  group('FcmService - Thao tác Token', () {
    test('nên lấy được FCM Token thành công', () async {
      when(
        () => mockFirebaseMessaging.getToken(),
      ).thenAnswer((_) async => 'mock_fcm_token');

      final token = await fcmService.getFcmToken();

      expect(token, 'mock_fcm_token');
      verify(() => mockFirebaseMessaging.getToken()).called(1);
    });

    test('nên gọi deleteToken khi xóa FCM Token', () async {
      when(() => mockFirebaseMessaging.deleteToken()).thenAnswer((_) async {});

      await fcmService.deleteFcmToken();

      verify(() => mockFirebaseMessaging.deleteToken()).called(1);
    });
  });

  group('FcmService - Đăng ký Topic', () {
    test('nên đăng ký topic thành công', () async {
      when(
        () => mockFirebaseMessaging.subscribeToTopic(any()),
      ).thenAnswer((_) async {});

      await fcmService.subscribeToTopic('promotion');

      verify(
        () => mockFirebaseMessaging.subscribeToTopic('promotion'),
      ).called(1);
    });

    test('nên hủy đăng ký topic thành công', () async {
      when(
        () => mockFirebaseMessaging.unsubscribeFromTopic(any()),
      ).thenAnswer((_) async {});

      await fcmService.unsubscribeFromTopic('promotion');

      verify(
        () => mockFirebaseMessaging.unsubscribeFromTopic('promotion'),
      ).called(1);
    });
  });
}
