// The @pragma('vm:entry-point') annotation on the background handler
// causes the Dart analyzer to treat this file as an executable entry point,
// which triggers false positive warnings that FcmService is unreachable.

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:base_flutter/core/base/services/local_noti_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

/// Hàm xử lý thông báo chạy ngầm (Background/Terminated Message Handler).
/// Bắt buộc phải là hàm top-level hoặc static method và được gắn tag `@pragma('vm:entry-point')`.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log(
    'Nhận thông báo chạy ngầm (Background Message ID): ${message.messageId}',
    name: 'fcm.service',
  );
}

/// Dịch vụ quản lý thông báo đẩy Firebase Cloud Messaging (FCM).
/// Hỗ trợ xử lý thông báo khi ứng dụng chạy ở foreground, background, bị tắt (terminated),
/// quản lý token, đăng ký chủ đề (topic), và phân quyền.
@lazySingleton
class FcmService {
  FcmService(this._firebaseMessaging, this._localNotificationService);

  final FirebaseMessaging _firebaseMessaging;
  final LocalNotificationService _localNotificationService;

  // Stream nhận sự kiện click vào thông báo (chứa dữ liệu data payload)
  final StreamController<Map<String, dynamic>> _notificationClickStream =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onClickNotification =>
      _notificationClickStream.stream;

  // Subscription để quản lý vòng đời lắng nghe click từ LocalNotificationService
  StreamSubscription<String?>? _localNotiClickSubscription;

  /// Khởi tạo và đăng ký lắng nghe các luồng sự kiện của FCM.
  Future<void> initialize() async {
    try {
      // 1. Đăng ký hàm xử lý thông báo chạy ngầm
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 2. Lắng nghe thông báo ở chế độ foreground (app đang mở)
      FirebaseMessaging.onMessage.listen((message) {
        developer.log(
          'Nhận thông báo Foreground: ${message.notification?.title}',
          name: 'fcm.service',
        );
        _handleForegroundMessage(message);
      });

      // 3. Lắng nghe người dùng nhấp vào thông báo khi app đang ở background
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        developer.log(
          'Người dùng nhấp mở thông báo từ chế độ Background',
          name: 'fcm.service',
        );
        _handleNotificationClick(message.data);
      });

      // 4. Lắng nghe nhấp chuột thông báo được chuyển tiếp từ LocalNotificationService (khi hiển thị ở foreground)
      _localNotiClickSubscription = _localNotificationService
          .onClickNotification
          .listen((payload) {
            if (payload != null && payload.isNotEmpty) {
              try {
                final data = jsonDecode(payload) as Map<String, dynamic>;
                _handleNotificationClick(data);
              } on Object catch (_) {
                // Trường hợp payload không phải JSON, gửi dạng map rỗng hoặc chứa payload gốc
                _handleNotificationClick({'payload': payload});
              }
            }
          });

      // 5. Kiểm tra xem ứng dụng có được khởi động từ một thông báo khi bị tắt hoàn toàn hay không
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        developer.log(
          'Ứng dụng được mở từ thông báo (Terminated state)',
          name: 'fcm.service',
        );
        _handleNotificationClick(initialMessage.data);
      }

      developer.log('Khởi tạo FcmService thành công', name: 'fcm.service');
    } on Object catch (e, s) {
      developer.log(
        'Lỗi khởi tạo FcmService',
        name: 'fcm.service',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Yêu cầu cấp quyền hiển thị thông báo.
  /// Trả về `true` nếu người dùng đồng ý cấp quyền.
  Future<bool> requestNotificationPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission();

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      developer.log(
        'Trạng thái quyền thông báo FCM: ${settings.authorizationStatus}',
        name: 'fcm.service',
      );
      return granted;
    } on Object catch (e, s) {
      developer.log(
        'Lỗi yêu cầu quyền thông báo FCM',
        name: 'fcm.service',
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

  /// Lấy FCM Token hiện tại để gửi lên Backend lưu trữ.
  Future<String?> getFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      developer.log('Đã lấy FCM Token thành công', name: 'fcm.service');
      return token;
    } on Object catch (e, s) {
      developer.log(
        'Lỗi lấy FCM Token',
        name: 'fcm.service',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  /// Thu hồi/Xoá FCM Token hiện tại (thường gọi khi người dùng Đăng xuất).
  Future<void> deleteFcmToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      developer.log('Xoá FCM Token thành công', name: 'fcm.service');
    } on Object catch (e, s) {
      developer.log(
        'Lỗi xoá FCM Token',
        name: 'fcm.service',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Stream thông báo khi FCM Token tự động làm mới/thay đổi.
  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  /// Đăng ký thiết bị nhận thông báo theo chủ đề (Topic).
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      developer.log(
        'Đăng ký nhận Topic thành công: $topic',
        name: 'fcm.service',
      );
    } on Object catch (e, s) {
      developer.log(
        'Lỗi đăng ký nhận Topic: $topic',
        name: 'fcm.service',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Hủy đăng ký nhận thông báo theo chủ đề (Topic).
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      developer.log('Huỷ nhận Topic thành công: $topic', name: 'fcm.service');
    } on Object catch (e, s) {
      developer.log(
        'Lỗi huỷ nhận Topic: $topic',
        name: 'fcm.service',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Xử lý hiển thị thông báo chế độ foreground bằng cách chuyển hướng qua LocalNotificationService.
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final id =
        message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch;

    unawaited(
      _localNotificationService.showInstantNotification(
        id: id,
        title: notification.title ?? '',
        body: notification.body ?? '',
        isHighPriority: true,
        payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
      ),
    );
  }

  /// Phát tín hiệu click thông báo và đẩy data payload qua Stream.
  void _handleNotificationClick(Map<String, dynamic> data) {
    developer.log(
      'Người dùng nhấp vào thông báo, dữ liệu data: $data',
      name: 'fcm.service',
    );
    _notificationClickStream.add(data);
  }

  /// Giải phóng tài nguyên.
  void dispose() {
    unawaited(_localNotiClickSubscription?.cancel());
    unawaited(_notificationClickStream.close());
  }
}
