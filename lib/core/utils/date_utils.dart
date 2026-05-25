import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _prettyFormat = DateFormat('MMM d, yyyy');

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatPrettyDate(DateTime date) {
    return _prettyFormat.format(date);
  }

  static DateTime parseDate(String dateStr) {
    return _dateFormat.parse(dateStr);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
