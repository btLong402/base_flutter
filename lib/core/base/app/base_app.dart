import 'package:base_flutter/core/base/config/environment.dart';
import 'package:base_flutter/core/base/theme/theme_provider.dart';
import 'package:base_flutter/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BaseApp extends HookConsumerWidget {
  const BaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = EnvironmentConfig.current;
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final lightTheme = ref.watch(lightThemeProvider);
        final darkTheme = ref.watch(darkThemeProvider);

        return MaterialApp.router(
          title: env.name,
          debugShowCheckedModeBanner: env.isDevelopment,
          // Theme Integration
          themeMode: themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          // Router Integration
          routerConfig: router,
          // Global Builder for Toast and Extensions
          builder: (context, child) {
            return FToastBuilder()(context, child);
          },
        );
      },
    );
  }
}
