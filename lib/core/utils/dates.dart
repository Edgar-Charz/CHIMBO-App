import 'package:intl/intl.dart';

/// Date formatting in the user's language. The API sends ISO-8601 UTC; we show local time.
abstract final class AppDates {
  static String formatDateTime(DateTime dateTime, String localeName) {
    return DateFormat.yMMMd(localeName).add_Hms().format(dateTime.toLocal());
  }

  /// "20 Mei, 2024" — order dates and delivery estimates.
  static String formatDate(DateTime dateTime, String localeName) {
    return DateFormat('d MMM, y', localeName).format(dateTime.toLocal());
  }

  /// "14 Mei, 10:30" — tracking timeline steps.
  static String formatDayTime(DateTime dateTime, String localeName) {
    return DateFormat('d MMM, HH:mm', localeName).format(dateTime.toLocal());
  }
}
