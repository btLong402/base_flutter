import 'package:base_flutter/core/base/widgets/toast/toast_notification.dart';
import 'package:base_flutter/features/home/presentation/pages/home_page.dart';
import 'package:base_flutter/features/main/presentation/main_shell_page.dart';
import 'package:base_flutter/features/search/presentation/search_page.dart';
import 'package:base_flutter/features/settings/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final shellNavigatorSearchKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final shellNavigatorSettingsKey = GlobalKey<NavigatorState>(
  debugLabel: 'settings',
);

class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String settings = '/settings';
}

final routerProvider = Provider<GoRouter>((ref) {
  // Link ToastController to global navigator key
  ToastController.instance.navigatorKey = rootNavigatorKey;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorSearchKey,
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
