import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Dịch vụ quản lý và hiển thị thông báo nội bộ (Local Notification).
/// Hỗ trợ nhiều kịch bản hiển thị: tức thì, lên lịch, lặp lại, hiển thị tiến trình, và nhóm thông báo.
@lazySingleton
class LocalNotificationService {
  LocalNotificationService(this._notificationsPlugin);

  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  // Stream thông báo phản hồi click của người dùng
  final StreamController<String?> _notificationClickStream =
      StreamController<String?>.broadcast();

  Stream<String?> get onClickNotification => _notificationClickStream.stream;

  // Cấu hình Channel mặc định cho Android
  static const _defaultChannelId = 'default_channel';
  static const _defaultChannelName = 'Default Notifications';
  static const _defaultChannelDesc = 'Kênh nhận thông báo mặc định của hệ thống';

  static const _highChannelId = 'high_importance_channel';
  static const _highChannelName = 'High Importance Notifications';
  static const _highChannelDesc = 'Kênh nhận thông báo khẩn cấp/quan trọng';

  static const _silentChannelId = 'silent_channel';
  static const _silentChannelName = 'Silent Notifications';
  static const _silentChannelDesc = 'Kênh nhận thông báo im lặng';

  /// Khởi tạo dịch vụ, thiết lập cấu hình và múi giờ.
  Future<void> initialize() async {
    try {
      // 1. Khởi tạo múi giờ
      tz.initializeTimeZones();
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final timeZoneName = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      developer.log(
        'Khởi tạo múi giờ thành công: $timeZoneName',
        name: 'local_notification.service',
      );

      // 2. Thiết lập cấu hình Android
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. Thiết lập cấu hình iOS (Darwin)
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 4. Khởi tạo plugin
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          developer.log(
            'Người dùng bấm vào thông báo với payload: $payload',
            name: 'local_notification.service',
          );
          _notificationClickStream.add(payload);
        },
      );

      // 5. Tạo các notification channels mặc định cho Android
      await _createAndroidChannels();

      developer.log(
        'Khởi tạo LocalNotificationService thành công',
        name: 'local_notification.service',
      );
    } on Object catch (e, s) {
      developer.log(
        'Lỗi khởi tạo LocalNotificationService',
        name: 'local_notification.service',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Tạo các kênh thông báo cho Android.
  Future<void> _createAndroidChannels() async {
    if (!Platform.isAndroid) return;

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) return;

    const defaultChannel = AndroidNotificationChannel(
      _defaultChannelId,
      _defaultChannelName,
      description: _defaultChannelDesc,
    );

    // Kênh thông báo khẩn cấp / heads-up
    const highChannel = AndroidNotificationChannel(
      _highChannelId,
      _highChannelName,
      description: _highChannelDesc,
      importance: Importance.max,
    );

    // Kênh thông báo im lặng
    const silentChannel = AndroidNotificationChannel(
      _silentChannelId,
      _silentChannelName,
      description: _silentChannelDesc,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    await Future.wait([
      androidImplementation.createNotificationChannel(defaultChannel),
      androidImplementation.createNotificationChannel(highChannel),
      androidImplementation.createNotificationChannel(silentChannel),
    ]);
  }

  /// Yêu cầu quyền thông báo từ người dùng.
  /// Trả về `true` nếu được cấp quyền thành công.
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidImplementation?.requestNotificationsPermission();
        return granted ?? false;
      } else if (Platform.isIOS) {
        final iosImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      return false;
    } on Object catch (e, s) {
      developer.log(
        'Lỗi yêu cầu cấp quyền thông báo',
        name: 'local_notification.service',
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

  /// Hiển thị thông báo tức thời.
  ///
  /// [id]: Mã định danh thông báo.
  /// [title]: Tiêu đề thông báo.
  /// [body]: Nội dung thông báo.
  /// [payload]: Dữ liệu đính kèm.
  /// [isHighPriority]: Thiết lập độ ưu tiên cao (Heads-up).
  /// [isSilent]: Thiết lập thông báo im lặng.
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isHighPriority = false,
    bool isSilent = false,
  }) async {
    try {
      final channelId = isSilent
          ? _silentChannelId
          : (isHighPriority ? _highChannelId : _defaultChannelId);
      final channelName = isSilent
          ? _silentChannelName
          : (isHighPriority ? _highChannelName : _defaultChannelName);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: isSilent
            ? Importance.low
            : (isHighPriority ? Importance.max : Importance.defaultImportance),
        priority: isSilent
            ? Priority.low
            : (isHighPriority ? Priority.high : Priority.defaultPriority),
        playSound: !isSilent,
        enableVibration: !isSilent,
      );

      const iosDetails = DarwinNotificationDetails();

      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } on Object catch (e, s) {
      developer.log(
        'Lỗi hiển thị thông báo tức thời',
        name: 'local_notification.service',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Lên lịch hiển thị thông báo một lần tại một thời điểm xác định trong tương lai.
  ///
  /// [id]: Mã định danh thông báo.
  /// [title]: Tiêu đề thông báo.
  /// [body]: Nội dung thông báo.
  /// [scheduledTime]: Thời điểm muốn hiển thị thông báo.
  /// [payload]: Dữ liệu đính kèm.
  /// [isHighPriority]: Thiết lập độ ưu tiên cao (Heads-up).
  Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    bool isHighPriority = false,
  }) async {
    try {
      final channelId = isHighPriority ? _highChannelId : _defaultChannelId;
      final channelName = isHighPriority ? _highChannelName : _defaultChannelName;

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: isHighPriority ? Importance.max : Importance.defaultImportance,
        priority: isHighPriority ? Priority.high : Priority.defaultPriority,
      );

      const iosDetails = DarwinNotificationDetails();

      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDateTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } on Object catch (e, s) {
      developer.log(
        'Lỗi lên lịch hiển thị thông báo',
        name: 'local_notification.service',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Lên lịch lặp lại hàng ngày vào một khung giờ cố định.
  ///
  /// [id]: Mã định danh thông báo.
  /// [title]: Tiêu đề thông báo.
  /// [body]: Nội dung thông báo.
  /// [hour]: Giờ lặp lại.
  /// [minute]: Phút lặp lại.
  /// [payload]: Dữ liệu đính kèm.
  Future<void> showDailyRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Nếu giờ lên lịch nhỏ hơn giờ hiện tại, chuyển sang ngày mai
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        _defaultChannelId,
        _defaultChannelName,
      );

      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } on Object catch (e, s) {
      developer.log(
        'Lỗi thiết lập thông báo lặp lại hàng ngày',
        name: 'local_notification.service',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Hiển thị thông báo tiến trình (Progress Bar Notification).
  ///
  /// [id]: Mã định danh thông báo.
  /// [title]: Tiêu đề thông báo.
  /// [body]: Nội dung thông báo.
  /// [maxProgress]: Tiến trình tối đa (ví dụ 100).
  /// [currentProgress]: Tiến trình hiện tại.
  /// [indeterminate]: Tiến trình vô định (chạy liên tục không số).
  /// [payload]: Dữ liệu đính kèm.
  Future<void> showProgressNotification({
    required int id,
    required String title,
    required String body,
    required int maxProgress,
    required int currentProgress,
    bool indeterminate = false,
    String? payload,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _silentChannelId,
        _silentChannelName,
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        maxProgress: maxProgress,
        progress: currentProgress,
        indeterminate: indeterminate,
        onlyAlertOnce: true,
      );

      const iosDetails = DarwinNotificationDetails();
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } on Object catch (e, s) {
      developer.log(
        'Lỗi hiển thị thông báo tiến trình',
        name: 'local_notification.service',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Hiển thị một nhóm thông báo (Grouped/Inbox notifications) trên Android.
  /// Để nhóm hoạt động, các thông báo cần có cùng `groupKey` và cần tạo một thông báo Summary đại diện.
  Future<void> showGroupedNotifications({
    required String groupKey,
    required String groupName,
    required List<Map<String, String>> messages, // Mỗi item có 'title' và 'body'
    required String summaryTitle,
    required String summaryBody,
  }) async {
    try {
      // 1. Gửi từng thông báo con trong nhóm
      for (var i = 0; i < messages.length; i++) {
        final msg = messages[i];
        final childAndroidDetails = AndroidNotificationDetails(
          _defaultChannelId,
          _defaultChannelName,
          groupKey: groupKey,
        );

        final childDetails = NotificationDetails(
          android: childAndroidDetails,
          iOS: const DarwinNotificationDetails(),
        );

        await _notificationsPlugin.show(
          id: groupKey.hashCode + i + 1,
          title: msg['title'],
          body: msg['body'],
          notificationDetails: childDetails,
        );
      }

      // 2. Tạo thông báo Summary đại diện cho nhóm (Bắt buộc cho Android)
      final inboxStyle = InboxStyleInformation(
        messages.map((m) => '${m['title']}: ${m['body']}').toList(),
        contentTitle: summaryTitle,
        summaryText: summaryBody,
      );

      final summaryAndroidDetails = AndroidNotificationDetails(
        _defaultChannelId,
        _defaultChannelName,
        styleInformation: inboxStyle,
        groupKey: groupKey,
        setAsGroupSummary: true,
      );

      final summaryDetails = NotificationDetails(
        android: summaryAndroidDetails,
        iOS: const DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        id: groupKey.hashCode,
        title: summaryTitle,
        body: summaryBody,
        notificationDetails: summaryDetails,
      );
    } on Object catch (e, s) {
      developer.log(
        'Lỗi hiển thị nhóm thông báo',
        name: 'local_notification.service',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Huỷ một thông báo cụ thể theo ID.
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } on Object catch (e, s) {
      developer.log(
        'Lỗi huỷ thông báo ID: $id',
        name: 'local_notification.service',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Huỷ tất cả thông báo đang hiển thị hoặc được lên lịch.
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } on Object catch (e, s) {
      developer.log(
        'Lỗi huỷ toàn bộ thông báo',
        name: 'local_notification.service',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Giải phóng tài nguyên.
  void dispose() {
    unawaited(_notificationClickStream.close());
  }
}
