import 'package:flutter/material.dart';
import 'package:base_flutter/core/l10n/l10n_extensions.dart';

/// Localized form field validators
/// These validators return localized error messages based on the current locale
class LocalizedValidators {
  LocalizedValidators._();

  /// Email validator with optional required check
  static String? Function(String?) email(
    BuildContext context, {
    bool isRequired = true,
  }) {
    return (String? value) {
      final l10n = context.l10n;

      if (value == null || value.isEmpty) {
        return isRequired ? l10n.validation_required(l10n.auth_email) : null;
      }

      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      if (!emailRegex.hasMatch(value)) {
        return l10n.validation_emailInvalid;
      }

      return null;
    };
  }

  /// Required field validator with localization (configurable)
  static String? Function(String?) required(
    BuildContext context, {
    required String fieldName,
    bool isRequired = true,
  }) {
    return (String? value) {
      if (!isRequired) return null;
      if (value == null || value.isEmpty) {
        return context.l10n.validation_required(fieldName);
      }
      return null;
    };
  }

  /// Minimum length validator with localization
  static String? Function(String?) minLength(
    BuildContext context,
    int minLength, {
    required String fieldName,
    bool isRequired = true,
  }) {
    return (String? value) {
      final l10n = context.l10n;

      if (value == null || value.isEmpty) {
        return isRequired ? l10n.validation_required(fieldName) : null;
      }

      if (value.length < minLength) {
        return l10n.validation_minLength(fieldName, minLength);
      }

      return null;
    };
  }

  /// Maximum length validator with localization
  static String? Function(String?) maxLength(
    BuildContext context,
    int maxLength, {
    required String fieldName,
    bool isRequired = true,
  }) {
    return (String? value) {
      if ((value == null || value.isEmpty) && !isRequired) return null;
      if (value != null && value.length > maxLength) {
        return context.l10n.validation_maxLength(fieldName, maxLength);
      }
      return null;
    };
  }

  /// Password validator with optional required
  static String? Function(String?) password(
    BuildContext context, {
    bool isRequired = true,
  }) {
    return (String? value) {
      final l10n = context.l10n;

      if (value == null || value.isEmpty) {
        return isRequired ? l10n.validation_required(l10n.auth_password) : null;
      }

      if (value.length < 8) {
        return l10n.validation_passwordTooShort(8);
      }

      return null;
    };
  }

  /// Confirm password validator
  static String? Function(String?) confirmPassword(
    BuildContext context,
    String? password, {
    bool isRequired = true,
  }) {
    return (String? value) {
      final l10n = context.l10n;

      if (value == null || value.isEmpty) {
        return isRequired
            ? l10n.validation_required(l10n.auth_confirmPassword)
            : null;
      }

      if (value != password) {
        return l10n.validation_passwordMismatch;
      }

      return null;
    };
  }

  /// Phone number validator with localization
  static String? Function(String?) phone(
    BuildContext context, {
    bool isRequired = true,
  }) {
    return (String? value) {
      final l10n = context.l10n;

      if (value == null || value.isEmpty) {
        return isRequired ? l10n.validation_required(l10n.profile_phone) : null;
      }

      final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

      if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
        return l10n.validation_phoneInvalid;
      }

      return null;
    };
  }

  /// URL validator with localization
  static String? Function(String?) url(
    BuildContext context, {
    bool isRequired = true,
  }) {
    return (String? value) {
      final l10n = context.l10n;

      if (value == null || value.isEmpty) {
        return isRequired ? l10n.validation_required('URL') : null;
      }

      final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      );

      if (!urlRegex.hasMatch(value)) {
        return l10n.validation_urlInvalid;
      }

      return null;
    };
  }

  /// Compose multiple validators (runs sequentially)
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  /// Optional validator (validates only if not empty)
  static String? Function(String?) optional(
    String? Function(String?) validator,
  ) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      return validator(value);
    };
  }
}
