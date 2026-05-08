import 'package:base_flutter/core/l10n/generated/l10n.dart';
import 'package:flutter/material.dart';

extension LocalizationExtension on BuildContext {
  /// Get AppLocalizations instance
  S get l10n => S.of(this);

  /// Get current locale
  Locale get currentLocale => Localizations.localeOf(this);

  /// Check if current locale is English  
  bool get isEnglish => currentLocale.languageCode == 'en';

  /// Check if current locale is Vietnamese
  bool get isVietnamese => currentLocale.languageCode == 'vi';
}
