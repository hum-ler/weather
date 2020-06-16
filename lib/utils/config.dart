import 'package:flutter/material.dart';

/// The minimum period between consecutive data fetches.
const Duration minFetchPeriod = Duration(minutes: 15);

/// The maximum period for a reading to be considered realtime.
const Duration maxReadingRecency = Duration(minutes: 45);

/// The maximum period for a 24-hour forecast to be considered up-to-date.
const Duration max24HourForecastRecency = Duration(hours: 6);

/// The maximum distance in km for a station or forecast area to be considered
/// near.
const double maxDistance = 10.0;

/// The maximum distance in km for a forecast region to be considered near.
const double maxRegionDistance = 20.0;

/// The style for small-size text.
const TextStyle smallTextStyle = TextStyle(
  fontSize: 12.0,
);

/// The style for medium-size text.
const TextStyle mediumTextStyle = TextStyle(
  fontSize: 14.0,
);

/// The style for large-size text.
const TextStyle largeTextStyle = TextStyle(
  fontSize: 100.0,
  fontWeight: FontWeight.bold,
);

/// The maximum length of a weather condition in the display.
const int maxConditionLength = 24;

/// The maximum length of a station or forecast area name in the display.
const int maxStationAreaNameLength = 18;

/// The size of small icons.
const double smallIconSize = 10.0;

/// The size of medium icons.
const double mediumIconSize = 48.0;

/// The size of large icons.
const double largeIconSize = 100.0;

/// The color to use to highlight anomalies.
///
/// Used inside [Icon]s and [Text]s.
const Color anomalyHighlight = Colors.red;

/// The pattern for displaying [DateTime]s to the user.
const String dateTimePattern = 'd MMM H:mm';

/// The app light theme.
final ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: Color(0xFFFF5722),
  primaryColorLight: Color(0xFFFFCCBC),
  primaryColorDark: Color(0xFFE64A19),
  accentColor: Color(0xFFFF9800),
);

/// The app dark theme.
final ThemeData darkTheme = ThemeData.dark().copyWith(
  primaryColor: Color(0xFFFF5722),
  primaryColorLight: Color(0xFFFFCCBC),
  primaryColorDark: Color(0xFFE64A19),
  accentColor: Color(0xFFFF9800),
);
