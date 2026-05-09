import 'package:base_flutter/core/base/app/base_app.dart';
import 'package:base_flutter/core/base/config/environment.dart';
import 'package:base_flutter/core/base/storage/local_storage.dart';
import 'package:base_flutter/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class AppBootstrap {
  static Future<void> run(AppFlavor flavor) async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Load environment configuration
    await EnvironmentConfig.load(flavor: flavor);
    // Initialize Local Storage (SharedPreferences)
    await LocalStorage.init();

    // Initialize Hive for caching
    await Hive.initFlutter();
    // 2. Initialize Dependency Injection
    await configureInjection();

    // 3. Run the app
    runApp(const ProviderScope(child: BaseApp()));
  }
}
