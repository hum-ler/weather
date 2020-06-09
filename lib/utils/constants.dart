import 'package:flutter/material.dart';

/// The mean Earth radius in km.
///
/// See https://en.wikipedia.org/wiki/Earth_radius.
const double meanEarthRadius = 6371.0088;

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
const String forecastUrl =
    'https://api.data.gov.sg/v1/environment/2-hour-weather-forecast';

/// The style for small-size text.
const TextStyle smallTextStyle = TextStyle(
  fontSize: 14.0,
);

/// The style for large-size text.
const TextStyle largeTextStyle = TextStyle(
  fontSize: 100.0,
  fontWeight: FontWeight.bold,
);

/// The size of small icons.
const double smallIconSize = 12.0;

/// The size of large icons.
const double largeIconSize = 100.0;

/// The color to use to highlight anomalies.
///
/// Used inside [Icon]s and [Text]s.
const Color anomalyHighlight = Colors.red;

/// The pattern for displaying [DateTime]s to the user.
const String dateTimePattern = 'd MMM H:mm';