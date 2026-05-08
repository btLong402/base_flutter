import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static const String initial = '/';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.initial,
    routes: [
      GoRoute(
        path: AppRoutes.initial,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Initial Screen')),
        ),
      ),
    ],
  );
});
