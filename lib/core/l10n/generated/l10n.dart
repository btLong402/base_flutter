// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Flutter App`
  String get app_title {
    return Intl.message('Flutter App', name: 'app_title', desc: '', args: []);
  }

  /// `Hết thời gian kết nối`
  String get error_timeout {
    return Intl.message(
      'Hết thời gian kết nối',
      name: 'error_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Lỗi kết nối mạng`
  String get error_network {
    return Intl.message(
      'Lỗi kết nối mạng',
      name: 'error_network',
      desc: '',
      args: [],
    );
  }

  /// `Lỗi không xác định`
  String get error_unknown {
    return Intl.message(
      'Lỗi không xác định',
      name: 'error_unknown',
      desc: '',
      args: [],
    );
  }

  /// `Yêu cầu bị hủy`
  String get error_request_cancelled {
    return Intl.message(
      'Yêu cầu bị hủy',
      name: 'error_request_cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập {field}`
  String validation_required(String field) {
    return Intl.message(
      'Vui lòng nhập $field',
      name: 'validation_required',
      desc: '',
      args: [field],
    );
  }

  /// `Email không hợp lệ`
  String get validation_emailInvalid {
    return Intl.message(
      'Email không hợp lệ',
      name: 'validation_emailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `{field} tối thiểu {min} ký tự`
  String validation_minLength(String field, int min) {
    return Intl.message(
      '$field tối thiểu $min ký tự',
      name: 'validation_minLength',
      desc: '',
      args: [field, min],
    );
  }

  /// `{field} tối đa {max} ký tự`
  String validation_maxLength(String field, int max) {
    return Intl.message(
      '$field tối đa $max ký tự',
      name: 'validation_maxLength',
      desc: '',
      args: [field, max],
    );
  }

  /// `Mật khẩu phải có ít nhất {min} ký tự`
  String validation_passwordTooShort(int min) {
    return Intl.message(
      'Mật khẩu phải có ít nhất $min ký tự',
      name: 'validation_passwordTooShort',
      desc: '',
      args: [min],
    );
  }

  /// `Mật khẩu không khớp`
  String get validation_passwordMismatch {
    return Intl.message(
      'Mật khẩu không khớp',
      name: 'validation_passwordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Số điện thoại không hợp lệ`
  String get validation_phoneInvalid {
    return Intl.message(
      'Số điện thoại không hợp lệ',
      name: 'validation_phoneInvalid',
      desc: '',
      args: [],
    );
  }

  /// `URL không hợp lệ`
  String get validation_urlInvalid {
    return Intl.message(
      'URL không hợp lệ',
      name: 'validation_urlInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get auth_email {
    return Intl.message('Email', name: 'auth_email', desc: '', args: []);
  }

  /// `Mật khẩu`
  String get auth_password {
    return Intl.message('Mật khẩu', name: 'auth_password', desc: '', args: []);
  }

  /// `Xác nhận mật khẩu`
  String get auth_confirmPassword {
    return Intl.message(
      'Xác nhận mật khẩu',
      name: 'auth_confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Số điện thoại`
  String get profile_phone {
    return Intl.message(
      'Số điện thoại',
      name: 'profile_phone',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'vi'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
