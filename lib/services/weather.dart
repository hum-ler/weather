import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:kiwi/kiwi.dart';

import '../models/condition.dart';
import '../models/forecast.dart';
import '../models/geoposition.dart';
import '../models/provider.dart';
import '../models/reading.dart';
import '../source_gen/json_serializable/2_hour_forecast_data.dart';
import '../source_gen/json_serializable/24_hour_forecast_data.dart';
import '../source_gen/json_serializable/pm2_5_data.dart';
import '../source_gen/json_serializable/reading_data.dart';
import '../utils/date_time_ext.dart';
import '../utils/http_utils.dart';

/// The weather service.
class Weather {
  /// The collection of readings for each [ReadingType].
  ///
  /// Keeping the readings separate because:
  /// - There is no convenient way of merging Readings.
  /// - These are only used by the respective getNearest... methods.
  ///
  /// Some readings are correlated to one another. For example, a wind speed
  /// reading is not useful unless paired with a corresponding wind direction
  /// reading from the same provider. The user will need to manually relate
  /// the two readings by comparing [Reading.provider.id].
  Map<ReadingType, Iterable<Reading>> _readings = {};

  /// The collection of [Reading.expiry] for each [ReadingType].
  ///
  /// Used by [_fetchReadingsOfType()] to determine whether to fetch fresh data.
  Map<ReadingType, DateTime> _readingTypeExpiry = {};

  /// The collection of 2-hour forecasts.
  Iterable<Forecast> _x2HourForecasts;

  /// The [Reading.expiry] for 2-hour forecasts.
  ///
  /// Used by [_fetch2HourForecasts()] to determine whether to fetch fresh data.
  DateTime _x2HourForecastExpiry;

  /// The collection of 24-hour forecasts.
  Iterable<List<Forecast>> _x24HourForecasts;

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

    Client client = KiwiContainer().resolve<Client>();

    List<dynamic> resultsList = await Future.wait([
      _fetchReadingsOfType(
        timestamp: timestamp,
        url: _temperatureUrl,
        type: ReadingType.temperature,
        userLocation: userLocation,
        client: client,
      ),
      _fetchReadingsOfType(
        timestamp: timestamp,
        url: _rainfallUrl,
        type: ReadingType.rainfall,
        userLocation: userLocation,
        client: client,
      ),
      _fetchReadingsOfType(
        timestamp: timestamp,
        url: _humidityUrl,
        type: ReadingType.humidity,
        userLocation: userLocation,
        client: client,
      ),
      _fetchReadingsOfType(
        timestamp: timestamp,
        url: _windSpeedUrl,
        type: ReadingType.windSpeed,
        userLocation: userLocation,
        client: client,
      ),
      _fetchReadingsOfType(
        timestamp: timestamp,
        url: _windDirectionUrl,
        type: ReadingType.windDirection,
        userLocation: userLocation,
        client: client,
      ),
      _fetchPM2_5Readings(
        timestamp: timestamp,
        userLocation: userLocation,
        client: client,
      ),
      _fetch2HourForecasts(
        timestamp: timestamp,
        userLocation: userLocation,
        client: client,
      ),
      _fetch24HourForecasts(
        timestamp: timestamp,
        userLocation: userLocation,
        client: client,
      ),
    ]);

    client.close();

    _collectFetchResults(resultsList, timestamp);
  }

  /// Gets the nearest reading of [type].
  ///
  /// Call [fetchReadings()] before calling this method.
  Reading _getNearestReadingOfType(ReadingType type) {
    if (_readings[type] == null || _readings[type].isEmpty) return null;

    return _readings[type].reduce((v, e) => v.distance < e.distance ? v : e);
  }

  /// Gets the nearest temperature reading.
  ///
  /// Call [fetchReadings()] before calling this method.
  Reading getNearestTemperatureReading() {
    return _getNearestReadingOfType(ReadingType.temperature);
  }

  /// Gets the nearest rainfall reading.
  ///
  /// Call [fetchReadings()] before calling this method.
  Reading getNearestRainfallReading() {
    return _getNearestReadingOfType(ReadingType.rainfall);
  }

  /// Gets the nearest relative humidity reading.
  ///
  /// Call [fetchReadings()] before calling this method.
  Reading getNearestHumidityReading() {
    return _getNearestReadingOfType(ReadingType.humidity);
  }

  /// Gets the nearest wind speed reading.
  ///
  /// Call [fetchReadings()] before calling this method.
  Reading getNearestWindSpeedReading() {
    return _getNearestReadingOfType(ReadingType.windSpeed);
  }

  /// Gets the nearest wind direction reading.
  ///
  /// Call [fetchReadings()] before calling this method.
  Reading getNearestWindDirectionReading() {
    return _getNearestReadingOfType(ReadingType.windDirection);
  }

  /// Gets the nearest PM2.5 reading.
  ///
  /// Call [fetchReadings()] before calling this method.
  Reading getNearestPM2_5Reading() {
    return _getNearestReadingOfType(ReadingType.pm2_5);
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
    if (_x2HourForecasts == null || _x2HourForecasts.isEmpty) return null;

    return _x2HourForecasts.reduce((v, e) => v.distance < e.distance ? v : e);
  }

  /// Gets the nearest 24-hour forecast.
  ///
  /// Call [fetchReadings()] before calling this method.
  ///
  /// The items in the returned list are arranged in chronological order.
  List<Forecast> getNearest24HourForecast() {
    if (_x24HourForecasts == null || _x24HourForecasts.isEmpty) return null;

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
    @required Client client,
  }) async {
    // This method is not meant for PM2.5 readings, which is a different API.
    if (type == ReadingType.pm2_5) return null;

    if (timestamp == null) return null;

    String fullUrl =
        '$url?date_time=${timestamp.format("yyyy-MM-ddTHH:mm:ss")}';

    dynamic json = await httpGetJsonData(fullUrl, client);
    if (json == null) return null;

    ReadingData readingData = ReadingData.fromJson(json);

    if (readingData.apiInfo.status == 'healthy') {
      // Server-side timestamp.
      if (readingData.items.first.timestamp == null) return null;
      DateTime creation = readingData.items.first.timestamp.toLocal();

      return readingData.items.first.readings.map((e) {
        ReadingDataStation station = readingData.metadata.stations
            .firstWhere((s) => s.id == e.stationId);

        // Perform conversion if necessary.
        num value = e.value;
        if (type == ReadingType.windSpeed) {
          value = _knotsToMetersPerSecond(value);
        }

        return Reading(
          type: type,
          creation: creation,
          provider: Provider.station(
            id: station.id,
            name: station.name,
            location: Geoposition(
              latitude: station.location.latitude,
              longitude: station.location.longitude,
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
    @required Client client,
  }) async {
    if (timestamp == null) return null;

    String fullUrl =
        '$_pm2_5Url?date_time=${timestamp.format("yyyy-MM-ddTHH:mm:ss")}';

    dynamic json = await httpGetJsonData(fullUrl, client);
    if (json == null) return null;

    PM25Data pm2_5Data = PM25Data.fromJson(json);

    if (pm2_5Data.apiInfo.status == 'healthy') {
      // Server-side timestamp.
      if (pm2_5Data.items.first.timestamp == null) return null;
      DateTime creation = pm2_5Data.items.first.timestamp.toLocal();

      // Cycle through the 5 known regions.
      return ['central', 'north', 'east', 'south', 'west'].map((e) {
        PM25DataRegionMetadata region =
            pm2_5Data.regionMetadata.firstWhere((r) => r.name == e);

        return Reading(
          type: ReadingType.pm2_5,
          creation: creation,
          provider: Provider.station(
            id: region.name,
            name: region.name,
            location: Geoposition(
              latitude: region.labelLocation.latitude,
              longitude: region.labelLocation.longitude,
            ),
          ),
          userLocation: userLocation,
          value: pm2_5Data.items.first.readings.pm2_5OneHourly[e],
        );
      });
    }

    return null;
  }

  /// Fetches actual data using the 2-hour weather forecast API.
  Future<Iterable<Forecast>> _fetch2HourForecasts({
    @required DateTime timestamp,
    @required Geoposition userLocation,
    @required Client client,
  }) async {
    if (timestamp == null) return null;

    String fullUrl =
        '$_x2HourForecastUrl?date_time=${timestamp.format("yyyy-MM-ddTHH:mm:ss")}';

    dynamic json = await httpGetJsonData(fullUrl, client);
    if (json == null) return null;

    X2HourForecastData x2HourForecastData = X2HourForecastData.fromJson(json);

    if (x2HourForecastData.apiInfo.status == 'healthy') {
      // Server-side timestamp.
      if (x2HourForecastData.items.first.timestamp == null) return null;
      DateTime creation = x2HourForecastData.items.first.timestamp.toLocal();

      return x2HourForecastData.items.first.forecasts.map((e) {
        X2HourForecastDataAreaMetadata area =
            x2HourForecastData.areaMetadata.firstWhere((a) => a.name == e.area);

        return Forecast(
          type: ForecastType.immediate,
          creation: creation,
          provider: Provider.area(
            id: area.name,
            name: area.name,
            location: Geoposition(
              latitude: area.labelLocation.latitude,
              longitude: area.labelLocation.longitude,
            ),
          ),
          userLocation: userLocation,
          condition: e.forecast,
        );
      });
    }

    return null;
  }

  /// Fetches actual data using the 24-hour weather forecast API.
  Future<Iterable<List<Forecast>>> _fetch24HourForecasts({
    @required DateTime timestamp,
    @required Geoposition userLocation,
    @required Client client,
  }) async {
    if (timestamp == null) return null;

    String fullUrl =
        '$_x24HourForecastUrl?date_time=${timestamp.format("yyyy-MM-ddTHH:mm:ss")}';

    dynamic json = await httpGetJsonData(fullUrl, client);
    if (json == null) return null;

    X24HourForecastData x24HourForecastData =
        X24HourForecastData.fromJson(json);

    if (x24HourForecastData.apiInfo.status == 'healthy') {
      // Server-side timestamp.
      if (x24HourForecastData.items.first.timestamp == null) return null;
      DateTime creation = x24HourForecastData.items.first.timestamp.toLocal();

      // Prepare 5 lists to return, each representing one reference region.
      Map<Provider, List<Forecast>> regionLists = {
        Providers.central: [],
        Providers.north: [],
        Providers.east: [],
        Providers.south: [],
        Providers.west: [],
      };

      (x24HourForecastData.items.first.periods).forEach((e) {
        ForecastType type;

        DateTime startTime = e.time.start.toLocal();
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
              condition: e.regions[k.name],
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
  void _collectFetchResults(
    List<dynamic> resultsList,
    DateTime timestamp,
  ) {
    // Handle temperature readings.
    _handleReadingsResultOfType(
      type: ReadingType.temperature,
      result: resultsList[0],
      timestamp: timestamp,
    );

    // Handle rainfall readings.
    _handleReadingsResultOfType(
      type: ReadingType.rainfall,
      result: resultsList[1],
      timestamp: timestamp,
    );

    // Handle relative humidity readings.
    _handleReadingsResultOfType(
      type: ReadingType.humidity,
      result: resultsList[2],
      timestamp: timestamp,
    );

    // Handle wind speed readings.
    _handleReadingsResultOfType(
      type: ReadingType.windSpeed,
      result: resultsList[3],
      timestamp: timestamp,
    );

    // Handle wind direction readings.
    _handleReadingsResultOfType(
      type: ReadingType.windDirection,
      result: resultsList[4],
      timestamp: timestamp,
    );

    // Handle PM2.5 readings.
    _handleReadingsResultOfType(
      type: ReadingType.pm2_5,
      result: resultsList[5],
      timestamp: timestamp,
    );

    // Handle 2-hour forecasts.
    if (resultsList[6] != null && resultsList[6] is Iterable<Forecast>) {
      _x2HourForecasts = resultsList[6];

      // Update the forecasts expiry.
      _x2HourForecastExpiry =
          _x2HourForecasts.isNotEmpty ? _x2HourForecasts.first.expiry : null;
    } else {
      // Clear off expired results to prevent reuse.
      if (_x2HourForecastExpiry != null &&
          _x2HourForecastExpiry.isBefore(timestamp)) {
        _x2HourForecasts = null;
        _x2HourForecastExpiry = null;
      }
    }

    // Handle 24-hour forecasts.
    if (resultsList[7] != null && resultsList[7] is Iterable<List<Forecast>>) {
      _x24HourForecasts = resultsList[7];

      // Update the forecasts expiry.
      _x24HourForecastExpiry = _x24HourForecasts.isNotEmpty
          ? _x24HourForecasts.first.first.expiry
          : null;
    } else {
      // Clear off expired results to prevent reuse.
      if (_x24HourForecastExpiry != null &&
          _x24HourForecastExpiry.isBefore(timestamp)) {
        _x24HourForecasts = null;
        _x24HourForecastExpiry = null;
      }
    }
  }

  /// Handles the API call result for [type].
  ///
  /// This is a helper method for [_collectFetchResults()].
  _handleReadingsResultOfType({
    @required ReadingType type,
    @required dynamic result,
    @required DateTime timestamp,
  }) {
    if (result != null && result is Iterable<Reading>) {
      _readings[type] = result;

      // Update the readings expiry.
      _readingTypeExpiry[type] =
          _readings[type].isNotEmpty ? _readings[type].first.expiry : null;
    } else {
      // Clear off expired results to prevent reuse.
      if (_readingTypeExpiry[type] != null &&
          _readingTypeExpiry[type].isBefore(timestamp)) {
        _readings[type] = null;
        _readingTypeExpiry[type] = null;
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
