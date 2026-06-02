import 'dart:async';

import 'package:base_flutter/core/base/constants/app_constants.dart';
import 'package:base_flutter/core/base/storage/local_storage.dart';
import 'package:base_flutter/core/base/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme mode notifier
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    unawaited(_loadTheme());
    return ThemeMode.system;
  }

  /// Load theme from storage
  Future<void> _loadTheme() async {
    final themeName = LocalStorage.getString(AppConstants.themeKey);

    if (themeName == 'light') {
      state = ThemeMode.light;
    } else if (themeName == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    final themeName = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await LocalStorage.setString(AppConstants.themeKey, themeName);
  }

  /// Toggle theme (switch between light and dark)
  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  /// Check if dark mode is active
  bool isDarkMode(BuildContext context) {
    if (state == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return state == ThemeMode.dark;
  }
}

/// Theme mode provider
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Light theme provider
final lightThemeProvider = Provider<ThemeData>((ref) => AppTheme.lightTheme);

/// Dark theme provider
final darkThemeProvider = Provider<ThemeData>((ref) => AppTheme.darkTheme);

/// Check if dark mode provider
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  // Note: This won't work for system theme without BuildContext
  // Use themeModeNotifier.isDarkMode(context) for accurate
  // system theme detection
  return themeMode == ThemeMode.dark;
});
