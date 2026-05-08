import 'dart:async';
import 'dart:developer' as developer;

import 'package:socket_io_client/socket_io_client.dart' as sio;

/// Events emitted by the server
abstract final class SocketEvents {
  static const String chatMessage = 'chat-message';
  static const String newComment = 'new-comment';
  static const String notification = 'notification';
}

/// Events emitted by the client
abstract final class SocketActions {
  static const String register = 'register';
  static const String joinRoom = 'join-room';
  static const String leaveRoom = 'leave-room';
}

/// Data received from a `new-comment` event
class NewCommentNotification {
  const NewCommentNotification({
    required this.title,
    required this.message,
    this.data,
  });

  factory NewCommentNotification.fromJson(Map<String, dynamic> json) {
    return NewCommentNotification(
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  final String title;
  final String message;
  final Map<String, dynamic>? data;
}

/// Socket.IO service for real-time chat messaging.
///
/// Lifecycle:
/// 1. [connect] with server URL
/// 2. [register] with current userId
/// 3. [joinRoom] when entering an order/chat
/// 4. Listen to [onChatMessage] for live messages
/// 5. [leaveRoom] when leaving chat
/// 6. [disconnect] on logout
class SocketService {
  SocketService();

  sio.Socket? _socket;
  String? _currentUserId;
  String? _currentRoomId;

  // Stream controllers
  final _chatMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _newCommentController =
      StreamController<NewCommentNotification>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  /// Stream of incoming chat messages (from users in same room)
  Stream<Map<String, dynamic>> get onChatMessage =>
      _chatMessageController.stream;

  /// Stream of new comment notifications (from users NOT in room)
  Stream<NewCommentNotification> get onNewComment =>
      _newCommentController.stream;

  /// Stream of connection state changes
  Stream<bool> get onConnectionChange => _connectionController.stream;

  /// Whether the socket is currently connected
  bool get isConnected => _socket?.connected ?? false;

  /// Current room the user has joined
  String? get currentRoomId => _currentRoomId;

  /// Connect to the Socket.IO server
  void connect(String serverUrl, {String? path}) {
    if (_socket != null) {
      developer.log(
        'Socket already exists, disconnecting first',
        name: 'SocketService',
      );
      disconnect();
    }

    developer.log('Connecting to $serverUrl', name: 'SocketService');

    _socket = sio.io(
      serverUrl,
      sio.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
    );

    _setupListeners();
    _socket!.connect();
  }

  void _setupListeners() {
    final socket = _socket;
    if (socket == null) return;

    socket
      ..onConnect((_) {
        developer.log('Socket connected', name: 'SocketService');
        _connectionController.add(true);

        // Re-register if we had a userId
        if (_currentUserId != null) {
          register(_currentUserId!);
        }
        // Re-join room if we had one
        if (_currentRoomId != null) {
          joinRoom(_currentRoomId!);
        }
      })
      ..onDisconnect((_) {
        developer.log('Socket disconnected', name: 'SocketService');
        _connectionController.add(false);
      })
      ..onConnectError((error) {
        developer.log(
          'Socket connection error: $error',
          name: 'SocketService',
          level: 900,
        );
      })
      ..onError((error) {
        developer.log(
          'Socket error: $error',
          name: 'SocketService',
          level: 900,
        );
      })
      // Listen for chat messages (broadcast to room members)
      ..on(SocketEvents.chatMessage, (data) {
        developer.log('Received chat-message', name: 'SocketService');
        if (data is Map<String, dynamic>) {
          _chatMessageController.add(data);
        } else if (data is Map) {
          _chatMessageController.add(Map<String, dynamic>.from(data));
        }
      })
      // Listen for new-comment notifications (personal)
      ..on(SocketEvents.newComment, (data) {
        developer.log(
          'Received new-comment notification',
          name: 'SocketService',
        );
        if (data is Map) {
          _newCommentController.add(
            NewCommentNotification.fromJson(Map<String, dynamic>.from(data)),
          );
        }
      })
      // Listen for general notifications
      ..on(SocketEvents.notification, (data) {
        developer.log('Received notification: $data', name: 'SocketService');
      });
  }

  /// Register the current user's socket mapping
  void register(String userId) {
    _currentUserId = userId;
    _socket?.emit(SocketActions.register, userId);
    developer.log('Registered userId: $userId', name: 'SocketService');
  }

  /// Join an order's chat room
  void joinRoom(String roomId) {
    // Leave previous room if any
    if (_currentRoomId != null && _currentRoomId != roomId) {
      leaveRoom(_currentRoomId!);
    }
    _currentRoomId = roomId;
    _socket?.emit(SocketActions.joinRoom, roomId);
    developer.log('Joined room: $roomId', name: 'SocketService');
  }

  /// Leave an order's chat room
  void leaveRoom(String roomId) {
    _socket?.emit(SocketActions.leaveRoom, roomId);
    if (_currentRoomId == roomId) {
      _currentRoomId = null;
    }
    developer.log('Left room: $roomId', name: 'SocketService');
  }

  /// Disconnect and clean up
  void disconnect() {
    if (_currentRoomId != null) {
      leaveRoom(_currentRoomId!);
    }
    _currentUserId = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    developer.log('Socket disconnected & disposed', name: 'SocketService');
  }

  /// Dispose all stream controllers
  Future<void> dispose() async {
    disconnect();
    await _chatMessageController.close();
    await _newCommentController.close();
    await _connectionController.close();
  }
}
