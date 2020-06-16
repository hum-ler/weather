import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  /// Return the date time value as a string in the given [pattern].
  ///
  /// See https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html
  /// for details on the pattern.
  String format(String pattern) => DateFormat(pattern).format(this);
}
