import 'package:base_flutter/core/base/extensions/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date and time formatting helpers
class DateTimeHelper {
  DateTimeHelper._();

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date.toLocal());
  }

  static String formatDateMedium(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date.toLocal());
  }

  /// Format date to Vietnamese style: 'd tháng M, yyyy'
  /// Supports relative dates: 'Hôm nay', 'Hôm qua'
  static String formatVnDateRelative(DateTime date) {
    final now = DateTime.now();
    final today = startOfDay(now);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = startOfDay(date);

    if (dateOnly == today) {
      return 'Hôm nay';
    } else if (dateOnly == yesterday) {
      return 'Hôm qua';
    }

    return DateFormat("d 'tháng' M, yyyy", 'vi').format(date.toLocal());
  }

  static String formatVnTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime.toLocal());
  }

  /// Get friendly relative time string (Vietnamese)
  /// Used for: Chat list, Message bubbles
  static String formatFriendly(DateTime time) {
    final now = DateTime.now();
    final localTime = time.toLocal();
    final diff = now.difference(localTime);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} phút';
    } else if (isToday(localTime)) {
      return formatVnTime(localTime);
    } else if (isYesterday(localTime)) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      const days = [
        'Thứ 2',
        'Thứ 3',
        'Thứ 4',
        'Thứ 5',
        'Thứ 6',
        'Thứ 7',
        'Chủ Nhật',
      ];
      return days[localTime.weekday - 1];
    } else {
      return formatDate(localTime); // dd/MM/yyyy
    }
  }

  static String formatDateLong(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date.toLocal());
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time.toLocal());
  }

  static String formatTime12(DateTime time) {
    return DateFormat('hh:mm a').format(time.toLocal());
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime.toLocal());
  }

  static String formatDateTimeMedium(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime.toLocal());
  }

  static String formatCustom(DateTime dateTime, String pattern) {
    return DateFormat(pattern).format(dateTime.toLocal());
  }

  /// Get relative time (e.g., "2 hours ago", "Just now")
  static String getRelativeTime(DateTime dateTime, {String locale = 'en'}) {
    final now = DateTime.now();
    final localTime = dateTime.toLocal();
    final difference = now.difference(localTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    final localDate = date.toLocal();
    return localDate.year == now.year &&
        localDate.month == now.month &&
        localDate.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final localDate = date.toLocal();
    return localDate.year == yesterday.year &&
        localDate.month == yesterday.month &&
        localDate.day == yesterday.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final localDate = date.toLocal();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return localDate.isAfter(weekStart) && localDate.isBefore(weekEnd);
  }

  /// Parse date string to DateTime
  static DateTime? parseDate(String dateString, {String? format}) {
    try {
      if (format != null) {
        return DateFormat(format).parse(dateString);
      }
      return DateTime.parse(dateString);
    } on Object catch (_) {
      return null;
    }
  }

  /// Check if two dates are the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return date.toStartOfDay;
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return date.toEndOfDay;
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    final localDate = date.toLocal();
    return DateTime(localDate.year, localDate.month);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    final localDate = date.toLocal();
    return DateTime(localDate.year, localDate.month + 1, 0, 23, 59, 59, 999);
  }

  /// Add business days (skip weekends)
  static DateTime addBusinessDays(DateTime date, int days) {
    var result = date;
    var addedDays = 0;

    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday &&
          result.weekday != DateTime.sunday) {
        addedDays++;
      }
    }

    return result;
  }

  /// Get age from birthdate
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    final localBirth = birthDate.toLocal();
    var age = now.year - localBirth.year;

    if (now.month < localBirth.month ||
        (now.month == localBirth.month && now.day < localBirth.day)) {
      age--;
    }

    return age;
  }

  // ─── Time String Helpers ──────────────────────────────────

  /// Formats an ISO-8601 date string to "dd/MM/yyyy HH:mm".
  /// Returns empty string if invalid/null.
  static String formatDateTimeString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return formatDateTime(dt);
  }

  /// Formats an ISO-8601 date string to "dd/MM/yyyy".
  /// Returns empty string if invalid/null.
  static String formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return formatDate(dt);
  }

  /// Format a time string from API (e.g. "HH:mm:ss" or "HH:mm") to
  /// display format "HH:mm". Returns '--' if null/empty/invalid.
  ///
  /// Use this whenever displaying a time string from the backend.
  static String formatTimeString(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '--';
    final parts = timeStr.split(':');
    if (parts.length < 2) return timeStr;
    return '${parts[0]}:${parts[1]}';
  }

  /// Format a [TimeOfDay] to API format "HH:mm:ss".
  ///
  /// Use this whenever sending a time value to the backend.
  static String formatTimeOfDayToApi(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  /// Format a [TimeOfDay] to display format "HH:mm".
  ///
  /// Use this for consistent 24h display regardless of locale.
  static String formatTimeOfDayDisplay(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
