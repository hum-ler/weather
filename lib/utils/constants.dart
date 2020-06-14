import 'package:flutter/material.dart';

import 'package:weather/models/geoposition.dart';

/// The mean Earth radius in km.
///
/// See https://en.wikipedia.org/wiki/Earth_radius.
const double meanEarthRadius = 6371.0088;

/// The equatorial radius in km.
///
/// See https://en.wikipedia.org/wiki/Earth_radius.
const double equatorialRadius = 6378.137;

/// The conversion factor from knot to m/s.
///
/// See https://en.wikipedia.org/wiki/Knot_(unit).
const double knotToMetersPerSecond = 0.514444;

/// The minimum period between consecutive data fetches.
const Duration minFetchPeriod = Duration(minutes: 15);

/// The maximum period for a reading to be considered realtime.
const Duration maxReadingRecency = Duration(minutes: 45);

/// The maximum distance in km for a station or forecast area to be considered
/// near.
const double maxDistance = 10.0;

/// The reference position for the central forecast region.
const Geoposition centralRegion = Geoposition(
  latitude: 1.360195,
  longitude: 103.815675,
);

/// The reference position for the north forecast region.
const Geoposition northRegion = Geoposition(
  latitude: 1.439147,
  longitude: 103.815675,
);

/// The reference position for the east forecast region.
const Geoposition eastRegion = Geoposition(
  latitude: 1.360195,
  longitude: 103.992073,
);

/// The reference position for the south forecast region.
const Geoposition southRegion = Geoposition(
  latitude: 1.290981,
  longitude: 103.815675,
);

/// The reference position for the west forecast region.
const Geoposition westRegion = Geoposition(
  latitude: 1.360195,
  longitude: 103.669195,
);

/// The maximum distance in km for a forecast region to be considered near.
const double maxRegionDistance = 20.0;

/// The URL of realtime air temperature readings API (at Data.gov.sg).
///
/// Updates every 1 minute. Takes parameter date_time=<ISO8601>. Unit is °C.
///
/// See https://data.gov.sg/dataset/realtime-weather-readings.
const String airTemperatureUrl =
    'https://api.data.gov.sg/v1/environment/air-temperature';

/// The URL of realtime rainfall readings API (at Data.gov.sg).
///
/// Updates every 5 minutes. Takes parameter date_time=<ISO8601>. Unit is mm.
///
/// See https://data.gov.sg/dataset/realtime-weather-readings.
const String rainfallUrl = 'https://api.data.gov.sg/v1/environment/rainfall';

/// The URL of realtime relative humidity readings API (at Data.gov.sg).
///
/// Updates every 1 minute. Takes parameter date_time=<ISO8601>. Unit is %.
///
/// See https://data.gov.sg/dataset/realtime-weather-readings.
const String relativeHumidityUrl =
    'https://api.data.gov.sg/v1/environment/relative-humidity';

/// The URL of realtime wind direction readings API (at Data.gov.sg).
///
/// Updates every 1 minute. Takes parameter date_time=<ISO8601>. Unit is °.
///
/// See https://data.gov.sg/dataset/realtime-weather-readings.
const String windDirectionUrl =
    'https://api.data.gov.sg/v1/environment/wind-direction';

/// The URL of realtime wind speed readings API (at Data.gov.sg).
///
/// Updates every 1 minute. Takes parameter date_time=<ISO8601>. Unit is knot.
///
/// See https://data.gov.sg/dataset/realtime-weather-readings.
const String windSpeedUrl = 'https://api.data.gov.sg/v1/environment/wind-speed';

/// The URL of the 2-hour weather forecast API (at Data.gov.sg).
///
/// Updates every 30 minutes. Takes parameter date_time=<ISO8601>.
///
/// See https://data.gov.sg/dataset/weather-forecast.
const String forecast2HourUrl =
    'https://api.data.gov.sg/v1/environment/2-hour-weather-forecast';

/// The URL of the 24-hour weather forecast API (at Data.gov.sg).
///
/// Takes parameter date_time=<ISO8601>.
///
/// See https://data.gov.sg/dataset/weather-forecast.
const String forecast24HourUrl =
    'https://api.data.gov.sg/v1/environment/24-hour-weather-forecast';

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
