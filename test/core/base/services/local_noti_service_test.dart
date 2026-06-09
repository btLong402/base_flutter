import 'package:base_flutter/core/base/services/local_noti_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late LocalNotificationService notificationService;

  setUpAll(() {
    tz.initializeTimeZones();
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
  });

  setUp(() {
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    notificationService = LocalNotificationService(mockNotificationsPlugin);
  });

  group('LocalNotificationService - showInstantNotification', () {
    test('nên gọi show với các thông số tương ứng', () async {
      when(() => mockNotificationsPlugin.show(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            notificationDetails: any(named: 'notificationDetails'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async {});

      await notificationService.showInstantNotification(
        id: 1,
        title: 'Title',
        body: 'Body',
        payload: 'payload_data',
      );

      verify(() => mockNotificationsPlugin.show(
            id: 1,
            title: 'Title',
            body: 'Body',
            notificationDetails: any(named: 'notificationDetails'),
            payload: 'payload_data',
          )).called(1);
    });
  });

  group('LocalNotificationService - showScheduledNotification', () {
    test('nên gọi zonedSchedule với thời điểm và cấu hình tương ứng', () async {
      when(() => mockNotificationsPlugin.zonedSchedule(
            id: any(named: 'id'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async {});

      final scheduledTime = DateTime.now().add(const Duration(minutes: 5));

      await notificationService.showScheduledNotification(
        id: 2,
        title: 'Sched Title',
        body: 'Sched Body',
        scheduledTime: scheduledTime,
        payload: 'scheduled_payload',
      );

      verify(() => mockNotificationsPlugin.zonedSchedule(
            id: 2,
            title: 'Sched Title',
            body: 'Sched Body',
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: 'scheduled_payload',
          )).called(1);
    });
  });

  group('LocalNotificationService - showProgressNotification', () {
    test('nên gọi show với cấu hình progress tương ứng', () async {
      when(() => mockNotificationsPlugin.show(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            notificationDetails: any(named: 'notificationDetails'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async {});

      await notificationService.showProgressNotification(
        id: 3,
        title: 'Download',
        body: 'In progress...',
        maxProgress: 100,
        currentProgress: 45,
      );

      verify(() => mockNotificationsPlugin.show(
            id: 3,
            title: 'Download',
            body: 'In progress...',
            notificationDetails: any(named: 'notificationDetails'),
          )).called(1);
    });
  });

  group('LocalNotificationService - cancel & cancelAll', () {
    test('nên gọi cancel theo ID', () async {
      when(() => mockNotificationsPlugin.cancel(
            id: any(named: 'id'),
            tag: any(named: 'tag'),
          )).thenAnswer((_) async {});

      await notificationService.cancelNotification(99);

      verify(() => mockNotificationsPlugin.cancel(
            id: 99,
          )).called(1);
    });

    test('nên gọi cancelAll', () async {
      when(() => mockNotificationsPlugin.cancelAll()).thenAnswer((_) async {});

      await notificationService.cancelAllNotifications();

      verify(() => mockNotificationsPlugin.cancelAll()).called(1);
    });
  });
}
