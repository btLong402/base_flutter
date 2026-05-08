import 'package:flutter/material.dart';

extension ContextExtenstion on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  bool get isDarkMode => theme.brightness == Brightness.dark;

  double get screenWidth => mediaQuery.size.width;

  double get screenHeight => mediaQuery.size.height;

  EdgeInsets get padding => mediaQuery.padding;

  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  bool get isMobileLayout => screenWidth < 600;

  bool get isTabletLayout => screenWidth >= 600 && screenWidth < 1024;

  bool get isDesktopLayout => screenWidth >= 1024;

  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}
