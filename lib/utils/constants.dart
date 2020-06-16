import '../models/geoposition.dart';

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
