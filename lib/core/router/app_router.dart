import 'package:base_flutter/core/base/config/environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        builder: (context, state) => const _InitialScreen(),
      ),
    ],
  );
});

class _InitialScreen extends StatelessWidget {
  const _InitialScreen();

  @override
  Widget build(BuildContext context) {
    final env = EnvironmentConfig.current;

    return Scaffold(
      appBar: AppBar(title: Text(env.name.toUpperCase())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 80.r,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 24.h),
            Text(
              'Base App Professional',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 28.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Flavor: ${env.flavor.name.toUpperCase()}',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 32.h),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 32.w),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    _InfoRow(label: 'Base URL', value: env.baseUrl),
                    Divider(height: 24.h),
                    const _InfoRow(
                      label: 'Responsive',
                      value: 'ScreenUtil Initialized',
                    ),
                    Divider(height: 24.h),
                    const _InfoRow(
                      label: 'Navigation',
                      value: 'GoRouter (Riverpod)',
                    ),
                    Divider(height: 24.h),
                    const _InfoRow(label: 'Theme', value: 'Dynamic Switching'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
        ),
      ],
    );
  }
}
