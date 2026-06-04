import 'package:intl/intl.dart';

/// Shared date/time formatting helpers (intl-backed).
class DateFormatter {
  DateFormatter._();

  static final DateFormat _fullDate = DateFormat('MMM d, y');
  static final DateFormat _shortDate = DateFormat('MMM d');

  /// "Jan 15, 2026"
  static String fullDate(DateTime date) => _fullDate.format(date.toLocal());

  /// "Jan 15"
  static String shortDate(DateTime date) => _shortDate.format(date.toLocal());

  /// Whole-day difference between [date] and today (local, date-only).
  /// Positive = in the future, 0 = today, negative = past.
  static int daysUntil(DateTime date) {
    final DateTime local = date.toLocal();
    final DateTime d = DateTime(local.year, local.month, local.day);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return d.difference(today).inDays;
  }

  /// Relative past time, e.g. "just now", "5 minutes ago", "2 days ago",
  /// falling back to an absolute date beyond ~30 days.
  static String relativeTime(DateTime date) {
    final DateTime local = date.toLocal();
    final Duration diff = DateTime.now().difference(local);

    if (diff.isNegative) {
      return fullDate(local);
    }
    if (diff.inSeconds < 60) {
      return 'just now';
    }
    if (diff.inMinutes < 60) {
      final int m = diff.inMinutes;
      return '$m minute${m == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      final int h = diff.inHours;
      return '$h hour${h == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 30) {
      final int d = diff.inDays;
      return '$d day${d == 1 ? '' : 's'} ago';
    }
    return fullDate(local);
  }
}
