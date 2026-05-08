extension DateTimeExtension on DateTime {
  /// Returns a [DateTime] at the very beginning of the day (00:00:00.000).
  DateTime get toStartOfDay => DateTime(year, month, day);

  /// Returns a [DateTime] at the very end of the day (23:59:59.999).
  DateTime get toEndOfDay => DateTime(year, month, day, 23, 59, 59, 999);
}
