import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'constants.dart' as constants;

/// Gets JSON data from the internet.
Future<dynamic> httpGetJsonData(String url) async {
  Response response = await get(
    url,
    headers: {'Accept': 'application/json'},
  );

  if (response.statusCode == 200) {
    try {
      return jsonDecode(response.body);
    } catch (exception) {
      print(exception);
    }
  } else {
    print(response.statusCode);
  }

  return null;
}

/// Converts from degrees to radians.
double degreesToRadians(double deg) => deg * pi / 180;

/// Converts from knots to meters per second.
double knotsToMetersPerSecond(double knots) {
  return knots * constants.knotToMetersPerSecond;
}

extension DateTimeExtension on DateTime {
  /// Return the date time value as a string in the given [pattern].
  ///
  /// See https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html
  /// for details on the pattern.
  String format(String pattern) => DateFormat(pattern).format(this);
}
