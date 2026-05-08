// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a vi locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'vi';

  static String m0(field, max) => "${field} tối đa ${max} ký tự";

  static String m1(field, min) => "${field} tối thiểu ${min} ký tự";

  static String m2(min) => "Mật khẩu phải có ít nhất ${min} ký tự";

  static String m3(field) => "Vui lòng nhập ${field}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "app_title": MessageLookupByLibrary.simpleMessage("Flutter App"),
    "auth_confirmPassword": MessageLookupByLibrary.simpleMessage(
      "Xác nhận mật khẩu",
    ),
    "auth_email": MessageLookupByLibrary.simpleMessage("Email"),
    "auth_password": MessageLookupByLibrary.simpleMessage("Mật khẩu"),
    "error_network": MessageLookupByLibrary.simpleMessage("Lỗi kết nối mạng"),
    "error_request_cancelled": MessageLookupByLibrary.simpleMessage(
      "Yêu cầu bị hủy",
    ),
    "error_timeout": MessageLookupByLibrary.simpleMessage(
      "Hết thời gian kết nối",
    ),
    "error_unknown": MessageLookupByLibrary.simpleMessage("Lỗi không xác định"),
    "profile_phone": MessageLookupByLibrary.simpleMessage("Số điện thoại"),
    "validation_emailInvalid": MessageLookupByLibrary.simpleMessage(
      "Email không hợp lệ",
    ),
    "validation_maxLength": m0,
    "validation_minLength": m1,
    "validation_passwordMismatch": MessageLookupByLibrary.simpleMessage(
      "Mật khẩu không khớp",
    ),
    "validation_passwordTooShort": m2,
    "validation_phoneInvalid": MessageLookupByLibrary.simpleMessage(
      "Số điện thoại không hợp lệ",
    ),
    "validation_required": m3,
    "validation_urlInvalid": MessageLookupByLibrary.simpleMessage(
      "URL không hợp lệ",
    ),
  };
}
