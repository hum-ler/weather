import 'package:flutter/material.dart';

import 'package:weather/models/forecast_area.dart';
import 'package:weather/models/geoposition.dart';
import 'package:weather/models/station.dart';
import 'package:weather/utils/constants.dart' as constants;
import 'package:weather/utils/utils.dart';

/// The weather service.
class Weather {
  // Use a singleton for this service.
  static final Weather _singleton = Weather._weather();

  Weather._weather();

  factory Weather() => _singleton;

  /// The collection of [NearestStation]s.
  ///
  /// Uses [Station.id] as the key.
  ///
  /// Using type [NearestStation] instead of [Station] as a convenience
  /// for findNearest... methods.
  Map<String, NearestStation> _stations;

  /// The collection of [NearestForecastArea]s.
  ///
  /// Uses [ForecastArea.id] as the key.
  ///
  /// Using type [NearestForecastArea] instead of [ForecastArea] as a
  /// convenience for [findNearest2HourForecast()].
  Map<String, NearestForecastArea> _forecastAreas;

  /// The time when [fetchReadings()] is last called.
  DateTime _timestamp;

  /// Retrieves all the [Station]s and their corresponding readings.
  Future<void> fetchReadings({DateTime timestamp}) async {
    timestamp ??= DateTime.now();

    // Preform a fetch only if we are over the minimum period.
    if (_timestamp != null &&
        _timestamp.difference(timestamp).abs() < constants.minFetchPeriod) {
      return;
    }

    _stations = <String, NearestStation>{};
    _forecastAreas = <String, NearestForecastArea>{};

    await _fetchAirTemperature(timestamp: timestamp);
    await _fetchRainfall(timestamp: timestamp);
    await _fetchRelativeHumidity(timestamp: timestamp);
    await _fetchWindDirection(timestamp: timestamp);
    await _fetchWindSpeed(timestamp: timestamp);

    await _fetch2HourWeatherForecasts(
      timestamp: timestamp,
      url: constants.forecastUrl,
    );

    _timestamp = timestamp;
  }

  /// Gets the nearest station with air temperature reading.
  ///
  /// Call [fetchReadings()] before this.
  NearestStation nearestAirTemperature(Geoposition geoposition) {
    NearestStation s = _deduceNearestStation(
      geoposition,
      WeatherReadingType.airTemperature,
    );

    return _updateAirTemperatureAnomalies(NearestStation.from(s));
  }

  /// Gets the nearest station with rainfall reading.
  ///
  /// Call [fetchReadings()] before this.
  NearestStation nearestRainfall(Geoposition geoposition) {
    NearestStation s = _deduceNearestStation(
      geoposition,
      WeatherReadingType.rainfall,
    );

    return _updateRainfallAnomalies(NearestStation.from(s));
  }

  /// Gets the nearest station with relative humidity reading.
  ///
  /// Call [fetchReadings()] before this.
  NearestStation nearestRelativeHumidity(Geoposition geoposition) {
    NearestStation s = _deduceNearestStation(
      geoposition,
      WeatherReadingType.relativeHumidity,
    );

    return _updateRelativeHumidityAnomalies(NearestStation.from(s));
  }

  /// Gets the nearest station with wind direction / wind speed readings.
  ///
  /// Call [fetchReadings()] before this.
  NearestStation nearestWindDirectionWindSpeed(Geoposition geoposition) {
    NearestStation s = _deduceNearestStation(
      geoposition,
      WeatherReadingType.windSpeed,
    );

    return _updateWindDirectionWindSpeedAnomalies(NearestStation.from(s));
  }

  /// Gets the nearest forecast area with forecast data.
  ///
  /// Call [fetchReadings()] before this.
  NearestForecastArea nearest2HourForecast(Geoposition geoposition) {
    NearestForecastArea f =
        _forecastAreas.values.where((e) => e.forecast != null).map((e) {
      e.userLocation = geoposition;
      e.distance = e.geoposition.distanceFrom(geoposition);
      return e;
    }).reduce((v, e) => v.distance < e.distance ? v : e);

    return _updateForecastAnomalies(f);
  }

  /// Picks the nearest station out of [_stations] for reading [type].
  ///
  /// Updates [NearestStation.userLocation] and [NearestStation.distance]
  /// in the element as a side-effect.
  NearestStation _deduceNearestStation(
    Geoposition geoposition,
    WeatherReadingType type,
  ) {
    if (geoposition == null) return null;

    Iterable<NearestStation> relevantStations;

    switch (type) {
      case WeatherReadingType.airTemperature:
        relevantStations =
            _stations.values.where((e) => e.airTemperature != null);
        break;

      case WeatherReadingType.rainfall:
        relevantStations = _stations.values.where((e) => e.rainfall != null);
        break;

      case WeatherReadingType.relativeHumidity:
        relevantStations =
            _stations.values.where((e) => e.relativeHumidity != null);
        break;

      case WeatherReadingType.windDirection:
      case WeatherReadingType.windSpeed:
        relevantStations = _stations.values
            .where((e) => e.windDirection != null && e.windSpeed != null);
        break;
    }

    if (relevantStations.length == 0) return null;

    return relevantStations.map((e) {
      e.userLocation = geoposition;
      e.distance = e.geoposition.distanceFrom(geoposition);
      return e;
    }).reduce((v, e) => v.distance < e.distance ? v : e);
  }

  /// Fetches actual data using the realtime weather readings API.
  ///
  /// The data structure returned by the API is the same for the different
  /// reading types.
  ///
  /// Updates [_stations].
  Future<void> _fetchRealtimeWeatherReadings({
    @required DateTime timestamp,
    @required String url,
    @required WeatherReadingType type,
  }) async {
    if (timestamp == null) return;

    String fullUrl = url +
        '?date_time=' +
        timestamp.toIso8601String().replaceFirst(RegExp(r'\.\d+$'), '');

    dynamic data = await httpGetJsonData(fullUrl);
    if (data == null) return;

    if (data['api_info']['status'] == 'healthy') {
      // Generate the list of all met stations from the metadata.
      Map<String, NearestStation> potentialStations =
          <String, NearestStation>{};

      (data['metadata']['stations'] as List).forEach((element) {
        if (!potentialStations.containsKey(element['id'])) {
          potentialStations[element['id']] = NearestStation(
            id: element['id'],
            name: element['name'],
            geoposition: Geoposition(
              latitude: element['location']['latitude'],
              longitude: element['location']['longitude'],
            ),
          );
        }
      });

      DateTime serverTimestamp =
          DateTime.tryParse(data['items'][0]['timestamp']);

      (data['items'][0]['readings'] as List).forEach((element) {
        NearestStation station;

        // Look for an existing station in [_stations] first. Otherwise, copy
        // over the new one from [potentialStations].
        if (_stations.containsKey(element['station_id'])) {
          station = _stations[element['station_id']];
        } else if (potentialStations.containsKey(element['station_id'])) {
          station = potentialStations[element['station_id']];
          _stations[station.id] = station;
        }

        if (station != null) {
          // The value may be returned with or without a decimal point, so a
          // conversion is needed.
          double value = (element['value'] as num).toDouble();

          switch (type) {
            case WeatherReadingType.airTemperature:
              station.airTemperature = value;
              station.airTemperatureTimestamp = serverTimestamp;
              break;

            case WeatherReadingType.rainfall:
              station.rainfall = value;
              station.rainfallTimestamp = serverTimestamp;
              break;

            case WeatherReadingType.relativeHumidity:
              station.relativeHumidity = value;
              station.relativeHumidityTimestamp = serverTimestamp;
              break;

            case WeatherReadingType.windDirection:
              station.windDirection = value.toInt();
              station.windDirectionTimestamp = serverTimestamp;
              break;

            case WeatherReadingType.windSpeed:
              station.windSpeed = knotsToMetersPerSecond(value);
              station.windSpeedTimestamp = serverTimestamp;
              break;
          }

          station.timestamp = timestamp;
        }
      });
    }
  }

  Future<void> _fetchAirTemperature({@required DateTime timestamp}) {
    return _fetchRealtimeWeatherReadings(
      timestamp: timestamp,
      url: constants.airTemperatureUrl,
      type: WeatherReadingType.airTemperature,
    );
  }

  Future<void> _fetchRainfall({@required DateTime timestamp}) {
    return _fetchRealtimeWeatherReadings(
      timestamp: timestamp,
      url: constants.rainfallUrl,
      type: WeatherReadingType.rainfall,
    );
  }

  Future<void> _fetchRelativeHumidity({@required DateTime timestamp}) {
    return _fetchRealtimeWeatherReadings(
      timestamp: timestamp,
      url: constants.relativeHumidityUrl,
      type: WeatherReadingType.relativeHumidity,
    );
  }

  Future<void> _fetchWindDirection({@required DateTime timestamp}) {
    return _fetchRealtimeWeatherReadings(
        timestamp: timestamp,
        url: constants.windDirectionUrl,
        type: WeatherReadingType.windDirection);
  }

  Future<void> _fetchWindSpeed({@required DateTime timestamp}) {
    return _fetchRealtimeWeatherReadings(
        timestamp: timestamp,
        url: constants.windSpeedUrl,
        type: WeatherReadingType.windSpeed);
  }

  /// Fetches actual data using the 2-hour weather forecast API.
  ///
  /// Updates [_forecastAreas].
  Future<void> _fetch2HourWeatherForecasts({
    @required DateTime timestamp,
    @required String url,
  }) async {
    if (timestamp == null) return;

    String fullUrl = url +
        '?date_time=' +
        timestamp.toIso8601String().replaceFirst(RegExp(r'\.\d+$'), '');

    dynamic data = await httpGetJsonData(fullUrl);
    if (data == null) return;

    if (data['api_info']['status'] == 'healthy') {
      // Generate the list of all met stations from the metadata.
      Map<String, NearestForecastArea> potentialForecastAreas =
          <String, NearestForecastArea>{};

      (data['area_metadata'] as List).forEach((element) {
        if (!potentialForecastAreas.containsKey(element['name'])) {
          potentialForecastAreas[element['name']] = NearestForecastArea(
            id: element['name'],
            name: element['name'],
            geoposition: Geoposition(
              latitude: element['label_location']['latitude'],
              longitude: element['label_location']['longitude'],
            ),
          );
        }
      });

      DateTime serverTimestamp =
          DateTime.tryParse(data['items'][0]['timestamp']);

      (data['items'][0]['forecasts'] as List).forEach((element) {
        NearestForecastArea forecastArea;

        // Look for an existing station in [_forecastAreas] first. Otherwise,
        // copy over the new one from [potentialForecastAreas].
        if (_forecastAreas.containsKey(element['area'])) {
          forecastArea = _forecastAreas[element['area']];
        } else if (potentialForecastAreas.containsKey(element['area'])) {
          forecastArea = potentialForecastAreas[element['area']];
          _forecastAreas[forecastArea.id] = forecastArea;
        }

        if (forecastArea != null) {
          forecastArea.forecast = element['forecast'];
          forecastArea.forecastTimestamp = serverTimestamp;
          forecastArea.timestamp = timestamp;
        }
      });
    }
  }

  NearestStation _updateAirTemperatureAnomalies(NearestStation s) {
    if (s != null) {
      s.readingAnomaly = false;
      s.timestampAnomaly =
          s.airTemperatureTimestamp.difference(_timestamp).abs() >
              constants.maxReadingRecency;
      s.distanceAnomaly = s.distance > constants.maxDistance;
    }

    return s;
  }

  NearestStation _updateRainfallAnomalies(NearestStation s) {
    if (s != null) {
      s.readingAnomaly = false;
      s.timestampAnomaly = s.rainfallTimestamp.difference(_timestamp).abs() >
          constants.maxReadingRecency;
      s.distanceAnomaly = s.distance > constants.maxDistance;
    }

    return s;
  }

  NearestStation _updateRelativeHumidityAnomalies(NearestStation s) {
    if (s != null) {
      s.readingAnomaly = false;
      s.timestampAnomaly =
          s.relativeHumidityTimestamp.difference(_timestamp).abs() >
              constants.maxReadingRecency;
      s.distanceAnomaly = s.distance > constants.maxDistance;
    }

    return s;
  }

  NearestStation _updateWindDirectionWindSpeedAnomalies(NearestStation s) {
    if (s != null) {
      s.readingAnomaly = false;
      s.timestampAnomaly = s.windSpeedTimestamp.difference(_timestamp).abs() >
          constants.maxReadingRecency;
      s.distanceAnomaly = s.distance > constants.maxDistance;
    }

    return s;
  }

  NearestForecastArea _updateForecastAnomalies(NearestForecastArea f) {
    if (f != null) {
      f.forecastAnomaly = f.forecast == null || f.forecast.isEmpty;
      f.timestampAnomaly = f.forecastTimestamp.difference(_timestamp).abs() >
          constants.maxReadingRecency;
      f.distanceAnomaly = f.distance > constants.maxDistance;
    }

    return f;
  }
}

enum WeatherReadingType {
  airTemperature,
  rainfall,
  relativeHumidity,
  windDirection,
  windSpeed,
}
