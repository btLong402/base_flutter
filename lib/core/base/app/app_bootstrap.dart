import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_flutter/core/base/config/environment.dart';
import 'package:base_flutter/core/di/injection.dart';
import 'package:base_flutter/core/base/app/base_app.dart';

class AppBootstrap {
  static Future<void> run(AppFlavor flavor) async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Load environment configuration
    await EnvironmentConfig.load(flavor: flavor);

    // 2. Initialize Dependency Injection
    await configureInjection();

    // 3. Run the app
    runApp(const ProviderScope(child: BaseApp()));
  }
}
