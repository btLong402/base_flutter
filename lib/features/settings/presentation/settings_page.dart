import 'dart:async';

import 'package:base_flutter/core/base/theme/theme_provider.dart';
import 'package:base_flutter/core/base/widgets/toast/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          const _SectionHeader(title: 'Appearance'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Theme Mode'),
                  subtitle: Text(themeMode.name.toUpperCase()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context, ref),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          const _SectionHeader(title: 'Debug & Test'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                  title: const Text('Success Toast'),
                  onTap: () => ToastService.success('Task completed successfully!'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.error_outline, color: Colors.red),
                  title: const Text('Error Toast'),
                  onTap: () => ToastService.error('Something went wrong.'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.blue),
                  title: const Text('Info Toast'),
                  onTap: () => ToastService.info('This is an informative message.'),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          const _SectionHeader(title: 'About'),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  trailing: Text('1.0.0'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.description_outlined),
                  title: Text('Licenses'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Theme'),
          content: HookConsumer(
            builder: (context, ref, child) {
              final currentMode = ref.watch(themeModeProvider);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: ThemeMode.values.map((mode) {
                  return RadioListTile<ThemeMode>(
                    title: Text(mode.name.toUpperCase()),
                    value: mode,
                    // ignore: deprecated_member_use, RadioGroup is preferred in newer versions
                    groupValue: currentMode,
                    // ignore: deprecated_member_use, RadioGroup is preferred in newer versions
                    onChanged: (value) {
                      if (value != null) {
                        unawaited(
                          ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(value),
                        );
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
