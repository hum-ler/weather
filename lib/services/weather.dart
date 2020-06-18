import 'package:flutter/material.dart';

import '../models/condition.dart';
import '../models/forecast.dart';
import '../models/geoposition.dart';
import '../models/provider.dart';
import '../models/reading.dart';
import '../utils/date_time_ext.dart';
import '../utils/http_utils.dart';

/// The weather service.
class Weather {
  // Use a singleton for this service.
  static final Weather _singleton = Weather._weather();

  Weather._weather();

  factory Weather() => _singleton;

  // Keeping the internal lists below separate because:
  // - There is no convenient way of merging Readings.
  // - These are only used by the respective getNearest... methods.
  //
  // This means that the user will need to manually merge Readings from the same
  // Provider by comparing Reading.provider.id.

  /// The collection of temperature readings.
  List<Reading> _temperatureReadings = [];

  /// The collection of rainfall readings.
  List<Reading> _rainfallReadings = [];

  /// The collection of relative humidity readings.
  List<Reading> _humidityReadings = [];

  /// The collection of wind speed readings.
  List<Reading> _windSpeedReadings = [];

  /// The collection of wind direction readings.
  ///
  /// These readings are not useful unless paired with a corresponding reading
  /// from [_windSpeedReading].
  List<Reading> _windDirectionReadings = [];

  /// The collection of PM2.5 readings.
  List<Reading> _pm2_5Readings = [];

  /// The collection of 2-hour forecasts.
  List<Forecast> _x2HourForecasts = [];

  /// The collection of 24-hour forecasts.
  List<List<Forecast>> _x24HourForecasts = [];

  /// The collection of [Reading.expiry] for each [ReadingType].
  ///
  /// Used by [_fetchReadingsOfType()] to determine whether to fetch fresh data.
  Map<ReadingType, DateTime> _readingTypeExpiry = {};

  /// The [Reading.expiry] for 2-hour forecasts.
  ///
  /// Used by [_fetch2HourForecasts()] to determine whether to fetch fresh data.
  DateTime _x2HourForecastExpiry;

  /// The [Reading.expiry] for 24-hour forecasts.
  ///
  /// Used by [_fetch24HourForecasts()] to determine whether to fetch fresh
  /// data.
  DateTime _x24HourForecastExpiry;

  /// Retrieve readings and forecasts.
  ///
  /// Call this before any getNearest... methods,
  /// [getNearestCondition()] or [getNearest24HourForecasts()].
  Future<void> fetchReadings({
    DateTime timestamp,
    @required Geoposition userLocation,
  }) async {
    timestamp ??= DateTime.now();

    List<dynamic> resultsList = await Future.wait([
      _fetchReadingsOfType(
        timestamp: timestamp,
        url: _temperatureUrl,
        type: ReadingType.temperature,
        userLocation: userLocation,
      ),
      _fetchReadingsOfType(
        timestamp: timestamp,
        url: _rainfallUrl,
        type: ReadingType.rainfall,
        userLocation: userLocation,
      ),
      _fetchReadingsOfType(
        timestamp: timestamp,
        url: _humidityUrl,
        type: ReadingType.humidity,
        userLocation: userLocation,
      ),
      _fetchReadingsOfType(
        timestamp: timestamp,
        url: _windSpeedUrl,
        type: ReadingType.windSpeed,
        userLocation: userLocation,
      ),
      _fetchReadingsOfType(
        timestamp: timestamp,
        url: _windDirectionUrl,
        type: ReadingType.windDirection,
        userLocation: userLocation,
      ),
      _fetchPM2_5Readings(
        timestamp: timestamp,
        userLocation: userLocation,
      ),
      _fetch2HourForecasts(
        timestamp: timestamp,
        userLocation: userLocation,
      ),
      _fetch24HourForecasts(
        timestamp: timestamp,
        userLocation: userLocation,
      ),
    ]);

    _collectFetchResults(resultsList);
  }

  /// Gets the nearest temperature reading.
  ///
  /// Call [fetchReadings()] before calling this method.
  Reading getNearestTemperatureReading() {
    if (_temperatureReadings.isEmpty) return null;

    return _temperatureReadings
        .reduce((v, e) => v.distance < e.distance ? v : e);
  }

  /// Gets the nearest rainfall reading.
  ///
  /// Call [fetchReadings()] before calling this method.
  Reading getNearestRainfallReading() {
    if (_rainfallReadings.isEmpty) return null;

    return _rainfallReadings.reduce((v, e) => v.distance < e.distance ? v : e);
  }

  /// Gets the nearest relative humidity reading.
  ///
  /// Call [fetchReadings()] before calling this method.
  Reading getNearestHumidityReading() {
    if (_humidityReadings.isEmpty) return null;

    return _humidityReadings.reduce((v, e) => v.distance < e.distance ? v : e);
  }

  /// Gets the nearest wind speed reading.
  ///
  /// Call [fetchReadings()] before calling this method.
  Reading getNearestWindSpeedReading() {
    if (_windSpeedReadings.isEmpty) return null;

    return _windSpeedReadings.reduce((v, e) => v.distance < e.distance ? v : e);
  }

  /// Gets the nearest wind direction reading.
  ///
  /// Call [fetchReadings()] before calling this method.
  Reading getNearestWindDirectionReading() {
    if (_windDirectionReadings.isEmpty) return null;

    return _windDirectionReadings
        .reduce((v, e) => v.distance < e.distance ? v : e);
  }

  /// Gets the nearest PM2.5 reading.
  ///
  /// Call [fetchReadings()] before calling this method.
  Reading getNearestPM2_5Reading() {
    if (_pm2_5Readings.isEmpty) return null;

    return _pm2_5Readings.reduce((v, e) => v.distance < e.distance ? v : e);
  }

  /// Gets the nearest weather condition.
  ///
  /// We are using the 2-hour forecast to approximate the current condition.
  ///
  /// Call [fetchReadings()] before calling this method.
  Condition getNearestCondition() => getNearest2HourForecast();

  /// Gets the nearest 2-hour forecast.
  ///
  /// Call [fetchReadings()] before calling this method.
  Forecast getNearest2HourForecast() {
    if (_x2HourForecasts.isEmpty) return null;

    return _x2HourForecasts.reduce((v, e) => v.distance < e.distance ? v : e);
  }

  /// Gets the nearest 24-hour forecast.
  ///
  /// Call [fetchReadings()] before calling this method.
  ///
  /// The items in the returned list are arranged in chronological order.
  List<Forecast> getNearest24HourForecast() {
    if (_x24HourForecasts.isEmpty) return null;

    return _x24HourForecasts
        .reduce((v, e) => v.first.distance < e.first.distance ? v : e);
  }

  /// Fetches actual data using the realtime weather readings API.
  ///
  /// The data structure returned by the API is the same for the different
  /// reading types.
  Future<Iterable<Reading>> _fetchReadingsOfType({
    @required DateTime timestamp,
    @required String url,
    @required ReadingType type,
    @required Geoposition userLocation,
  }) async {
    // This method is not meant for PM2.5 readings, which is a different API.
    if (type == ReadingType.pm2_5) return null;

    if (timestamp == null) return null;

    // Perform a fetch only if we are over the validity period.
    if (_readingTypeExpiry[type] != null &&
        timestamp.isBefore(_readingTypeExpiry[type])) {
      return null;
    }

    String fullUrl =
        '$url?date_time=${timestamp.toLocal().format("yyyy-MM-ddTHH:mm:ss")}';

    dynamic data = await httpGetJsonData(fullUrl);
    if (data == null) return null;

    if (data['api_info']['status'] == 'healthy') {
      // Server-side timestamp.
      DateTime creation =
          DateTime.tryParse(data['items'][0]['timestamp']).toLocal();

      List<dynamic> stations = data['metadata']['stations'];

      return (data['items'][0]['readings'] as List).map((e) {
        dynamic s = stations.firstWhere((s) => s['id'] == e['station_id']);

        // Perform conversion if necessary.
        num value = e['value'];
        if (type == ReadingType.windSpeed) {
          value = _knotsToMetersPerSecond(value);
        }

        return Reading(
          type: type,
          creation: creation,
          provider: Provider.station(
            id: s['id'],
            name: s['name'],
            location: Geoposition(
              latitude: s['location']['latitude'],
              longitude: s['location']['longitude'],
            ),
          ),
          userLocation: userLocation,
          value: value,
        );
      });
    }

    return null;
  }

  /// Fetches actual data using the PM2.5 API.
  Future<Iterable<Reading>> _fetchPM2_5Readings({
    @required DateTime timestamp,
    @required Geoposition userLocation,
  }) async {
    if (timestamp == null) return null;

    // Perform a fetch only if we are over the validity period.
    if (_readingTypeExpiry[ReadingType.pm2_5] != null &&
        timestamp.isBefore(_readingTypeExpiry[ReadingType.pm2_5])) {
      return null;
    }

    String fullUrl =
        '$_pm2_5Url?date_time=${timestamp.toLocal().format("yyyy-MM-ddTHH:mm:ss")}';

    dynamic data = await httpGetJsonData(fullUrl);
    if (data == null) return null;

    if (data['api_info']['status'] == 'healthy') {
      // Server-side timestamp.
      DateTime creation =
          DateTime.tryParse(data['items'][0]['timestamp']).toLocal();

      List<dynamic> regions = data['region_metadata'];
      dynamic readings = data['items'][0]['readings']['pm25_one_hourly'];

      // Cycle through the 5 known regions.
      return ['central', 'north', 'east', 'south', 'west'].map((e) {
        dynamic region = regions.firstWhere((r) => r['name'] == e);

        return Reading(
          type: ReadingType.pm2_5,
          creation: creation,
          provider: Provider.station(
            id: region['name'],
            name: region['name'],
            location: Geoposition(
              latitude: region['label_location']['latitude'],
              longitude: region['label_location']['longitude'],
            ),
          ),
          userLocation: userLocation,
          value: readings[e],
        );
      });
    }

    return null;
  }

  /// Fetches actual data using the 2-hour weather forecast API.
  Future<Iterable<Forecast>> _fetch2HourForecasts({
    @required DateTime timestamp,
    @required Geoposition userLocation,
  }) async {
    if (timestamp == null) return null;

    // Perform a fetch only if we are over the validity period.
    if (_x2HourForecastExpiry != null &&
        timestamp.isBefore(_x2HourForecastExpiry)) {
      return null;
    }

    String fullUrl =
        '$_x2HourForecastUrl?date_time=${timestamp.toLocal().format("yyyy-MM-ddTHH:mm:ss")}';

    dynamic data = await httpGetJsonData(fullUrl);
    if (data == null) return null;

    if (data['api_info']['status'] == 'healthy') {
      // Server-side timestamp.
      DateTime creation =
          DateTime.tryParse(data['items'][0]['timestamp']).toLocal();

      List<dynamic> areas = data['area_metadata'];

      return (data['items'][0]['forecasts'] as List).map((e) {
        dynamic a = areas.firstWhere((a) => a['name'] == e['area']);

        return Forecast(
          type: ForecastType.immediate,
          creation: creation,
          provider: Provider.area(
            id: a['name'],
            name: a['name'],
            location: Geoposition(
              latitude: a['label_location']['latitude'],
              longitude: a['label_location']['longitude'],
            ),
          ),
          userLocation: userLocation,
          condition: e['forecast'],
        );
      });
    }

    return null;
  }

  /// Fetches actual data using the 24-hour weather forecast API.
  Future<Iterable<List<Forecast>>> _fetch24HourForecasts({
    @required DateTime timestamp,
    @required Geoposition userLocation,
  }) async {
    if (timestamp == null) return null;

    // Perform a fetch only if we are over the validity period.
    if (_x24HourForecastExpiry != null &&
        timestamp.isBefore(_x24HourForecastExpiry)) {
      return null;
    }

    String fullUrl =
        '$_x24HourForecastUrl?date_time=${timestamp.toLocal().format("yyyy-MM-ddTHH:mm:ss")}';

    dynamic data = await httpGetJsonData(fullUrl);
    if (data == null) return null;

    if (data['api_info']['status'] == 'healthy') {
      // Server-side timestamp.
      DateTime creation =
          DateTime.tryParse(data['items'][0]['timestamp']).toLocal();

      // Prepare 5 lists to return, each representing one reference region.
      Map<Provider, List<Forecast>> regionLists = {
        Providers.central: [],
        Providers.north: [],
        Providers.east: [],
        Providers.south: [],
        Providers.west: [],
      };

      (data['items'][0]['periods'] as List).forEach((e) {
        ForecastType type;

        DateTime startTime = DateTime.parse(e['time']['start']).toLocal();
        switch (startTime.hour) {
          case 0:
            type = ForecastType.predawn;
            break;

          case 6:
            type = ForecastType.morning;
            break;

          case 12:
            type = ForecastType.afternoon;
            break;

          case 18:
            type = ForecastType.night;
            break;
        }

        regionLists.forEach((k, v) {
          v.add(
            Forecast(
              type: type,
              creation: creation,
              provider: k,
              userLocation: userLocation,
              condition: e['regions'][k.name],
            ),
          );
        });
      });

      return regionLists.values;
    }

    return null;
  }

  /// Handles the results coming back from parallel API calls.
  ///
  /// See [fetchReadings()] (specifically the call to [Future.wait()]) to find
  /// out the expected order of the results:
  /// - temperature
  /// - rainfall
  /// - relative humidity
  /// - wind speed
  /// - wind direction
  /// - 2-hour forecasts
  /// - 24-hour forecasts
  void _collectFetchResults(List<dynamic> resultsList) {
    // Handle temperature readings.
    if (resultsList[0] != null && resultsList[0] is Iterable<Reading>) {
      _temperatureReadings = resultsList[0].toList();

      if (_temperatureReadings.isNotEmpty) {
        _readingTypeExpiry[ReadingType.temperature] =
            _temperatureReadings.first.expiry;
      }
    }

    // Handle rainfall readings.
    if (resultsList[1] != null && resultsList[1] is Iterable<Reading>) {
      _rainfallReadings = resultsList[1].toList();

      if (_rainfallReadings.isNotEmpty) {
        _readingTypeExpiry[ReadingType.rainfall] =
            _rainfallReadings.first.expiry;
      }
    }

    // Handle relative humidity readings.
    if (resultsList[2] != null && resultsList[2] is Iterable<Reading>) {
      _humidityReadings = resultsList[2].toList();

      if (_humidityReadings.isNotEmpty) {
        _readingTypeExpiry[ReadingType.humidity] =
            _humidityReadings.first.expiry;
      }
    }

    // Handle wind speed readings.
    if (resultsList[3] != null && resultsList[3] is Iterable<Reading>) {
      _windSpeedReadings = resultsList[3].toList();

      if (_windSpeedReadings.isNotEmpty) {
        _readingTypeExpiry[ReadingType.windSpeed] =
            _windSpeedReadings.first.expiry;
      }
    }

    // Handle wind direction readings.
    if (resultsList[4] != null && resultsList[4] is Iterable<Reading>) {
      _windDirectionReadings = resultsList[4].toList();

      if (_windDirectionReadings.isNotEmpty) {
        _readingTypeExpiry[ReadingType.windDirection] =
            _windDirectionReadings.first.expiry;
      }
    }

    // Handle PM2.5 readings.
    if (resultsList[5] != null && resultsList[5] is Iterable<Reading>) {
      _pm2_5Readings = resultsList[5].toList();

      if (_pm2_5Readings.isNotEmpty) {
        _readingTypeExpiry[ReadingType.pm2_5] = _pm2_5Readings.first.expiry;
      }
    }

    // Handle 2-hour forecasts.
    if (resultsList[6] != null && resultsList[6] is Iterable<Forecast>) {
      _x2HourForecasts = resultsList[6].toList();

      if (_x2HourForecasts.isNotEmpty) {
        _x2HourForecastExpiry = _x2HourForecasts.first.expiry;
      }
    }

    // Handle 24-hour forecasts.
    if (resultsList[7] != null && resultsList[7] is Iterable<List<Forecast>>) {
      _x24HourForecasts = resultsList[7].toList();

      if (_x24HourForecasts.isNotEmpty) {
        _x24HourForecastExpiry = _x24HourForecasts.first.first.expiry;
      }
    }
  }

  /// Converts from knots to meters per second.
  num _knotsToMetersPerSecond(num knots) {
    return knots * _knotToMetersPerSecond;
  }

  /// The conversion factor from knot to m/s.
  ///
  /// See https://en.wikipedia.org/wiki/Knot_(unit).
  static const double _knotToMetersPerSecond = 0.514444;

  /// The URL of realtime air temperature readings API (at Data.gov.sg).
  ///
  /// Updates every 1 minute. Takes parameter date_time=<ISO8601>. Unit is °C.
  ///
  /// See https://data.gov.sg/dataset/realtime-weather-readings.
  static const String _temperatureUrl =
      'https://api.data.gov.sg/v1/environment/air-temperature';

  /// The URL of realtime rainfall readings API (at Data.gov.sg).
  ///
  /// Updates every 5 minutes. Takes parameter date_time=<ISO8601>. Unit is mm.
  ///
  /// See https://data.gov.sg/dataset/realtime-weather-readings.
  static const String _rainfallUrl =
      'https://api.data.gov.sg/v1/environment/rainfall';

  /// The URL of realtime relative humidity readings API (at Data.gov.sg).
  ///
  /// Updates every 1 minute. Takes parameter date_time=<ISO8601>. Unit is %.
  ///
  /// See https://data.gov.sg/dataset/realtime-weather-readings.
  static const String _humidityUrl =
      'https://api.data.gov.sg/v1/environment/relative-humidity';

  /// The URL of realtime wind speed readings API (at Data.gov.sg).
  ///
  /// Updates every 1 minute. Takes parameter date_time=<ISO8601>. Unit is knot.
  ///
  /// See https://data.gov.sg/dataset/realtime-weather-readings.
  static const String _windSpeedUrl =
      'https://api.data.gov.sg/v1/environment/wind-speed';

  /// The URL of realtime wind direction readings API (at Data.gov.sg).
  ///
  /// Updates every 1 minute. Takes parameter date_time=<ISO8601>. Unit is °.
  ///
  /// See https://data.gov.sg/dataset/realtime-weather-readings.
  static const String _windDirectionUrl =
      'https://api.data.gov.sg/v1/environment/wind-direction';

  /// The URL of the PM2.5 API (at Data.gov.sg).
  ///
  /// Takes parameter date_time=<ISO8601>.
  ///
  /// See https://data.gov.sg/dataset/pm2-5.
  static const String _pm2_5Url = 'https://api.data.gov.sg/v1/environment/pm25';

  /// The URL of the 2-hour weather forecast API (at Data.gov.sg).
  ///
  /// Updates every 30 minutes. Takes parameter date_time=<ISO8601>.
  ///
  /// See https://data.gov.sg/dataset/weather-forecast.
  static const String _x2HourForecastUrl =
      'https://api.data.gov.sg/v1/environment/2-hour-weather-forecast';

  /// The URL of the 24-hour weather forecast API (at Data.gov.sg).
  ///
  /// Takes parameter date_time=<ISO8601>.
  ///
  /// See https://data.gov.sg/dataset/weather-forecast.
  static const String _x24HourForecastUrl =
      'https://api.data.gov.sg/v1/environment/24-hour-weather-forecast';
}
