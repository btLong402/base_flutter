// lib/core/context/app_context.dart
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

/// Giữ context gốc của app (từ MaterialApp)
@lazySingleton
class AppContext {
  factory AppContext() => _instance;
  AppContext._internal();

  static final AppContext _instance = AppContext._internal();

  static BuildContext? _rootContext;

  /// Gán context (thường trong MaterialApp builder)
  set rootContext(BuildContext context) {
    _rootContext = context;
  }

  /// Lấy context an toàn
  BuildContext get rootContext {
    if (_rootContext == null) {
      throw Exception('AppContext.rootContext chưa được khởi tạo!');
    }
    return _rootContext!;
  }
}
